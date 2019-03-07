class Framework
  module Definition
    module AST
      class Field
        class Options
          attr_reader :field, :options
          def initialize(field)
            @field = field
            @options = { presence: true }
          end

          def build(lookup_values)
            options[:exports_to] = field.warehouse_name

            add_known_type_validations! if field.known?
            options.delete(:presence) if field.type == :urn # The URN validator covers this
            set_optional_modifiers! if field.optional?

            options[:case_insensitive_inclusion] = { in: lookup_values } if lookup_values&.any?
            options
          end

          private

          def set_optional_modifiers!
            options.delete(:presence)
            options[:allow_nil] = true if field.validators?
          end

          def add_known_type_validations!
            field_type = DataWarehouse::KnownFields.type_for(field.warehouse_name)
            options.merge!(TYPE_VALIDATIONS.fetch(field_type))
          end
        end
      end
    end
  end
end
