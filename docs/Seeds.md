[Voltar](../README.md)

# Seeds - Manual de Uso

## O que são Seeds?

Seeds são dados iniciais que você pode inserir no banco de dados para:

- Testar a aplicação com dados realistas
- Ter dados para desenvolvimento
- Criar cenários de teste específicos

> Os seeds são especialmente importantes para não precisarmos ficar criando dados manualmente para testes e desenvolvimento.

**Desenvolvimento Constante:** Um importante aspecto é que os seeds não são um código imutável. Por mais que você queira achar a **solução definitiva**, isso jamais existirá, assim como a documentação e qualquer código, os seeds requerem manutenção, atualização, assim como qualquer outro código, então mantenha isso em mente quando você mudar a estrutura das APIs, do banco de dados para que os outros desenvolvedores não quebrem a cabeça com seeds desatualizados.

## Arquitetura do Sistema

O sistema de seeds usa uma **arquitetura facade** modular com os seguintes módulos:

| Módulo | Descrição |
|--------|-----------|
| `teams_offices_users` | Teams, escritórios e usuários/advogados |
| `law_areas` | Áreas do direito (Civil, Criminal, etc.) |
| `law_areas_powers` | Poderes específicos por área do direito |
| `customers` | Clientes e perfis de clientes |
| `works` | Processos e trabalhos |
| `jobs` | Tarefas e jobs |

## Como Usar

### Executar Todos os Seeds

```bash
rails db:seed
```

### Excluir Módulos Específicos

Você pode excluir um ou mais módulos usando a variável `EXCEPT`, isso será útil para por exemplo o modelo `Work` que ainda está em construção.

```bash
# Excluir apenas works
EXCEPT=works rails db:seed

# Excluir works e jobs
EXCEPT=works,jobs rails db:seed

# Excluir múltiplos módulos
EXCEPT=teams_offices_users,works,jobs rails db:seed
```

### Resetar e Popular Banco

Para começar do zero:

```bash
# Método completo
rails db:drop && rails db:create && rails db:migrate && rails db:seed

# Ou com exclusões
rails db:drop && rails db:create && rails db:migrate && EXCEPT=works rails db:seed
```

## Associações Polimórficas

Os seeds agora usam **nested attributes** para criar associações polimórficas automaticamente de endereços, e-mails, contas bancárias e telefones para: `Customer/ProfileCustomer`, `User/UserProfile`, `Office`.

## Dados Criados

### Credenciais de Teste

**User/UserProfile -> Advogados/Staff:**
- Email: `joao.prado@advocacia.com.br` | Senha: `Password123!`
- Email: `maria.silva@advocacia.com.br` | Senha: `Password123!`
- Email: `ana.secretaria@advocacia.com.br` | Senha: `Password123!`

**User/UserProfile -> Secretay/Paralegal/Intern/Staff:**
- TD: Quando as polices forem atualizadas.

**Customer/Processos -> Clientes:**
- Email: `cliente1@gmail.com` | Senha: `ClientPass123!`
- Email: `empresa@empresa.com.br` | Senha: `ClientPass123!`
- Email: `cliente.menor@gmail.com` | Senha: `ClientPass123!`

### Estrutura de Dados

- **2 Teams** (Principal e Filial)
- **2 Escritórios** com endereços, telefones, emails e contas bancárias
- **3 Usuários** com perfis completos
- **14 Áreas do Direito** com hierarquia
- **68 Poderes** específicos por área
- **3 Clientes** com perfis completos e dados polimórficos

## Dicas Importantes

1. **Ordem de Dependência**: Os módulos são carregados em ordem de dependência automática
2. **Transações**: Todo o processo roda em uma transação - se algo falhar, nada é salvo
3. **Idempotência**: Pode executar múltiplas vezes sem duplicar dados
4. **Performance**: Use exclusões para acelerar desenvolvimento quando não precisar de todos os dados

## Troubleshooting

### Erro de Validação
Se encontrar erros de validação (CPF, CNPJ, etc.), os seeds usam dados de teste válidos. Reporte se encontrar problemas.

### Módulos em Desenvolvimento
Se um módulo estiver causando problemas, simplesmente exclua-o:
```bash
EXCEPT=works,jobs rails db:seed
```

### Reset Completo
Para garantir estado limpo:
```bash
rails db:drop && rails db:create && rails db:migrate && rails db:seed
```

## Exemplo de Uso no Desenvolvimento

```bash
# Para desenvolvimento frontend (sem processos complexos)
EXCEPT=works rails db:seed

# Para testar sistema completo
rails db:seed

# Para testar apenas dados básicos
EXCEPT=works,jobs rails db:seed
```

Este sistema facilita o desenvolvimento permitindo que você tenha exatamente os dados que precisa para cada cenário de teste.
