[Back](../README.md)
* Não confundir com a pasta `app/jobs` que tratam de background tasks to Rails.

# Job - Tarefa

A ideia central deste Modelo é criar uma forma simples e rápida dos usuários criarem `Tarefas` em geral para ajudar no seu dia a dia. Apesar do nosso sistema ser voltado para o público do direito, precisamos manter uma certa liberdade na criação de tarefas simples que não precisam ser vinculadas nem a um Cliente específico e nem a um Trabalho específico.

Isso acontece porque muitas vezes não queremos nos dar ao trabalho de fazer um cadastro tão grande de um cliente que pode nem sequer irá realmente fechar um negócio com o escritório.

A ideia central é seguir um sistema genérico como o Monday ou Trello por exemplo em que você tem uma liberdade maior para gerar as obrigações e cards, movendo e deletando-os facilmente sem praticamente qualquer restrição.

## Campos
- Descrição: Descrição da tarefa
- Deadline: Data de entrega
- Status: Status { pending, in_progress, completed, cancelled }
- Priority: Prioridade { low, medium, high, urgent }

## Relacionamentos

Por outro lado o Jobs também pode ser sim relacionado com outros modelos, como o Work ou o Cliente. Isso garante uma maior precisão do trabalho e contexto para o advogado que estará trabalhando no sistema.

## Notificações

O Job terá muitos relacionamentos com notificações entre usuários, isso facilita na sua rotina de troca de informações, usaremos um sistema de menções que permitirá esse trabalho.

## Chat

Existirá uma forma de comunicação entre cada Job, não será uma conversa estilo WhatsApp, mas um modelo mais ou menos como fórum, de forma asíncrona, permitindo que os usuários troquem informações sobre cada job individualmente.

## Arquivos

Ainda pendente de criar um sistema que permita o upload de arquivos para os Jobs, facilitando também o trabalho entre usuários.
