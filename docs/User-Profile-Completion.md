[Back](../README.md)

# User - Profile Creation
A criação do perfil é uma etapa importante em todos os sistemas. Queremos que o usuário tenha um login e registro facilitados e apenas em um segundo momento seja necessário realizar toda a etapa de "embarque" no sistema preenchendo seus dados pessoais. Todos sabem como isso pode ser chato e fazer com que o usuário desista de utilizar a plataforma de imediato.

Assim, algumas ações são executadas no backend para facilitar essa tarefa:

- Uma requisição é feita para a API Legal_Data para buscar dados básicos do advogado, se isso estiver disponível
- Dados básicos do advogado são preenchidos => UserProfile fica parcialmente preenchido
- Um time também é gerado automaticamente com informações básicas do usuário como mock data
- Frontend pede apenas os dados que ainda não foram preenchidos, em um modal antes de deixar o usuário entrar efetivamente no sistema
