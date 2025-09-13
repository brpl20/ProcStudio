<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let currentAvatarUrl: string | null = null;
  export let userName: string = '';
  export let loading: boolean = false;

  const dispatch = createEventDispatcher();

  let fileInput: HTMLInputElement;
  let previewUrl: string | null = currentAvatarUrl;
  let isDragging = false;
  let imageFile: File | null = null;
  let cropperActive = false;
  let imageElement: HTMLImageElement;

  // Cropper state
  let cropX = 0;
  let cropY = 0;
  let cropSize = 200;
  let scale = 1;
  let imageNaturalWidth = 0;
  let imageNaturalHeight = 0;

  // Color options for default avatar
  const avatarColors = [
    'bg-primary',
    'bg-secondary',
    'bg-accent',
    'bg-success',
    'bg-warning',
    'bg-info',
    'bg-error',
    'bg-neutral'
  ];
  let selectedColor = 'bg-primary';
  let useCustomColor = false;

  function handleFileSelect(event: Event) {
    const target = event.target as HTMLInputElement;
    const file = target.files?.[0];
    if (file) {
      processFile(file);
    }
  }

  function processFile(file: File) {
    if (!file.type.startsWith('image/')) {
      dispatch('error', { message: 'Por favor, selecione um arquivo de imagem válido.' });
      return;
    }

    if (file.size > 5 * 1024 * 1024) {
      dispatch('error', { message: 'A imagem deve ter no máximo 5MB.' });
      return;
    }

    imageFile = file;
    const reader = new FileReader();
    reader.onload = (e) => {
      previewUrl = e.target?.result as string;
      cropperActive = true;
      loadImageDimensions(previewUrl);
    };
    reader.readAsDataURL(file);
  }

  function loadImageDimensions(url: string) {
    const img = new window.Image();
    img.onload = () => {
      imageNaturalWidth = img.width;
      imageNaturalHeight = img.height;

      // Center the crop area
      const minDimension = Math.min(imageNaturalWidth, imageNaturalHeight);
      cropSize = Math.min(minDimension, 400);
      cropX = (imageNaturalWidth - cropSize) / 2;
      cropY = (imageNaturalHeight - cropSize) / 2;
    };
    img.src = url;
  }

  function handleDrop(event: DragEvent) {
    event.preventDefault();
    isDragging = false;

    const file = event.dataTransfer?.files[0];
    if (file) {
      processFile(file);
    }
  }

  function handleDragOver(event: DragEvent) {
    event.preventDefault();
    isDragging = true;
  }

  function handleDragLeave() {
    isDragging = false;
  }

  async function cropAndUpload() {
    if (!imageFile || !previewUrl) {
return;
}

    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    if (!ctx) {
return;
}

    canvas.width = 200;
    canvas.height = 200;

    const img = new window.Image();
    img.onload = () => {
      // Apply cropping
      ctx.drawImage(
        img,
        cropX,
        cropY,
        cropSize,
        cropSize,
        0,
        0,
        200,
        200
      );

      canvas.toBlob(async (blob) => {
        if (blob) {
          dispatch('upload', {
            file: new File([blob], 'avatar.jpg', { type: 'image/jpeg' }),
            preview: canvas.toDataURL('image/jpeg', 0.9)
          });
          cropperActive = false;
        }
      }, 'image/jpeg', 0.9);
    };
    img.src = previewUrl;
  }

  function removeAvatar() {
    previewUrl = null;
    imageFile = null;
    useCustomColor = true;
    dispatch('remove');
  }

  function selectCustomColor(color: string) {
    selectedColor = color;
    useCustomColor = true;
    previewUrl = null;
    dispatch('colorChange', { color });
  }

  function cancelCrop() {
    cropperActive = false;
    previewUrl = currentAvatarUrl;
    imageFile = null;
  }

  // Mouse controls for cropper
  let isDraggingCrop = false;
  let dragStartX = 0;
  let dragStartY = 0;
  let initialCropX = 0;
  let initialCropY = 0;

  function startDrag(event: MouseEvent) {
    isDraggingCrop = true;
    dragStartX = event.clientX;
    dragStartY = event.clientY;
    initialCropX = cropX;
    initialCropY = cropY;
  }

  function handleMouseMove(event: MouseEvent) {
    if (!isDraggingCrop) {
return;
}

    const deltaX = event.clientX - dragStartX;
    const deltaY = event.clientY - dragStartY;

    cropX = Math.max(0, Math.min(imageNaturalWidth - cropSize, initialCropX + deltaX * 2));
    cropY = Math.max(0, Math.min(imageNaturalHeight - cropSize, initialCropY + deltaY * 2));
  }

  function stopDrag() {
    isDraggingCrop = false;
  }
</script>

<svelte:window on:mousemove={handleMouseMove} on:mouseup={stopDrag} />

