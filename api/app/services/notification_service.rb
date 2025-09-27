# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength, Metrics/ParameterLists
class NotificationService
  class << self
    def notify(recipients:, title:, body:, type: 'info', sender: nil, action_url: nil, data: {}, broadcast: true)
      recipients_array = normalize_recipients(recipients)

      notifications = recipients_array.map do |user_profile|
        notification = create_notification(
          user_profile: user_profile,
          title: title,
          body: body,
          notification_type: type,
          sender: sender,
          action_url: action_url,
          data: data
        )

        broadcast_notification(notification) if broadcast && notification.persisted?
        notification
      end

      notifications.one? ? notifications.first : notifications
    rescue StandardError => e
      Rails.logger.error "NotificationService Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end

    def notify_team(team:, title:, body:, scope: :all, **)
      recipients = case scope
                   when :all
                     team.users.joins(:user_profile).map(&:user_profile)
                   when :lawyers
                     team.users.joins(:user_profile).where(user_profiles: { role: 'lawyer' }).map(&:user_profile)
                   when :interns
                     team.users.joins(:user_profile).where(user_profiles: { role: 'intern' }).map(&:user_profile)
                   when :admins
                     team.users.joins(:user_profile).where(user_profiles: { role: 'admin' }).map(&:user_profile)
                   else
                     if scope.respond_to?(:map)
                       scope.map { |u| u.respond_to?(:user_profile) ? u.user_profile : u }
                     else
                       []
                     end
                   end

      notify(recipients: recipients, title: title, body: body, **)
    end

    def notify_compliance(team:, resource:, title:, body:, **options)
      default_data = {
        compliance_type: options[:compliance_type] || infer_compliance_type(resource),
        resource_type: resource.class.name,
        resource_id: resource.id
      }

      notify_team(
        team: team,
        scope: :lawyers,
        title: title,
        body: body,
        type: 'compliance',
        sender: resource,
        data: default_data.merge(options[:data] || {}),
        **options.except(:data, :compliance_type)
      )
    end

    def notify_task_assignment(job:, assignees:, **options)
      assignees_array = Array(assignees)

      title = options[:title] || 'Nova tarefa atribuída'
      body = options[:body] || "A tarefa ##{job.id} foi atribuída a você: #{job.description || 'Sem descrição'}"

      notify(
        recipients: assignees_array,
        title: title,
        body: body,
        type: 'task_assignment',
        sender: job.created_by,
        action_url: "/jobs/#{job.id}",
        data: {
          job_id: job.id,
          job_status: job.status,
          job_description: job.description
        }.merge(options[:data] || {}),
        **options.except(:title, :body, :data)
      )
    end

    def notify_job_creation(job:)
      job_data = {
        job_deadline: job.deadline.to_s,
        job_priority: job.priority,
        work_id: job.work_id,
        customer_id: job.profile_customer_id,
        customer_name: job.profile_customer&.name
      }

      # Notify assignees (excluding creator)
      assignees_to_notify = job.assignees.reject { |a| a == job.created_by.user_profile }
      if assignees_to_notify.any?
        notify_task_assignment(
          job: job,
          assignees: assignees_to_notify,
          data: job_data
        )
      end

      # Notify supervisors
      return unless job.supervisors.any?

      notify_task_assignment(
        job: job,
        assignees: job.supervisors,
        title: 'Nova tarefa para supervisão',
        body: "Você foi designado como supervisor da tarefa ##{job.id}: #{job.description || 'Sem descrição'}",
        data: job_data.merge(role: 'supervisor')
      )
    end

    def notify_capacity_change(profile_customer:, old_capacity:, new_capacity:, reason: nil)
      team = profile_customer.customer&.teams&.first
      return unless team

      age = calculate_age(profile_customer.birth) if profile_customer.birth.present?

      title = capacity_change_title(new_capacity, reason)
      body = capacity_change_body(profile_customer, old_capacity, new_capacity, age, reason)

      notify_compliance(
        team: team,
        resource: profile_customer,
        title: title,
        body: body,
        action_url: "/customers/#{profile_customer.id}/compliance",
        data: {
          old_capacity: old_capacity,
          new_capacity: new_capacity,
          age: age,
          reason: reason,
          profile_customer_id: profile_customer.id,
          profile_customer_name: profile_customer.full_name
        }
      )
    end

    def notify_representation_change(represent:, notification_type:)
      return if represent.team.blank?
      return unless ['unable', 'relatively'].include?(represent.profile_customer&.capacity)

      customer_name = represent.profile_customer&.full_name
      representor_name = represent.representor&.full_name

      title = I18n.t("notifications.representation.#{notification_type}.title",
                     relationship_type: represent.relationship_type.capitalize,
                     default: "Representation #{notification_type.humanize}")

      body = I18n.t("notifications.representation.#{notification_type}.body",
                    representor_name: representor_name,
                    relationship_type: represent.relationship_type,
                    customer_name: customer_name,
                    default: "#{representor_name} (#{represent.relationship_type}) - #{customer_name}")

      notify_compliance(
        team: represent.team,
        resource: represent,
        title: title,
        body: body,
        compliance_type: notification_type,
        action_url: "/customers/#{represent.profile_customer_id}/represents",
        data: {
          profile_customer_id: represent.profile_customer_id,
          profile_customer_name: customer_name,
          representor_id: represent.representor_id,
          representor_name: representor_name,
          relationship_type: represent.relationship_type,
          active: represent.active
        }
      )
    end

    private

    def normalize_recipients(recipients)
      case recipients
      when Array
        recipients.flat_map { |r| normalize_single_recipient(r) }.compact.uniq
      else
        Array(normalize_single_recipient(recipients)).compact
      end
    end

    def normalize_single_recipient(recipient)
      case recipient
      when UserProfile
        recipient
      when User
        recipient.user_profile
      when Team
        recipient.users.joins(:user_profile).map(&:user_profile)
      end
    end

    def create_notification(user_profile:, title:, body:, notification_type:, sender:, action_url:, data:)
      return nil unless user_profile

      # Get team from user_profile's user
      team = user_profile.user.team
      return nil unless team

      Notification.create!(
        user_profile: user_profile,
        team: team,
        title: title,
        body: body,
        notification_type: notification_type,
        sender: sender,
        action_url: action_url,
        data: data,
        read: false
      )
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Failed to create notification: #{e.message}"
      nil
    end

    def broadcast_notification(notification)
      return unless notification&.user_profile&.user

      NotificationChannel.broadcast_to(
        notification.user_profile.user,
        NotificationSerializer.new(notification).serializable_hash[:data][:attributes]
      )
    rescue StandardError => e
      Rails.logger.error "Failed to broadcast notification: #{e.message}"
    end

    def infer_compliance_type(resource)
      case resource
      when ProfileCustomer
        'capacity_change'
      when Represent
        resource.active? ? 'new_representation' : 'representation_ended'
      else
        'general_compliance'
      end
    end

    def calculate_age(birth_date)
      return nil unless birth_date

      today = Date.current
      age = today.year - birth_date.year
      age -= 1 if today < birth_date + age.years
      age
    end

    def capacity_change_title(new_capacity, reason)
      if reason == 'age_transition'
        case new_capacity
        when 'relatively'
          'Minor transitioned to relatively incapable'
        when 'able'
          'Minor became an adult'
        else
          'Capacity change due to age'
        end
      else
        case new_capacity
        when 'able'
          'Customer capacity changed to fully capable'
        when 'relatively'
          'Customer capacity changed to relatively incapable'
        when 'unable'
          'Customer capacity changed to unable'
        else
          'Customer capacity updated'
        end
      end
    end

    def capacity_change_body(profile_customer, old_capacity, new_capacity, age, reason)
      age_info = age ? " (Age: #{age})" : ''

      if reason == 'age_transition'
        "#{profile_customer.full_name} (CPF: #{profile_customer.cpf}) has turned #{age} years old today. " \
          "Their capacity has automatically changed from '#{old_capacity}' to '#{new_capacity}'. " \
          'Please review and update any necessary documents.'
      else
        "#{profile_customer.full_name} (CPF: #{profile_customer.cpf})#{age_info} " \
          "has had their capacity changed from '#{old_capacity}' to '#{new_capacity}'. " \
          'Please review and update all related documents and legal procedures.'
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength, Metrics/ParameterLists
