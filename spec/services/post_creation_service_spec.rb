# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PostCreationService do
  describe '.call' do
    context 'with valid params' do
      let(:params) do
        { title: 'New Post', body: 'New Body', login: 'joao', ip: '10.0.0.1' }
      end

      it 'creates a post' do
        result = described_class.call(params)

        expect(result.success?).to be true
        expect(result.data[:post].title).to eq('New Post')
        expect(result.data[:post].user.login).to eq('joao')
        expect(result.data[:post].ip).to eq('10.0.0.1')
      end

      it 'creates a new user when login does not exist' do
        expect { described_class.call(params) }.to change(User, :count).by(1)
      end

      it 'reuses existing user' do
        create(:user, login: 'joao')
        expect { described_class.call(params) }.not_to(change(User, :count))
      end
    end

    context 'with invalid params' do
      let(:params) do
        { title: '', body: 'Body', login: 'joao', ip: '1.1.1.1' }
      end

      it 'returns failure with errors' do
        result = described_class.call(params)

        expect(result.success?).to be false
        expect(result.error).to include("Title can't be blank")
      end
    end

    context 'when user already exists' do
      before { create(:user, login: 'joao') }

      let(:params) { { title: 'Post', body: 'Body', login: 'joao', ip: '1.1.1.1' } }

      it 'reuses the user and creates the post' do
        result = described_class.call(params)

        expect(result.success?).to be true
        expect(result.data[:user].login).to eq('joao')
        expect(result.data[:post].title).to eq('Post')
      end
    end
  end
end
