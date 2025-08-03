# Legal Practice Management System - Multi-User Migration Guide

## Project Overview

This comprehensive guide outlines the migration of a legal practice management system from a single-user architecture to a multi-user, team-based system with polymorphic data modeling and subscription management.

## Current System Analysis

### Database Schema Assessment

Based on the current schema, the system contains:

**Core Entities:**
- `admins` - System users (lawyers and staff)
- `profile_admins` - Admin profile information
- `customers` - Client accounts
- `profile_customers` - Customer profile information
- `offices` - Law office entities
- `works` - Legal cases/projects


**Work Management:**
- `works` - Main case entity
- `honoraries` - Fee structures
- `documents` - Case documents
- `jobs` - Tasks and assignments
- `work_events` - Case timeline events

## Phase 1: Polymorphic Data Model Enhancement

### 1.1 Create Polymorphic Contact Information Tables

#### Migration: Create ContactInfo Polymorphic Model

```ruby
# db/migrate/xxx_create_contact_infos.rb
class CreateContactInfos < ActiveRecord::Migration[]
  def change
    create_table :contact_infos do |t|
      t.references :contactable, polymorphic: true, null: false
      t.string :contact_type, null: false # 'address', 'email', 'phone', 'bank_account'
      t.json :contact_data, null: false
      t.boolean :is_primary, default: false
      t.timestamps
      t.datetime :deleted_at
    end

    add_index :contact_infos, [:contactable_type, :contactable_id]
    add_index :contact_infos, [:contact_type, :contactable_type, :contactable_id]
    add_index :contact_infos, :deleted_at
  end
end
```

#### Model Implementation

```ruby
# app/models/contact_info.rb
class ContactInfo < ApplicationRecord
  belongs_to :contactable, polymorphic: true

  validates :contact_type, inclusion: { in: %w[address email phone bank_account] }
  validates :contact_data, presence: true

  scope :addresses, -> { where(contact_type: 'address') }
  scope :emails, -> { where(contact_type: 'email') }
  scope :phones, -> { where(contact_type: 'phone') }
  scope :bank_accounts, -> { where(contact_type: 'bank_account') }
  scope :primary, -> { where(is_primary: true) }

  def self.acts_as_paranoid
    default_scope { where(deleted_at: nil) }
  end
end
```

### 1.2 Update Existing Models

#### Admin Model Updates

```ruby
# app/models/admin.rb
class Admin < ApplicationRecord
  has_many :contact_infos, as: :contactable, dependent: :destroy
  has_many :addresses, -> { where(contact_type: 'address') },
           class_name: 'ContactInfo', as: :contactable
  has_many :emails, -> { where(contact_type: 'email') },
           class_name: 'ContactInfo', as: :contactable
  has_many :phones, -> { where(contact_type: 'phone') },
           class_name: 'ContactInfo', as: :contactable
  has_many :bank_accounts, -> { where(contact_type: 'bank_account') },
           class_name: 'ContactInfo', as: :contactable
end
```

#### Customer Model Updates

```ruby
# app/models/customer.rb
class Customer < ApplicationRecord
  has_many :contact_infos, as: :contactable, dependent: :destroy
  has_many :addresses, -> { where(contact_type: 'address') },
           class_name: 'ContactInfo', as: :contactable
  has_many :emails, -> { where(contact_type: 'email') },
           class_name: 'ContactInfo', as: :contactable
  has_many :phones, -> { where(contact_type: 'phone') },
           class_name: 'ContactInfo', as: :contactable
  has_many :bank_accounts, -> { where(contact_type: 'bank_account') },
           class_name: 'ContactInfo', as: :contactable
end
```

#### Office Model Updates

```ruby
# app/models/office.rb
class Office < ApplicationRecord
  has_many :contact_infos, as: :contactable, dependent: :destroy
  has_many :addresses, -> { where(contact_type: 'address') },
           class_name: 'ContactInfo', as: :contactable
  has_many :emails, -> { where(contact_type: 'email') },
           class_name: 'ContactInfo', as: :contactable
  has_many :phones, -> { where(contact_type: 'phone') },
           class_name: 'ContactInfo', as: :contactable
  has_many :bank_accounts, -> { where(contact_type: 'bank_account') },
           class_name: 'ContactInfo', as: :contactable
end
```

### 1.3 Data Migration Script

