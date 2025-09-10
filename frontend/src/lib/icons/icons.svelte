<script>
  import { getIcon } from './icons/index.js';

  export let name;
  export let className = 'h-5 w-5';
  export let strokeWidth = '2';

  $: IconComponent = getIcon(name);
</script>

<svelte:component this={IconComponent} {className} {strokeWidth} />
