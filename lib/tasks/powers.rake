# frozen_string_literal: true
require 'bundler/setup'

namespace :cad do
  desc 'Power Creation'
    task power: :environment do

      def create_powers(power_descriptions, category)
        power_descriptions.each do |description|
          Power.create!(description: description, category: category)
        end
      end

      # Por favor note que antes de especificar os poderes teremos
      # o termo => "para:"
      # Please note before the powers we will have a term => "to:"

      # Administrative General Powers
      create_powers([
        "representar",
        "peticionar",
        "solicitar",
        "assinar",
        "dar ciência e retirar",
        "cópias de processos administrativos"],0)

      # Administrative Specific Powers
      # Not necessary in this stage
      # category => 1



      # Administrative Specific Prev Powers
      create_powers([
        "acessar documentos resguardados pelo sigilo médico independente do seu teor",
        "representar administrativamente - assinar, protocolar requerimentos, desistir de pedidos ou de benefícios, fazer carga de processos, ter vistas e acessar documentos bem como acesso digital, gerar, cadastrar e-mail, telefone e senhas nos portais Gov.br e Meu INSS",
        "buscar informações de titularidade de seus familiares falecidos para informação e instrução de seus pedidos pessoais",
        "buscar informações de titularidade de familiares em relação a dados cadastrais prisionais, para fins de concessão do benefício de auxílio reclusão",
        "Instituto Nacional do Seguro Social - INSS",
        "firmar e Declarar Imposto de Renda e Isenções",
        "RPPS - Regime Próprio de Previdência Municipal e Estadual ao qual o outorgante esteja vinculado",
        "acessar autos em segredo de justiça e relativos a direitos sucessórios e para obtenção de pensão por morte",
        "renunciar valores superiores à Requisições de Pequeno Valor (RPV) em Precatórios"],2)

      # Administrative Specific Powers Tributary
      create_powers([
        "representar, solicitar, assinar, dar ciência e retirar, cópias de processos administrativos",
        "cópia de processos administrativos de inscrição em dívida ativa",
        "negativas, protocolos, extratos de débitos, extrato de situação fiscal",
        "parcelamentos, extrato e saldo de parcelamentos, cópias de documentos",
        "pedidos de ressarcimentos e restituições",
        "pedido de ajuste de guia",
        "restrições de pessoa física, empresas e imóveis",
        "petições e requerimentos de qualquer natureza e demais documentos necessários para a liberação da competente certidão negativa de débitos (CND)",
        "certidão positiva com efeitos de negativa (CPD-EN)",
        "alvará",
        "auto de infração",
        "notificação de lançamento",
        "termo de confissão de dívida",
        "serviços previdenciários disponibilizados na internet e presencialmente pela SECRETARIA DA RECEITA FEDERAL DO BRASIL, PREVIDÊNCIA SOCIAL, PROCURADORIA GERAL DA FAZENDA NACIONAL",
        "extrato de contribuições de funcionários domésticos, REDARF’s",
        "pedido de revisão de débito confessado em GFIP (DCG/LDCG)",
        "retificações de DARF, DCTFs e Speds",
        "acessar autos em segredo de justiça",
        "ajuste de GPS, DBE"],
        3)

      # Administrative Specific Powers Tributary ECAC
      create_powers([
        "acesso caixa postal",
        "downloads speds (contábil/contribuições/icms ipi)",
        "pagamentos e parcelamentos (consulta comprovantes) ",
        "transmissão de declarações",
        "declarações e demonstrativos (extrato dctf e cópia de declaração)",
        "todas opções Restituição e Compensação (perdcomp)",
        "certidões e consultas fiscais",
        "dívida ativa da União",
        "PGFN - Consulta débitos inscritos a partir de 01/11/2012",
        "Sief Cobrança - intimações DCTF",
        "acessar Per/Dcomp Web",
        "comunicação para compensação de ofício"],4)

      # Law Specific Crime
      create_powers([
        "Acompanhamento em Inquérito Policial",
        "Defesa Criminal",
        "Acessar autos criminais",
        "Realizar Queixa Crime",
        "Acessar Autos em Segredo de Justiça",
        "comunicação para compensação de ofício"],8)

      # Substabelecer
      create_powers([
        "Substabelecer, com ou sem reserva de poderes"],10)


    end

  end
