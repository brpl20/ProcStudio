# Troubleshooting

- Lembre-se: 90% das vezes o problema não é da máquina, mas de você.
- Isole o problema em camadas, dê alguns passos atrás para poder dar um passo a frente.

## Problemas Comuns

1. **RuboCop falhando**: Execute `bundle exec rubocop -A` para auto-correção
2. **Testes falhando**: Verifique se o banco de teste está limpo com `rails db:test:prepare`
3. **Performance lenta**: Analise N+1 queries com `bullet` gem

## Comandos Úteis

```bash
# Regenerar RuboCop TODO
bundle exec rubocop --auto-gen-config

# Rodar apenas testes modificados
bundle exec rspec --only-failures

# Limpar logs
rails log:clear

# Verificar rotas
rails routes
```
