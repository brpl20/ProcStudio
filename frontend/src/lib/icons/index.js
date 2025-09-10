// Icon component imports
import Dashboard from './Dashboard.svelte';
import Admin from './Admin.svelte';
import Settings from './Settings.svelte';
import Reports from './Reports.svelte';
import Tasks from './Tasks.svelte';
import Teams from './Teams.svelte';
import Logout from './Logout.svelte';
import Hamburger from './Hamburger.svelte';
import Search from './Search.svelte';
import Notification from './Notification.svelte';
import Heart from './Heart.svelte';
import Lightning from './Lightning.svelte';
import Briefcase from './Briefcase.svelte';
import Adjustments from './Adjustments.svelte';
import Work from './Work.svelte';
import Customer from './Customer.svelte';
import ChevronUp from './ChevronUp.svelte';
import Help from './Help.svelte';
import Support from './Support.svelte';
import LogoutAlt from './LogoutAlt.svelte';
import ArrowLeft from './ArrowLeft.svelte';
import Error from './Error.svelte';
import Success from './Success.svelte';
import Warning from './Warning.svelte';
import Comment from './Comment.svelte';
import Default from './Default.svelte';

// Icon component exports
export {
  Dashboard,
  Admin,
  Settings,
  Reports,
  Tasks,
  Teams,
  Logout,
  Hamburger,
  Search,
  Notification,
  Heart,
  Lightning,
  Briefcase,
  Adjustments,
  Work,
  Customer,
  ChevronUp,
  Help,
  Support,
  LogoutAlt,
  ArrowLeft,
  Error,
  Success,
  Warning,
  Comment,
  Default
};

// Icon mapping for dynamic loading
export const iconMap = {
  dashboard: Dashboard,
  admin: Admin,
  settings: Settings,
  reports: Reports,
  tasks: Tasks,
  teams: Teams,
  logout: Logout,
  hamburger: Hamburger,
  search: Search,
  notification: Notification,
  heart: Heart,
  lightning: Lightning,
  briefcase: Briefcase,
  adjustments: Adjustments,
  work: Work,
  customer: Customer,
  'chevron-up': ChevronUp,
  help: Help,
  support: Support,
  'logout-alt': LogoutAlt,
  'arrow-left': ArrowLeft,
  error: Error,
  success: Success,
  warning: Warning,
  comment: Comment,
  default: Default
};

// Helper function to get icon component by name
export function getIcon(name) {
  return iconMap[name] || iconMap['default'];
}
