# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Customer::WorksController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/customer/works').to route_to('api/v1/customer/works#index')
    end

    it 'routes to #show' do
      expect(get: '/api/v1/customer/works/1').to route_to('api/v1/customer/works#show', id: '1')
    end
  end
end
