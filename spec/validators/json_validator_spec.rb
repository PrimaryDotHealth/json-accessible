# frozen_string_literal: true

require 'rails_helper'

MockModel = Struct.new(:json, keyword_init: true) do
  require ActiveModel::Validations
  validates :json, json: { includes: [:username, :password, :optional?, { nested: { child: %i[grandchild] } }] }
end

RSpec.describe JsonValidator do
  let(:json) do
    {
      username: 'abc',
      password: 'def',
      options: 'ghi',
      nested: {
        child: {
          grandchild: true
        }
      }
    }
  end
  describe '`includes`' do
    it 'requires the JSON attribute to include all the keys' do
      record = MockModel.new(json: json)
      expect(record).to be_valid
    end

    context 'with string keys' do
      it 'requires the JSON attribute to include all the keys' do
        record = MockModel.new(json: json.deep_stringify_keys)
        expect(record).to be_valid
      end
    end

    context 'when an optional (ending in `?`) key is missing' do
      before { json.delete(:optional) }

      it 'is valid' do
        record = MockModel.new(json: json)
        expect(record).to be_valid
      end
    end

    context 'when a key is missing' do
      before { json.delete(:password) }

      it 'adds an error' do
        record = MockModel.new(json: json)
        expect(record).to be_invalid
        expect(record.errors[:json]).to include(/must include a `password` key/)
      end
    end

    context 'when a required key has a null value' do
      before { json[:password] = nil }

      it 'adds an error' do
        record = MockModel.new(json: json)
        expect(record).to be_invalid
        expect(record.errors[:json]).to include(/must include a `password` key/)
      end
    end

    context 'when a nested key is missing' do
      before { json[:nested].delete(:child) }

      it 'adds an error' do
        record = MockModel.new(json: json)
        expect(record).to be_invalid
        expect(record.errors[:json]).to include('must include a `nested.child` key')
      end
    end
  end
end