<div class="space-y-4">
  <!-- Current Avatar Display -->
  <div class="flex items-center gap-6">
    <div class="avatar">
      <div class="w-32 rounded-full ring ring-primary ring-offset-base-100 ring-offset-2">
        {#if previewUrl && !useCustomColor}
          <img src={previewUrl} alt={userName} />
        {:else if useCustomColor || !currentAvatarUrl}
          <div class="{selectedColor} text-base-100 rounded-full w-32 h-32 flex items-center justify-center">
            <span class="text-5xl font-bold">{userName.charAt(0).toUpperCase()}</span>
          </div>
        {:else if currentAvatarUrl}
          <img src={currentAvatarUrl} alt={userName} />
        {/if}
      </div>
    </div>

    <div class="flex-1">
      <h3 class="text-lg font-semibold mb-2">Foto do Perfil</h3>
      <p class="text-sm opacity-70 mb-3">
        Faça upload de uma nova foto ou escolha uma cor personalizada
      </p>

      <!-- Action Buttons -->
      <div class="flex flex-wrap gap-2">
        <button
          class="btn btn-primary btn-sm"
          on:click={() => fileInput?.click()}
          disabled={loading}
        >
          {#if loading}
            <span class="loading loading-spinner loading-xs"></span>
          {/if}
          Escolher Foto
        </button>

        {#if currentAvatarUrl || previewUrl}
          <button
            class="btn btn-error btn-outline btn-sm"
            on:click={removeAvatar}
            disabled={loading}
          >
            Remover Foto
          </button>
        {/if}
      </div>
    </div>
  </div>

  <!-- Hidden File Input -->
  <input
    bind:this={fileInput}
    type="file"
    accept="image/*"
    on:change={handleFileSelect}
    class="hidden"
  />

  <!-- Drag and Drop Zone -->
  <div
    role="button"
    tabindex="0"
    class="border-2 border-dashed rounded-lg p-8 text-center transition-colors
           {isDragging ? 'border-primary bg-primary/10' : 'border-base-300'}"
    on:drop={handleDrop}
    on:dragover={handleDragOver}
    on:dragleave={handleDragLeave}
    on:click={() => fileInput?.click()}
    on:keydown={(e) => e.key === 'Enter' && fileInput?.click()}
  >
    <svg class="w-12 h-12 mx-auto mb-3 text-base-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
            d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
    </svg>
    <p class="text-sm opacity-70">
      Arraste e solte uma imagem aqui ou clique em "Escolher Foto"
    </p>
    <p class="text-xs opacity-50 mt-2">
      Formatos aceitos: JPG, PNG, GIF (máx. 5MB)
    </p>
  </div>

  <!-- Color Selection -->
  <div class="card bg-base-200">
    <div class="card-body">
      <h4 class="card-title text-sm">Ou escolha uma cor de fundo</h4>
      <div class="flex flex-wrap gap-2">
        {#each avatarColors as color}
          <button
            class="btn btn-circle btn-sm {color}"
            on:click={() => selectCustomColor(color)}
            class:ring-2={selectedColor === color && useCustomColor}
            class:ring-offset-2={selectedColor === color && useCustomColor}
          >
            {#if selectedColor === color && useCustomColor}
              <svg class="w-4 h-4 text-base-100" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
              </svg>
            {/if}
          </button>
        {/each}
      </div>
    </div>
  </div>
</div>

<!-- Image Cropper Modal -->
{#if cropperActive && previewUrl}
  <div class="modal modal-open">
    <div class="modal-box max-w-2xl">
      <h3 class="font-bold text-lg mb-4">Ajustar Imagem</h3>

      <div class="relative overflow-hidden bg-base-200 rounded-lg" style="height: 400px;">
        <div class="relative w-full h-full flex items-center justify-center">
          <img
            bind:this={imageElement}
            src={previewUrl}
            alt="Preview"
            class="max-w-full max-h-full"
            style="transform: scale({scale})"
          />

          <!-- Crop Overlay -->
          <div
            role="button"
            tabindex="0"
            aria-label="Área de corte da imagem - arraste para reposicionar"
            class="absolute border-2 border-white shadow-lg cursor-move"
            style="
              width: {cropSize / 2}px;
              height: {cropSize / 2}px;
              left: 50%;
              top: 50%;
              transform: translate(-50%, -50%);
            "
            on:mousedown={startDrag}
            on:keydown={(e) => e.key === 'Enter' && startDrag(e)}
          >
            <div class="absolute inset-0 border border-white/30"></div>
            <div class="absolute inset-0 grid grid-cols-3 grid-rows-3">
              {#each Array(9) as _}
                <div class="border border-white/20"></div>
              {/each}
            </div>
          </div>

          <!-- Dark overlay outside crop area -->
          <div class="absolute inset-0 pointer-events-none">
            <svg class="w-full h-full">
              <defs>
                <mask id="hole">
                  <rect width="100%" height="100%" fill="white"/>
                  <rect
                    x="calc(50% - {cropSize / 4}px)"
                    y="calc(50% - {cropSize / 4}px)"
                    width="{cropSize / 2}px"
                    height="{cropSize / 2}px"
                    fill="black"
                  />
                </mask>
              </defs>
              <rect width="100%" height="100%" fill="black" opacity="0.5" mask="url(#hole)"/>
            </svg>
          </div>
        </div>
      </div>

      <!-- Zoom Control -->
      <div class="mt-4">
        <label class="label" for="zoom-control">
          <span class="label-text">Zoom</span>
        </label>
        <input
          id="zoom-control"
          type="range"
          min="0.5"
          max="2"
          step="0.1"
          bind:value={scale}
          class="range range-primary"
          aria-label="Controle de zoom da imagem"
        />
      </div>

      <div class="modal-action">
        <button class="btn btn-ghost" on:click={cancelCrop}>Cancelar</button>
        <button class="btn btn-primary" on:click={cropAndUpload}>
          Aplicar
        </button>
      </div>
    </div>
  </div>
{/if}