```ruby
# db/migrate/xxx_migrate_to_polymorphic_contacts.rb
class MigrateToPolymorphicContacts < ActiveRecord::Migration[]
  def up
    # Migrate Admin contacts
    migrate_admin_contacts

    # Migrate Customer contacts
    migrate_customer_contacts

    # Migrate Office contacts
    migrate_office_contacts
  end

  private

  def migrate_admin_contacts
    AdminAddress.includes(:address, :profile_admin).find_each do |admin_address|
      next unless admin_address.address && admin_address.profile_admin

      ContactInfo.create!(
        contactable: admin_address.profile_admin.admin,
        contact_type: 'address',
        contact_data: {
          description: admin_address.address.description,
          zip_code: admin_address.address.zip_code,
          street: admin_address.address.street,
          number: admin_address.address.number,
          neighborhood: admin_address.address.neighborhood,
          city: admin_address.address.city,
          state: admin_address.address.state
        },
        created_at: admin_address.created_at,
        updated_at: admin_address.updated_at,
        deleted_at: admin_address.deleted_at
      )
    end

    # Similar migrations for AdminEmail, AdminPhone, AdminBankAccount
    migrate_admin_emails
    migrate_admin_phones
    migrate_admin_bank_accounts
  end

  def migrate_customer_contacts
    # Similar structure for customer contacts
  end

  def migrate_office_contacts
    # Similar structure for office contacts
  end
end
```

## Phase 2: Legal Entity Separation

### 2.1 Create Legal Entity Models

#### Individual Entity Model

```ruby
# db/migrate/xxx_create_individual_entities.rb
class CreateIndividualEntities < ActiveRecord::Migration[]
  def change
    create_table :individual_entities do |t|
      t.string :name, null: false
      t.string :last_name
      t.string :gender
      t.string :rg
      t.string :cpf, null: false
      t.string :nationality
      t.string :civil_status
      t.string :profession
      t.date :birth
      t.string :mother_name
      t.string :nit
      t.string :inss_password
      t.boolean :invalid_person, default: false
      t.json :additional_documents
      t.timestamps
      t.datetime :deleted_at
    end

    add_index :individual_entities, :cpf, unique: true
    add_index :individual_entities, :deleted_at
  end
end
```

#### Legal Entity Model

```ruby
# db/migrate/xxx_create_legal_entities.rb
class CreateLegalEntities < ActiveRecord::Migration[]
  def change
    create_table :legal_entities do |t|
      t.string :name, null: false
      t.string :cnpj
      t.string :inscription_number
      t.string :state_registration
      t.string :oab_id
      t.string :society_link
      t.integer :number_of_partners
      t.string :status, default: 'active'
      t.string :accounting_type
      t.string :entity_type # 'law_firm', 'company', 'office'
      t.references :legal_representative, null: true,
                   foreign_key: { to_table: :individual_entities }
      t.timestamps
      t.datetime :deleted_at
    end

    add_index :legal_entities, :cnpj, unique: true, where: "cnpj IS NOT NULL"
    add_index :legal_entities, :entity_type
    add_index :legal_entities, :deleted_at
  end
end
```

### 2.2 Update Profile Models

#### Profile Admin Migration

```ruby
# db/migrate/xxx_add_entity_references_to_profile_admins.rb
class AddEntityReferencesToProfileAdmins < ActiveRecord::Migration[]
  def change
    add_reference :profile_admins, :individual_entity,
                  null: true, foreign_key: true
    add_reference :profile_admins, :legal_entity,
                  null: true, foreign_key: true
  end
end
```

#### Profile Customer Migration

```ruby
# db/migrate/xxx_add_entity_references_to_profile_customers.rb
class AddEntityReferencesToProfileCustomers < ActiveRecord::Migration[]
  def change
    add_reference :profile_customers, :individual_entity,
                  null: true, foreign_key: true
    add_reference :profile_customers, :legal_entity,
                  null: true, foreign_key: true
  end
end
```

## Phase 3: Multi-User Team Architecture

### 3.1 Create Teams System

#### Teams Table

