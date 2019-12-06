require 'csv'

module Export
  class Submissions < ToIO
    HEADER = %w[
      TaskID
      SubmissionID
      Status
      SubmissionType
      SubmissionFileType
      ContractEntryCount
      ContractValue
      CCSManagementChargeValue
      CCSManagementChargeRate
      CreatedDate
      CreatedBy
      SupplierApprovedDate
      SupplierApprovedBy
      FinanceExportDate
      PONumber
    ].freeze
  end
end
