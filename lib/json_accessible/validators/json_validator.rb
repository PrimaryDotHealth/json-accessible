# frozen_string_literal: true

# Check for presence of keys in a JSON field. Can check for presence of nested keys too.
# Syntax:
# Require `field_name` to have an `a` key
#   validate :field_name, json: { includes: :a }
# Require `field_name` to both `a` and `b` keys
#   validate :field_name, json: { includes: [:a, :b] }
# Require `field_name` to include `a`, `b`, `b.c`, and `b.d`
#   validate :field_name, json: { includes: [:a, { b: [:c, :d] }] }
class JsonValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    value = JSON.parse(value) if value.is_a?(String)
    normalized_value = value&.with_indifferent_access
    validate_includes(record, attribute, normalized_value, options[:includes])
  end

  private
    def validate_includes(record, attribute, node, keys, path = [])
      if keys.is_a?(Hash)
        keys.each_pair do |k, child_keys|
          key_name = key_without_optional_suffix(k)
          if node.key?(key_name)
            validate_includes(record, attribute, node[key_name], child_keys, path + [key_name])
          elsif required?(k)
            add_error(record, attribute, node, path, k)
          end
        end
      else
        Array(keys).each do |key|
          if key.is_a?(Hash)
            validate_includes(record, attribute, node, key, path)
          elsif required?(key) && (node.nil? || node[key_without_optional_suffix(key)].nil?)
            add_error(record, attribute, node, path, key_without_optional_suffix(key))
          end
        end
      end
    end

    def key_without_optional_suffix(key)
      key.to_s.gsub("?", "")
    end

    def required?(key)
      !key.end_with?("?")
    end

    def add_error(record, attribute, _node, path, key)
      record.errors.add(attribute, "must include a `#{(path + [key]).join('.')}` key")
    end
end
