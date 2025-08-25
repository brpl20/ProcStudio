# Compliance System - Frontend Implementation Manual

## Overview
This manual describes the compliance notification system implementation for managing customer capacity changes and related legal requirements.

## Key Changes

### 1. Customer Email Validation
- **Unable persons** (minors under 16) can now share emails with their guardians
- Email uniqueness validation is skipped for customers with `capacity: 'unable'`
- This allows a parent/guardian to use their email for the minor's account

### 2. Customer Capacity States
```javascript
const CAPACITY_STATES = {
  able: 'able',           // 18+ years or legally capable
  relatively: 'relatively', // 16-17 years (relatively incapable)
  unable: 'unable'        // 0-15 years (absolutely incapable)
}
```

### 3. Customer Status Changes
- Removed `deceased` from Customer status enum
- Customer status now only has: `active`, `inactive`
- Death tracking moved to `ProfileCustomer.deceased_at` field

### 4. ProfileCustomer Fields

#### Removed Fields
- `invalid_person` - This field has been removed from the database

#### New Fields
- `deceased_at` (datetime) - Tracks when a customer died

#### Modified Validations
- `profession` - Now optional for customers with `capacity: 'unable'`
- Still required for `relatively` and `able` customers

## Compliance Notifications

### Model Structure
```javascript
ComplianceNotification = {
  id: number,
  notification_type: string,
  title: string,
  description: string,
  status: string, // 'pending', 'resolved', 'ignored'
  team_id: number,
  user_id: number | null,
  resource_type: string,
  resource_id: number,
  metadata: object,
  resolved_at: datetime | null,
  ignored_at: datetime | null,
  created_at: datetime,
  updated_at: datetime
}
```

### Notification Types
```javascript
const NOTIFICATION_TYPES = {
  capacity_change: 'capacity_change',
  age_transition: 'age_transition',
  manual_capacity_update: 'manual_capacity_update',
  lawyer_removal: 'lawyer_removal',
  lawyer_retirement: 'lawyer_retirement',
  trainee_promotion: 'trainee_promotion',
  company_manager_change: 'company_manager_change',
  contract_cancellation: 'contract_cancellation'
}
```

## Frontend Implementation Guidelines

### 1. Compliance Dashboard Component

```jsx
// Example React component structure
const ComplianceDashboard = () => {
  const [notifications, setNotifications] = useState([]);
  const [filter, setFilter] = useState('pending');

  useEffect(() => {
    fetchComplianceNotifications();
  }, [filter]);

  const fetchComplianceNotifications = async () => {
    const response = await api.get('/api/v1/compliance_notifications', {
      params: { status: filter }
    });
    setNotifications(response.data);
  };

  const handleResolve = async (notificationId) => {
    await api.patch(`/api/v1/compliance_notifications/${notificationId}/resolve`);
    fetchComplianceNotifications();
  };

  const handleIgnore = async (notificationId) => {
    await api.patch(`/api/v1/compliance_notifications/${notificationId}/ignore`);
    fetchComplianceNotifications();
  };

  return (
    <div className="compliance-dashboard">
      <h2>Compliance Notifications</h2>
      <NotificationFilters 
        activeFilter={filter} 
        onFilterChange={setFilter} 
      />
      <NotificationList 
        notifications={notifications}
        onResolve={handleResolve}
        onIgnore={handleIgnore}
      />
    </div>
  );
};
```

### 2. Customer Form Adjustments

```jsx
// ProfileCustomer form component
const ProfileCustomerForm = ({ customer }) => {
  const [formData, setFormData] = useState(customer);
  
  // Determine if profession is required
  const isProfessionRequired = formData.capacity !== 'unable';
  
  // Check if email can be shared
  const canShareEmail = formData.capacity === 'unable';
  
  return (
    <form>
      {/* Email field with conditional validation message */}
      <FormField
        name="email"
        label="Email"
        value={formData.email}
        helperText={canShareEmail ? 
          "This email can be shared with the guardian's account" : 
          "Email must be unique"
        }
      />
      
      {/* Profession field - conditionally required */}
      <FormField
        name="profession"
        label="Profession"
        value={formData.profession}
        required={isProfessionRequired}
        disabled={!isProfessionRequired}
        helperText={!isProfessionRequired ? 
          "Not required for minors under 16" : 
          "Required field"
        }
      />
      
      {/* Capacity field */}
      <SelectField
        name="capacity"
        label="Legal Capacity"
        value={formData.capacity}
        options={[
          { value: 'able', label: 'Fully Capable (18+)' },
          { value: 'relatively', label: 'Relatively Incapable (16-17)' },
          { value: 'unable', label: 'Unable (0-15 or incapacitated)' }
        ]}
      />
      
      {/* Deceased tracking */}
      <DateField
        name="deceased_at"
        label="Date of Death"
        value={formData.deceased_at}
        helperText="Leave blank if customer is alive"
      />
    </form>
  );
};
```

### 3. Notification Display Component

