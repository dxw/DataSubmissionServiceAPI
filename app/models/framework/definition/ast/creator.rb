class Framework
  module Definition
    module AST
      # This transform exists for the express purpose of creating an AST for generating
      # an ActiveModel class with validations for a Framework
      class Creator < Parslet::Transform
        # Primitive type casts
        rule(string: simple(:s))      { String(s) }
        rule(decimal: simple(:d))     { BigDecimal(d) }
        rule(integer: simple(:i))     { Integer(i) }

        # Range simplifier
        rule(integer: sequence(:nil)) { nil } # .maybe produces { integer: [] } for empty

        # Lookup simplifier
        rule(lookup_reference: simple(:r))                { String(r) }

        # Just stripping Parslet::Slice
        rule(primitive: 'String', range: subtree(:range)) { { primitive: 'String', range: range } }
        rule(primitive: simple(:primitive))               { { primitive: String(primitive) } }
        rule(lookup: simple(:lookup))                     { { lookup: String(lookup) } }

        # match known fields only
        rule(field: simple(:field), from: simple(:from)) { { kind: :known, field: field.to_s, from: from.to_s } }
        rule(optional: simple(:optional), field: simple(:field), from: simple(:from)) do
          { kind: :known, optional: true, field: field.to_s, from: from.to_s }
        end
        rule(field: simple(:field), from: simple(:from), depends_on: subtree(:depends_on)) do
          { kind: :known, field: field.to_s, from: from.to_s, depends_on: depends_on }
        end

        # optional Additional field rule
        rule(optional: simple(:optional), type_def: subtree(:type), field: simple(:field), from: subtree(:from)) do
          { kind: :additional, optional: true, type: type, field: field.to_s, from: from }
        end

        # Additional field rule
        rule(type_def: subtree(:type), field: simple(:field), from: subtree(:from)) do
          { kind: :additional, type: type, field: field.to_s, from: from }
        end

        # Unknown fields rules
        rule(type_def: subtree(:type), from: simple(:from)) do
          { kind: :unknown, type: type, from: from }
        end

        rule(optional: simple(:optional), type_def: subtree(:type), from: simple(:from)) do
          { kind: :unknown, optional: true, type: type, from: from }
        end

        # Lookups
        # {
        #   lookup_name: 'UnitType',
        #   list: [{ :string => 'Day' }, { :string => 'Each' }]
        # } =>
        #   { 'UnitType' => ['Day', 'Each'] }
        rule(lookup_name: simple(:lookup_name), list: sequence(:values)) do
          { lookup_name.to_s => values }
        end

        #
        # Take a list of lookups like
        # { lookups: [{ 'UnitType' => ['Day', 'Each'] }, { 'Other' => ['Value 1', 'Value2'] }] }
        # and produce a simplified tree like
        # { 'UnitType' => ['Day', 'Each'], 'Other' => ['Value 1', 'Value 2'] }
        rule(lookups: subtree(:lookups)) do
          lookups.each_with_object({}) do |single_key_value, result|
            lookup_name, value_list = *single_key_value.first
            result[lookup_name] = value_list
          end
        end

        # dictionary key/value pairs
        rule(key: simple(:key), value: simple(:value)) { { key => value } }

        # Transform a CST sequence like [{ key1 => value1}, { key2 => value2}] to a
        # real hash                      { key1 => value1, key2 => value2 }
        rule(dictionary: subtree(:dictionary)) do
          dictionary.each_with_object({}) do |kv, result|
            result[kv.keys.first] = kv.values.first
          end
        end

        # Sector-based management charges need
        # keys like CentralGovernment transformed to :central_government
        rule(sector_based: subtree(:sector_kv)) do
          { sector_based: sector_kv.transform_keys { |key| key.to_s.underscore.to_sym } }
        end
      end
    end
  end
end