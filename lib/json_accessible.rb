# frozen_string_literal: true

require_relative 'json_accessible/version'

module JsonAccessible
  extend ActiveSupport::Concern

  class_methods do
    def json_accessor(json_field, keys, parent_path = [])
      keys.each do |key|
        if key.is_a? Hash
          key.each do |name, values|
            name = key_without_optional_suffix(name)
            define_json_accessors(json_field, name, parent_path)
            json_accessor(json_field, values, parent_path + [name])
          end
        else
          key = key_without_optional_suffix(key)
          define_json_accessors(json_field, key, parent_path)
        end
      end

      validates json_field, json: { includes: keys } if parent_path.empty?
    end

    private

    def key_without_optional_suffix(key)
      key.to_s.delete('?')
    end

    def define_json_accessors(json_field, key, parent_path = [])
      method_name = (parent_path + [key]).join('_')
      define_json_reader(method_name, json_field, key, parent_path)
      define_json_writer(method_name, json_field, key, parent_path)
    end

    def define_json_reader(method_name, json_field, key, parent_path)
      define_method method_name do
        if parent_path.present?
          (send(parent_path.join('_')) || {})[key.to_s]
        else
          self[json_field][key.to_s]
        end
      end
    end

    def define_json_writer(method_name, json_field, key, parent_path)
      define_method "#{method_name}=" do |value|
        parent_method = parent_path.join('_')
        if parent_path.present?
          send("#{parent_method}=", {}) if send(parent_method).nil?
          send(parent_path.join('_'))[key.to_s] = value
        else
          self[json_field] ||= {}
          self[json_field][key.to_s] = value
        end
      end
    end
  end
end
