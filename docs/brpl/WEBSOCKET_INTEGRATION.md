# WebSocket Integration Guide for Frontend

## Overview
The backend now supports real-time notifications via WebSocket connections using Rails Action Cable.

## Connection Details

### WebSocket URL
```
Development: ws://localhost:3000/cable
Production: wss://your-api-domain.com/cable
```

### Authentication
Pass the JWT token as a query parameter:
```javascript
const wsUrl = `ws://localhost:3000/cable?token=${jwtToken}`;
```

## Frontend Implementation

### 1. Install Action Cable Client
```bash
npm install @rails/actioncable
```

### 2. Create Connection
```javascript
import { createConsumer } from '@rails/actioncable';

// Create consumer with JWT token
const cable = createConsumer(`ws://localhost:3000/cable?token=${authToken}`);

// Subscribe to NotificationChannel
const notificationSubscription = cable.subscriptions.create('NotificationChannel', {
  connected() {
    console.log('Connected to NotificationChannel');
  },

  disconnected() {
    console.log('Disconnected from NotificationChannel');
  },

  received(data) {
    console.log('Received notification:', data);
    // Handle different notification types
    switch(data.type) {
      case 'connection_established':
        // Initial connection, shows unread count
        updateUnreadBadge(data.unread_count);
        break;
      case 'notification':
        // New notification received
        showNotification(data);
        break;
      case 'notification_marked_as_read':
        // Notification was marked as read
        updateNotificationStatus(data.notification_id);
        updateUnreadBadge(data.unread_count);
        break;
      case 'all_notifications_marked_as_read':
        // All notifications marked as read
        markAllAsRead();
        updateUnreadBadge(0);
        break;
      case 'unread_count_update':
        // Unread count update
        updateUnreadBadge(data.unread_count);
        break;
    }
  },

  // Client-side actions
  markAsRead(notificationId) {
    this.perform('mark_as_read', { notification_id: notificationId });
  },

  markAllAsRead() {
    this.perform('mark_all_as_read');
  },

  requestUnreadCount() {
    this.perform('request_unread_count');
  }
});
```

### 3. Svelte Store Example
```javascript
// stores/notifications.js
import { writable, derived } from 'svelte/store';
import { createConsumer } from '@rails/actioncable';

function createNotificationStore() {
  const { subscribe, set, update } = writable({
    notifications: [],
    unreadCount: 0,
    connected: false
  });

  let cable;
  let subscription;

  return {
    subscribe,
    
    connect(token) {
      cable = createConsumer(`ws://localhost:3000/cable?token=${token}`);
      
      subscription = cable.subscriptions.create('NotificationChannel', {
        connected() {
          update(state => ({ ...state, connected: true }));
        },
        
        disconnected() {
          update(state => ({ ...state, connected: false }));
        },
        
        received(data) {
          if (data.type === 'connection_established') {
            update(state => ({ ...state, unreadCount: data.unread_count }));
          } else if (data.type === 'notification') {
            update(state => ({
              ...state,
              notifications: [data, ...state.notifications],
              unreadCount: state.unreadCount + 1
            }));
          }
          // Handle other message types...
        }
      });
    },
    
    disconnect() {
      if (subscription) {
        subscription.unsubscribe();
      }
      if (cable) {
        cable.disconnect();
      }
    },
    
    markAsRead(notificationId) {
      if (subscription) {
        subscription.perform('mark_as_read', { notification_id: notificationId });
      }
    },
    
    markAllAsRead() {
      if (subscription) {
        subscription.perform('mark_all_as_read');
      }
    }
  };
}

export const notifications = createNotificationStore();
```

## Notification Types

When a new Job is created, notifications are sent with:
- `notification_type`: "task_assignment"
- `priority`: Based on job priority (urgent/high → 3, medium → 2, low → 1)
- `action_url`: "/jobs/{job_id}"
- `data`: Contains job details (id, description, deadline, customer info, etc.)

## Testing

1. Open `test_websocket.html` in a browser
2. Get a valid JWT token (use the authenticator tool: `node ai-tools/authenticator.js auth user1`)
3. Replace `YOUR_JWT_TOKEN_HERE` with the actual token
4. Click "Connect" to establish WebSocket connection
5. Create a new Job via API to see real-time notifications

## API Endpoints

Regular REST endpoints for notifications are also available:
- `GET /api/v1/notifications` - List notifications
- `GET /api/v1/notifications/:id` - Get single notification
- `POST /api/v1/notifications` - Create notification
- `PUT /api/v1/notifications/:id` - Update notification
- `DELETE /api/v1/notifications/:id` - Delete notification
- `POST /api/v1/notifications/:id/mark_as_read` - Mark as read
- `POST /api/v1/notifications/:id/mark_as_unread` - Mark as unread
- `POST /api/v1/notifications/mark_all_as_read` - Mark all as read
- `GET /api/v1/notifications/unread_count` - Get unread count

## Notes

- Notifications are automatically broadcast when created
- The WebSocket connection requires a valid JWT token
- CORS is configured to allow connections from `http://localhost:5173`
- **Development**: Uses async adapter (no Redis required)
- **Production**: Requires Redis for Action Cable

## Troubleshooting

### Redis Connection Error
If you see "Connection refused - connect(2) for 127.0.0.1:6379", it means:

**In Development:**
- The app is configured to use async adapter (no Redis needed)
- Make sure `config/cable.yml` has `adapter: async` for development

**In Production:**
- Install and start Redis server
- Configure `REDIS_URL` environment variable

### WebSocket Connection Issues
- Ensure server is running on port 3000
- Check that `/cable` endpoint returns WebSocket upgrade response
- Verify JWT token is valid and included in connection URL