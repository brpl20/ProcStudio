<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import Quill from 'quill';
  import 'quill/dist/quill.snow.css';
  import { allUserProfiles } from '../stores/usersCacheStore';
  import type { UserProfileData } from '../api/types/user.types';

   interface Props {
    placeholder?: string;
    minHeight?: string;
    content?: string;
  }

  const { 
    placeholder = 'Escreva aqui...', 
    minHeight = '200px',
    content = ''
  }: Props = $props();

  let editor: HTMLDivElement;
  let quill: Quill | null = null;
  let showAutocomplete = $state(false);
  let autocompletePosition = $state({ x: 0, y: 0 });
  let mentionSearchTerm = $state('');
  let currentMentionRange: any = null;
  let selectedIndex = $state(0);
  let debounceTimer: number | null = null;

  let userProfiles = $derived($allUserProfiles);
  let filteredUsers = $derived(searchUsers(mentionSearchTerm));

  $effect(() => {
    if (showAutocomplete && filteredUsers.length > 0) {
      selectedIndex = 0;
    }
  });

  onMount(() => {
    if (editor) {
      quill = new Quill(editor, {
        theme: 'snow',
        placeholder,
        modules: {
          toolbar: [
            [{ header: [1, 2, 3, false] }],
            ['bold', 'italic', 'underline', 'strike'],
            ['blockquote', 'code-block'],
            [{ list: 'ordered' }, { list: 'bullet' }],
            [{ indent: '-1' }, { indent: '+1' }],
            [{ color: [] }, { background: [] }],
            [{ align: [] }],
            ['link', 'image'],
            ['clean']
          ]
        }
      });

      if (content) {
        quill.root.innerHTML = content;
      }

      // Correção: prefixar com _ para indicar que não são usados
      quill.on('text-change', (_delta, _oldDelta, source) => {
        if (source === 'user') {
          handleTextChange();
        }
      });

      quill.on('selection-change', (range) => {
        if (!range) showAutocomplete = false;
      });

      quill.root.addEventListener('keydown', handleKeydown);
    }
  });

  onDestroy(() => {
    if (quill) {
      quill.root.removeEventListener('keydown', handleKeydown);
      quill = null;
    }
    if (debounceTimer) clearTimeout(debounceTimer);
  });

  export function getContent() {
    return quill ? quill.root.innerHTML : '';
  }

  export function getText() {
    return quill ? quill.getText() : '';
  }

  function handleKeydown(event: KeyboardEvent) {
    if (!showAutocomplete) return;

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault();
        selectedIndex = Math.min(selectedIndex + 1, filteredUsers.length - 1);
        break;
      case 'ArrowUp':
        event.preventDefault();
        selectedIndex = Math.max(selectedIndex - 1, 0);
        break;
      case 'Enter':
        event.preventDefault();
        if (filteredUsers[selectedIndex]) {
          handleUserSelect(filteredUsers[selectedIndex]);
        }
        break;
      case 'Escape':
        event.preventDefault();
        showAutocomplete = false;
        currentMentionRange = null;
        break;
    }
  }

  function handleTextChange() {
    if (!quill) return;
    
    if (debounceTimer) clearTimeout(debounceTimer);
    
    debounceTimer = setTimeout(() => processTextChange(), 100);
  }

  function processTextChange() {
    if (!quill) return;

    const range = quill.getSelection();
    if (!range) return;

    const text = quill.getText();
    const cursorPos = range.index;

    let atSignPos = -1;
    for (let i = cursorPos - 1; i >= 0; i--) {
      if (text[i] === '@') {
        atSignPos = i;
        break;
      }
      if (text[i] === ' ' || text[i] === '\n') break;
    }

    if (atSignPos !== -1) {
      mentionSearchTerm = text.substring(atSignPos + 1, cursorPos);
      const bounds = quill.getBounds(atSignPos);

      // Correção: verificar se bounds não é null
      if (!bounds) return;

      currentMentionRange = {
        index: atSignPos,
        length: cursorPos - atSignPos
      };

      showAutocomplete = true;
      selectedIndex = 0;

      autocompletePosition = {
        x: bounds.left,
        y: bounds.bottom + 5
      };
    } else {
      showAutocomplete = false;
      currentMentionRange = null;
    }
  }

  function handleUserSelect(user: UserProfileData) {
    if (!quill || !currentMentionRange) return;

    quill.deleteText(currentMentionRange.index, currentMentionRange.length);

    const userName = `${user.attributes?.name || ''} ${user.attributes?.last_name || ''}`.trim();

    quill.insertText(currentMentionRange.index, `@${userName}`, {
      bold: true,
      color: '#0066cc'
    });

    quill.insertText(currentMentionRange.index + userName.length + 1, ' ');
    quill.setSelection(currentMentionRange.index + userName.length + 2);

    showAutocomplete = false;
    currentMentionRange = null;
    selectedIndex = 0;
  }

  function searchUsers(term: string) {
    if (!term || term.trim() === '') return userProfiles;

    const lowerTerm = term.toLowerCase();
    return userProfiles.filter((profile) => {
      const fullName = `${profile.attributes?.name || ''} ${profile.attributes?.last_name || ''}`.toLowerCase();
      const email = profile.attributes?.access_email?.toLowerCase() || '';
      return fullName.includes(lowerTerm) || email.includes(lowerTerm);
    });
  }
