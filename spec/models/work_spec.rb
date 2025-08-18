# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Work do
  describe 'Attributes' do
    it do
      is_expected.to have_attributes(
        id: nil,
        procedure: nil,
        subject: nil,
        number: nil,
        rate_parceled_exfield: nil,
        folder: nil,
        note: nil,
        extra_pending_document: nil,
        created_at: nil,
        updated_at: nil,
        civel_area: nil,
        social_security_areas: nil,
        laborite_areas: nil,
        tributary_areas: nil,
        other_description: nil,
        compensations_five_years: nil,
        compensations_service: nil,
        lawsuit: nil,
        gain_projection: nil,
        physical_lawyer: nil,
        responsible_lawyer: nil,
        partner_lawyer: nil,
        intern: nil,
        bachelor: nil,
        initial_atendee: nil,
        procedures: [],
        created_by_id: nil,
        status: 'in_progress'
      )
    end
  end

  describe 'Associations' do
    subject(:work) { build(:work) }

    it { is_expected.to have_one(:honorary) }
    it { is_expected.to have_one(:draft_work) }
    it { is_expected.to have_many_attached(:tributary_files) }
    it { is_expected.to have_many(:profile_customers) }
    it { is_expected.to have_many(:profile_admins) }
    it { is_expected.to have_many(:powers) }
    it { is_expected.to have_many(:documents) }
    it { is_expected.to have_many(:offices) }
    it { is_expected.to have_many(:recommendations) }
    it { is_expected.to have_many(:jobs) }
    it { is_expected.to have_many(:work_events) }
  end

  describe 'Enums' do
    it do
      is_expected.to define_enum_for(:procedure)
                       .with_values(
                         administrative: 'administrativo',
                         judicial: 'judicial',
                         extrajudicial: 'extrajudicial'
                       ).backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:subject)
                       .with_values(
                         administrative_subject: 'administrativo',
                         civil: 'civel',
                         criminal: 'criminal',
                         social_security: 'previdenciario',
                         laborite: 'trabalhista',
                         tributary: 'tributario',
                         tributary_pis: 'tributario_pis_confins',
                         others: 'outros'
                       ).backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:civel_area)
                       .with_values(
                         family: 'familia',
                         consumer: 'consumidor',
                         moral_damages: 'danos morais'
                       ).backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:tributary_areas)
                       .with_values(
                         asphalt: 'asfalto',
                         license: 'alvara',
                         others_tributary: 'outros'
                       ).backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:social_security_areas)
                       .with_values(
                         retirement_by_time: 'aposentadoria_contribuicao',
                         retirement_by_age: 'aposentadoria_idade',
                         retirement_by_rural: 'aposentadoria_rural',
                         disablement: 'invalidez',
                         benefit_review: 'revisão_beneficio',
                         administrative_services: 'servicos_administrativos'
                       ).backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:laborite_areas)
                       .with_values(labor_claim: 'reclamatoria_trabalhista')
                       .backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:status)
                       .with_values(
                         in_progress: 'in_progress',
                         paused: 'paused',
                         completed: 'completed'
                       ).backed_by_column_of_type(:string)
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:subject) }
  end

  describe 'Nested Attributes' do
    [:documents, :pending_documents, :honorary, :recommendations].each do |association|
      it { is_expected.to accept_nested_attributes_for(association).allow_destroy(true) }
    end
  end

  describe 'Class Methods' do
    it '.filter_by_customer_id' do
      profile_customer = create(:profile_customer)
      works = create_list(:work, 3)
      works.first(2).each do |work|
        create(:customer_work, profile_customer: profile_customer, work: work)
      end

      expect(described_class.filter_by_customer_id(profile_customer.id).count).to eq(2)
    end
  end
end