```ruby
# db/migrate/xxx_create_teams.rb
class CreateTeams < ActiveRecord::Migration[]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.string :subdomain, null: false
      t.references :main_admin, null: false,
                   foreign_key: { to_table: :admins }
      t.references :owner_admin, null: false,
                   foreign_key: { to_table: :admins }
      t.string :status, default: 'active'
      t.json :settings, default: {}
      t.timestamps
      t.datetime :deleted_at
    end

    add_index :teams, :subdomain, unique: true
    add_index :teams, :deleted_at
  end
end
```

#### Team Memberships

```ruby
# db/migrate/xxx_create_team_memberships.rb
class CreateTeamMemberships < ActiveRecord::Migration[]
  def change
    create_table :team_memberships do |t|
      t.references :team, null: false, foreign_key: true
      t.references :admin, null: false, foreign_key: true
      t.string :role, null: false, default: 'member'
      t.string :status, default: 'active'
      t.datetime :joined_at
      t.timestamps
      t.datetime :deleted_at
    end

    add_index :team_memberships, [:team_id, :admin_id], unique: true
    add_index :team_memberships, :role
    add_index :team_memberships, :deleted_at
  end
end
```

#### Team Offices

```ruby
# db/migrate/xxx_create_team_offices.rb
class CreateTeamOffices < ActiveRecord::Migration[]
  def change
    create_table :team_offices do |t|
      t.references :team, null: false, foreign_key: true
      t.references :office, null: false, foreign_key: true
      t.timestamps
      t.datetime :deleted_at
    end

    add_index :team_offices, [:team_id, :office_id], unique: true
    add_index :team_offices, :deleted_at
  end
end
```

### 3.2 Subscription Management

#### Subscription Plans

```ruby
# db/migrate/xxx_create_subscription_plans.rb
class CreateSubscriptionPlans < ActiveRecord::Migration[]
  def change
    create_table :subscription_plans do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.string :currency, default: 'BRL'
      t.string :billing_interval # 'monthly', 'yearly'
      t.integer :max_users
      t.integer :max_offices
      t.integer :max_cases
      t.json :features, default: {}
      t.boolean :is_active, default: true
      t.timestamps
    end

    add_index :subscription_plans, :is_active
  end
end
```

#### Subscriptions

```ruby
# db/migrate/xxx_create_subscriptions.rb
class CreateSubscriptions < ActiveRecord::Migration[]
  def change
    create_table :subscriptions do |t|
      t.references :team, null: false, foreign_key: true
      t.references :subscription_plan, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date
      t.string :status, default: 'trial'
      t.date :trial_end_date
      t.decimal :monthly_amount, precision: 10, scale: 2
      t.timestamps
      t.datetime :deleted_at
    end

    add_index :subscriptions, [:team_id, :status]
    add_index :subscriptions, :deleted_at
  end
end
```

#### Payment Transactions

```ruby
# db/migrate/xxx_create_payment_transactions.rb
class CreatePaymentTransactions < ActiveRecord::Migration[]
  def change
    create_table :payment_transactions do |t|
      t.references :subscription, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, default: 'BRL'
      t.string :status, default: 'pending'
      t.string :payment_method
      t.string :transaction_id
      t.json :payment_data, default: {}
      t.datetime :processed_at
      t.timestamps
    end

    add_index :payment_transactions, :status
    add_index :payment_transactions, :transaction_id
  end
end
```

### 3.3 Invitation System

#### Roles

```ruby
# db/migrate/xxx_create_roles.rb
class CreateRoles < ActiveRecord::Migration[]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.text :description
      t.json :permissions, default: {}
      t.boolean :is_system_role, default: false
      t.timestamps
    end

    add_index :roles, :name, unique: true
  end
end
```

#### Invitations

```ruby
# db/migrate/xxx_create_invitations.rb
class CreateInvitations < ActiveRecord::Migration[]
  def change
    create_table :invitations do |t|
      t.references :team, null: false, foreign_key: true
      t.string :invited_email, null: false
      t.references :role, null: false, foreign_key: true
      t.string :token, null: false
      t.string :status, default: 'pending'
      t.references :invited_by_admin, null: false,
                   foreign_key: { to_table: :admins }
      t.datetime :expires_at
      t.timestamps
    end

    add_index :invitations, :token, unique: true
    add_index :invitations, [:team_id, :invited_email]
    add_index :invitations, :status
  end
end
```

### 3.4 Email Logging System

