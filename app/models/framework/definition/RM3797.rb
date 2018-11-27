class Framework
  module Definition
    class RM3797 < Base
      framework_short_name 'RM3797'
      framework_name       'Journal Subscriptions'

      management_charge_rate BigDecimal('1')

      class Invoice < Sheet
        total_value_field 'Total Charge (Ex VAT)'

        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode', presence: true
        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber'
        field 'Product Group', :string, exports_to: 'ProductGroup'
        field 'Publisher Name', :string, exports_to: 'ProductClass'
        field 'Product Description', :string, exports_to: 'ProductDescription'
        field 'Crown Commercial Service Unique Product Codes', :string, exports_to: 'ProductCode'
        field 'UNSPSC', :string, exports_to: 'UNSPSC', ingested_numericality: { only_integer: true }, allow_nil: true
        field 'Unit of Measure', :string, exports_to: 'UnitType'
        field 'Price per Unit', :string, exports_to: 'UnitPrice', ingested_numericality: true, allow_nil: true
        field 'Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: true, allow_nil: true
        field 'Total Charge (Ex VAT)', :string, exports_to: 'InvoiceValue', ingested_numericality: true
        field 'VAT amount charged', :string, exports_to: 'VATCharged', ingested_numericality: true
        field 'Cost Centre', :string
        field 'Contract Number', :string
        field 'Publisher List Price', :string, exports_to: 'Additional2', ingested_numericality: true, allow_nil: true
      end
    end
  end
end
