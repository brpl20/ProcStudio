<script>
  const { title, children } = $props();
</script>

<div class="card bg-base-100 shadow">
  <div class="card-body">
    <h3 class="card-title text-lg font-semibold mb-4">{title}</h3>
    {@render children()}
  </div>
</div>