```ruby
# db/migrate/xxx_create_email_logs.rb
class CreateEmailLogs < ActiveRecord::Migration[]
  def change
    create_table :email_logs do |t|
      t.string :recipient_email, null: false
      t.string :subject
      t.text :body
      t.string :template_name
      t.datetime :sent_at
      t.string :status, default: 'pending'
      t.references :contact_info, null: true, foreign_key: true
      t.references :team, null: true, foreign_key: true
      t.string :email_type # 'invitation', 'notification', 'reminder'
      t.json :metadata, default: {}
      t.timestamps
    end

    add_index :email_logs, :recipient_email
    add_index :email_logs, :status
    add_index :email_logs, :email_type
    add_index :email_logs, :sent_at
  end
end
```

## Phase 4: Model Relationships and Validations

### 4.1 Core Model Updates

#### Team Model

```ruby
# app/models/team.rb
class Team < ApplicationRecord
  belongs_to :main_admin, class_name: 'Admin'
  belongs_to :owner_admin, class_name: 'Admin'

  has_many :team_memberships, dependent: :destroy
  has_many :admins, through: :team_memberships
  has_many :team_offices, dependent: :destroy
  has_many :offices, through: :team_offices
  has_many :subscriptions, dependent: :destroy
  has_many :invitations, dependent: :destroy
  has_many :email_logs, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :subdomain, presence: true, uniqueness: true,
            format: { with: /\A[a-z0-9][a-z0-9-]*[a-z0-9]\z/ }
  validates :status, inclusion: { in: %w[active inactive suspended] }

  scope :active, -> { where(status: 'active') }
  scope :by_subdomain, ->(subdomain) { where(subdomain: subdomain) }
end
```

#### Updated Admin Model

```ruby
# app/models/admin.rb
class Admin < ApplicationRecord
  has_one :profile_admin, dependent: :destroy
  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships
  has_many :owned_teams, class_name: 'Team', foreign_key: 'owner_admin_id'
  has_many :main_teams, class_name: 'Team', foreign_key: 'main_admin_id'
  has_many :invitations_sent, class_name: 'Invitation',
           foreign_key: 'invited_by_admin_id'

  # Contact info through polymorphic relationship
  has_many :contact_infos, as: :contactable, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[active inactive suspended] }

  def current_team
    team_memberships.active.first&.team
  end

  def team_role(team)
    team_memberships.find_by(team: team)&.role
  end
end
```

### 4.2 Entity Models

#### Individual Entity

```ruby
# app/models/individual_entity.rb
class IndividualEntity < ApplicationRecord
  has_many :profile_admins, dependent: :nullify
  has_many :profile_customers, dependent: :nullify
  has_many :legal_entities_as_representative, class_name: 'LegalEntity',
           foreign_key: 'legal_representative_id'

  validates :name, presence: true
  validates :cpf, presence: true, uniqueness: true

  def full_name
    [name, last_name].compact.join(' ')
  end
end
```

#### Legal Entity

```ruby
# app/models/legal_entity.rb
class LegalEntity < ApplicationRecord
  belongs_to :legal_representative, class_name: 'IndividualEntity', optional: true
  has_many :profile_admins, dependent: :nullify
  has_many :profile_customers, dependent: :nullify

  validates :name, presence: true
  validates :cnpj, uniqueness: true, allow_blank: true
  validates :entity_type, inclusion: { in: %w[law_firm company office] }
  validates :status, inclusion: { in: %w[active inactive suspended] }
end
```

## Phase 5: Controller Updates and API Testing

### 5.1 Controller Modifications

#### Teams Controller

```ruby
# app/controllers/api/v1/teams_controller.rb
class Api::V1::TeamsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_team, only: [:show, :update, :destroy]

  def index
    @teams = current_admin.teams.includes(:main_admin, :owner_admin)
    render json: @teams
  end

  def show
    render json: @team, include: [:admins, :offices, :subscription]
  end

  def create
    @team = Team.new(team_params)
    @team.main_admin = current_admin
    @team.owner_admin = current_admin

    if @team.save
      # Create initial team membership
      @team.team_memberships.create!(
        admin: current_admin,
        role: 'owner',
        joined_at: Time.current
      )

      render json: @team, status: :created
    else
      render json: { errors: @team.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_team
    @team = current_admin.teams.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :subdomain, settings: {})
  end
end
```

#### Contact Info Controller

