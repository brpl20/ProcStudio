/**
 * Logo utilities for handling office logos
 */

/**
 * Build the full URL for a logo from Rails Active Storage path
 * @param logoPath - The relative path from the API (e.g., "/rails/active_storage/...")
 * @returns The full URL for the logo
 */
export function buildLogoUrl(logoPath: string | null | undefined): string | null {
  if (!logoPath) {
    return null;
  }

  // If it's already a full URL, return it
  if (logoPath.startsWith('http://') || logoPath.startsWith('https://')) {
    return logoPath;
  }

  // In development, the proxy will handle /api requests, but Active Storage URLs
  // are served directly from Rails, so we need the full Rails server URL
  const baseUrl = import.meta.env.DEV
    ? 'http://localhost:3000'
    : window.location.origin;

  // Ensure the path starts with /
  const path = logoPath.startsWith('/') ? logoPath : `/${logoPath}`;

  return `${baseUrl}${path}`;
}

/**
 * Generate image style for small thumbnails
 * Ensures consistent sizing for table display
 */
export function getLogoThumbnailStyle(): string {
  return 'object-cover w-full h-full';
}

/**
 * Get placeholder emoji based on entity type
 */
export function getPlaceholderEmoji(type: 'office' | 'user' | 'team' = 'office'): string {
  const emojis = {
    office: '🏢',
    user: '👤',
    team: '👥'
  };
  return emojis[type] || '📷';
}