[Back](../README.md)

# Notificações

Sistema de notificações criado para comunicação entre os usuários e outras notificações úteis do sistema para os usuários, como por exemplo avisar que um documento venceu ou que um menor de idade precisa atualizar sua procuração (compliance).

# Backend

O Backend vai se conectar com o frontend usando Websockets com [ActionCable](https://guides.rubyonrails.org/action_cable_overview.html).

1. Notification Model - Enhanced with polymorphic sender, priority levels, notification types, and WebSocket broadcasting
2. NotificationsController - Full CRUD operations with filtering, pagination, and batch operations
3. NotificationSerializer - JSON:API serialization with computed fields like time_ago and priority labels
4. NotificationPolicy - Authorization using Pundit following BackOfficeController pattern
5. API Routes - RESTful endpoints including mark_as_read, mark_all_as_read, and unread_count
6. NotificationChannel - Action Cable channel for real-time updates with JWT authentication
7. Database Migration - Updated existing table with new columns and performance indexes

# API
Métodos salvos na API do Postman na pasta: Notificações.

# Notification Fields
```ruby
id:,
created_at:,
updated_at:,
team_id:,
title:,  # string => Título da notificação
read: false, # boolean => Se foi lido ou não
priority: "0", # string => Default "0" => prioridade da notificação: low: 0 - normal: 1 - high:2 - urgent: 3,
body:,  # text => o que vai ser comunicado na notificação
notification_type:, # string fechado => info, success, warning, error, system, user_action, process_update, task_assignment, compliance
data: {}, # jsonb => Qualquer informação que deva estar na notificação
action_url:, # string => /works/123 => local onde o usuário deverá executar a ação
sender_type:, # string => De onde vem o request, de qual model, veja explicação mais completa abaixo
sender_id:, # int => id do usuário que está enviando a notificação
user_profile_id: # int => id do destinatário que receberá a notificação
```

## sender_type
Esse é o ponto mais importante do modelo, é o que se relacionará com o modelo a ser utilizado. Então quando o usuário utilizar a notificação dentro de um modelo como Job, esse model será passado no request, então teremos `sender_type: Job', ou Work, Document e assim sucessivamente.

**Importante:** Para mensagens do sistema utilize `sender_type: nil` e `sender_id: nil` isso será utilizado quando precisarmos enviar mensagens do sistema como mensagens do Compliance.

## ToDo:
- Implement Compliance notifications here
- Code Quality Review - Notification System Implementation

### Critical Issues Found:

2. Missing Test Coverage
  - spec/models/notification_spec.rb:35 only has pending tests
  - No actual test implementations despite complex business logic

3. Security Vulnerability
  - NotificationsController:69-76 allows setting arbitrary user_profile_id without proper authorization checks
beyond team membership

4. DRY Violations in Services
  - Both AgeTransitionCheckerJob and CapacityChangeService duplicate notification creation logic (lines 98-120
vs 41-63)
  - Age calculation is duplicated in both services

5. Performance Issues
  - NotificationsController:9-12 loads all notifications before filtering
  - Missing database indexes for frequent queries

6. Code Smell - Magic Numbers
  - Priority values stored as strings ('0', '1', '2', '3') instead of using enums properly

Recommended Improvements:

2. Create a NotificationService to centralize notification creation
3. Implement proper test coverage with factories
4. Use Rails enums for priority field
5. Add pagination gem (Kaminari/Pagy) instead of manual implementation
6. Extract age calculation to a module
7. Add database-level constraints for data integrity
8. Implement response builders to avoid duplication

# ToDo: Outros modelos que precisam ser atualizados para utilizar o sistema corretamente
User & Team Management:
- UsersController - User creation, updates, deletion
- TeamsController - Team member additions/removals
- UserRegistrationController - New user registrations

Work & Document Management:
- WorksController - Work status changes, assignments
- WorkEventsController - Important work events
- Document Services - Document creation, signing requests
- ZapsignService - Document signature status updates

Customer Management:
- CustomersController - Customer confirmations, profile updates
- ProfileCustomersController - Customer document generation
- RepresentsController - Representation status changes

Financial & Legal:
- LegalCostsController - Cost approvals, updates
- ProceduresController - Procedure status changes
- HonorariesController - Honorary calculations, approvals

Background Jobs:
- MailDeliveryJob - Email delivery status
- AgeTransitionCheckerJob - Age-based status changes
- DraftCleanupJob - Draft deletions

Compliance:
- CapacityChangeService - Capacity status changes
