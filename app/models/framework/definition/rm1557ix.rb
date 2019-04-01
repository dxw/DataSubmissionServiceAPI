class Framework
  module Definition
    class RM1557ix < Base
      framework_short_name 'RM1557ix'
      framework_name 'G-Cloud 9'

      management_charge ManagementChargeCalculator::FlatRate.new(percentage: BigDecimal('0.75'))

      UNIT_OF_MEASURE_VALUES = [
        'Per Unit',
        'Per User'
      ].freeze

      LOT_1_SERVICES = [
        'Archiving, Backup and Disaster Recovery',
        'Block Storage',
        'Compute and Application Hosting',
        'Container Service',
        'Content Delivery Network',
        'Data Warehousing',
        'Database',
        'Distributed Denial of Service Attack (DDOS) Protection',
        'Firewall',
        'Infrastructure and Platform Security',
        'Intrusion Detection',
        'Load Balancing',
        'Logging and Analysis',
        'Message Queuing and Processing',
        'Networking (including Network as a Service)',
        'NoSQL database',
        'Object Storage',
        'Platform as a Service (PaaS)',
        'Protective Monitoring',
        'Relational Database',
        'Search',
        'Storage',
      ].freeze

      LOT_2_SERVICES = [
        'Accounting and Finance',
        'Analytics and Business Intelligence',
        'Application Security',
        'Collaborative Working',
        'Creative, Design and Publishing',
        'Customer Relationship Management (CRM)',
        'Electronic Document and Records Management (EDRM)',
        'Healthcare',
        'Human Resources and Employee Management',
        'Information and Communication Technology (ICT)',
        'Legal and Enforcement',
        'Marketing',
        'Operations Management',
        'Project management and Planning',
        'Sales',
        'Schools, Education and Libraries',
        'Software Development Tools',
        'Transport and Logistics',
      ].freeze

      LOT_3_SERVICES = [
        'Ongoing Support',
        'Planning',
        'Setup and Migration',
        'Testing',
        'Training',
      ].freeze

      MAPPING = {
        'Lot Number' => {
          '1' => LOT_1_SERVICES,
          '2' => LOT_2_SERVICES,
          '3' => LOT_3_SERVICES,
        }
      }.freeze

      class Invoice < EntryData
        total_value_field 'Total Charge (Ex VAT)'

        field 'Buyer Cost Centre', :string
        field 'Call Off Contract Reference', :string, exports_to: 'SupplierReferenceNumber', presence: true
        field 'Buyer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Buyer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Buyer Post Code', :string, exports_to: 'CustomerPostCode', presence: true
        field 'Invoice Date', :string, exports_to: 'CustomerInvoiceDate', ingested_date: true, presence: true
        field 'Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Service Group', :string, exports_to: 'ProductGroup', presence: true, dependent_field_inclusion: { parent: 'Lot Number', in: MAPPING }
        field 'Digital Marketplace Service ID', :string, exports_to: 'ProductGroup', ingested_numericality: { only_integer: true }, presence: true
        field 'UNSPSC', :string, exports_to: 'UNSPSC', ingested_numericality: { only_integer: true }, presence: true
        field 'Unit of Purchase', :string, exports_to: 'UnitType', case_insensitive_inclusion: { in: UNIT_OF_MEASURE_VALUES }
        field 'Price per Unit', :string, exports_to: 'UnitPrice', ingested_numericality: true, presence: true
        field 'Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: true, presence: true
        field 'Total Charge (Ex VAT)', :string, exports_to: 'InvoiceValue', ingested_numericality: true, presence: true
        field 'VAT amount charged', :string, exports_to: 'VATCharged', ingested_numericality: true, presence: true
        field 'Expenses/Disbursements', :string, exports_to: 'Expenses', ingested_numericality: true, presence: true
      end

      class Order < EntryData
        total_value_field 'Call Off Value'

        field 'Call Off Contract Reference', :string, exports_to: 'SupplierReferenceNumber', presence: true
        field 'Buyer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Buyer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Buyer Post Code', :string, exports_to: 'CustomerPostCode', presence: true
        field 'Buyer Contact Name', :string
        field 'Buyer Contact Number', :string
        field 'Buyer Email Address', :string
        field 'Buyer Call Off Start Date', :string, exports_to: 'ContractStartDate', ingested_date: true, presence: true
        field 'Call Off End Date', :string, exports_to: 'ContractEndDate', ingested_date: true, presence: true
        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Service Group', :string, exports_to: 'ProductGroup', presence: true, dependent_field_inclusion: { parent: 'Lot Number', in: MAPPING }
        field 'Digital Marketplace Service ID', :string, exports_to: 'ProductGroup', ingested_numericality: { only_integer: true }, presence: true
        field 'Call Off Value', :string, exports_to: 'ContractValue', ingested_numericality: true, presence: true
      end
    end
  end
end
