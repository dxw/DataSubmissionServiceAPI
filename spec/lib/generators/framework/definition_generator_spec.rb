require 'rails_helper'
require 'generators/framework/definition_generator'

RSpec.describe Framework::DefinitionGenerator, type: :generator do
  let(:destination)      { Rails.root.join('tmp', 'generator_results') }
  let(:definitions_root) { 'app/models/framework/definition' }

  subject(:definition) { @definition }

  before do
    assert_file(File.join(definitions_root, expected_definition_file)) do |definition|
      @definition = definition
    end
  end

  context 'RM3786 – General Legal Services' do
    let(:generator_arguments)      { %w[RM3786] }
    let(:expected_definition_file) { 'RM3786.rb' }

    it 'has a class derived from Framework::Definition::Base' do
      expect(definition).to match 'class RM3786 < Base'
    end
    it 'Has the framework_short_name as class method metadata' do
      expect(definition).to match "framework_short_name 'RM3786'"
    end
    it 'Has the framework_name looked up from the MISO CSV' do
      expect(definition).to match(/framework_name\s+'General Legal Advice Services'/)
    end
    it 'has a Sheet class for Invoices' do
      expect(definition).to match 'Invoice < Sheet'
    end
    it 'defines the total value field for Invoices' do
      expect(definition).to match(/Invoice < Sheet.*\n\s+total_value_field 'Total Cost \(ex VAT\)'/i)
    end
    it 'has a Sheet class for Orders' do
      expect(definition).to match 'Order < Sheet'
    end
    it 'defines the total value field for Orders' do
      expect(definition).to match(/Order < Sheet.*\n\s+total_value_field 'Expected Total Order Value'/i)
    end
    it 'maps mandatory fields using exports_to' do
      expect(definition).to match "field 'Customer URN', :integer, exports_to: 'CustomerURN'"
    end
    it 'only defines fields that "! do not export"' do
      expect(definition).to match "field 'Cost Centre', :string"
    end
  end

  context 'CM/OSG/05/3565 – Laundry Wave 2' do
    let(:generator_arguments)      { %w[CM/OSG/05/3565] }
    let(:expected_definition_file) { 'CM_OSG_05_3565.rb' }

    it 'has an underscored class derived from Framework::Definition::Base' do
      expect(definition).to match 'class CM_OSG_05_3565 < Base'
    end
    it 'Has the original framework_short_name as class method metadata' do
      expect(definition).to match "framework_short_name 'CM/OSG/05/3565'"
    end
    it 'Has the framework_name looked up from the MISO CSV' do
      expect(definition).to match(/framework_name\s+'Laundry Services - Wave 2'/)
    end
    it 'has a Sheet class for Invoices' do
      expect(definition).to match 'Invoice < Sheet'
    end
    it 'has no Sheet class for Orders, as the CSV does not define any fields' do
      expect(definition).not_to match 'Order < Sheet'
    end
    it 'maps mandatory fields using the exports_to: option' do
      expect(definition).to match "field 'Customer URN', :integer, exports_to: 'CustomerURN'"
    end
    it 'does not map fields that "! do not export"' do
      expect(definition).to match "field 'Cost Centre', :string"
    end
  end

  context 'Single quotes in fields – RM3797' do
    let(:generator_arguments)      { %w[RM3797] }
    let(:expected_definition_file) { 'RM3797.rb' }

    it %(escapes the "Publisher's Name" field) do
      expect(definition).to include(%(field "Publisher's Name"))
    end
  end
end