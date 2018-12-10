require 'rails_helper'

RSpec.describe SubmissionEntry do
  it { is_expected.to belong_to(:submission) }
  it { is_expected.to belong_to(:submission_file) }

  it { is_expected.to validate_presence_of(:data) }

  describe 'sheet scope' do
    let(:sheet_1_entry) { FactoryBot.create(:submission_entry, sheet_name: 'Sheet 1') }
    let(:another_sheet_1_entry) { FactoryBot.create(:submission_entry, sheet_name: 'Sheet 1') }
    let(:sheet_2_entry) { FactoryBot.create(:submission_entry, sheet_name: 'Sheet 2') }

    it 'returns entries for the specified sheet' do
      expect(SubmissionEntry.sheet('Sheet 1')).to contain_exactly(sheet_1_entry, another_sheet_1_entry)
      expect(SubmissionEntry.sheet('Sheet 2')).to contain_exactly(sheet_2_entry)
    end
  end

  describe 'sector scopes' do
    let(:home_office) { FactoryBot.create(:customer, :central_government, name: 'Home Office') }
    let(:health_dept) { FactoryBot.create(:customer, :central_government, name: 'Department for Health') }
    let(:bobs_charity) { FactoryBot.create(:customer, :wider_public_sector, name: 'Bob’s Charity') }

    let!(:home_office_entry) { FactoryBot.create(:submission_entry, customer_urn: home_office.urn) }
    let!(:health_dept_entry) { FactoryBot.create(:submission_entry, customer_urn: health_dept.urn) }
    let!(:bobs_charity_entry) { FactoryBot.create(:submission_entry, customer_urn: bobs_charity.urn) }

    it 'return entries for the specified sectors' do
      expect(SubmissionEntry.central_government).to contain_exactly(home_office_entry, health_dept_entry)
      expect(SubmissionEntry.wider_public_sector).to contain_exactly(bobs_charity_entry)
    end
  end

  describe 'ordered_by_row' do
    let!(:tenth_row) { FactoryBot.create(:submission_entry, row: 10) }
    let!(:first_row)  { FactoryBot.create(:submission_entry, row: 1) }
    let!(:second_row) { FactoryBot.create(:submission_entry, row: 2) }

    it 'returns entries ordered by their source row' do
      expect(SubmissionEntry.ordered_by_row).to eq [first_row, second_row, tenth_row]
    end
  end

  it 'is associated with a customer via the customer‘s URN' do
    customer = FactoryBot.create(:customer)
    submission_entry = FactoryBot.create(:submission_entry, customer_urn: customer.urn)

    expect(submission_entry.customer).to eq customer
  end

  describe 'validate_against_framework_definition!' do
    let!(:customer) { FactoryBot.create(:customer, urn: 12345678) }
    let(:framework) { FactoryBot.create(:framework, short_name: 'RM3767') }
    let(:submission) { FactoryBot.create(:submission, framework: framework) }
    let(:entry) { FactoryBot.create(:invoice_entry, submission: submission, data: data_hash) }
    let(:valid_data_hash) do
      {
        'Lot Number' => '1',
        'Customer URN' => '12345678',
        'Customer Organisation Name' => 'Organisation Name',
        'Customer Invoice Date' => '01/01/2018',
        'UNSPSC' => '1',
        'Total Cost (ex VAT)' => 12.34,
        'Run Flats (Y/N)' => 'N'
      }
    end

    before { entry.validate_against_framework_definition! }

    context 'with a valid data hash' do
      let(:data_hash) { valid_data_hash }

      it 'transitions state to validated' do
        expect(entry.reload).to be_validated
        expect(entry.validation_errors).to eq(nil)
      end
    end

    context 'with an invalid data hash' do
      let(:data_hash) { valid_data_hash.merge('UNSPSC' => nil) }

      it 'transitions state to errored' do
        expect(entry.reload).to be_errored
      end

      it 'sets the validation errors' do
        expect(entry.validation_errors).to eq(
          [
            {
              'message' => 'is not a number',
              'location' => {
                'row' => entry.source['row'],
                'column' => 'UNSPSC',
              },
            }
          ]
        )
      end
    end
  end
end
