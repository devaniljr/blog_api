# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Ips', type: :request do
  describe 'GET /api/v1/ips' do
    before do
      user_a = create(:user, login: 'alice')
      user_b = create(:user, login: 'bob')
      user_c = create(:user, login: 'charlie')

      # IP 192.168.1.1 → alice e bob (2 autores)
      create(:post, user: user_a, ip: '192.168.1.1')
      create(:post, user: user_b, ip: '192.168.1.1')

      # IP 10.0.0.5 → charlie (1 autor)
      create(:post, user: user_c, ip: '10.0.0.5')

      # alice posta de outro IP também
      create(:post, user: user_a, ip: '10.0.0.5')
    end

    it 'returns status 200' do
      get '/api/v1/ips'
      expect(response).to have_http_status(:ok)
    end

    it 'groups logins by ip' do
      get '/api/v1/ips'
      json = response.parsed_body

      ip_192 = json.find { |entry| entry['ip'] == '192.168.1.1' }
      expect(ip_192['logins']).to contain_exactly('alice', 'bob')
    end

    it 'includes all distinct logins for shared ips' do
      get '/api/v1/ips'
      json = response.parsed_body

      ip_10 = json.find { |entry| entry['ip'] == '10.0.0.5' }
      # charlie e alice postaram desse IP
      expect(ip_10['logins']).to contain_exactly('charlie', 'alice')
    end

    it 'returns an array with ip and logins fields' do
      get '/api/v1/ips'
      json = response.parsed_body

      expect(json.first.keys).to contain_exactly('ip', 'logins')
    end
  end
end
