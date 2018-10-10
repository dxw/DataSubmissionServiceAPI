require 'rails_helper'

RSpec.describe 'rake export:contracts', type: :task do
  let!(:complete_submission) do
    create :submission,
           aasm_state: 'completed',
           framework: create(:framework, short_name: 'RM3786')
  end

  let!(:contract) do
    # Explicit times are necessary because Export::Contracts::Extract.all_relevant
    # relies on order(:created_date)
    create :contract_entry, :legal_framework_contract_data, submission: complete_submission,
                                                            created_at: Time.zone.local(2018, 12, 25, 13, 55, 59)
  end

  let!(:contract2) do
    create :contract_entry, submission: complete_submission,
                            created_at: Time.zone.local(2018, 12, 25, 14, 55, 59)
  end

  let(:extracted_contracts) { Export::Contracts::Extract.all_relevant }

  context 'no args are given' do
    let(:output_filename) { '/tmp/contracts_2018-12-25.csv' }
    let(:args)            { {} }
    let(:output_lines)    { File.read(output_filename).split("\n") }

    around(:example) do |example|
      travel_to(Date.new(2018, 12, 25)) { example.run }
    end

    before do
      expect(contract.created_at).to be < contract2.created_at,
                                     'precondition: these specs depend on created_at order'
      task.execute(args)
    end
    after { File.delete(output_filename) }

    it 'writes a header to that output' do
      expect(output_lines.first).to eql(
        'SubmissionID,CustomerURN,CustomerName,CustomerPostCode,SupplierReferenceNumber,'\
        'CustomerReferenceNumber,LotNumber,ProductDescription,ProductGroup,ProductClass,ProductSubClass,ProductCode,'\
        'ProductLevel6,CustomerContactName,CustomerContactNumber,CustomerContactEmail,'\
        'ContractStartDate,ContractEndDate,ContractValue,ContractAwardChannel,'\
        'Additional1,Additional2,Additional3,Additional4,Additional5,Additional6,Additional7,Additional8'
      )
    end

    it 'writes each contract to that output' do
      expect(output_lines.length).to eql(3)
      expect(output_lines[1]).to eql(
        "#{contract.submission_id},10010915,Government Legal Department,WC1B 4ZZ,471600.00001,"\
        'DWP - Claim by Mr I Dontexist,1,Contentious Employment,,,,,,,,,'\
        '6/27/18,6/27/20,5000.00,Further Competition,N/A,N,Central Government Department,N,0.00,15,,'
      )
    end

    it 'writes #NOTINDATA for fields it cannot map' do
      expect(output_lines[2]).to eql(
        "#{contract2.submission_id},#NOTINDATA,#NOTINDATA,#NOTINDATA,#NOTINDATA,,#NOTINDATA," \
        ',,,,,,,,,' \
        '#NOTINDATA,#NOTINDATA,#NOTINDATA,#NOTINDATA,,,,,,,,'
      )
    end

    it 'has as many headers as row values' do
      expect(Export::Contracts::HEADER.length).to eql(
        Export::Contracts::Row.new(extracted_contracts.first).row_values.length
      )
    end
  end
end