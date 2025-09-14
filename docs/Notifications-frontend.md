[Back](../README.md)

# Frontend Notification System Implementation Plan

Aqui está a arquitetura do sistema de notificações para o frontend. Atualmente só criamos o sistema para rodar em development, em produção teremos que configurar tudo para rodar com robustez incluindo a configuração de Redis. Na página /admins para verificar os testes básicos. Ainda não há uma definição clara de como o sistema de notificações funcionará:

- Uma página dedicada (estilo Monday)?
- Um sistema independente de acordo com cada modelo?
- Integrar no Dashboard?

## Arquitetura Básica

1. Architecture Overview

- Real-time Updates: WebSocket connection via Action Cable
- State Management: Svelte stores for reactive notification state
- Persistence: LocalStorage for read/unread state sync

2. WebSocket Setup

- Connection Manager:
  - Establish Action Cable connection on app initialization
  - Auto-reconnect with exponential backoff
  - Authentication via JWT token in connection params
- Subscription Channels:
  - NotificationChannel for real-time updates
  - Handle connection lifecycle events

3. Component Structure

components/
├── NotificationBell.svelte        # Header icon with unread count
├── NotificationDropdown.svelte    # Quick view dropdown
├── NotificationList.svelte        # Full notification list
├── NotificationItem.svelte        # Individual notification
├── NotificationToast.svelte       # Pop-up for new notifications
└── NotificationCenter.svelte      # Full-page notification center

4. State Management

- Svelte Stores:
  - notificationStore - Array of notifications
  - unreadCount - Derived store for badge
  - connectionStatus - WebSocket connection state
  - filters - Active filter preferences
- Actions:
  - Add/remove notifications
  - Mark as read/unread
  - Bulk operations
  - Filter/sort notifications

5. UI/UX Features

- Visual Indicators:
  - Badge with unread count
  - Priority-based color coding
  - Animation for new notifications
- Interactions:
  - Click to mark as read
  - Swipe to dismiss (mobile)
  - Bulk select and actions
  - Filter by type/priority/date
- Toast Notifications:
  - Show for high-priority items
  - Auto-dismiss after 5 seconds
  - Click to navigate to action

6. Job Creation Integration

- Backend Trigger:
  - Add after_create callback in Job model
  - Create notification with job details
  - Broadcast via NotificationChannel
- Frontend Handling:
  - Receive job notification via WebSocket
  - Display toast for new job
  - Update notification list
  - Navigate to job details on click

7. Performance Optimizations

- Pagination: Load notifications in chunks
- Virtual Scrolling: For large lists
- Debounced Updates: Batch multiple notifications
- Lazy Loading: Load details on demand
- Cache Strategy: Store recent notifications locally

8. Error Handling

- Connection Failures: Queue notifications locally
- Retry Logic: Exponential backoff for failed requests
- Offline Mode: Show cached notifications
- Sync on Reconnect: Reconcile local/server state

9. Testing Strategy

- Unit Tests: Store logic and utilities
- Component Tests: UI interactions
- E2E Tests: Full notification flow
- WebSocket Mocking: For reliable testing

10. Implementation Phases

1. Phase 1: Basic notification display and REST API
2. Phase 2: WebSocket integration
3. Phase 3: Job creation notifications
4. Phase 4: Advanced features (filters, bulk actions)
5. Phase 5: Performance optimizations


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
- Redis is required for Action Cable in production
