require 'csv'

module Export
  # Used to generate reports summarising submissions in the format needed for
  # feeding into Coda, the CCS finance system.
  class CodaFinanceReport
    attr_reader :submissions, :output

    HEADERS = [
      'RunID',
      'Nominal',
      'Customer Code',
      'Customer Name',
      'Contract ID',
      'Order Number',
      'Lot Description',
      'Inf Sales',
      'Commission',
      'Commission %',
      'End User',
      'Submitter',
      'Month',
      'M_Q'
    ].freeze

    def initialize(submissions, output)
      @submissions = submissions
      @output = output
    end

    def run
      output.puts CSV.generate_line(HEADERS)
      submissions.each do |submission|
        output.puts(CSV.generate_line(row_for_submission(submission, Customer.sectors[:central_government])))
        output.puts(CSV.generate_line(row_for_submission(submission, Customer.sectors[:wider_public_sector])))
      end
    end

    private

    def row_for_submission(submission, sector)
      data = Row.new(submission, sector).data

      [
        data['RunID'],
        data['Nominal'],
        data['Customer Code'],
        data['Customer Name'],
        data['Contract ID'],
        data['Order Number'],
        data['Lot Description'],
        data['Inf Sales'],
        data['Commission'],
        data['Commission %'],
        data['End User'],
        data['Submitter'],
        data['Month'],
        monthly_or_quarterly
      ]
    end

    # Used to indicate if the data in the report is for monthly or quarterly
    # submissions. In reality, only monthly submissions are supported by both
    # the legacy and the new system and quarterly frameworks (of which there is
    # one?) is handled manually by CCS.
    def monthly_or_quarterly
      'M'
    end
  end
end