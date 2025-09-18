# ProcStudio
## Backend
API RESTful desenvolvida em Ruby on Rails para o sistema ProcStudio.

## Frontend
Svelte 5.0

## Índice - Updated

- [Visão e Evolução do Projeto](#visão-e-evolução-do-projeto)
  - [Modelo de Negócios](#modelo-de-negócios)
  - [Declaração de Missão](#declaracao-de-missao)
  - [Princípios](#princípios)
      - [Usuário e Aprendizado](#usuário-e-aprendizado-com-o-usuário)
      - [Zero Papel](#zero-papel)
      - [Mobilidade](#mobilidade)
      - [Integração](#integração)
      - [Público Alvo](#público-alvo)
      - [Customização](#customização-pelo-usuário)
      - [Atendimento automatizado](#atendimento-automatizado)

- Prototipagem
  - [Prototipagem e Figma](#prototipagem-e-figma)

### Ferramentas e Recursos
- [Arquivos](#arquivos-compartilhados)
- [Helpers](#helpers)
- [FakeFiller](#formulários)
- [Senhas](#senhas)
- [Domínios e Registros](#domínios-e-registros)
- [Pagamentos](#pagamentos)
- [Desafios](#desafios)
- [Docx](#docx)

### Documentação Técnica

- API Interna
  - [API](./docs/API.md)

- API Externa
  - [Cep e Wap](./docs/external-api-cep-wap.md)
  - [Legal Data](./docs/external-api-legal_data.md)

- User Auth & Register
  - [Authentication](./docs/Auth.md)
  - [Users](./docs/User.md)
  - [User Registration](./docs/User-Registration.md)
  - [User Profile Completion](./docs/User-Profile-Completion.md)
  - [Avatar Upload Backend](./docs/User-Avatar-Upload-Backend.md)

- Políticas de Autorização de Usuário
  - [Policies](./docs/Policies.md)

- SuperAdmin
  - [SuperAdmin](./docs/Super-Admin.md)

- Teams and Offices
  - [Teams](./docs/Team.md)
  - [Office](./docs/Office.md)

- Notificações
  - [Notificações Backend](./docs/Notifications-backend.md)
  - [Notificações Frontend](./docs/Notifications-frontend.md)

- Background Jobs
  - [SideKick](./docs/SideKick.md)

- Deletion Policies - Políticas de Deletação
  - [Deletion](./docs/Deletion.md)

- Compliance System
  - Será um sistema para verificação de conformidade do sistema com relação aos clientes, jobs, works, honorários etc. Atualmente temos dois arquivos no ./brpl que precisarão ser revistos em momento oportuno. Neste primeiros códigos teve um pequeno sistema de notificações específico para as verificações de conformidade que serão integrados com o sistema de notificação definitivo.

- Draft System - Rascunhos
  - [Draft](./docs/Draft.md)

- Job
  - [Job](./docs/Job.md)

- Customer
  - [Customer & ProfileCustomer](./docs/Customer.md)

- Work
  - [Power](./docs/Power.md)
  - [Work](./docs/Work.md)
    - [Work Endpoints](./docs/Work-Endpoints.md)
    - [Work - Honoraries & Legal Costs](./docs/Work-Honoraries-LegalCosts.md)
      - [Work - Honoraries & Legal Costs Examples](./docs/Work-Honoraries-LegalCosts-examples.md)
    - [Work Procedures](./docs/Work-Procedures.md)
      - [Work Procedures Migration](./docs/Work-Procedures-migration.md)

- Active Storage e Amazon S3
  - [S3](./docs/s3.md)

- DB issues
  - [Polimorphic Tables](./docs/Polimorphic-Tables.md)

## Frontend
- Learning and Svelte
  - [Dragable](./docs/frontend-dragable.md)
  - [Types e JSON Conversion](./docs/frontend-json-to-types.md)
  - [Debugging](./docs/frontend-svelte-debugging.md)
  - [Filters and Lists](./docs/frontend-filters-and-lists.md)
  - [MCP](./docs/frontend-svelte-mcp.md)
  - [Virtual List](./docs/frontend-svelte-virtual-list.md)
  - [Draft Helper](./docs/frontend_draft_helper.js)

### Frontend - Components and Forms
- [Forms and Decoupling](./docs/frontend-forms-and-decoupling.md)
- Forms Specific:
  - [CNPJ](./docs/frontend-cnpj.md)

## Testes
- [Tests](./docs/Test.md)

## Instalação e Início
- [Instalacão](./docs/Instalação.md)

### Desenvolvimento
- [Padrão de Desenvolvimento](./docs/code-padrao.md)
- [Padrão de Desenvolvimento com IA](./docs/code-padrao-ia.md)
- [Guia de Contribuição](./docs/code-contribuicao.md)
- [Regras de Linting](./docs/code-linting.md)
- [Troubleshooting](./docs/code-troubleshooting.md)

## Deploy
- [Deploy](./docs/Deploy.md)

## Monitoramento
- [Monitoramento](./docs/Monitoramento.md)

---

## Visão e Evolução do Projeto

### Modelo de Negócios
https://youtu.be/XqIycze_D2c

### Declaração de Missão
O ProcStudio foi concebido para revolucionar como advogados geram documentos legais, transformando um processo tradicionalmente complexo e demorado em um fluxo de trabalho simplificado e eficiente, desta forma...

> Devemos sempre pensar na experiência do usuário em primeiro lugar como a matriz principal do negócio

O sistema deve facilitar a vida do usuário advogado e também dos seus clientes, que serão também usuários secundários do nosso sistema, independente dos caminhos tecnológicos que tenhamos que seguir.

A ideia do sistema surgiu a partir da necessidade prática de evitar trabalhos repetitivos e aprimorar o fluxo de trabalho para o advogado e sua equipe com a ideia central de geração de documentos de forma automatizada, porém, com a criação de documentos, vem uma série de requisitos como cadastro do usuário e dados relacionados a tarefas, trabalhos, processos e requisitos afins essenciais para o bom desenvolvimento do trabalho do advogado.

O documento mais utilizado em um escritório é a Procuração. Este é o documento que permite a atuação do advogado em favor do seu cliente, daí no nome ProcStudio. Outros documentos muito utilizados são: Contrato de Honorários, Termo de Renúncia do Juizado Especial de Pequenas Causas e Declaração de Carência.

Esses são os documentos básicos que estão no sistema. O objetivo é implementar todos esses documentos de acordo com as particularidades de cada área de atuação do direito e no futuro implementar outros documentos mais avançados que permitirão ao advogado uma facilidade extra no fluxo do seu trabalho, como por exemplo contratos em geral e petições.

A plataforma atende à necessidade crítica dos advogados de produzir tanto documentos individuais simples quanto no futuro, a geração em massa de documentos (V?), mantendo a precisão legal e conformidade.

### Princípios
1. Usuário em primeiro lugar + Aprendizado com o usuário
2. Zero Papel
3. Mobilidade
4. Integração
5. Customização pelo usuário
6. Atendimento Automatizado

#### Usuário e Aprendizado com o Usuário

Devemos ter noção de que o direito, como um ramo muito extenso, possui particularidades mesmo na geração de pequenos documentos. Um advogado que atua mais na área empresarial por exemplo, utilizará pouco o Termo de Renúncia e a Declaração de Carência, enquanto que, um criminalista também precisará de documentos diferentes, com poderes específicos e termos diversos, o que mesmo com toda a inteligência artificial disponível não será possível prever.

Assim, ao invés de reclamarmos que o usuário está pedindo uma customização vamos aproveitar o feedback gratuito para gerar essa customização e abarcar todo um grupo de usuários como por exemplo no ramo do direito administrativo por exemplo.

#### Zero Papel

Um dos princípios defendidos pelo ProcStudio é a adoção de ZERO papel no escritório do advogado e isso não é tão fácil como parece. É muito mais fácil imprimir uma procuração e entregar para o cliente assinar do que utilizar uma complexo sistema de identificação e assinatura digital, especialmente se ele estiver na sua frente, no seu escritório, conseguiu imaginar a situação?

Para isso, precisamos criar sistemas de assinatura muito fluídos, para que seja um processo cômodo, seguro, arquivável com segurança e fácil de ser acessado posteriormente tanto pelo nosso usuário advogado como para outros usuários.

Além da geração de documentos, instituir uma política de zero papel no escritório também é difícil por conta dos documentos físicos existentes (e persistentes), que precisam ser digitalizados e tratados, o que muitas vezes, por comodidade, acaba “ficando no escritório” até durante anos.

Desta forma, devemos auxiliar nosso usuário também na digitalização de documentos, o que é uma implementação também necessária em um escritório. Devemos adotar tecnologias modernas de digitalização, indexação, arquivamento para facilitar esse objetivo comum.

#### Mobilidade
Nossa meta também é a criação de aplicativos móveis capazes de dar o mesmo conforto na geração de documentos, hoje não podemos pensar no desenvolvimento sem pensar também no aspecto de mobilidade.

O objetivo é que o advogado possa gerar um contrato de forma “Instantânea” onde quer que ele esteja. Está em uma reunião com um cliente? Basta pegar os dados pessoais, digitar, tirar uma foto de dois ou três documentos que o cliente receberá em seu celular uma notificação (geralmente através de e-mail ou whatsapp) para assinar o referido documento.

#### Integração
Um dos nossos nortes é também comunicação com outros aplicativos através de API, tornando-se um sistema capaz de adotar os serviços mais conhecidos atualmente como Google Cloud, Microsoft e Dropbox.

Não queremos reinventar a roda. Por exemplo, seria muito mais fácil fazer a geração dos documentos diretamente em PDF. Existem centenas de ferramentas que fazem isso com base em qualquer tipo de informação, do HTML até bancos de dados mais complexos.

Mais fácil para nós, porém, melhor para o cliente? Com certeza não, porque o DOCX é um formato universal utilizado há décadas que está enraizado na cultura brasileira. E não podemos ser arrogantes ao ponto de pensar que o documento será gerado de forma tão perfeita que não será necessária uma revisão final, e quem melhor do que o próprio advogado que gera o documento para avaliar e entender se aquele documento está apto a ser assinado por todas as partes?

#### Público Alvo
Nosso foco é entre um advogado iniciante e intermediário, geralmente que trabalha de forma autônoma, com parceiros advogados e/ou contadores, uma secretária e um estagiário ou somente um dos dois.

Não necessariamente teremos um serviço de armazenamento em nuvem, porém, em certa medida a tendência é que seja necessário uma quantidade grande de armazenamento mesmo em razão da geração dos documentos e seu armazenamento e formas de autenticação e confiabilidade.

Neste sentido, precisamos otimizar os arquivos de PDF de forma fluída, sem necessidade de intervenção do usuário, bem como adicionar leitura de OCR e até em um futuro a geração de cadastros e documentos com base em OCR, o que tem sido facilitado com a carteira de motorista digital e o cadastro Gov.Br (biblioteca de OCR em desenvolvimento).

A ideia é encontrar um advogado que esteja procurando uma forma de se organizar melhor no seu escritório e ajuda-lo nesta busca oferecendo os serviços do ProcStudio.

#### Customização pelo usuário
Precisamos de um sistema dinâmico que o usuário possa ajudar a construir e criar por si mesmo, não dependendo tanto de atualizações dos desenvolvedores para adaptação de suas necessidades particulares, o que é possível observar como tendência de grandes aplicativos como Trello, Monday e outros semelhantes.

Essa ajuda do usuário também será sempre fundamental para melhorias e o crescimento do sistema, temos muito a aprender com advogados espalhados por todo o Brasil.

#### Atendimento automatizado
Um dos nossos maiores gargalos iniciais é o atendimento e conforto do usuário. Uma forma de atendê-los de forma personalizada é o ideal, porém, no momento inicial, ainda inviável, de forma que precisamos pensar em soluções de atendimento ao usuário de baixo custo, como a criação de Wikis e ChatBots para tirar as dúvidas mais comuns e entender os pontos de atrito entre o usuário e o sistema.

## Prototipagem e Figma

Acabamos abandonando a prototipagem pelo figma, ao invés disso é melhor abrir um repositório a parte ou uma branch para validação instruindo a IA a realizar os códigos de frontend isolados que o ganho de produtividade será [x1000](https://www.linkedin.com/pulse/prototipagem-1000x-revolucionando-o-design-de-com-ia-pellizzetti-qwpuf/?trackingId=FmVefBY3qSqmpju6nviBhQ%3D%3D), confira neste respositório a [prototipagem básica do sistema](https://github.com/brpl20/prc_admin-fe).

## Arquivos compartilhados
- Temos uma pasta compartilhada no google drive em que teremos:
  - identidade visual => `/prc-identidade-visual

## Helpers

Como usamos muito os Modelos do Rails, criei esse helper para facilitar a sua visualização. atualmente ele pega todos os campos do modelo e organiza para nós com o seu tipo, identificando também as relações do modelo, para funcionar rode o seguinte comando:

- `rails runner public/brpl/model_explorer.rb UserProfile`

Ele ira gerar um arquivo na documentação: `./docs/models` sobre o modelo.


### Formulários
Use a extensão [fakefiller](https://fakefiller.com/) para preencher formulários mais rapidamente e os helpers de CPF e CNPJ para criar esses campos de forma válida.

- CPF Generator: Gerador de CPF válido para formulários;
  - `test/helpers/cpf.js`
- CNPJ Generator: Gerador de CNPJ válido para formulários;
  - `test/helpers/cnpj.rb`

## Senhas
- Bitwarden

## Domínios e Registros
- PROCSTUDIO.APP.BR
- PROCSTUDIO.BLOG.BR
- PROCSTUDIO.COM.BR => Principal
- PROCSTUDIOAI.COM.BR => Principal ProcStudioAI
- PROCSTUDIOIA.COM.BR

---


## Pagamentos
Vamos utilizar Stripe que tem boa integração com o Ruby e já temos conta cadastrada.

## Desafios
- Reduzir o PDF  para caber em uma única página quando ocupar pouco mais de um parágrafo na segunda folha: arquivos de Word podem mudar de formatação e não serem muito precisos, especialmente quando convertermos em PDF, o que pode gerar um documento desagradável, ruim, deixando por exemplo apenas uma assinatura na segunda folha.
- Melhorar o sistema de deletação e arquivamento, combinar com regras de LGPD e anonimização.

## Docx
- Usamos a GEM [ruby-docx](https://github.com/ruby-docx/docx) para lidar com arquivos Docx, porém demos uma atualizada nela para corrigir alguns bugs e implementar outras funcionalidades. Como o arquivo Docx é muito chato de lidar, poderemos utilizar outros recursos como APIs internas, assim podemos utilizar todas as ferramentas em qualquer linguagem: Python, Node para conseguirmos o resultado ideal com esse formato de arquivo.

Arquivos de teste locais estão em `./docx`

Nosso fork está em: [https://github.com/brpl20/ruby-docx](https://github.com/brpl20/ruby-docx)
