# Cnpj.svelte — Usage Guide

`frontend/src/lib/components/forms_commons/Cnpj.svelte`

A ideia do Cnpj.svelte é ser apenas um exemplo de como configurar componentes individuais para serem utilizados por toda a plataforma, seguindo o conceito de:

> Componentes => Wrappers => Pages

A ideia é que a Pages tenha o mínimo de código e lógica possível, sendo fácil portanto para criarmos as metodologias de autorização e restrição de visualizações de acordo com as políticas de uso do sistema.

## Padrão de Required Field e Validação
O CNPJ pode ser requerido ou não na criação de um escritório por exemplo. Se for um novo escritório não teremos o CNPJ ainda, agora se o usuário quiser cadastrar um escritório que já existe ele terá esse número em mãos.

Então percebemos que os campos requeridos nem sempre são requeridos em todos os momentos, assim é preciso que seja possível escolher seu critério `required` e consequentemente `validação`.

Então podemos ter um elemento que é `required={false}` em uma page mas `required` em outra, bem como os critérios de validação também podem ser diferentes.

Por padrão a validação do CNPJ não ocorrerá em campos vazios, mas é importante também que o campo seja bloqueado, utilizando `disabled={true}`.
