<script lang="ts">
  import { getIcon } from './index.js';

  interface Props {
    name: string;
    className?: string;
    strokeWidth?: string;
  }

  const { name, className = 'h-5 w-5', strokeWidth = '2' }: Props = $props();

  const IconComponent = $derived(getIcon(name));
</script>

<IconComponent {className} {strokeWidth} />
