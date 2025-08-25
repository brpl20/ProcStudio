<script>
  import AuthSidebar from '../components/AuthSidebar.svelte';
</script>

<AuthSidebar activeSection="dashboard">
  <div class="container mx-auto">
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Conteúdo das configurações -->
      <div class="lg:col-span-3">
        <div class="card bg-base-100 shadow-xl">
          <div class="card-body">
            <h2 class="card-title text-2xl mb-6">Configurações Gerais</h2>
            <h2 class="card-title text-2xl mb-6">ToDo (em desenvolvimento)</h2>

            <!-- Configurações do perfil -->
            <p>Usuário:</p>
            <p>Email:</p>
            <p>Oab:</p>

            <div class="divider"></div>
            Configurações de IA Créditos de IA Comprar Créditos de IA
            <div class="divider"></div>

            Configurações de Documentos Geração Entrega Configurações de Áreas de Atuação
            Configurações de Poderes Configurações de Permissão

            <!-- Configurações de notificação -->
            <h3 class="text-lg font-semibold mb-4">🔔 Notificações</h3>

            <div class="form-control">
              <label class="label cursor-pointer">
                <span class="label-text">Receber emails de notificação</span>
                <input type="checkbox" checked class="checkbox checkbox-primary" />
              </label>
            </div>

            <div class="form-control">
              <label class="label cursor-pointer">
                <span class="label-text">Notificações push</span>
                <input type="checkbox" class="checkbox checkbox-primary" />
              </label>
            </div>

            <div class="form-control">
              <label class="label cursor-pointer">
                <span class="label-text">Notificações de equipe</span>
                <input type="checkbox" checked class="checkbox checkbox-primary" />
              </label>
            </div>

            <div class="divider"></div>

            <!-- Configurações de aparência -->
            <h3 class="text-lg font-semibold mb-4">🎨 Aparência</h3>

            <div class="form-control w-full max-w-xs">
              <label class="label" for="theme-select">
                <span class="label-text">Tema</span>
              </label>
              <select id="theme-select" class="select select-bordered">
                <option disabled selected>Escolha um tema</option>
                <option>Claro</option>
                <option>Escuro</option>
                <option>Auto</option>
              </select>
            </div>

            <div class="form-control w-full max-w-xs">
              <label class="label" for="language-select">
                <span class="label-text">Idioma</span>
              </label>
              <select id="language-select" class="select select-bordered">
                <option disabled selected>Escolha um idioma</option>
                <option>Português (BR)</option>
                <option>English</option>
                <option>Español</option>
              </select>
            </div>

            <div class="divider"></div>

            <!-- Botões de ação -->
            <div class="card-actions justify-end mt-6">
              <button class="btn btn-outline">Cancelar</button>
              <button class="btn btn-primary">Salvar Alterações</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</AuthSidebar>
