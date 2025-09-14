export interface NotificationData {
  job_id?: number;
  customer_id?: number;
  team_id?: number;
  user_id?: number;
  description?: string;
  deadline?: string;
  customer_name?: string;
  [key: string]: unknown;
}

export interface Notification {
  id: number;
  user_id: number;
  title: string;
  message: string;
  notification_type: string;
  priority: number;
  read: boolean;
  action_url?: string;
  data?: NotificationData;
  created_at: string;
  updated_at: string;
}

export type NotificationMessageType =
  | 'connection_established'
  | 'notification'
  | 'notification_marked_as_read'
  | 'all_notifications_marked_as_read'
  | 'unread_count_update';

export interface NotificationMessage {
  type: NotificationMessageType;
  notification?: Notification;
  notification_id?: number;
  unread_count?: number;
  notifications?: Notification[];
}

export interface NotificationState {
  notifications: Notification[];
  unreadCount: number;
  connected: boolean;
  loading: boolean;
  error: string | null;
}

export type NotificationType =
  | 'task_assignment'
  | 'job_update'
  | 'deadline_reminder'
  | 'customer_update'
  | 'team_update'
  | 'system';

export enum NotificationPriority {
  LOW = 1,
  MEDIUM = 2,
  HIGH = 3,
  URGENT = 4
}