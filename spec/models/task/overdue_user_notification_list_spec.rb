require 'rails_helper'
require 'stringio'

RSpec.describe Task::OverdueUserNotificationList do
  subject(:generator) { Task::OverdueUserNotificationList.new(year: year, month: month, output: output) }

  describe '#generate' do
    let(:output) { StringIO.new }

    before { stub_govuk_bank_holidays_request }

    context 'there are incomplete submissions for the month in question' do
      let(:year)  { 2019 }
      let(:month) { 1 }

      let(:alice)      { create :user, name: 'Alice Example', email: 'alice@example.com' }
      let(:bob)        { create :user, name: 'Bob Example', email: 'bob@example.com' }
      let(:charley)    { create :user, name: 'Charley Goodsupplier', email: 'charley.goodsupplier@example.com' }
      let(:frank)      { create(:user, :inactive, name: 'Frank Inactive', email: 'frank.inactive@example.com') }

      before do
        framework1 = create :framework, short_name: 'RM0001'
        framework2 = create :framework, short_name: 'RM0002'
        framework3 = create :framework, short_name: 'COMPLETE0001'

        supplier_a = create(:supplier, name: 'Supplier A')
        supplier_b = create(:supplier, name: 'Supplier B')
        supplier_c = create(:supplier, name: 'Supplier C')

        create :membership, user: alice, supplier: supplier_a
        create :membership, user: alice, supplier: supplier_b
        create :membership, user: bob, supplier: supplier_b
        create :membership, user: frank, supplier: supplier_b
        create :membership, user: charley, supplier: supplier_c

        create :task, supplier: supplier_a, framework: framework1, period_month: 1
        create :task, supplier: supplier_a, framework: framework2, period_month: 1
        create :task, supplier: supplier_b, framework: framework1, period_month: 1

        create :task, :completed, supplier: supplier_a, framework: framework3
        create :task, :completed, supplier: supplier_c, framework: framework1

        generator.generate
      end

      subject(:lines) { output.string.split("\n") }

      it 'has a header row that lists all the frameworks' do
        expect(lines.first).to eql(
          'email address,due_date,person_name,supplier_name,reporting_month,COMPLETE0001,RM0001,RM0002'
        )
      end

      it 'has a line for each user and supplier, listing the frameworks they have late tasks for' do
        expect(lines.size).to eq 4
        expect(lines).to include('alice@example.com,7 February 2019,Alice Example,Supplier A,January 2019,no,yes,yes')
        expect(lines).to include('alice@example.com,7 February 2019,Alice Example,Supplier B,January 2019,no,yes,no')
        expect(lines).to include('bob@example.com,7 February 2019,Bob Example,Supplier B,January 2019,no,yes,no')
      end

      it 'does not include inactive users' do
        expect(output.string).not_to include('Frank Inactive')
      end

      it 'does not include suppliers with no incomplete submissions' do
        expect(output.string).not_to include('Charley Goodsupplier')
      end
    end
  end
end
