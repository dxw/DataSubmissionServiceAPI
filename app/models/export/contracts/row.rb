module Export
  class Contracts
    class Row < Export::CsvRow
      alias_method :contract, :model

      def row_values
        puts contract.data.inspect
        [
          contract.submission_id,
          value_for('CustomerURN')
        ]
      end

      (1..8).each do |n|
        define_method "additional#{n}" do
          value_for("Additional#{n}", default: nil)
        end
      end

      private

      def value_for(destination_field, default: NOT_IN_DATA)
        source_field = Export::Template.source_field_for(
          destination_field,
          contract._framework_short_name
        )
        contract.data.fetch(source_field, default)
      end
    end
  end
end
