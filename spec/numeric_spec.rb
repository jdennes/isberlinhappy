require 'spec_helper'

describe Numeric do
  describe '#fahrenheit_to_celsius' do
    it 'converts an integer representing fahrenheit to the equivalent integer in celsius' do
      result = 85.fahrenheit_to_celsius
      expect(result).to eq(29)
    end

    it 'converts a decimal representing fahrenheit to the equivalent decimal in celsius' do
      result = 85.35.fahrenheit_to_celsius
      expect((result * 100).round / 100.0).to eq(29.64)
    end
  end

  describe '#celsius_to_fahrenheit' do
    it 'converts an integer representing celsius to the equivalent integer in fahrenheit' do
      result = 29.celsius_to_fahrenheit
      expect(result).to eq(84)
    end

    it 'converts a decimal representing celsius to the equivalent decimal in fahrenheit' do
      result = 29.64.celsius_to_fahrenheit
      expect((result * 100).round / 100.0).to eq(85.35)
    end
  end
end
