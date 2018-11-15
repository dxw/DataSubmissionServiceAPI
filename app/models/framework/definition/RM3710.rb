class Framework
  module Definition
    class RM3710 < Base
      framework_short_name 'RM3710'
      framework_name       'Vehicle Lease and Fleet Management'

      management_charge_rate BigDecimal('0.5')

      class Invoice < Sheet
        total_value_field 'Total Charge (Ex VAT)'

        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer PostCode', :string, exports_to: 'CustomerPostCode'
        field 'Customer Organisation', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Invoice Date', :date, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Unit of Purchase', :string, exports_to: 'UnitType', presence: true
        field 'Price per Unit (Ex VAT)', :decimal, exports_to: 'UnitPrice', numericality: true
        field 'Quantity', :decimal, exports_to: 'UnitQuantity', numericality: true
        field 'Total Charge (Ex VAT)', :decimal, exports_to: 'InvoiceValue', numericality: true
        field 'VAT Applicable', :string, exports_to: 'VATIncluded', presence: true
        field 'VAT amount charged', :decimal, exports_to: 'VATCharged', numericality: true
        field 'CAP Code', :string, exports_to: 'ProductCode', presence: true
        field 'Vehicle Make', :string, exports_to: 'ProductClass', presence: true
        field 'Vehicle Model', :string, exports_to: 'ProductSubClass', presence: true
        field 'Product Description - Vehicle Derivative / Fleet Management Services', :string, exports_to: 'ProductDescription', presence: true
        field 'Product Classification', :string, exports_to: 'ProductGroup', presence: true
        field 'UNSPSC', :integer, exports_to: 'UNSPSC', numericality: { only_integer: true }
        field 'Cost Centre', :string
        field 'Contract Number', :string
        field 'Subcontractor Supplier Name', :string, exports_to: 'Additional2', presence: true
        field 'Vehicle Registration', :string, exports_to: 'Additional1', presence: true
        field 'Fuel Type', :string, exports_to: 'Additional4', presence: true
        field 'CO2 Emission Levels', :decimal, exports_to: 'Additional3', numericality: true
        field 'Vehicle Convertors Name', :string, exports_to: 'Additional5', presence: true
        field 'Vehicle Conversion Type', :string, exports_to: 'Additional6', presence: true
        field 'Vehicle Type', :string, exports_to: 'Additional7', presence: true
        field 'Lease Start Date', :date, exports_to: 'Additional8', ingested_date: true
        field 'Lease End Date', :date, ingested_date: true
        field 'Lease Period (Months)', :integer, numericality: { only_integer: true }
        field 'Payment Profile', :string, presence: true
        field 'Annual Lease Mileage', :decimal, numericality: true
        field 'Base Vehicle Price ex VAT', :decimal, numericality: true
        field 'Lease Finance Charge ex VAT', :decimal, numericality: true
        field 'Annual Service Maintenance & Repair Costs ex VAT', :decimal, numericality: true
        field 'Residual Value', :decimal, numericality: true
        field 'Total Manufacturer Discount (%)', :decimal, numericality: true
        field 'Spend Code', :string, exports_to: 'PromotionCode', presence: true
      end
    end
  end
end
