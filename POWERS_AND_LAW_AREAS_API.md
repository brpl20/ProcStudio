# 📋 API Powers & Law Areas - Documentação

Sistema hierárquico de **Poderes** e **Áreas do Direito** com herança e customização por equipe.

---

## 🏗️ **Arquitetura do Sistema**

### **Estrutura Hierárquica:**
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

### **Tipos de Poderes:**
1. **Base**: Aplicam-se a todos os procedimentos (`is_base: true`)
2. **Específicos**: Vinculados a uma área do direito (`law_area_id: X`)
3. **Customizados**: Criados pelos usuários para seu team

---

## 🔗 **LAW AREAS API**

### **GET /api/v1/law_areas** - Listar áreas
```http
GET /api/v1/law_areas
Authorization: Bearer {token}
```

**Resposta:**
```json
{
  "data": [
    {
      "id": "1",
      "type": "law_area",
      "attributes": {
        "id": 1,
        "name": "Civil",
        "code": "civil",
        "description": "Direito Civil - relações entre particulares",
        "active": true,
        "sort_order": 1,
        "full_name": "Civil",
        "is_main_area": true,
        "is_sub_area": false,
        "is_system_area": true,
        "depth": 0,
        "sub_areas_count": 3,
        "powers_count": 4
      }
    }
  ]
}
```

### **POST /api/v1/law_areas** - Criar área principal
```json
{
  "law_area": {
    "name": "Empresarial",
    "code": "corporate",
    "description": "Direito Empresarial",
    "active": true,
    "sort_order": 6
  }
}
```

### **POST /api/v1/law_areas** - Criar subárea
```json
{
  "law_area": {
    "name": "Societário",
    "code": "corporate_law",
    "description": "Direito Societário - constituição de empresas",
    "parent_area_id": 1,
    "active": true,
    "sort_order": 1
  }
}
```

### **PUT /api/v1/law_areas/:id** - Atualizar área
```json
{
  "law_area": {
    "description": "Direito Civil atualizado",
    "sort_order": 2
  }
}
```

### **DELETE /api/v1/law_areas/:id** - Excluir área
```http
DELETE /api/v1/law_areas/1
Authorization: Bearer {token}
```

---

## ⚖️ **POWERS API**

### **GET /api/v1/powers** - Listar poderes
```http
GET /api/v1/powers
Authorization: Bearer {token}
```

**Resposta:**
```json
{
  "data": [
    {
      "id": "1",
      "type": "power",
      "attributes": {
        "id": 1,
        "description": "representar",
        "category": "administrative",
        "law_area_id": null,
        "is_base": true,
        "category_name": "Administrative",
        "law_area": null,
        "full_description": "Administrative - representar",
        "is_custom": false,
        "created_by_team": null
      }
    },
    {
      "id": "15",
      "type": "power",
      "attributes": {
        "id": 15,
        "description": "representar em divórcio consensual",
        "category": "judicial",
        "law_area_id": 4,
        "is_base": false,
        "category_name": "Judicial",
        "law_area": {
          "id": 4,
          "name": "Família",
          "code": "family",
          "full_name": "Civil - Família",
          "parent_area": {
            "id": 1,
            "name": "Civil",
            "code": "civil"
          }
        },
        "full_description": "Judicial (Civil - Família) - representar em divórcio consensual",
        "is_custom": true,
        "created_by_team": {
          "id": 1,
          "name": "Escritório XYZ"
        }
      }
    }
  ]
}
```

### **POST /api/v1/powers** - Criar poder base
```json
{
  "power": {
    "description": "representar em qualquer instância",
    "category": "judicial",
    "is_base": true
  }
}
```

### **POST /api/v1/powers** - Criar poder específico para área
```json
{
  "power": {
    "description": "representar em ações cíveis",
    "category": "judicial",
    "law_area_id": 1,
    "is_base": false
  }
}
```

### **POST /api/v1/powers** - Criar poder específico para subárea
```json
{
  "power": {
    "description": "representar em divórcio consensual",
    "category": "judicial",
    "law_area_id": 4,
    "is_base": false
  }
}
```

