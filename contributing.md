# Instruções para contribuir no projeto


As intruções de instalação e coniguração do sistema se encontram no readme.md

## Convenções

A motivação para criarmos convenções de desenvolvimento veio da necessidade de linkar as issues com os commits e com os pull requests.

### Branches

Para contribuir no projeto, após instalado, certifique-se de estar na branch `master` antes de iniciar um novo ticket e partir dela crie uma nova branch com a numeração do ticket escolhido para desenvolver, exemplo:

Ticket #123 - Cria algo no sistema

Ver branch atual e alterações realizadas:

```git status```

Após executar no terminal você deve receber a resposta `On branch master`

Criando a nova branch

```git checkout -b re123```

### Commits

Para commitar sual alterações no projeto use o seguinte padrão:

`RE #numero do ticket`, exemplo: `RE #123 - Altera isso e aquilo`

### Pull Requests

Considerando que o ticket foi finalizado, após commitar tudo que foi feito abra uma solicitação de pull request para a branch `master` com o seguinte nome:

```RE#numero_do_ticket``` exemplo: ```RE#123```

Depois do Pull Request criado, retorne para a branch `master` antes de iniciar o próximo ticket.

### Visão geral

 - Ticket: #123
 - Brach: re123
 - Commit: RE #123 - Altera isso e aquilo
 - Pull Request: RE #123

### Rubocop

É necessário instalar localmente as gems:
 - rubocop
 - rubocop-rails
 - rubocop-rspec

`bundle exec rubocop` executa a verificação de arquivos em todo o sistema

`bundle exec rubocop <arquivo>` _executa rubocop e exibe ocorrências no arquivo_

`bundle exec rubocop <arquivo> -a` _executa rubocop, exibe e corrige ocorrências no arquivo_ (não muito recomendado)

`bundle exec rubocop -C false --auto-gen-config --exclude-limit 10000` _atualiza rubocop_todo.yml, usar em casos de conflitos de merge e/ou ajustes de
ocorrências já existentes_ verificar a necessidade antes de executar este comando

### Observação
O comentário no topo de todos os arquivos rb # frozen_string_literal: true é um comentário mágico, suportado pela primeira vez no Ruby 2.3, que informa ao Ruby que todas as strings literais no arquivo estão implicitamente congeladas, como se #freeze tivesse sido chamado em cada uma delas, ou seja, se uma string literal for definida em um arquivo com este comentário e você chamar um método nessa string que a modifique, como <<, você obterá RuntimeError: can't modify frozen String.
