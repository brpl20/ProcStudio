<script lang="ts">

  import type { Snippet } from 'svelte';

  interface Props {
    password: string;
    value?: string;
    name?: string;
    required?: boolean;
    placeholder?: string;
    class?: string;
    errorClass?: string;
    labelSlot?: Snippet;
    children?: Snippet;
  }

  let {
    password,
    value = $bindable(''),
    name = 'password_confirmation',
    required = true,
    placeholder = 'Confirme sua senha',
    class: className = '',
    errorClass = '',
    labelSlot,
    children
  }: Props = $props();

  let showPassword = $state(false);
  let touched = $state(false);

  const isMatch = $derived(
    !touched || !value || value === password
  );

  const errorMessage = $derived(
    !isMatch ? 'As senhas não coincidem' : ''
  );

  function handleInput(e: Event) {
    const target = e.target as HTMLInputElement;
    value = target.value;
  }

  function handleBlur() {
    touched = true;
  }

  function togglePasswordVisibility() {
    showPassword = !showPassword;
  }
</script>

<div class="form-control w-full">
  {#if labelSlot}
    {@render labelSlot()}
  {:else}
    <label class="label" for={name}>
      <span class="label-text">
        Confirme a Senha
        {#if required}
          <span class="text-error">*</span>
        {/if}
      </span>
    </label>
  {/if}

  <div class="relative">
    <input
      id={name}
      {name}
      type={showPassword ? 'text' : 'password'}
      {required}
      {placeholder}
      {value}
      oninput={handleInput}
      onblur={handleBlur}
      class="input input-bordered w-full pr-10 {className} {!isMatch ? 'input-error' : ''} {errorClass}"
    />

    {#if value}
      <button
        type="button"
        onclick={togglePasswordVisibility}
        class="absolute right-3 top-1/2 -translate-y-1/2 btn btn-ghost btn-xs btn-circle"
        aria-label={showPassword ? 'Ocultar senha' : 'Mostrar senha'}
      >
        {#if showPassword}
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.523 10.523 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228l-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.242 4.242L9.88 9.88" />
          </svg>
        {:else}
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 010-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178z" />
            <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
        {/if}
      </button>
    {/if}
  </div>

  {#if errorMessage && touched}
    <div class="label">
      <span class="label-text-alt text-error">{errorMessage}</span>
    </div>
  {/if}

  {#if touched && isMatch && value}
    <div class="label">
      <span class="label-text-alt text-success flex items-center gap-1">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4">
          <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5" />
        </svg>
        Senhas coincidem
      </span>
    </div>
  {/if}

  {#if children}
    {@render children()}
  {/if}
</div>