```ruby
# app/controllers/api/v1/contact_infos_controller.rb
class Api::V1::ContactInfosController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_contactable
  before_action :set_contact_info, only: [:show, :update, :destroy]

  def index
    @contact_infos = @contactable.contact_infos.includes(:contactable)
    render json: @contact_infos
  end

  def show
    render json: @contact_info
  end

  def create
    @contact_info = @contactable.contact_infos.build(contact_info_params)

    if @contact_info.save
      render json: @contact_info, status: :created
    else
      render json: { errors: @contact_info.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @contact_info.update(contact_info_params)
      render json: @contact_info
    else
      render json: { errors: @contact_info.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @contact_info.update(deleted_at: Time.current)
    head :no_content
  end

  private

  def set_contactable
    if params[:admin_id]
      @contactable = Admin.find(params[:admin_id])
    elsif params[:customer_id]
      @contactable = Customer.find(params[:customer_id])
    elsif params[:office_id]
      @contactable = Office.find(params[:office_id])
    else
      render json: { error: 'Contactable not found' }, status: :not_found
    end
  end

  def set_contact_info
    @contact_info = @contactable.contact_infos.find(params[:id])
  end

  def contact_info_params
    params.require(:contact_info).permit(:contact_type, :is_primary, contact_data: {})
  end
end
```

### 5.2 API Testing Checklist

#### Authentication Tests
- [ ] Admin login with JWT token
- [ ] Token validation on protected routes
- [ ] Password reset functionality
- [ ] Multi-team access control

#### Contact Info Tests
- [ ] Create address for admin
- [ ] Create multiple emails for customer
- [ ] Create multiple phones for office
- [ ] Update contact information
- [ ] Soft delete contact info
- [ ] Set primary contact

#### Team Management Tests
- [ ] Create new team
- [ ] Add admin to team
- [ ] Remove admin from team
- [ ] Update team settings
- [ ] Team subdomain validation

#### Invitation Tests
- [ ] Send team invitation
- [ ] Accept invitation
- [ ] Decline invitation
- [ ] Expired invitation handling

#### Entity Tests
- [ ] Create individual entity
- [ ] Create legal entity with representative
- [ ] Link entities to profiles
- [ ] Entity validation rules

## Phase 6: Data Migration Scripts

### 6.1 Profile Entity Migration

```ruby
# db/migrate/xxx_migrate_profile_entities.rb
class MigrateProfileEntities < ActiveRecord::Migration[]
  def up
    # Migrate Individual Profiles
    ProfileAdmin.includes(:admin).where.not(cpf: [nil, '']).find_each do |profile|
      individual = IndividualEntity.create!(
        name: profile.name,
        last_name: profile.last_name,
        gender: profile.gender,
        rg: profile.rg,
        cpf: profile.cpf,
        nationality: profile.nationality,
        civil_status: profile.civil_status,
        birth: profile.birth,
        mother_name: profile.mother_name,
        created_at: profile.created_at,
        updated_at: profile.updated_at
      )

      profile.update!(individual_entity: individual)
    end

    # Migrate Office to Legal Entities
    Office.find_each do |office|
      legal_entity = LegalEntity.create!(
        name: office.name,
        cnpj: office.cnpj,
        entity_type: 'office',
        status: 'active',
        accounting_type: office.accounting_type,
        created_at: office.created_at,
        updated_at: office.updated_at
      )

      # Link office to legal entity through a new association
      office.update!(legal_entity_id: legal_entity.id) if office.respond_to?(:legal_entity_id=)
    end
  end

  def down
    # Rollback logic
  end
end
```

### 6.2 Team Creation Migration

```ruby
# db/migrate/xxx_create_default_teams.rb
class CreateDefaultTeams < ActiveRecord::Migration[]
  def up
    # Create a default team for each admin
    Admin.includes(:profile_admin).find_each do |admin|
      next unless admin.profile_admin

      team_name = admin.profile_admin.name&.present? ?
                  "#{admin.profile_admin.name}'s Team" :
                  "Team #{admin.id}"

      subdomain = generate_subdomain(admin)

      team = Team.create!(
        name: team_name,
        subdomain: subdomain,
        main_admin: admin,
        owner_admin: admin,
        status: 'active'
      )

      # Create team membership
      TeamMembership.create!(
        team: team,
        admin: admin,
        role: 'owner',
        status: 'active',
        joined_at: admin.created_at
      )

      # Associate existing offices with team
      admin.profile_admin.office&.then do |office|
        TeamOffice.create!(team: team, office: office)
      end
    end
  end

  private

  def generate_subdomain(admin)
    base = admin.profile_admin&.name&.parameterize || "team#{admin.id}"
    subdomain = base
    counter = 1

    while Team.exists?(subdomain: subdomain)
      subdomain = "#{base}#{counter}"
      counter += 1
    end

    subdomain
  end
end
```

