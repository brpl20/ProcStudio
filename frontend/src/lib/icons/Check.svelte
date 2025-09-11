<script lang="ts">
  interface Props {
    className?: string;
  }

  const { className = 'h-5 w-5' }: Props = $props();
</script>

<svg
  xmlns="http://www.w3.org/2000/svg"
  class={className}
  fill="none"
  viewBox="0 0 24 24"
  stroke="currentColor"
>
  <path
    stroke-linecap="round"
    stroke-linejoin="round"
    stroke-width="2"
    d="M5 13l4 4L19 7"
  />
</svg>