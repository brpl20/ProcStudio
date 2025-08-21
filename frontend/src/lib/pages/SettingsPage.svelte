<script>
  import AuthSidebar from '../components/AuthSidebar.svelte';
</script>

<AuthSidebar activeSection="settings">
  <div class="container mx-auto">
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Menu de configurações -->
      <div class="lg:col-span-1">
        <div class="card bg-base-100 shadow-xl">
          <div class="card-body">
            <h3 class="card-title">Configurações</h3>
            <ul class="menu bg-base-200 rounded-box">
              <li><a>🔧 Geral</a></li>
              <li><a>👤 Perfil</a></li>
              <li><a>🔐 Segurança</a></li>
              <li><a>🔔 Notificações</a></li>
              <li><a>🎨 Aparência</a></li>
              <li><a>🌐 Idioma</a></li>
            </ul>
          </div>
        </div>
      </div>

      <!-- Conteúdo das configurações -->
      <div class="lg:col-span-2">
        <div class="card bg-base-100 shadow-xl">
          <div class="card-body">
            <h2 class="card-title text-2xl mb-6">⚙️ Configurações Gerais</h2>

            <!-- Configurações do perfil -->
            <div class="form-control w-full max-w-xs">
              <label class="label">
                <span class="label-text">Nome de usuário</span>
              </label>
              <input
                type="text"
                placeholder="Digite seu nome"
                class="input input-bordered w-full max-w-xs"
              />
            </div>

            <div class="form-control w-full max-w-xs">
              <label class="label">
                <span class="label-text">Email</span>
              </label>
              <input
                type="email"
                placeholder="seu@email.com"
                class="input input-bordered w-full max-w-xs"
              />
            </div>

            <div class="divider"></div>

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
              <label class="label">
                <span class="label-text">Tema</span>
              </label>
              <select class="select select-bordered">
                <option disabled selected>Escolha um tema</option>
                <option>Claro</option>
                <option>Escuro</option>
                <option>Auto</option>
              </select>
            </div>

            <div class="form-control w-full max-w-xs">
              <label class="label">
                <span class="label-text">Idioma</span>
              </label>
              <select class="select select-bordered">
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
