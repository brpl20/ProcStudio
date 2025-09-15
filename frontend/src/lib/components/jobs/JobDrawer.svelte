<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import Quill from 'quill';
  import 'quill/dist/quill.snow.css';
  import AutoComplete from 'simple-svelte-autocomplete';
  import { usersCacheStore, allUserProfiles } from '../../stores/usersCacheStore';
  import type { UserProfileData } from '../../api/types/user.types';

  export let isOpen = false;

  let editor: HTMLDivElement;
  let quill: Quill | null = null;
  let showAutocomplete = false;
  let autocompletePosition = { x: 0, y: 0 };
  let searchTerm = '';
  let userProfiles: UserProfileData[] = [];
  let selectedUser: UserProfileData | null = null;
  let currentMentionRange: any = null;
  let selectedIndex = 0;
  let filteredUsers: UserProfileData[] = [];
  let debounceTimer: number | null = null;

  // Role translations
  const roleTranslations: Record<string, string> = {
    lawyer: 'Advogado',
    secretary: 'Secretário',
    admin: 'Administrador'
  };

  $: userProfiles = $allUserProfiles;
  $: filteredUsers = searchUsers(searchTerm);
  $: if (showAutocomplete && filteredUsers.length > 0) {
    selectedIndex = 0; // Pre-select first user when list updates
  }

  onMount(async () => {
    // Initialize users cache
    await usersCacheStore.initialize();

    if (editor) {
      quill = new Quill(editor, {
        theme: 'snow',
        placeholder: 'Escreva sua mensagem aqui...',
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

      // Listen for text changes to detect @ mentions
      quill.on('text-change', (delta, oldDelta, source) => {
        if (source === 'user') {
          handleTextChange();
        }
      });

      // Listen for selection changes
      quill.on('selection-change', (range, oldRange, source) => {
        if (!range) {
          showAutocomplete = false;
        }
      });

      // Add keyboard event listener to the editor
      quill.root.addEventListener('keydown', handleKeydown);
    }
  });

  onDestroy(() => {
    if (quill) {
      quill.root.removeEventListener('keydown', handleKeydown);
      quill = null;
    }
    if (debounceTimer) {
      clearTimeout(debounceTimer);
    }
  });

  function handleKeydown(event: KeyboardEvent) {
    if (!showAutocomplete) {
      return;
    }

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
    if (!quill) {
      return;
    }

    // Clear existing debounce timer
    if (debounceTimer) {
      clearTimeout(debounceTimer);
    }

    // Set new debounce timer
    debounceTimer = setTimeout(() => {
      processTextChange();
    }, 100);
  }

  function processTextChange() {
    if (!quill) {
      return;
    }

    const range = quill.getSelection();
    if (!range) {
      return;
    }

    const text = quill.getText();
    const cursorPos = range.index;

    // Look for @ symbol before cursor
    let atSignPos = -1;
    for (let i = cursorPos - 1; i >= 0; i--) {
      if (text[i] === '@') {
        atSignPos = i;
        break;
      }
      // Stop if we hit a space or newline
      if (text[i] === ' ' || text[i] === '\n') {
        break;
      }
    }

    if (atSignPos !== -1) {
      // Extract the search term after @ (can be empty to show all users)
      searchTerm = text.substring(atSignPos + 1, cursorPos);

      // Get the position of the @ symbol in the editor
      const bounds = quill.getBounds(atSignPos);

      // Store the range for replacement
      currentMentionRange = {
        index: atSignPos,
        length: cursorPos - atSignPos
      };

      // Show autocomplete immediately when @ is typed
      showAutocomplete = true;
      selectedIndex = 0; // Reset selection to first item

      // Position the autocomplete below the cursor
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
    if (!quill || !currentMentionRange) {
      return;
    }

    // Delete the @ and partial name
    quill.deleteText(currentMentionRange.index, currentMentionRange.length);

    // Insert the user mention with formatting
    const userName = `${user.attributes?.name || ''} ${user.attributes?.last_name || ''}`.trim();

    // Insert formatted mention
    quill.insertText(currentMentionRange.index, `@${userName}`, {
      bold: true,
      color: '#0066cc'
    });

    // Insert a space after the mention
    quill.insertText(currentMentionRange.index + userName.length + 1, ' ');

    // Move cursor after the space
    quill.setSelection(currentMentionRange.index + userName.length + 2);

    // Hide autocomplete
    showAutocomplete = false;
    currentMentionRange = null;
    selectedUser = null;
    selectedIndex = 0;
  }

  function closeDrawer() {
    isOpen = false;
    showAutocomplete = false;
  }

  function handleSave() {
    if (quill) {
      const content = quill.root.innerHTML;
      const text = quill.getText();
      // TODO: Implement save functionality
      // For now, the content is captured but not persisted
    }
  }

  function searchUsers(term: string) {
    // Show all users when no search term (when @ is just typed)
    if (!term || term.trim() === '') {
      return userProfiles;
    }

    const lowerTerm = term.toLowerCase();
    return userProfiles.filter((profile) => {
      const fullName =
        `${profile.attributes?.name || ''} ${profile.attributes?.last_name || ''}`.toLowerCase();
      const email = profile.attributes?.access_email?.toLowerCase() || '';

      return fullName.includes(lowerTerm) || email.includes(lowerTerm);
    });
  }

  function getUserLabel(user: UserProfileData) {
    if (!user) {
      return '';
    }
    const name = `${user.attributes?.name || ''} ${user.attributes?.last_name || ''}`.trim();
    const email = user.attributes?.access_email || '';
    return name ? `${name} (${email})` : email;
  }

  // Group users by role
  function getUsersByRole(users: UserProfileData[], role: string) {
    return users.filter(
      (user) =>
        !user.attributes?.role || user.attributes.role === role || user.attributes.role === 'lawyer' // Default to lawyer if no role or matching role
    );
  }
</script>

<div class="drawer drawer-end z-50">
  <input id="job-drawer" type="checkbox" class="drawer-toggle" bind:checked={isOpen} />

  <div class="drawer-side">
    <label for="job-drawer" aria-label="close sidebar" class="drawer-overlay"></label>

    <div class="menu bg-base-100 text-base-content min-h-full w-96 p-0">
      <div class="flex items-center justify-between p-4 border-b">
        <h3 class="text-lg font-semibold">Anotações</h3>
        <button class="btn btn-sm btn-ghost btn-circle" aria-label="Fechar" onclick={closeDrawer}>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-5 w-5"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M6 18L18 6M6 6l12 12"
            />
          </svg>
        </button>
      </div>

      <div class="flex-1 flex flex-col p-4 relative">
        <div class="mb-4">
          <label for="message-editor" class="text-sm font-medium text-base-content/70 mb-2 block">
            Mensagem
          </label>
          <div class="border rounded-lg bg-base-100 relative">
            <div bind:this={editor} class="min-h-[400px]"></div>

            {#if showAutocomplete}
              <div
                class="absolute bg-base-100 border-2 rounded-lg shadow-2xl max-h-96 overflow-y-auto z-50"
                style="left: {autocompletePosition.x}px; top: {autocompletePosition.y}px; min-width: 320px;"
              >
                <!-- Lawyer Header -->
                <div class="sticky top-0 bg-base-200 px-4 py-2 border-b">
                  <h4 class="font-semibold text-sm flex items-center gap-2">
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      class="h-4 w-4"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3"
                      />
                    </svg>
                    Advogados
                  </h4>
                </div>

                <div class="p-2">
                  {#if filteredUsers.length === 0}
                    <div class="text-sm text-base-content/60 p-4 text-center">
                      Nenhum usuário encontrado
                    </div>
                  {:else}
                    <div class="text-xs text-base-content/60 mb-2 px-2">
                      {filteredUsers.length} usuário{filteredUsers.length !== 1 ? 's' : ''} encontrado{filteredUsers.length !==
                      1
                        ? 's'
                        : ''}
                    </div>
                    {#each filteredUsers.slice(0, 8) as user, index}
                      <button
                        class="w-full text-left p-3 rounded-lg flex items-center gap-3 transition-colors {index ===
                        selectedIndex
                          ? 'bg-primary/10 ring-2 ring-primary'
                          : 'hover:bg-base-200'}"
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
                          <div
                            class="w-10 h-10 rounded-full bg-primary text-primary-content flex items-center justify-center text-sm font-semibold"
                          >
                            {(user.attributes?.name || '?')[0].toUpperCase()}
                          </div>
                        {/if}
                        <div class="flex-1 min-w-0">
                          <div class="font-medium truncate">
                            {user.attributes?.name || ''}
                            {user.attributes?.last_name || ''}
                          </div>
                          <div class="text-xs text-base-content/60 truncate">
                            {user.attributes?.access_email || ''}
                          </div>
                          {#if user.attributes?.oab}
                            <div class="text-xs text-base-content/50 mt-0.5">
                              OAB: {user.attributes.oab}
                            </div>
                          {/if}
                        </div>
                        {#if index === selectedIndex}
                          <div class="text-xs text-primary">
                            <svg
                              xmlns="http://www.w3.org/2000/svg"
                              class="h-5 w-5"
                              fill="none"
                              viewBox="0 0 24 24"
                              stroke="currentColor"
                            >
                              <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                stroke-width="2"
                                d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                              />
                            </svg>
                          </div>
                        {/if}
                      </button>
                    {/each}
                  {/if}
                </div>

                <!-- Keyboard shortcuts hint -->
                <div
                  class="sticky bottom-0 bg-base-200 px-4 py-2 border-t text-xs text-base-content/60"
                >
                  <div class="flex gap-4">
                    <span>↑↓ Navegar</span>
                    <span>Enter Selecionar</span>
                    <span>Esc Fechar</span>
                  </div>
                </div>
              </div>
            {/if}
          </div>
          <div class="text-xs text-base-content/60 mt-1">Digite @ para mencionar um usuário</div>
        </div>

        <div class="mt-auto pt-4 border-t">
          <div class="flex gap-2 justify-end">
            <button class="btn btn-ghost" onclick={closeDrawer}> Cancelar </button>
            <button class="btn btn-primary" onclick={handleSave}> Salvar </button>
          </div>
        </div>
      </div>
    </div>
  </div>
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

  :global(.ql-editor) {
    min-height: 350px;
  }

  :global(.ql-editor.ql-blank::before) {
    color: oklch(var(--bc) / 0.5);
    font-style: normal;
  }
</style>
