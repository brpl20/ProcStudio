[Back](../README.md)

# API Powers & Law Areas - Documentação

Sistema hierárquico de **Poderes** e **Áreas do Direito** com herança e customização por equipe. A estrutura de Poderes define o que o advogado pode fazer a favor do seu cliente. Cada área de atuação do direito tem uma série de poderes diferentes, então é importante que esse modelo seja customizável pelo usuário amplatamente.

Este modelo também está diretamente relacionado com o Works, e a revisão para implementação ocorrerá em conjunto.

## Arquitetura do Sistema

### Estrutura Hierárquica:
```
Procedimento (category)
├── Administrative (base powers)
├── Judicial (base powers)
└── Extrajudicial (base powers)

Áreas do Direito (law_areas)
├── Civil (área principal)
│   ├── Família (subárea - herda de Civil)
│   ├── Contratos (subárea - herda de Civil)
│   └── Responsabilidade Civil (subárea - herda de Civil)
├── Previdenciário (área principal)
│   ├── Aposentadoria (subárea - herda de Previdenciário)
│   ├── Auxílio Doença (subárea - herda de Previdenciário)
│   └── Pensão por Morte (subárea - herda de Previdenciário)
└── Tributário (área principal)
    ├── PIS/COFINS (subárea - herda de Tributário)
    ├── ICMS (subárea - herda de Tributário)
    └── Imposto de Renda (subárea - herda de Tributário)
```

### Tipos de Poderes
1. **Base**: Aplicam-se a todos os procedimentos (`is_base: true`)
2. **Específicos**: Vinculados a uma área do direito (`law_area_id: X`)
3. **Customizados**: Criados pelos usuários para seu team

### Herança de poderes
- **Família** herda todos os poderes de **Civil** + seus próprios
- **Civil** herda todos os poderes **Judicial base** + seus próprios
- Poderes mais específicos têm precedência sobre os gerais

## Autorização
- Sistema de autorização será refeito.

### Team Scoping:
- **Áreas/Poderes do Sistema**: Visíveis para todos
- **Áreas/Poderes Customizados**: Apenas para o team que criou
- **Lawyers** podem criar/editar apenas do próprio team
- **Super Admins** podem gerenciar tudo

## API
- Ver nas rotas da API (Postman)


## Dados dos Seeds

Após executar os seeds, você terá:

### **15 Áreas do Direito:**
- **5 Principais**: Civil, Previdenciário, Tributário, Criminal, Trabalhista
- **10 Subáreas**: Família, Contratos, Aposentadoria, PIS/COFINS, etc.

### **74 Poderes:**
- **43 Base**: 13 Administrative + 15 Judicial + 13 Extrajudicial + 2 duplicados
- **31 Específicos**: Distribuídos por área e subárea

### **Estrutura Completa:**
```
 Civil (4 poderes específicos)
  ├── Família (5 poderes + herda Civil + base)
  ├── Contratos (herda Civil + base)
  └── Responsabilidade Civil (herda Civil + base)

 Previdenciário (5 poderes específicos)
  ├── Aposentadoria (4 poderes + herda Previdenciário + base)
  ├── Auxílio Doença (herda Previdenciário + base)
  └── Pensão por Morte (herda Previdenciário + base)

 Tributário (5 poderes específicos)
  ├── PIS/COFINS (5 poderes + herda Tributário + base)
  ├── ICMS (herda Tributário + base)
  └── Imposto de Renda (herda Tributário + base)
```
