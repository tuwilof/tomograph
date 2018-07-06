require 'spec_helper'
require 'tomograph/api_blueprint/json_schema'

RSpec.describe Tomograph::ApiBlueprint::JsonSchema do
  context 'given JSON with two actions' do
    subject { described_class.new('', input_file) }
    let(:input_file) { 'spec/fixtures/api3.json' }
    let(:tomogram_hash) do
      [{"path"=>Tomograph::Path.new("/sessions"),
        "method"=>"POST",
        "content-type"=>"application/json",
        "request"=>
        {"$schema"=>"http://json-schema.org/draft-04/schema#",
         "type"=>"object",
         "properties"=>
         {"login"=>{"type"=>"string"},
          "password"=>{"type"=>"string"},
          "captcha"=>{"type"=>"string"}},
         "required"=>["login", "password"]},
        "responses"=>
        [{"status"=>"401", "body"=>{}, "content-type"=>"application/json"},
         {"status"=>"429", "body"=>{}, "content-type"=>"application/json"},
         {"status"=>"201",
          "body"=>
          {"$schema"=>"http://json-schema.org/draft-04/schema#",
           "type"=>"object",
           "properties"=>
           {"confirmation"=>
            {"type"=>"object",
             "properties"=>
             {"id"=>{"type"=>"string"},
              "type"=>{"type"=>"string"},
              "operation"=>{"type"=>"string"}},
             "required"=>["id", "type", "operation"]},
            "captcha"=>{"type"=>"string"},
            "captcha_does_not_match"=>{"type"=>"boolean"}}},
          "content-type"=>"application/json"}],
        "resource"=>"/sessions"},
       {"path"=>Tomograph::Path.new("/sessions/{id}"),
        "method"=>"DELETE",
        "content-type"=>"application/json",
        "request"=>
        {"$schema"=>"http://json-schema.org/draft-04/schema#",
         "type"=>"object",
         "properties"=>{"status"=>{"type"=>"string"}},
         "required"=>["status"]},
        "responses"=>
        [{"status"=>"401", "body"=>{}, "content-type"=>"application/json"},
         {"status"=>"423", "body"=>{}, "content-type"=>"application/json"},
         {"status"=>"200",
          "body"=>
          {"$schema"=>"http://json-schema.org/draft-04/schema#",
           "type"=>"object",
           "properties"=>{"status"=>{"type"=>"string"}},
           "required"=>["status"]},
          "content-type"=>"application/json"}],
        "resource"=>"/sessions"}]
    end
    let(:resource_map) do
      {"/sessions"=>["POST /sessions", "DELETE /sessions/{id}"]}
    end

    it 'produces correct Tomogram' do
      expect(subject.to_tomogram.map(&:to_hash)).to eq(tomogram_hash)
    end

    it 'produces correct resource map' do
      expect(subject.to_resources).to eq(resource_map)
    end
  end

end