## Phase 7: Insomnia API Test Collection

### 7.1 Environment Setup

```json
{
  "name": "polimorphic-tests",
  "description": "API tests for polymorphic multi-user system",
  "variables": [
    {
      "name": "base_url",
      "value": "http://localhost:3000/api/v1"
    },
    {
      "name": "auth_token",
      "value": ""
    },
    {
      "name": "team_id",
      "value": ""
    },
    {
      "name": "admin_id",
      "value": ""
    }
  ]
}
```

### 7.2 Authentication Tests

```json
{
  "name": "Auth - Admin Login",
  "method": "POST",
  "url": "{{ base_url }}/auth/sign_in",
  "body": {
    "mimeType": "application/json",
    "text": "{\"email\": \"admin@test.com\", \"password\": \"password123\"}"
  },
  "tests": [
    {
      "name": "Status 200",
      "code": "expect(response.status).to.equal(200);"
    },
    {
      "name": "Has JWT Token",
      "code": "const body = JSON.parse(response.body); expect(body.jwt_token).to.be.a('string'); insomnia.environment.set('auth_token', body.jwt_token);"
    }
  ]
}
```

### 7.3 Team Management Tests

```json
{
  "name": "Teams - Create Team",
  "method": "POST",
  "url": "{{ base_url }}/teams",
  "headers": [
    {
      "name": "Authorization",
      "value": "Bearer {{ auth_token }}"
    }
  ],
  "body": {
    "mimeType": "application/json",
    "text": "{\"team\": {\"name\": \"Test Law Firm\", \"subdomain\": \"testlawfirm\"}}"
  }
}
```

### 7.4 Contact Info Tests

```json
{
  "name": "ContactInfo - Create Admin Address",
  "method": "POST",
  "url": "{{ base_url }}/admins/{{ admin_id }}/contact_infos",
  "headers": [
    {
      "name": "Authorization",
      "value": "Bearer {{ auth_token }}"
    }
  ],
  "body": {
    "mimeType": "application/json",
    "text": "{\"contact_info\": {\"contact_type\": \"address\", \"is_primary\": true, \"contact_data\": {\"street\": \"123 Main St\", \"city\": \"São Paulo\", \"state\": \"SP\", \"zip_code\": \"01234-567\"}}}"
  }
}
```

### 7.5 Subscription Tests

```json
{
  "name": "Subscriptions - Create Team Subscription",
  "method": "POST",
  "url": "{{ base_url }}/teams/{{ team_id }}/subscriptions",
  "headers": [
    {
      "name": "Authorization",
      "value": "Bearer {{ auth_token }}"
    }
  ],
  "body": {
    "mimeType": "application/json",
    "text": "{\"subscription\": {\"subscription_plan_id\": 1, \"start_date\": \"2025-08-01\", \"status\": \"trial\"}}"
  }
}
```

## Phase 8: Validation and Testing Strategy

### 8.1 Controller Testing Script

```ruby
# lib/tasks/api_validation.rake
namespace :api do
  desc "Validate API endpoints after migration"
  task validate: :environment do
    puts "🔍 Starting API validation..."

    # Test polymorphic contact creation
    test_polymorphic_contacts

    # Test team functionality
    test_team_operations

    # Test entity relationships
    test_entity_relationships

    # Test subscription system
    test_subscription_system

    puts "✅ API validation completed!"
  end

  private

  def test_polymorphic_contacts
    puts "\n📞 Testing polymorphic contacts..."

    admin = Admin.first
    return puts "❌ No admin found" unless admin

    # Test address creation
    address = admin.contact_infos.create!(
      contact_type: 'address',
      contact_data: {
        street: 'Test Street 123',
        city: 'Test City',
        state: 'TS'
      }
    )
    puts "✅ Address created: #{address.id}"

    # Test multiple emails
    email1 = admin.contact_infos.create!(
      contact_type: 'email',
      contact_data: { email: 'test1@example.com' },
      is_primary: true
    )

    email2 = admin.contact_infos.create!(
      contact_type: 'email',
      contact_data: { email: 'test2@example.com' }
    )
    puts "✅ Multiple emails created: #{email1.id}, #{email2.id}"
  end

  def test_team_operations
    puts "\n👥 Testing team operations..."

    admin = Admin.first
    return puts "❌ No admin found" unless admin

    team = Team.create!(
      name: 'Test Team',
      subdomain: 'testteam123',
      main_admin: admin,
      owner_admin: admin
    )
    puts "✅ Team created: #{team.name}"

    membership = team.team_memberships.create!(
      admin: admin,
      role: 'owner',
      status: 'active'
    )
    puts "✅ Team membership created: #{membership.role}"
  end
end
```

