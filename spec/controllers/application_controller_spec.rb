require 'rails_helper'

describe ApplicationController do
  controller(ApplicationController) do
    def index
      render nothing: true
    end
  end

  context '#deep_snake_case_params!' do
    context 'for an array' do
      it 'converts nested keys from camelCase to snake_case' do
        array = [
          'camelCaseKey' => {
            'nestedCamelCaseKey' => [1, 2],
            'key' => 1
          }
        ]

        output = controller.send :deep_snake_case_params!, array
        expect(output).to eq([
          'camel_case_key' => {
            'nested_camel_case_key' => [1, 2],
            'key' => 1
          }
        ])
      end
    end

    context 'for a hash' do
      it 'converts nested keys from camelCase to snake_case' do
        hash = {
          'camelCaseKey' => {
            'nestedCamelCaseKey' => [1, 2],
            'key' => 1
          }
        }

        output = controller.send :deep_snake_case_params!, hash
        expect(output).to eq(
          'camel_case_key' => {
            'nested_camel_case_key' => [1, 2],
            'key' => 1
          }
        )
      end
    end

    context 'for ActionController parameters' do
      it 'converts nested keys from camelCase to snake_case' do
        params = ActionController::Parameters.new(
          'camelCaseKey' => {
            'nestedCamelCaseKey' => [1, 2],
            'key' => 1
          }
        )

        output = controller.send :deep_snake_case_params!, params
        expected_output = ActionController::Parameters.new(
          'camel_case_key' => {
            'nested_camel_case_key' => [1, 2],
            'key' => 1
          }
        )
        expect(output).to eq expected_output
      end
    end
  end
end
