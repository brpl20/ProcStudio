# frozen_string_literal: true

require 'bundler/setup'

namespace :cad do
  desc 'Power Creation'
  task power: :environment do
    def create_powers(_description, power_descriptions, category)
      power_descriptions.each do |description|
        Power.create!(description: description, category: category)
      end
    end

    # Por favor note que antes de especificar os poderes teremos
    # o termo => "para:"
    # create_powers("Procedimento Administrativo - Assunto: Administrativo", [ "Fazer isso ou aquilo ..." ], 0)

    # enums category:
    #    admgeneral: 0,
    #    admspecific: 1,
    #    admspecificprev: 2,
    #    admspecifictributary: 3,
    #    admspecifictributaryecac: 4,
    #    lawgeneral: 5,
    #    lawsprev: 6,
    #    lawstributary: 7,
    #    lawspecificcrime: 8,
    #    extrajudicial: 9,
    #    subs: 10,

    # Procedimento Administrativo
    create_powers(
      'Procedimento Administrativo - Poderes Gerais',
      [
        'representar',
        'peticionar',
        'solicitar',
        'assinar',
        'recorrer',
        'desistir',
        'dar ciência',
        'retirar',
        'requerer',
        'criar senhas e consultar dados de acesso',
        'copiar processos'
      ],
      0
    )

    create_powers(
      'Procedimento Administrativo - Assunto: Previdenciário',
      [
        'acessar documentos resguardados pelo sigilo médico independente do seu teor',
        'preencher e assinar autodeclaração rural',
        'representar administrativamente - assinar, protocolar requerimentos, desistir de pedidos ou de benefícios, fazer carga de processos, ter vistas e acessar documentos bem como acesso digital, gerar, cadastrar e-mail, telefone e senhas nos portais Gov.br e Meu INSS',
        'buscar informações de titularidade de seus familiares falecidos para informação e instrução de seus pedidos pessoais',
        'buscar informações de titularidade de familiares em relação a dados cadastrais prisionais, para fins de concessão do benefício de auxílio reclusão',
        'Instituto Nacional do Seguro Social - INSS',
        'firmar e Declarar Imposto de Renda e Isenções',
        'RPPS - Regime Próprio de Previdência Municipal e Estadual ao qual o outorgante esteja vinculado',
        'acessar autos em segredo de justiça e relativos a direitos sucessórios e para obtenção de pensão por morte',
        'renunciar valores superiores à Requisições de Pequeno Valor (RPV) em Precatórios'
      ],
      2
    )

    create_powers(
      'Procedimento Administartivo - Assunto: Tributário',
      [
        'cópia de processos administrativos de inscrição em dívida ativa',
        'negativas, protocolos, extratos de débitos, extrato de situação fiscal',
        'parcelamentos, extrato e saldo de parcelamentos, cópias de documentos',
        'pedidos de ressarcimentos e restituições',
        'pedido de ajuste de guia',
        'restrições de pessoa física, empresas e imóveis',
        'petições e requerimentos de qualquer natureza e demais documentos necessários para a liberação da competente certidão negativa de débitos (CND)',
        'certidão positiva com efeitos de negativa (CPD-EN)',
        'alvará',
        'auto de infração',
        'notificação de lançamento',
        'termo de confissão de dívida',
        'serviços previdenciários disponibilizados na internet e presencialmente pela SECRETARIA DA RECEITA FEDERAL DO BRASIL, PREVIDÊNCIA SOCIAL, PROCURADORIA GERAL DA FAZENDA NACIONAL',
        'extrato de contribuições de funcionários domésticos, REDARF’s',
        'pedido de revisão de débito confessado em GFIP (DCG/LDCG)',
        'retificações de DARF, DCTFs e Speds',
        'acessar autos em segredo de justiça',
        'ajuste de GPS, DBE'
      ],
      3
    )

    create_powers(
      'Procedimento Administrativo - Assunto: Tributário - ECAC',
      [
        'acesso caixa postal',
        'downloads speds (contábil/contribuições/icms ipi)',
        'pagamentos e parcelamentos (consulta comprovantes) ',
        'transmissão de declarações',
        'declarações e demonstrativos (extrato dctf e cópia de declaração)',
        'todas opções Restituição e Compensação (perdcomp)',
        'certidões e consultas fiscais',
        'dívida ativa da União',
        'PGFN - Consulta débitos inscritos a partir de 01/11/2012',
        'Sief Cobrança - intimações DCTF',
        'acessar Per/Dcomp Web',
        'comunicação para compensação de ofício'
      ],
      4
    )

    # Judicial
    create_powers(
      'Procedimento Judicial: Geral',
      [
        'Foro em geral, contidos na cláusula ad judicia et extra',
        'representar órgãos públicos e privados',
        'receber citação',
        'confessar',
        'reconhecer a procedência do pedido',
        'transigir',
        'indicar e-mail para notificações',
        'firmar compromissos e acordos',
        'desistir do processo e incidentes',
        'renunciar ao direito o qual se funda a ação',
        'receber e dar quitação',
        'firmar declaração de imposto de renda',
        'assinar declaração de hipossuficiência ecdnômica e termo de renúncia para fins de Juizado Especial',
        'renunciar valores superiores à Requisições de Pequeno Valor em Precatórios',
        'substabelecer com ou sem reserva de poderes'
      ],
      5
    )

    create_powers(
      'Procedimento Judicial - Assunto: Previdenciário',
      [
        'ingressar com Mandado de Segurança'
      ],
      6
    )

    create_powers(
      'Procedimento Judicial - Assunto: Criminal', 
      [
        'Acompanhamento em Inquérito Policial',
        'Defesa Criminal',
        'Acessar autos criminais',
        'Realizar Queixa Crime',
        'Acessar Autos em Segredo de Justiça',
        'comunicação para compensação de ofício'
      ],
      8
    )

    create_powers(
      'Procedimento Extrajudicial - Geral', 
      [
        'peticionar',
        'solicitar',
        'assinar',
        'recorrer',
        'desistir',
        'dar ciência',
        'retirar',
        'requerer',
        'criar senhas e consultar dados de acesso',
        'copiar processos',
        'notificar',
        'cobrar'
      ],
      9
    )
  end
end
