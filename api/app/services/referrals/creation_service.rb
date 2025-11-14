# frozen_string_literal: true

module Referrals
  class CreationService
    MAX_REFERRALS_PER_REQUEST = 50

    def self.send_referrals(emails:, current_user:, base_url:)
      new(emails: emails, current_user: current_user, base_url: base_url).call
    end

    def initialize(emails:, current_user:, base_url:)
      @emails = normalize_emails(emails)
      @current_user = current_user
      @base_url = base_url
      @successful_referrals = []
      @failed_referrals = []
    end

    def call
      validate_inputs
      return build_error_result if @errors.present?

      process_referrals

      build_result
    end

    private

    attr_reader :emails, :current_user, :base_url, :successful_referrals, :failed_referrals

    def normalize_emails(emails)
      return [] unless emails.is_a?(Array)

      emails.map { |email| email.to_s.downcase.strip }.uniq.compact_blank
    end

    def validate_inputs
      @errors = []

      if emails.blank?
        @errors << 'Nenhum e-mail fornecido'
        return
      end

      if emails.size > MAX_REFERRALS_PER_REQUEST
        @errors << "Máximo de #{MAX_REFERRALS_PER_REQUEST} indicações por vez"
      end

      invalid_emails = emails.reject { |email| valid_email?(email) }
      @errors << "E-mails inválidos: #{invalid_emails.join(', ')}" if invalid_emails.any?
    end

    def valid_email?(email)
      email.match?(URI::MailTo::EMAIL_REGEXP)
    end

    def process_referrals
      emails.each do |email|
        process_single_referral(email)
      end
    end

    def process_single_referral(email)
      referral = create_referral(email)

      if referral.persisted?
        send_referral_email(referral)
        successful_referrals << referral
      else
        failed_referrals << { email: email, errors: referral.errors.full_messages }
      end
    rescue StandardError => e
      Rails.logger.error("[Referral Creation Error]: #{e.message}")
      failed_referrals << { email: email, errors: [e.message] }
    end

    def create_referral(email)
      ReferralInvitation.create(
        email: email,
        referred_by: current_user,
        metadata: { campaign: 'user_referral', source: 'dashboard' }
      )
    end

    def send_referral_email(referral)
      referral_url = build_referral_url(referral)
      Referrals::Mail::ReferralEmailService.new(referral, referral_url).call
    rescue StandardError => e
      Rails.logger.error("[Referral Email Error]: #{e.message}")
    end

    def build_referral_url(referral)
      "#{base_url}/signup?ref=#{referral.token}"
    end

    def build_result
      Result.new(
        success: failed_referrals.empty?,
        data: {
          successful: successful_referrals.map { |ref| serialize_referral(ref) },
          failed: failed_referrals,
          summary: {
            total: emails.size,
            successful_count: successful_referrals.size,
            failed_count: failed_referrals.size
          }
        }
      )
    end

    def build_error_result
      Result.new(
        success: false,
        errors: @errors
      )
    end

    def serialize_referral(referral)
      {
        id: referral.id,
        email: referral.email,
        status: referral.status,
        expires_at: referral.expires_at,
        days_until_expiration: referral.days_until_expiration
      }
    end

    class Result
      attr_reader :data, :errors

      def initialize(success:, data: nil, errors: nil)
        @success = success
        @data = data
        @errors = errors
      end

      def success?
        @success
      end

      def failure?
        !@success
      end
    end
  end
end
