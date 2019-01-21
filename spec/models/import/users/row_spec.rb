require 'rails_helper'

RSpec.describe Import::Users::Row do
  describe '#import!' do
    let(:email) { 'bob@bob.com' }
    let(:name) { 'Bob Burton' }
    let(:salesforce_id) { 'SALESFORCE123' }

    let!(:matching_supplier) { FactoryBot.create(:supplier, salesforce_id: salesforce_id) }
    let!(:auth0_create_call) { stub_auth0_create_user_request(email) }

    let(:row) { Import::Users::Row.new(email: email, name: name, supplier_salesforce_id: salesforce_id) }

    let(:result) { row.import! }

    before { stub_auth0_token_request }

    context 'with a new user’s details' do
      it 'returns a user matching the details' do
        expect(result).to be_a(User)
        expect(result).to be_persisted
        expect(result.email).to eq(email)
        expect(result.name).to eq(name)
      end

      it 'connects the user to auth0' do
        expect(result.auth_id).to eq("auth0|#{email}")
        expect(auth0_create_call).to have_been_requested
      end

      it 'associates the user with its supplier' do
        expect(result.suppliers).to contain_exactly(matching_supplier)
      end

      context 'when Auth0 errors' do
        let!(:auth0_create_call) { stub_auth0_create_user_request_failure(email) }

        it 'does not save the user' do
          expect { row.import! }.to raise_error(Auth0::ServerError)
          expect(User.find_by(email: email)).to be_nil
        end
      end
    end

    context 'with a pre-existing user' do
      let!(:existing_user) { FactoryBot.create(:user, email: email) }

      it 'associates the existing user with the supplier' do
        expect(result).to eq existing_user
        expect(existing_user.suppliers).to contain_exactly(matching_supplier)
      end

      it 'doesn’t make any Auth0 calls' do
        expect(auth0_create_call).not_to have_been_requested
      end
    end
  end
end