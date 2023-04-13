require 'swagger_helper'

RSpec.describe 'Claims API', type: :request do
  path '/provider_solicitors/{id}/delete' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('delete provider solicitor') do
      response(204, 'successful') do
        let(:id) { '1' }

        after do |example|
          if response.body!=''
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names: true)
            }
          }
          end
        end
        run_test!
      end
    end
  end

  path '/provider_solicitors' do

    get('list provider_solicitors') do
      response(200, 'successful') do

        after do |example|
          if response.body!=''
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names: true)
            }
          }
          end
        end
        run_test!
      end
    end

    post('create provider solicitor') do
      response(204, 'successful') do

        after do |example|
          if response.body!=''
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names: true)
            }
          }
          end
        end
        run_test!
      end
    end
  end

  path '/provider_solicitors/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show provider solicitor') do
      response(200, 'successful') do
        let(:id) { '1' }

        after do |example|
          if response.body!=''
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names: true)
            }
          }
          end
        end
        run_test!
      end
    end

    patch('update provider solicitor') do
      response(204, 'successful') do
        let(:id) { '1' }

        after do |example|
          if response.body!=''
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names: true)
            }
          }
          end
        end
        run_test!
      end
    end

    put('update provider solicitor') do
      response(204, 'successful') do
        let(:id) { '1' }

        after do |example|
          if response.body!=''
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names: true)
            }
          }
          end
        end
        run_test!
      end
    end

    delete('delete provider solicitor') do
      response(204, 'successful') do
        let(:id) { '1' }

        after do |example|
          if response.body!=''
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names: true)
            }
          }
          end
        end
        run_test!
      end
    end
  end
end
