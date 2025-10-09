<script>
  import { router } from './router.svelte';
  
  export let href = '';
  export let replace = false;
  export let native = false;
  export let className = '';
  export let activeClass = 'active';
  export let exact = false;
  
  let isActive = $derived(router.isActive(href, exact));
  let computedClass = $derived(
    `${className} ${isActive ? activeClass : ''}`.trim()
  );
  
  function handleClick(e) {
    if (native) return;
    
    e.preventDefault();
    router.navigate(href, replace);
  }
</script>

<a 
  {href}
  class={computedClass}
  data-native={native}
  onclick={handleClick}
  {...$$restProps}
>
  <slot />
</a>