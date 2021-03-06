module StringUtils
  US_DATE_FORMAT = %r(^(\d{1,2})\/(\d{1,2})\/(\d{2})$).freeze
  UK_DATE_FORMAT = %r(^(\d{1,2})\/(\d{1,2})\/(\d{4})$).freeze

  # Parses the two formats of dates that we currently see returned by the ingest
  # process: 'DD/MM/YYYY' and 'MM/DD/YY'
  #
  # Returns a Date if the string is a valid date, nil if it is not.
  def parse_date_string(value)
    case value
    when UK_DATE_FORMAT then Date.strptime(value, '%d/%m/%Y')
    end
  rescue ArgumentError
    nil
  end
end
