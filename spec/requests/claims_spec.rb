require 'swagger_helper'

RSpec.describe 'Claims API', type: :request do
  path '/claims/{id}/delete' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('delete claim') do
      response(204, 'successful') do
        let(:id) { '2' }

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

  path '/claims' do

    get('list claims') do
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

    post('create claim') do
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

  path '/claims/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show claim') do
      response(200, 'successful') do
        let(:id) { '2' }

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

    patch('update claim') do
      response(204, 'successful') do
        let(:id) { '2' }

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

    put('update claim') do
      response(204, 'successful') do
        let(:id) { '2' }

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

    delete('delete claim') do
      response(204, 'successful') do
        let(:id) { '2' }

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
