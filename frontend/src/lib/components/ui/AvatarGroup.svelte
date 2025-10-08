<!-- components/ui/AvatarGroup.svelte -->
<script lang="ts">
  interface User {
    name: string;
    last_name?: string;
    avatar?: string;
  }

  export let users: User[] = [];
  export let maxDisplay: number = 2;
  export let size: 'xs' | 'sm' | 'md' | 'lg' = 'sm';

  const sizeClasses = {
    responsive: 'w-6 h-6 text-xs sm:w-8 sm:h-8 sm:text-sm md:w-10 md:h-10 md:text-base lg:w-12 lg:h-12 lg:text-lg',
    xs: 'w-6 h-6 text-xs',
    sm: 'w-8 h-8 text-xs',
    md: 'w-10 h-10 text-sm',
    lg: 'w-12 h-12 text-base'
  };

  // Função para gerar hash simples baseado no nome do usuário
  function hashString(str: string): number {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 2) - hash) + char;
      hash = hash & hash;
    }
    return Math.abs(hash);
  }

  function getUserColor(user: User, index: number): string {
    const userKey = `${user.name}${user.last_name || ''}`;
    const hash = hashString(userKey);

    // Usa a proporção áurea para distribuição harmônica das cores
    const goldenRatio = 0.618033988749895;
    const baseHue = (hash % 360);

    // Adiciona variação usando golden ratio
    const hue = (baseHue + (index * goldenRatio * 360)) % 360;

    // Parâmetros para cores vibrantes e legíveis
    const saturation = 65 + (hash % 25); // 65-90%
    const lightness = 50 + (hash % 15);  // 50-65%

    return `hsl(${Math.floor(hue)}, ${saturation}%, ${lightness}%)`;
  }

  function getInitials(user: User): string {
    const firstName = user.name?.charAt(0) || '';
    const lastName = user.last_name?.charAt(0) || '';
    return (firstName + lastName).toUpperCase();
  }

  // Função para determinar cor do texto baseada na cor de fundo
  function getTextColor(backgroundColor: string): string {
    // Para HSL, assumimos que cores com lightness < 60% precisam texto branco
    if (backgroundColor.includes('hsl')) {
      const lightness = parseInt(backgroundColor.match(/(\d+)%\)$/)?.[1] || '50');
      return lightness < 60 ? '#ffffff' : '#000000';
    }

    // Para RGB, calculamos luminância
    const rgbMatch = backgroundColor.match(/rgb\((\d+),\s*(\d+),\s*(\d+)\)/);
    if (rgbMatch) {
      const [, r, g, b] = rgbMatch.map(Number);
      const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
      return luminance > 0.6 ? '#000000' : '#ffffff';
    }

    return '#ffffff'; // padrão
  }

  $: displayUsers = users.slice(0, maxDisplay);
  $: remainingCount = Math.max(0, users.length - maxDisplay);
</script>

{#if users.length === 0}
  <span class="text-base-content/30">-</span>
{:else}
  <div class="avatar-group -space-x-4 justify-center">
    {#each displayUsers as user, index}
      <div class="avatar">
        {#if user.avatar}
          <div
            class="{sizeClasses[size]} rounded-full ring-2 ring-offset-2 ring-offset-base-100"
            style="--ring-color: {getUserColor(user, index)}; border: 2px solid var(--ring-color);"
          >
            <img src={user.avatar} alt={user.name} class="rounded-full object-cover" />
          </div>
        {:else}
          {@const bgColor = getUserColor(user, index)}
          {@const textColor = getTextColor(bgColor)}
          <div
            class="rounded-full {sizeClasses[size]} font-medium ring-2 ring-offset-2 ring-offset-base-100"
            style="background-color: {bgColor}; color: {textColor}; --ring-color: {bgColor}; border: 2px solid var(--ring-color); display: flex !important; align-items: center; justify-content: center;"
          >
            {getInitials(user)}
          </div>
        {/if}
      </div>
    {/each}
    {#if remainingCount > 0}
      <div class="avatar placeholder">
        <div
          class="bg-primary text-neutral-content rounded-full {sizeClasses[size]} font-medium ring-2 ring-offset-2 ring-neutral"
          style="display: flex !important; align-items: center; justify-content: center;"
        >
          +{remainingCount}
        </div>
      </div>
    {/if}
  </div>
{/if}
