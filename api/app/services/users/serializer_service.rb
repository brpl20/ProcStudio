# frozen_string_literal: true

module Users
  class SerializerService
    def self.serialize_user(user)
      UserSerializer.new(user, include: [:user_profile]).serializable_hash
    end

    def self.serialize_users_with_meta(users)
      UserSerializer.new(
        users,
        meta: { total_count: users.offset(nil).limit(nil).count },
        include: [:user_profile]
      ).serializable_hash
    end
  end
end
