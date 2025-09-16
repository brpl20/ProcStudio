[Back](../README.md)

# Tabelas Polimórficas
Há tempos temos um problema no sistema de código repetido, onde tínhamos (e ainda temos) tabelas com por exemplo multiplas validações de e-mail, multiplas validações de telefone, tabelas relacionadas com telefone e endereço por modelo: `office_mail, user_mail` porém com o tempo temos passado essas tabelas para serem polimórficas, o que dá um pouco de trabalho na criação e migração do sistema antigo, mas vai garantir melhor manutenção do sistema com o passar do tempo.

# DONE
- Phone => Phoneable
- Address => Adressable

## TD PENDING
- E-Mail
- Banks
