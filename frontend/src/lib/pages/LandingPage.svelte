<script lang="ts">
  import MainLayout from '../components/MainLayout.svelte';
  import { router } from '../stores/routerStore';
  import logoProcStudio from '../../assets/procstudio_logotipo_vertical_sem_fundo.png';

  let openFaq: number | null = null;

  const toggleFaq = (index: number) => {
    openFaq = openFaq === index ? null : index;
  };

  const faqs = [
    {
      question: "O ProcStudio tem inteligência artificial?",
      answer: "Ainda não oferecemos funcionalidades de IA, mas estamos planejando implementar diversas opções de inteligência artificial que se integrarão naturalmente ao fluxo de trabalho diário do seu escritório, tornando suas rotinas ainda mais eficientes."
    },
    {
      question: "O ProcStudio oferece assinatura eletrônica?",
      answer: "No momento, não temos suporte para assinatura eletrônica. Porém, em breve implementaremos essa funcionalidade de forma nativa e através de integração com APIs de provedores reconhecidos do mercado."
    },
    {
      question: "O ProcStudio tem plano gratuito?",
      answer: "Sim! Nosso plano Básico é totalmente gratuito e ideal para advogados iniciantes ou profissionais autônomos. Ele inclui:<br>- Cadastro de clientes<br>- Criação de trabalhos e tarefas<br>- Geração de documentos<br><br>Observação: O plano gratuito possui limites de uso para essas funcionalidades."
    },
    {
      question: "É possível adicionar membros no plano gratuito?",
      answer: "Sim! Você pode incluir membros adicionais ao plano por apenas R$ 15,00 por membro/mês."
    },
    {
      question: "Qual a diferença entre o plano gratuito e o plano pago?",
      answer: "A principal diferença está nos limites de uso:<br><br><strong>Plano Básico (Gratuito):</strong><br>- Limites restritos para criação de documentos, trabalhos, tarefas e clientes<br>- Ideal para advogados autônomos<br><br><strong>Plano Pro (Pago):</strong><br>- Limites expandidos para todas as funcionalidades<br>- Cadastro de advogados com sociedades<br>- Recursos avançados para escritórios em crescimento"
    },
    {
      question: "O ProcStudio permite múltiplos usuários com diferentes permissões?",
      answer: "Ainda não, mas estamos trabalhando nisso! Planejamos implementar a criação de perfis diferenciados para paralegais, estagiários, secretárias e advogados, cada um com suas permissões específicas."
    },
    {
      question: "O ProcStudio trabalha com controle de prazos processuais?",
      answer: "No momento, essa funcionalidade ainda não está disponível. Entendemos que muitos advogados já controlam seus prazos diretamente nos sistemas judiciais, mas em uma implementação futura pretendemos incluir um sistema completo de gestão de prazos processuais."
    },
    {
      question: "O ProcStudio possui integração com tribunais?",
      answer: "Ainda não temos integração direta com os sistemas dos tribunais. Porém, estamos desenvolvendo uma extensão de navegador para alguns tribunais que permitirá trabalhar de modo mais fluido com os sistemas judiciais, facilitando a captura e organização de informações processuais."
    },
    {
      question: "O ProcStudio permite a criação de documentos?",
      answer: "Sim! Esta é uma das funcionalidades principais do sistema. Você pode gerar automaticamente:<br>- Procurações<br>- Contratos<br>- Declarações e Termos, por exemplo declaração de carência e termo de renuncia<br>- Contratos sociais (para criação de sociedades de advogados)<br><br>Enfim, nosso foco é suprir automação para os documentos mais utilizados na prática advocatícia.<br><br><strong>Futuro:</strong> Planejamos expandir ainda mais, incluindo petições, recursos e outros documentos essenciais para a advocacia."
    },
    {
      question: "Como funciona a geração de documentos?",
      answer: "O sistema utiliza templates pré-definidos no formato DOCX que são automaticamente preenchidos com as informações inseridas por você no sistema. Basta cadastrar os dados necessários (cliente, partes envolvidas, dados contratuais, área de atuação etc.) e o ProcStudio gera o documento completo, pronto para uso."
    },
    {
      question: "Existe programa de indicações?",
      answer: "Sim! O ProcStudio possui um programa de indicações. Quando você indicar outro usuário e ele contratar o Plano Pro, você ganhará um mês gratuito de acesso."
    },
    {
      question: "Tem suporte ao financeiro do escritório?",
      answer: "Temos algumas ferramentas que podem ajudar no seu financeiro, como especificações de honorários, indicações, divisão de honorários, organização da sociedade com distribuição de lucros ou não, retirada de pro-labore. Porém ainda não temos o módulo específico financeiro, o que será criado em uma implementação futura."
    }
  ];
</script>

<MainLayout>
  <div class="relative overflow-hidden">
    <!-- Hero Section -->
    <div class="relative min-h-[80vh] flex items-center">
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
          {#each faqs as faq, index}
            <div class="group border border-gray-200 rounded-xl overflow-hidden hover:border-[#0277EE] transition-all duration-300">
              <button
                class="w-full px-6 py-5 text-left flex items-center justify-between bg-white hover:bg-gray-50 transition-colors duration-300"
                on:click={() => toggleFaq(index)}
              >
                <span class="text-lg font-semibold text-[#01013D] pr-8">{faq.question}</span>
                <svg
                  class="w-6 h-6 text-[#0277EE] flex-shrink-0 transform transition-transform duration-300 {openFaq === index ? 'rotate-180' : ''}"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              <div class="overflow-hidden transition-all duration-300 {openFaq === index ? 'max-h-[500px]' : 'max-h-0'}">
                <div class="px-6 py-5 bg-gray-50 border-t border-gray-200">
                  <p class="text-gray-700 leading-relaxed">
                    {@html faq.answer}
                  </p>
                </div>
              </div>
            </div>
          {/each}
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