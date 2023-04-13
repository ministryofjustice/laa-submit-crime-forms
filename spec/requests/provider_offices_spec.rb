require 'swagger_helper'

RSpec.describe 'Claims API', type: :request do
  path '/provider_offices/{id}/delete' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('delete provider office') do
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

  path '/provider_offices' do

    get('list provider_offices') do
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

    post('create provider office') do
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

  path '/provider_offices/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show provider office') do
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

    patch('update provider office') do
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

    put('update provider office') do
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

    delete('delete provider office') do
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
