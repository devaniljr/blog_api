require 'rails_helper'

RSpec.describe 'Api::V1::Posts', type: :request do
  describe 'POST /api/v1/posts' do
    context 'with valid params' do
      let(:params) do
        { title: 'My post', body: 'My body', login: 'joao', ip: '192.168.1.1' }
      end

      it 'creates a new post' do
        expect { post '/api/v1/posts', params: params }.to change { Post.count }.by(1)
      end

      it 'creates a new user when login does not exist' do
        expect { post '/api/v1/posts', params: params }.to change { User.count }.by(1)
      end

      it 'returns status 201' do
        post '/api/v1/posts', params: params
        expect(response).to have_http_status(:created)
      end

      it 'returns the post and user in the response' do
        post '/api/v1/posts', params: params
        json = JSON.parse(response.body)

        expect(json['post']['title']).to eq('My post')
        expect(json['post']['body']).to eq('My body')
        expect(json['post']['ip']).to eq('192.168.1.1')
        expect(json['user']['login']).to eq('joao')
      end

      it 'reuses existing user when login already exists' do
        create(:user, login: 'joao')
        expect { post '/api/v1/posts', params: params }.to change { User.count }.by(0)
      end
    end

    context 'with invalid params' do
      let(:params) do
        { title: '', body: 'My body', login: 'joao', ip: '192.168.1.1' }
      end

      it 'does not create a post' do
        expect { post '/api/v1/posts', params: params }.not_to change { Post.count }
      end

      it 'returns status 422' do
        post '/api/v1/posts', params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns validation errors' do
        post '/api/v1/posts', params: params
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Title can't be blank")
      end
    end
  end
end
