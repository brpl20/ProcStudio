import { writable, derived, get } from 'svelte/store';
import { createConsumer } from '@rails/actioncable';
import type {
  Notification,
  NotificationState,
  NotificationMessage
} from '../api/types/notification.types';
import { API_CONFIG } from '../api/config';

function createNotificationStore() {
  const initialState: NotificationState = {
    notifications: [],
    unreadCount: 0,
    connected: false,
    loading: false,
    error: null
  };

  const { subscribe, set, update } = writable<NotificationState>(initialState);

  let cable: ReturnType<typeof createConsumer> | null = null;
  let subscription: any = null;

  const getWebSocketUrl = (token: string): string => {
    // Handle relative URLs in development (when using Vite proxy)
    if (API_CONFIG.BASE_URL.startsWith('/')) {
      // In development, connect directly to Rails server WebSocket
      return `ws://localhost:3000/cable?token=${token}`;
    }

    // Handle absolute URLs
    const wsProtocol = API_CONFIG.BASE_URL.startsWith('https') ? 'wss' : 'ws';
    const wsUrl = API_CONFIG.BASE_URL.replace(/^https?/, wsProtocol);
    return `${wsUrl}/cable?token=${token}`;
  };

  return {
    subscribe,

    connect(token: string) {
      if (cable || subscription) {
        this.disconnect();
      }

      update((state) => ({ ...state, loading: true, error: null }));

      try {
        const wsUrl = getWebSocketUrl(token);
        console.log('🔗 Attempting WebSocket connection to:', wsUrl);
        cable = createConsumer(wsUrl);

        subscription = cable.subscriptions.create('NotificationChannel', {
          connected() {
            console.log('✅ Connected to NotificationChannel');
            update((state) => ({
              ...state,
              connected: true,
              loading: false,
              error: null
            }));
          },

          disconnected() {
            console.log('❌ Disconnected from NotificationChannel');
            update((state) => ({
              ...state,
              connected: false,
              loading: false
            }));
          },

          rejected() {
            console.error('❌ Connection rejected by NotificationChannel');
            update((state) => ({
              ...state,
              connected: false,
              loading: false,
              error: 'Connection rejected - check authentication'
            }));
          },

          received(data: NotificationMessage) {
            console.log('📨 Received notification message:', data);

            switch (data.type) {
              case 'connection_established':
                console.log('🔗 Connection established, unread count:', data.unread_count);
                update((state) => ({
                  ...state,
                  unreadCount: data.unread_count || 0,
                  notifications: data.notifications || state.notifications
                }));
                break;

              case 'notification':
                if (data.notification) {
                  console.log('🔔 New notification received:', data.notification);
                  update((state) => ({
                    ...state,
                    notifications: [data.notification!, ...state.notifications],
                    unreadCount: state.unreadCount + 1
                  }));
                }
                break;

              case 'notification_marked_as_read':
                console.log('✅ Notification marked as read:', data.notification_id);
                update((state) => ({
                  ...state,
                  notifications: state.notifications.map((notif) =>
                    notif.id === data.notification_id
                      ? { ...notif, read: true }
                      : notif
                  ),
                  unreadCount: data.unread_count || Math.max(0, state.unreadCount - 1)
                }));
                break;

              case 'all_notifications_marked_as_read':
                console.log('✅ All notifications marked as read');
                update((state) => ({
                  ...state,
                  notifications: state.notifications.map((notif) => ({ ...notif, read: true })),
                  unreadCount: 0
                }));
                break;

              case 'unread_count_update':
                console.log('📊 Unread count updated:', data.unread_count);
                update((state) => ({
                  ...state,
                  unreadCount: data.unread_count || 0
                }));
                break;

              default:
                console.warn('⚠️ Unknown notification message type:', data.type);
            }
          }
        });

      } catch (error) {
        console.error('❌ Failed to connect to WebSocket:', error);
        update((state) => ({
          ...state,
          connected: false,
          loading: false,
          error: error instanceof Error ? error.message : 'Connection failed'
        }));
      }
    },

    disconnect() {
      if (subscription) {
        subscription.unsubscribe();
        subscription = null;
        console.log('🔌 Unsubscribed from NotificationChannel');
      }

      if (cable) {
        cable.disconnect();
        cable = null;
        console.log('🔌 Disconnected from WebSocket');
      }

      update((state) => ({ ...state, connected: false }));
    },

    markAsRead(notificationId: number) {
      if (subscription && get({ subscribe }).connected) {
        console.log('📤 Marking notification as read:', notificationId);
        subscription.perform('mark_as_read', { notification_id: notificationId });
      } else {
        console.warn('⚠️ Cannot mark as read - not connected');
      }
    },

    markAllAsRead() {
      if (subscription && get({ subscribe }).connected) {
        console.log('📤 Marking all notifications as read');
        subscription.perform('mark_all_as_read');
      } else {
        console.warn('⚠️ Cannot mark all as read - not connected');
      }
    },

    requestUnreadCount() {
      if (subscription && get({ subscribe }).connected) {
        console.log('📤 Requesting unread count');
        subscription.perform('request_unread_count');
      } else {
        console.warn('⚠️ Cannot request unread count - not connected');
      }
    },

    reset() {
      this.disconnect();
      set(initialState);
    },

    addLocalNotification(notification: Notification) {
      update((state) => ({
        ...state,
        notifications: [notification, ...state.notifications],
        unreadCount: notification.read ? state.unreadCount : state.unreadCount + 1
      }));
    }
  };
}

export const notificationStore = createNotificationStore();

export const unreadCount = derived(
  notificationStore,
  ($store) => $store.unreadCount
);

export const isConnected = derived(
  notificationStore,
  ($store) => $store.connected
);

export const recentNotifications = derived(
  notificationStore,
  ($store) => $store.notifications.slice(0, 10)
);

export const unreadNotifications = derived(
  notificationStore,
  ($store) => $store.notifications.filter((n) => !n.read)
);