### 8.2 Data Integrity Checks

```ruby
# lib/tasks/data_integrity.rake
namespace :data do
  desc "Check data integrity after migration"
  task integrity_check: :environment do
    puts "🔍 Checking data integrity..."

    check_contact_info_migration
    check_entity_relationships
    check_team_associations

    puts "✅ Data integrity check completed!"
  end

  private

  def check_contact_info_migration
    puts "\n📊 Contact Info Migration Check:"

    # Check if all admin addresses were migrated
    original_addresses = AdminAddress.count
    migrated_addresses = ContactInfo.where(contact_type: 'address').count
    puts "Addresses: Original(#{original_addresses}) -> Migrated(#{migrated_addresses})"

    # Check for missing data
    orphaned_contacts = ContactInfo.where(contactable: nil).count
    puts "Orphaned contacts: #{orphaned_contacts}"
  end
end
```

## Phase 9: Missing Components from Current Schema

Based on the provided schema analysis, here are additional considerations:

### 9.1 Preserve Existing Functionality

#### Work Events Integration
```ruby
# Ensure work events maintain team context
# db/migrate/xxx_add_team_to_work_events.rb
class AddTeamToWorkEvents < ActiveRecord::Migration[]
  def change
    add_reference :work_events, :team, null: true, foreign_key: true
    add_index :work_events, :team_id
  end
end
```

#### Document Management
```ruby
# Update documents to support team access
# db/migrate/xxx_add_team_to_documents.rb
class AddTeamToDocuments < ActiveRecord::Migration[]
  def change
    add_reference :documents, :team, null: true, foreign_key: true
    add_index :documents, :team_id
  end
end
```

### 9.2 Active Storage Integration

Ensure file attachments work with the new team structure:

```ruby
# app/models/document.rb
class Document < ApplicationRecord
  belongs_to :work
  belongs_to :profile_customer, optional: true
  belongs_to :team, optional: true

  has_one_attached :file

  validates :document_type, presence: true
  validates :format, inclusion: { in: %w[pdf doc docx jpg png] }
  validates :status, inclusion: { in: %w[draft pending signed] }
end
```

### 9.3 Recommendation System Update

```ruby
# db/migrate/xxx_add_team_to_recommendations.rb
class AddTeamToRecommendations < ActiveRecord::Migration[]
  def change
    add_reference :recommendations, :team, null: true, foreign_key: true
    add_index :recommendations, :team_id
  end
end
```

## Summary Checklist

### Pre-Migration
- [ ] Test migration on staging environment
- [ ] Verify all existing API endpoints
- [ ] Document current data volumes

### Migration Execution
- [ ] Run polymorphic contact migration
- [ ] Execute entity separation scripts
- [ ] Create team structures
- [ ] Set up subscription plans
- [ ] Migrate existing data

### Post-Migration Validation
- [ ] Test all API endpoints
- [ ] Verify data integrity
- [ ] Check polymorphic relationships
- [ ] Validate team access controls
- [ ] Test subscription workflows

### API Testing
- [ ] Import Insomnia collection
- [ ] Execute authentication tests
- [ ] Test CRUD operations for all entities
- [ ] Verify multi-user access patterns
- [ ] Test email and phone multiple entries

### Performance Monitoring
- [ ] Monitor database query performance
- [ ] Check for N+1 queries
- [ ] Validate polymorphic query efficiency
- [ ] Test large dataset operations

This comprehensive migration guide ensures a smooth transition from single-user to multi-user architecture while preserving all existing functionality and data integrity.
