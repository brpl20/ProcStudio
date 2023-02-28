# Instruções para contribuir no projeto


As intruções de instalação e coniguração do sistema se encontram no readme.md

## Convenções

Aqui descrevemos algumas convenções que adotamos para melhor gerir o projeto.

### Branches

Para contribuir no projeto, após instalado, certifique-se de estar na branch `master` antes de iniciar um novo ticket e partir dela crie uma nova branch com a numeração do ticket escolhido para desenvolver, exemplo:

Ticket #123 - Cria algo no sistema

Ver branch atual e alterações realizadas:

```git status``` 

Após executar no terminal você deve receber a resposta `On branch master`

Criando a nova branch

```git checkout -b re123```


### Pull Requests

Considerando que o ticket foi finalizado, após commitar tudo que foi feito abra uma solicitação de pull request para a branch `master` com o seguinte nome:

```RE#numero_do_ticket``` exemplo: ```RE#123```

Depois do Pull Request criado, retorne para a branch `master` antes de iniciar o próximo ticket.
