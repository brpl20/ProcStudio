<script lang="ts">
  import MainLayout from '../components/MainLayout.svelte';
  import { router } from '../stores/routerStore';
  import logoProcStudio from '../../assets/procstudio_logotipo_vertical_sem_fundo.png'; 

  let openFaq: number | null = null;

  const toggleFaq = (index: number) => {
    openFaq = openFaq === index ? null : index;
  };
</script>

<MainLayout>
  <div class="relative overflow-hidden">
    <!-- Hero Section -->
    <div class="relative min-h-[80vh] flex items-center">
      <!-- Background decorative elements -->
      <div class="absolute inset-0 overflow-hidden pointer-events-none">
        <div class="absolute top-20 right-10 w-72 h-72 bg-[#0277EE] rounded-full mix-blend-multiply filter blur-3xl opacity-10 animate-blob"></div>
        <div class="absolute top-40 left-10 w-96 h-96 bg-[#0277EE] rounded-full mix-blend-multiply filter blur-3xl opacity-10 animate-blob animation-delay-2000"></div>
        <div class="absolute bottom-20 left-1/2 w-80 h-80 bg-[#01013D] rounded-full mix-blend-multiply filter blur-3xl opacity-10 animate-blob animation-delay-4000"></div>
      </div>

      <div class="relative w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center">
            <img 
                src={logoProcStudio} 
                alt="Logotipo do ProcStudio" 
                class="h-48 w-auto mx-auto mb-6 animate-fade-in" 
              />
          <p class="text-2xl sm:text-3xl lg:text-4xl text-[#01013D] opacity-80 mb-4 font-light animate-fade-in-delay-1">
            Sistema em Desenvolvimento
          </p>
          <p class="text-lg sm:text-xl text-gray-600 mb-12 max-w-2xl mx-auto animate-fade-in-delay-2">
            Gerencie seus processos jurídicos de forma eficiente e moderna
          </p>

          <div class="flex flex-col sm:flex-row gap-4 justify-center items-center animate-fade-in-delay-3">
            <button 
              class="group relative px-8 py-4 bg-[#0277EE] text-white text-lg font-semibold rounded-xl overflow-hidden transition-all duration-300 hover:scale-105 hover:shadow-2xl hover:shadow-[#0277EE]/30 w-full sm:w-auto"
              on:click={() => router.navigate('/register')}
            >
              <span class="relative z-10">Começar agora</span>
              <div class="absolute inset-0 bg-gradient-to-r from-[#0277EE] to-[#01013D] opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            </button>
            <button 
              class="px-8 py-4 bg-transparent text-[#01013D] text-lg font-semibold rounded-xl border-2 border-[#01013D] transition-all duration-300 hover:bg-[#01013D] hover:text-white hover:scale-105 hover:shadow-xl w-full sm:w-auto"
              on:click={() => router.navigate('/login')}
            >
              Fazer login
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Features Section -->
    <section class="relative py-24 bg-gradient-to-b from-white to-[#eef0ef]/30">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-16">
          <h3 class="text-4xl sm:text-5xl font-bold text-[#01013D] mb-4">
            Funcionalidades
          </h3>
          <div class="w-24 h-1 bg-gradient-to-r from-[#0277EE] to-[#01013D] mx-auto rounded-full"></div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <!-- Card 1 -->
          <div class="group relative bg-white rounded-2xl p-8 shadow-lg hover:shadow-2xl transition-all duration-300 hover:-translate-y-2 border border-gray-100">
            <div class="absolute inset-0 bg-gradient-to-br from-[#0277EE]/5 to-transparent rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            <div class="relative">
              <div class="w-16 h-16 bg-gradient-to-br from-[#0277EE] to-[#01013D] rounded-xl flex items-center justify-center mb-6 text-3xl transform group-hover:scale-110 transition-transform duration-300">
                ⚖️
              </div>
              <h4 class="text-2xl font-bold text-[#01013D] mb-3">Gestão Jurídica</h4>
              <p class="text-gray-600 leading-relaxed">
                Controle completo de processos, prazos e documentos em uma única plataforma integrada.
              </p>
              <div class="mt-6 inline-flex items-center text-[#0277EE] font-semibold">
                <span>Em desenvolvimento</span>
                <svg class="w-5 h-5 ml-2 transform group-hover:translate-x-2 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"></path>
                </svg>
              </div>
            </div>
          </div>

          <!-- Card 2 -->
          <div class="group relative bg-white rounded-2xl p-8 shadow-lg hover:shadow-2xl transition-all duration-300 hover:-translate-y-2 border border-gray-100">
            <div class="absolute inset-0 bg-gradient-to-br from-[#0277EE]/5 to-transparent rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            <div class="relative">
              <div class="w-16 h-16 bg-gradient-to-br from-[#0277EE] to-[#01013D] rounded-xl flex items-center justify-center mb-6 text-3xl transform group-hover:scale-110 transition-transform duration-300">
                👥
              </div>
              <h4 class="text-2xl font-bold text-[#01013D] mb-3">Equipes</h4>
              <p class="text-gray-600 leading-relaxed">
                Colaboração eficiente com gestão de times, permissões e fluxos de trabalho personalizados.
              </p>
              <div class="mt-6 inline-flex items-center text-[#0277EE] font-semibold">
                <span>Em desenvolvimento</span>
                <svg class="w-5 h-5 ml-2 transform group-hover:translate-x-2 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"></path>
                </svg>
              </div>
            </div>
          </div>

          <!-- Card 3 -->
          <div class="group relative bg-white rounded-2xl p-8 shadow-lg hover:shadow-2xl transition-all duration-300 hover:-translate-y-2 border border-gray-100">
            <div class="absolute inset-0 bg-gradient-to-br from-[#0277EE]/5 to-transparent rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            <div class="relative">
              <div class="w-16 h-16 bg-gradient-to-br from-[#0277EE] to-[#01013D] rounded-xl flex items-center justify-center mb-6 text-3xl transform group-hover:scale-110 transition-transform duration-300">
                📊
              </div>
              <h4 class="text-2xl font-bold text-[#01013D] mb-3">Relatórios</h4>
              <p class="text-gray-600 leading-relaxed">
                Analytics avançados e relatórios personalizáveis para tomada de decisões estratégicas.
              </p>
              <div class="mt-6 inline-flex items-center text-[#0277EE] font-semibold">
                <span>Em desenvolvimento</span>
                <svg class="w-5 h-5 ml-2 transform group-hover:translate-x-2 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"></path>
                </svg>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Pricing Section -->
    <section class="relative py-24 bg-gradient-to-b from-[#eef0ef]/30 to-white">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-16">
          <h3 class="text-4xl sm:text-5xl font-bold text-[#01013D] mb-4">
            Nossos Planos
          </h3>
          <p class="text-xl text-gray-600 mb-8">
            Encontre o melhor plano de acordo com a necessidade do seu escritório.
          </p>
          <div class="w-24 h-1 bg-gradient-to-r from-[#0277EE] to-[#01013D] mx-auto rounded-full"></div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-8 lg:gap-12">
          <!-- Individual Plan -->
          <div class="group relative bg-white rounded-2xl overflow-hidden shadow-lg hover:shadow-2xl transition-all duration-300 hover:-translate-y-2 border border-gray-100">
            <div class="absolute inset-0 bg-gradient-to-br from-[#0277EE]/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            
            <div class="relative p-8 md:p-10">
              <div class="mb-6">
                <h4 class="text-3xl font-bold text-[#01013D] mb-2">Individual</h4>
                <p class="text-gray-600 mb-4">Advogado iniciante</p>
                <div class="flex items-baseline gap-2">
                  <span class="text-5xl font-bold text-[#0277EE]">Grátis</span>
                </div>
              </div>

              <div class="border-t border-b border-gray-200 py-8 mb-8 space-y-4">
                <div class="flex items-center gap-3">
                  <svg class="w-6 h-6 text-green-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
                  </svg>
                  <span class="text-gray-700 font-medium">Geração de Documentos</span>
                </div>
                <div class="flex items-center gap-3">
                  <svg class="w-6 h-6 text-green-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
                  </svg>
                  <span class="text-gray-700 font-medium">Gestão de Clientes</span>
                </div>
                <div class="flex items-center gap-3">
                  <svg class="w-6 h-6 text-green-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
                  </svg>
                  <span class="text-gray-700 font-medium">Gestão de Tarefas</span>
                </div>
                <div class="flex items-center gap-3">
                  <svg class="w-6 h-6 text-green-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
                  </svg>
                  <span class="text-gray-700 font-medium">Gestão de Trabalhos</span>
                </div>
              </div>

              <button
                class="w-full py-4 bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white font-bold rounded-xl transition-all duration-300 hover:scale-105 hover:shadow-lg transform"
                on:click={() => router.navigate('/register')}
              >
                Selecionar este plano
              </button>
            </div>
          </div>

          <!-- CNPJ Plan -->
          <div class="group relative bg-white rounded-2xl overflow-hidden shadow-lg hover:shadow-2xl transition-all duration-300 hover:-translate-y-2 border-2 border-[#0277EE]">
            <div class="absolute top-0 right-0 bg-gradient-to-br from-[#0277EE] to-[#01013D] text-white px-4 py-2 rounded-bl-lg">
              <span class="text-sm font-bold">Popular</span>
            </div>
            
            <div class="absolute inset-0 bg-gradient-to-br from-[#0277EE]/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            
            <div class="relative p-8 md:p-10">
              <div class="mb-6">
                <h4 class="text-3xl font-bold text-[#01013D] mb-2">CNPJ</h4>
                <p class="text-gray-600 mb-4">Advogado com CNPJ</p>
                <div class="flex items-baseline gap-2">
                  <span class="text-5xl font-bold text-[#0277EE]">R$ 70</span>
                  <span class="text-gray-600 text-lg">/mês</span>
                </div>
              </div>

              <div class="border-t border-b border-gray-200 py-8 mb-8 space-y-4">
                <div class="flex items-center gap-3">
                  <svg class="w-6 h-6 text-green-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
                  </svg>
                  <span class="text-gray-700 font-medium">Inclusão de uma sociedade</span>
                </div>
                <div class="flex items-center gap-3">
                  <svg class="w-6 h-6 text-green-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
                  </svg>
                  <span class="text-gray-700 font-medium">Acesso de Dois Advogados</span>
                </div>
                <div class="flex items-center gap-3">
                  <svg class="w-6 h-6 text-green-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
                  </svg>
                  <span class="text-gray-700 font-medium">Acesso de um membro equipe</span>
                </div>
                <div class="flex items-center gap-3">
                  <svg class="w-6 h-6 text-green-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
                  </svg>
                  <span class="text-gray-700 font-medium">Membros Adicionais <span class="text-[#0277EE] font-bold">R$ 15,00</span></span>
                </div>
              </div>

              <button
                class="w-full py-4 bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white font-bold rounded-xl transition-all duration-300 hover:scale-105 hover:shadow-lg transform"
                on:click={() => router.navigate('/register')}
              >
                Selecionar este plano
              </button>
            </div>
          </div>
        </div>

        <div class="mt-12 text-center">
          <p class="text-gray-600 text-lg">
            Precisa de um plano customizado?
            <a href="mailto:contato@procstudio.com" class="text-[#0277EE] font-semibold hover:text-[#01013D] transition-colors duration-300">
              Entre em contato
            </a>
          </p>
        </div>
      </div>
    </section>

    <!-- FAQ Section -->
    <section class="relative py-24 bg-white">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-16">
          <h3 class="text-4xl sm:text-5xl font-bold text-[#01013D] mb-4">
            Perguntas Frequentes
          </h3>
          <p class="text-xl text-gray-600 mb-8">
            Tire suas dúvidas sobre o ProcStudio
          </p>
          <div class="w-24 h-1 bg-gradient-to-r from-[#0277EE] to-[#01013D] mx-auto rounded-full"></div>
        </div>

        <div class="space-y-4">
          <!-- FAQ Item 1 -->
          <div class="group border border-gray-200 rounded-xl overflow-hidden hover:border-[#0277EE] transition-all duration-300">
            <button
              class="w-full px-6 py-5 text-left flex items-center justify-between bg-white hover:bg-gray-50 transition-colors duration-300"
              on:click={() => toggleFaq(0)}
            >
              <span class="text-lg font-semibold text-[#01013D] pr-8">Lorem ipsum dolor sit amet consectetur?</span>
              <svg
                class="w-6 h-6 text-[#0277EE] flex-shrink-0 transform transition-transform duration-300 {openFaq === 0 ? 'rotate-180' : ''}"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>
            <div class="overflow-hidden transition-all duration-300 {openFaq === 0 ? 'max-h-96' : 'max-h-0'}">
              <div class="px-6 py-5 bg-gray-50 border-t border-gray-200">
                <p class="text-gray-700 leading-relaxed">
                  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.
                </p>
              </div>
            </div>
          </div>

          <!-- FAQ Item 2 -->
          <div class="group border border-gray-200 rounded-xl overflow-hidden hover:border-[#0277EE] transition-all duration-300">
            <button
              class="w-full px-6 py-5 text-left flex items-center justify-between bg-white hover:bg-gray-50 transition-colors duration-300"
              on:click={() => toggleFaq(1)}
            >
              <span class="text-lg font-semibold text-[#01013D] pr-8">Adipiscing elit sed do eiusmod tempor?</span>
              <svg
                class="w-6 h-6 text-[#0277EE] flex-shrink-0 transform transition-transform duration-300 {openFaq === 1 ? 'rotate-180' : ''}"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>
            <div class="overflow-hidden transition-all duration-300 {openFaq === 1 ? 'max-h-96' : 'max-h-0'}">
              <div class="px-6 py-5 bg-gray-50 border-t border-gray-200">
                <p class="text-gray-700 leading-relaxed">
                  Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
                </p>
              </div>
            </div>
          </div>

          <!-- FAQ Item 3 -->
          <div class="group border border-gray-200 rounded-xl overflow-hidden hover:border-[#0277EE] transition-all duration-300">
            <button
              class="w-full px-6 py-5 text-left flex items-center justify-between bg-white hover:bg-gray-50 transition-colors duration-300"
              on:click={() => toggleFaq(2)}
            >
              <span class="text-lg font-semibold text-[#01013D] pr-8">Incididunt ut labore et dolore magna aliqua?</span>
              <svg
                class="w-6 h-6 text-[#0277EE] flex-shrink-0 transform transition-transform duration-300 {openFaq === 2 ? 'rotate-180' : ''}"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>
            <div class="overflow-hidden transition-all duration-300 {openFaq === 2 ? 'max-h-96' : 'max-h-0'}">
              <div class="px-6 py-5 bg-gray-50 border-t border-gray-200">
                <p class="text-gray-700 leading-relaxed">
                  Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.
                </p>
              </div>
            </div>
          </div>

          <!-- FAQ Item 4 -->
          <div class="group border border-gray-200 rounded-xl overflow-hidden hover:border-[#0277EE] transition-all duration-300">
            <button
              class="w-full px-6 py-5 text-left flex items-center justify-between bg-white hover:bg-gray-50 transition-colors duration-300"
              on:click={() => toggleFaq(3)}
            >
              <span class="text-lg font-semibold text-[#01013D] pr-8">Ut enim ad minim veniam quis nostrud?</span>
              <svg
                class="w-6 h-6 text-[#0277EE] flex-shrink-0 transform transition-transform duration-300 {openFaq === 3 ? 'rotate-180' : ''}"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>
            <div class="overflow-hidden transition-all duration-300 {openFaq === 3 ? 'max-h-96' : 'max-h-0'}">
              <div class="px-6 py-5 bg-gray-50 border-t border-gray-200">
                <p class="text-gray-700 leading-relaxed">
                  Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.
                </p>
              </div>
            </div>
          </div>

          <!-- FAQ Item 5 -->
          <div class="group border border-gray-200 rounded-xl overflow-hidden hover:border-[#0277EE] transition-all duration-300">
            <button
              class="w-full px-6 py-5 text-left flex items-center justify-between bg-white hover:bg-gray-50 transition-colors duration-300"
              on:click={() => toggleFaq(4)}
            >
              <span class="text-lg font-semibold text-[#01013D] pr-8">Exercitation ullamco laboris nisi aliquip?</span>
              <svg
                class="w-6 h-6 text-[#0277EE] flex-shrink-0 transform transition-transform duration-300 {openFaq === 4 ? 'rotate-180' : ''}"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>
            <div class="overflow-hidden transition-all duration-300 {openFaq === 4 ? 'max-h-96' : 'max-h-0'}">
              <div class="px-6 py-5 bg-gray-50 border-t border-gray-200">
                <p class="text-gray-700 leading-relaxed">
                  Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur.
                </p>
              </div>
            </div>
          </div>

          <!-- FAQ Item 6 -->
          <div class="group border border-gray-200 rounded-xl overflow-hidden hover:border-[#0277EE] transition-all duration-300">
            <button
              class="w-full px-6 py-5 text-left flex items-center justify-between bg-white hover:bg-gray-50 transition-colors duration-300"
              on:click={() => toggleFaq(5)}
            >
              <span class="text-lg font-semibold text-[#01013D] pr-8">Duis aute irure dolor in reprehenderit?</span>
              <svg
                class="w-6 h-6 text-[#0277EE] flex-shrink-0 transform transition-transform duration-300 {openFaq === 5 ? 'rotate-180' : ''}"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>
            <div class="overflow-hidden transition-all duration-300 {openFaq === 5 ? 'max-h-96' : 'max-h-0'}">
              <div class="px-6 py-5 bg-gray-50 border-t border-gray-200">
                <p class="text-gray-700 leading-relaxed">
                  At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident.
                </p>
              </div>
            </div>
          </div>
        </div>

        <div class="mt-12 text-center">
          <p class="text-gray-600 text-lg mb-4">
            Não encontrou sua resposta?
          </p>
          <a
            href="mailto:contato@procstudio.com"
            class="inline-flex items-center gap-2 text-[#0277EE] font-semibold hover:text-[#01013D] transition-colors duration-300"
          >
            <span>Entre em contato conosco</span>
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
            </svg>
          </a>
        </div>
      </div>
    </section>

    <!-- CTA Section -->
    <section class="relative py-20 bg-gradient-to-r from-[#01013D] to-[#0277EE] overflow-hidden">
      <div class="absolute inset-0 opacity-10">
        <div class="absolute transform rotate-45 -right-20 top-10 w-96 h-96 bg-white rounded-full"></div>
        <div class="absolute transform -rotate-45 -left-20 bottom-10 w-80 h-80 bg-white rounded-full"></div>
      </div>
      <div class="relative max-w-4xl mx-auto text-center px-4">
        <h3 class="text-4xl font-bold text-white mb-6">
          Pronto para transformar sua gestão jurídica?
        </h3>
        <p class="text-xl text-white/90 mb-8">
          Junte-se a nós e experimente uma nova forma de gerenciar processos
        </p>
        <button
          class="px-10 py-4 bg-white text-[#0277EE] text-lg font-bold rounded-xl hover:bg-[#eef0ef] transition-all duration-300 hover:scale-105 hover:shadow-2xl"
          on:click={() => router.navigate('/register')}
        >
          Começar gratuitamente
        </button>
      </div>
    </section>
  </div>
</MainLayout>

<style>
  @keyframes blob {
    0%, 100% {
      transform: translate(0, 0) scale(1);
    }
    33% {
      transform: translate(30px, -50px) scale(1.1);
    }
    66% {
      transform: translate(-20px, 20px) scale(0.9);
    }
  }

  .animate-blob {
    animation: blob 7s infinite;
  }

  .animation-delay-2000 {
    animation-delay: 2s;
  }

  .animation-delay-4000 {
    animation-delay: 4s;
  }

  @keyframes fade-in {
    from {
      opacity: 0;
      transform: translateY(20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  .animate-fade-in {
    animation: fade-in 0.8s ease-out;
  }

  .animate-fade-in-delay-1 {
    animation: fade-in 0.8s ease-out 0.2s both;
  }

  .animate-fade-in-delay-2 {
    animation: fade-in 0.8s ease-out 0.4s both;
  }

  .animate-fade-in-delay-3 {
    animation: fade-in 0.8s ease-out 0.6s both;
  }
</style>