</script>

<div class="border rounded-lg bg-base-100 relative">
  <div bind:this={editor} style="min-height: {minHeight}"></div>

  {#if showAutocomplete}
    <div
      class="absolute bg-base-100 border-2 rounded-lg shadow-2xl max-h-96 overflow-y-auto z-50"
      style="left: {autocompletePosition.x}px; top: {autocompletePosition.y}px; min-width: 320px;"
    >
      <div class="sticky top-0 bg-base-200 px-4 py-2 border-b">
        <h4 class="font-semibold text-sm">Usuários</h4>
      </div>

      <div class="p-2">
        {#if filteredUsers.length === 0}
          <div class="text-sm text-base-content/60 p-4 text-center">
            Nenhum usuário encontrado
          </div>
        {:else}
          {#each filteredUsers.slice(0, 8) as user, index}
            <button
              class="w-full text-left p-3 rounded-lg flex items-center gap-3 transition-colors {index === selectedIndex ? 'bg-primary/10 ring-2 ring-primary' : 'hover:bg-base-200'}"
              onclick={() => handleUserSelect(user)}
              onmouseenter={() => (selectedIndex = index)}
            >
              {#if user.attributes?.avatar_url}
                <img
                  src={user.attributes.avatar_url}
                  alt={user.attributes?.name || ''}
                  class="w-10 h-10 rounded-full object-cover"
                />
              {:else}
                <div class="w-10 h-10 rounded-full bg-primary text-primary-content flex items-center justify-center text-sm font-semibold">
                  {(user.attributes?.name || '?')[0].toUpperCase()}
                </div>
              {/if}
              <div class="flex-1 min-w-0">
                <div class="font-medium truncate">
                  {user.attributes?.name || ''} {user.attributes?.last_name || ''}
                </div>
                <div class="text-xs text-base-content/60 truncate">
                  {user.attributes?.access_email || ''}
                </div>
              </div>
            </button>
          {/each}
        {/if}
      </div>

      <div class="sticky bottom-0 bg-base-200 px-4 py-2 border-t text-xs text-base-content/60">
        <div class="flex gap-4">
          <span>↑↓ Navegar</span>
          <span>Enter Selecionar</span>
          <span>Esc Fechar</span>
        </div>
      </div>
    </div>
  {/if}
</div>

<div class="text-xs text-base-content/60 mt-1">
  Digite @ para mencionar um usuário
</div>

<style>
  :global(.ql-toolbar) {
    border-top-left-radius: 0.5rem;
    border-top-right-radius: 0.5rem;
    border-color: oklch(var(--bc) / 0.2);
  }

  :global(.ql-container) {
    border-bottom-left-radius: 0.5rem;
    border-bottom-right-radius: 0.5rem;
    border-color: oklch(var(--bc) / 0.2);
    font-size: 1rem;
  }

  :global(.ql-editor.ql-blank::before) {
    color: oklch(var(--bc) / 0.5);
    font-style: normal;
  }
</style>