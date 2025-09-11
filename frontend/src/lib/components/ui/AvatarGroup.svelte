<!-- components/ui/AvatarGroup.svelte -->
<script lang="ts">
  interface User {
    name: string;
    last_name?: string;
  }

  interface Props {
    users: User[];
    maxDisplay?: number;
    size?: 'xs' | 'sm' | 'md' | 'lg';
  }

  const {
    users = [],
    maxDisplay = 2,
    size = 'sm'
  }: Props = $props();

  const sizeClasses = {
    xs: 'w-6 h-6 text-xs',
    sm: 'w-8 h-8 text-xs',
    md: 'w-10 h-10 text-sm',
    lg: 'w-12 h-12 text-base'
  };

  const sizeClass = $derived(sizeClasses[size]);

  function getInitials(user: User): string {
    const firstName = user.name?.charAt(0) || '';
    const lastName = user.last_name?.charAt(0) || '';
    return (firstName + lastName).toUpperCase();
  }

  const displayUsers = $derived(users.slice(0, maxDisplay));
  const remainingCount = $derived(Math.max(0, users.length - maxDisplay));
</script>

{#if users.length === 0}
  <span class="text-base-content/30">-</span>
{:else if users.length === 1}
  <!-- Single member -->
  <div class="avatar placeholder">
    <div class="bg-primary text-primary-content rounded-full {sizeClass}">
      <span class="font-medium">
        {getInitials(users[0])}
      </span>
    </div>
  </div>
{:else}
  <!-- Multiple members -->
  <div class="avatar-group -space-x-4">
    {#each displayUsers as user, index}
      <div class="avatar placeholder">
        <div class="{index === 0 ? 'bg-primary text-primary-content' : 'bg-secondary text-secondary-content'} rounded-full {sizeClass}">
          <span class="font-medium">
            {getInitials(user)}
          </span>
        </div>
      </div>
    {/each}
    {#if remainingCount > 0}
      <div class="avatar placeholder">
        <div class="bg-accent text-accent-content rounded-full {sizeClass}">
          <span class="font-bold">
            +{remainingCount}
          </span>
        </div>
      </div>
    {/if}
  </div>
{/if}