### **PUT /api/v1/powers/:id** - Atualizar poder
```json
{
  "power": {
    "description": "representar em divórcio litigioso e consensual"
  }
}
```

### **DELETE /api/v1/powers/:id** - Excluir poder
```http
DELETE /api/v1/powers/1
Authorization: Bearer {token}
```

---

## 🎯 **Casos de Uso Práticos**

### **1. Configurar poderes para Direito de Família:**

```bash
# 1. Criar área Civil (já existe nos seeds)
POST /api/v1/law_areas
{
  "law_area": {
    "name": "Civil",
    "code": "civil"
  }
}

# 2. Criar subárea Família
POST /api/v1/law_areas  
{
  "law_area": {
    "name": "Família",
    "code": "family",
    "parent_area_id": 1
  }
}

# 3. Criar poder específico para Família
POST /api/v1/powers
{
  "power": {
    "description": "representar em processo de guarda",
    "category": "judicial",
    "law_area_id": 4,
    "is_base": false
  }
}
```

### **2. Customizar poder para o seu escritório:**

```bash
# Criar poder customizado para uma subárea específica
POST /api/v1/powers
{
  "power": {
    "description": "representar especificamente em divórcio com violência doméstica",
    "category": "judicial", 
    "law_area_id": 4,
    "is_base": false
  }
}
# Resultado: Será automaticamente associado ao seu team
```

### **3. Herança de poderes:**

- **Família** herda todos os poderes de **Civil** + seus próprios
- **Civil** herda todos os poderes **Judicial base** + seus próprios  
- Poderes mais específicos têm precedência sobre os gerais

---

## 🛡️ **Autorização**

### **Permissões por Role:**

| Ação | Super Admin | Lawyer | Secretary | Paralegal |
|------|-------------|--------|-----------|-----------|
| **Listar** | ✅ | ✅ | ✅ | ✅ |
| **Ver** | ✅ | ✅ | ✅ | ✅ |
| **Criar** | ✅ | ✅ | ❌ | ❌ |
| **Editar** | ✅ Sistema + Team | ✅ Team | ❌ | ❌ |
| **Excluir** | ✅ Sistema + Team | ✅ Team | ❌ | ❌ |

### **Team Scoping:**
- **Áreas/Poderes do Sistema**: Visíveis para todos
- **Áreas/Poderes Customizados**: Apenas para o team que criou
- **Lawyers** podem criar/editar apenas do próprio team
- **Super Admins** podem gerenciar tudo

---

## 📊 **Dados dos Seeds**

Após executar os seeds, você terá:

### **15 Áreas do Direito:**
- **5 Principais**: Civil, Previdenciário, Tributário, Criminal, Trabalhista
- **10 Subáreas**: Família, Contratos, Aposentadoria, PIS/COFINS, etc.

### **74 Poderes:**
- **43 Base**: 13 Administrative + 15 Judicial + 13 Extrajudicial + 2 duplicados
- **31 Específicos**: Distribuídos por área e subárea

### **Estrutura Completa:**
```
📁 Civil (4 poderes específicos)
  ├── 👨‍👩‍👧‍👦 Família (5 poderes + herda Civil + base)
  ├── 📋 Contratos (herda Civil + base)  
  └── ⚖️ Responsabilidade Civil (herda Civil + base)

📁 Previdenciário (5 poderes específicos)
  ├── 👴 Aposentadoria (4 poderes + herda Previdenciário + base)
  ├── 🏥 Auxílio Doença (herda Previdenciário + base)
  └── 💀 Pensão por Morte (herda Previdenciário + base)

📁 Tributário (5 poderes específicos)  
  ├── 💰 PIS/COFINS (5 poderes + herda Tributário + base)
  ├── 🏪 ICMS (herda Tributário + base)
  └── 💸 Imposto de Renda (herda Tributário + base)
```

**✅ Sistema totalmente funcional e customizável!**