# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Customer::ProfileCustomersController, type: :routing do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: '/api/v1/customer/profile_customers/1').to route_to('api/v1/customer/profile_customers#show', id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: '/api/v1/customer/profile_customers/1').to route_to('api/v1/customer/profile_customers#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/api/v1/customer/profile_customers/1').to route_to('api/v1/customer/profile_customers#update', id: '1')
    end
  end
end
