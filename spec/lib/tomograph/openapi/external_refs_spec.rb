require 'spec_helper'

describe Tomograph::Tomogram do
  subject(:tomogram) do
    described_class.new(
      openapi3_yaml_path: File.expand_path('spec/fixtures/openapi3/external/openapi.yaml'),
      prefix: ''
    )
  end

  def action(method, path)
    tomogram.to_a.find { |item| item.method == method && item.path.to_s == path }
  end

  it 'inlines external path files and component schema refs' do
    login = action('POST', '/auth').to_hash
    request = login['requests'].first

    expect(login['content-type']).to eq('application/json')
    expect(request['$ref']).to eq('#/components/schemas/LoginRequest')
    expect(request.dig('components', 'schemas', 'LoginRequest', 'required')).to eq(['email'])

    body = login['responses'].first['body']
    expect(body['oneOf'].map { |item| item['$ref'] }).to eq(
      ['#/components/schemas/LoginSuccess', '#/components/schemas/NotFoundError']
    )
    schemas = body.dig('components', 'schemas')
    expect(schemas.keys).to include('LoginSuccess', 'User', 'UserRole', 'NotFoundError')
    expect(schemas['LoginSuccess'].dig('properties', 'result', '$ref')).to eq('#/components/schemas/User')
    expect(schemas['User'].dig('properties', 'role', '$ref')).to eq('#/components/schemas/UserRole')
  end

  it 'resolves a response $ref from an external responses file' do
    logout = action('DELETE', '/auth').to_hash
    body = logout['responses'].first['body']

    expect(logout['responses'].first['status']).to eq('401')
    expect(body['$ref']).to eq('#/components/schemas/NotFoundError')
    expect(body.dig('components', 'schemas', 'NotFoundError', 'properties', 'status', 'enum')).to eq(['notFound'])
  end

  it 'turns OpenAPI nullable into a JSON Schema null type' do
    tomogram = described_class.new(
      openapi3_yaml_path: File.expand_path('spec/fixtures/openapi3/nullable.yml')
    )
    email = tomogram.to_a.first.to_hash['responses'].first['body'].dig('properties', 'email')

    expect(email['type']).to eq(%w[string null])
    expect(email).not_to have_key('nullable')
    expect(tomogram.to_a.first.to_hash['responses'].map { |response| response['body'] }.last).to eq({})
  end

  it 'reads a multipart request schema and ignores path-level parameters' do
    create = action('POST', '/campaigns').to_hash
    request = create['requests'].first

    expect(tomogram.to_a.map(&:method)).not_to include('PARAMETERS')
    expect(create['content-type']).to eq('multipart/form-data')
    expect(request['$ref']).to eq('#/components/schemas/CreateCampaignForm')
    expect(request.dig('components', 'schemas').keys).to include('CreateCampaignForm', 'TimeZone')
  end
end
