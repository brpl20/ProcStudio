/**
 * Date formatting utilities
 */

export function formatDate(date: Date): string {
  return new Intl.DateTimeFormat('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  }).format(date);
}

export function formatDateTime(date: Date): string {
  return new Intl.DateTimeFormat('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }).format(date);
}

export function formatRelativeTime(date: Date): string {
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
  const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
  const diffMinutes = Math.floor(diffMs / (1000 * 60));

  if (diffMinutes < 1) {
    return 'agora';
  }
  if (diffMinutes < 60) {
    return `${diffMinutes} min atrás`;
  }
  if (diffHours < 24) {
    return `${diffHours}h atrás`;
  }
  if (diffDays === 1) {
    return 'ontem';
  }
  if (diffDays < 7) {
    return `${diffDays} dias atrás`;
  }

  return formatDate(date);
}

export function isOverdue(date: Date): boolean {
  const now = new Date();
  now.setHours(0, 0, 0, 0);
  const compareDate = new Date(date);
  compareDate.setHours(0, 0, 0, 0);

  return compareDate < now;
}

export function isDueToday(date: Date): boolean {
  const now = new Date();
  const compareDate = new Date(date);

  return now.toDateString() === compareDate.toDateString();
}

export function isDueTomorrow(date: Date): boolean {
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  const compareDate = new Date(date);

  return tomorrow.toDateString() === compareDate.toDateString();
}