```jsx
const NotificationCard = ({ notification, onResolve, onIgnore }) => {
  const getNotificationIcon = (type) => {
    switch(type) {
      case 'age_transition':
        return '🎂';
      case 'manual_capacity_update':
        return '⚖️';
      case 'lawyer_removal':
        return '👨‍⚖️';
      default:
        return '📋';
    }
  };

  const getUrgencyClass = (notification) => {
    if (notification.notification_type === 'age_transition') {
      return 'urgent';
    }
    return 'normal';
  };

  return (
    <div className={`notification-card ${getUrgencyClass(notification)}`}>
      <div className="notification-header">
        <span className="icon">{getNotificationIcon(notification.notification_type)}</span>
        <h3>{notification.title}</h3>
        <span className="date">{formatDate(notification.created_at)}</span>
      </div>
      
      <p className="description">{notification.description}</p>
      
      {notification.metadata && (
        <div className="metadata">
          {notification.metadata.old_capacity && (
            <span>Changed from: {notification.metadata.old_capacity}</span>
          )}
          {notification.metadata.new_capacity && (
            <span>Changed to: {notification.metadata.new_capacity}</span>
          )}
        </div>
      )}
      
      {notification.status === 'pending' && (
        <div className="actions">
          <button 
            className="btn-resolve" 
            onClick={() => onResolve(notification.id)}
          >
            Mark as Resolved
          </button>
          <button 
            className="btn-ignore" 
            onClick={() => onIgnore(notification.id)}
          >
            Ignore
          </button>
        </div>
      )}
    </div>
  );
};
```

## API Endpoints

### Compliance Notifications

#### List Notifications
```
GET /api/v1/compliance_notifications
Query params:
  - status: 'pending' | 'resolved' | 'ignored'
  - notification_type: string
  - page: number
  - per_page: number
```

#### Get Single Notification
```
GET /api/v1/compliance_notifications/:id
```

#### Resolve Notification
```
PATCH /api/v1/compliance_notifications/:id/resolve
```

#### Ignore Notification
```
PATCH /api/v1/compliance_notifications/:id/ignore
```

### Profile Customer Updates

#### Update Customer with Capacity Change
```
PATCH /api/v1/profile_customers/:id
Body: {
  profile_customer: {
    capacity: 'able' | 'relatively' | 'unable',
    profession: string (optional for unable),
    deceased_at: datetime (optional)
  }
}
```

## Important Business Rules

### 1. Age-Based Capacity Transitions
- Automatic transitions occur daily at 1:00 AM
- 16th birthday: `unable` → `relatively`
- 18th birthday: `relatively` → `able`
- Creates automatic compliance notifications

### 2. Manual Capacity Changes
- Tracked via PaperTrail gem
- Creates compliance notifications for manual updates
- Used for medical/legal capacity changes

### 3. Email Sharing Rules
- Only `unable` persons can share emails
- Validation error for duplicate emails unless one is `unable`
- Frontend should show appropriate helper text

### 4. Profession Requirements
- Required for `able` and `relatively` incapable persons
- Optional for `unable` persons
- Frontend should disable/enable field based on capacity

## State Management Recommendations

```javascript
// Redux/Context state structure
const complianceState = {
  notifications: {
    items: [],
    loading: false,
    error: null,
    filters: {
      status: 'pending',
      notification_type: null,
      team_id: null
    },
    pagination: {
      current_page: 1,
      total_pages: 1,
      per_page: 20
    }
  },
  stats: {
    pending_count: 0,
    resolved_today: 0,
    ignored_count: 0
  }
};
```

## Notification Badge Implementation

```jsx
const ComplianceNotificationBadge = () => {
  const [pendingCount, setPendingCount] = useState(0);

  useEffect(() => {
    const fetchPendingCount = async () => {
      const response = await api.get('/api/v1/compliance_notifications/pending_count');
      setPendingCount(response.data.count);
    };

    fetchPendingCount();
    
    // Poll every 30 seconds for new notifications
    const interval = setInterval(fetchPendingCount, 30000);
    return () => clearInterval(interval);
  }, []);

  if (pendingCount === 0) return null;

  return (
    <div className="notification-badge">
      <span className="count">{pendingCount}</span>
      <span className="label">Pending Compliance Items</span>
    </div>
  );
};
```

## Testing Checklist

- [ ] Test email sharing between guardian and unable person
- [ ] Verify profession field is optional for unable persons
- [ ] Test capacity change creates compliance notification
- [ ] Verify age transition job runs at 1 AM
- [ ] Test resolve/ignore actions on notifications
- [ ] Verify team scoping for notifications
- [ ] Test deceased_at field updates
- [ ] Verify PaperTrail tracking for manual changes

## Migration Notes

1. **Existing Customers**: 
   - Run data migration to set proper capacity based on age
   - Review customers with status 'deceased' and migrate to deceased_at field

2. **Email Conflicts**:
   - Identify existing duplicate emails
   - Mark appropriate accounts as 'unable' or merge accounts

3. **Profession Data**:
   - Update validation to allow null profession for unable persons
   - No data migration needed, just validation change

## Support and Troubleshooting

### Common Issues

1. **Email validation errors for guardians**
   - Ensure the minor's account has `capacity: 'unable'`
   - Check that email validation is properly configured

2. **Missing compliance notifications**
   - Verify team association exists
   - Check sidekiq-cron is running
   - Review logs for job execution

3. **Capacity not updating automatically**
   - Verify birth date is set correctly
   - Check AgeTransitionCheckerJob is scheduled
   - Review job logs for errors