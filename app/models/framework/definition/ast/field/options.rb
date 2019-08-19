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

            options.merge!(PRIMITIVE_TYPE_VALIDATIONS.fetch(field.primitive_type))

            options.delete(:presence) if no_presence_required?
            set_optional_modifiers! if field.optional?

            add_inclusion_validators(lookup_values)
            set_length_options!

            options
          end

          private

          def add_inclusion_validators(lookup_values)
            options[:case_insensitive_inclusion] = { in: lookup_values } if lookup_values&.any?
            options[:dependent_field_inclusion] =  { parent: field.dependent_fields, in: { field.dependent_fields => field.dependent_field_inclusion_values } } if field.dependent_field_inclusion?
          end

          def set_length_options!
            options[:length] = field.length_options if field.length_options.any?
          end

          def no_presence_required?
            # UrnValidator doesn't require an accompanying +presence: true+
            # IngestedNumericality validator treats nil as an error so should
            # have +allow_nil: true+ for optional fields, not +presence: true+ for mandatory fields
            %i[urn decimal integer date].include?(field.primitive_type)
          end

          def set_optional_modifiers!
            options.delete(:presence)
            options[:allow_nil] = true if field.validators?
          end
        end
      end
    end
  end
end
