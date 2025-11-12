<script>
  import { router } from './router.svelte';

  let {
    href = '',
    replace = false,
    native = false,
    className = '',
    activeClass = 'active',
    exact = false,
    children,
    ...restProps
  } = $props();

  const isActive = $derived(router.isActive(href, exact));
  const computedClass = $derived(
    `${className} ${isActive ? activeClass : ''}`.trim()
  );

  function handleClick(e) {
    if (native) {
      return;
    }

    e.preventDefault();
    router.navigate(href, replace);
  }
</script>

<a
  {href}
  class={computedClass}
  data-native={native}
  onclick={handleClick}
  {...restProps}
>
  {@render children?.()}
</a>