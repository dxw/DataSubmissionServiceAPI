# The CSV file was generated with the help of db/data_migrate/filter_customers.rb
#
# Execute with:
#
#   rails runner db/data_migrate/20190327095400_import_march_customers.rb
#
require 'csv'
require 'progress_bar'

puts 'Reading CSV file...'
customers_csv_path = Rails.root.join('db', 'data_migrate', '20190327095400_import_march_customers.csv')
csv = CSV.read(customers_csv_path, headers: true, header_converters: :symbol)

puts 'Importing customers...'
bar = ProgressBar.new(csv.count)
csv.each do |customer_row|
  postcode = customer_row[:postcode] == 'XXXX' ? nil : customer_row[:postcode].strip.upcase.gsub(/[^A-Z0-9\ ]/, '')

  customer = Customer.find_or_initialize_by(urn: customer_row[:urn])
  customer.postcode = postcode
  customer.sector = customer_row[:sector].strip.parameterize.underscore
  customer.name = customer_row[:organisation].strip
  customer.save!

  bar.increment!
end
