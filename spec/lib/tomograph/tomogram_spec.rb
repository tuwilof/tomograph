require 'spec_helper'

RSpec.describe Tomograph::Tomogram do
  describe '#json' do
    subject {JSON.parse(described_class.new(drafter_yaml_path: documentation, prefix: '', drafter_yaml: nil).json)}
    let(:parsed) {MultiJson.load(File.read(json_schema))}
    let(:documentation) {nil}

    before do
      allow(Rails).to receive(:root).and_return("#{ENV['RBENV_DIR']}/spec/fixtures")
    end

    context 'if one action' do
      let(:json_schema) {'spec/fixtures/api2.json'}
      let(:documentation) {'api2.yaml'}

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'additional desription' do
      let(:json_schema) {'spec/fixtures/api16.json'}
      let(:documentation) {'api16.yaml'}

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'if two actions' do
      let(:json_schema) {'spec/fixtures/api3.json'}
      let(:documentation) {'api3.yaml'}

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'if two controllers and three actions' do
      let(:json_schema) {'spec/fixtures/api4.json'}
      let(:documentation) {'api4.yaml'}

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end

      context 'and separated data structures' do
        let(:json_schema) {'spec/fixtures/separated_data_structures.json'}
        let(:documentation) {'separated_data_structures.yaml'}

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end
    end

    context 'blank request' do
      let(:json_schema) {'spec/fixtures/api5.json'}
      let(:documentation) {'api5.yaml'}

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'action with comment' do
      let(:json_schema) {'spec/fixtures/api6.json'}
      let(:documentation) {'api6.yaml'}

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'action with his unique path' do
      let(:json_schema) {'spec/fixtures/api7.json'}
      let(:documentation) {'api7.yaml'}

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'if there is a description of the project' do
      context 'action with his unique path' do
        let(:json_schema) {'spec/fixtures/api8.json'}
        let(:documentation) {'api8.yaml'}

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'action with his unique path' do
        let(:json_schema) {'spec/fixtures/api9.json'}
        let(:documentation) {'api9.yaml'}

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end
    end

    context 'if the structure of the first' do
      let(:json_schema) {'spec/fixtures/api10.json'}
      let(:documentation) {'api10.yaml'}

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'if the structure of the first' do
      let(:json_schema) {'spec/fixtures/api11.json'}
      let(:documentation) {'api11.yaml'}

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'if two response with the same code' do
      let(:json_schema) {'spec/fixtures/api12.json'}
      let(:documentation) {'api12.yaml'}

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'if you forget to specify the type of response' do
      let(:json_schema) {'spec/fixtures/api13.json'}
      let(:documentation) {'api13.yaml'}

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'if you with to specify the type of request' do
      let(:json_schema) {'spec/fixtures/api14.json'}
      let(:documentation) {'api14.yaml'}

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'if you with to specify the type of response' do
      let(:json_schema) {'spec/fixtures/api15.json'}
      let(:documentation) {'api15.yaml'}

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'with request body' do
      let(:json_schema) {'spec/fixtures/api_builtin_scheme.json'}
      let(:documentation) {'api_builtin_scheme.yaml'}

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'with a broken schema' do
      let(:json_schema) {'spec/fixtures/api_with_broken_schema.json'}
      let(:documentation) {'api_with_broken_schema.yaml'}

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end
  end

  describe '#find_request' do
    let(:method) {'POST'}
    let(:tomogram) {[{}]}
    let(:path) {'/status'}

    let(:parsed) {MultiJson.load(File.read(json_schema))}
    before do
      allow(Rails).to receive(:root).and_return("#{ENV['RBENV_DIR']}/spec/fixtures")
      allow(Tomograph).to receive(:configuration).and_return(
        double(documentation: documentation, prefix: '', drafter_yaml: nil))
      allow(Tomograph::Documentation).to receive(:new).and_return(double(to_hash: {'content' => [{'content' => {}}]},
        groups: double(inject: tomogram)))
    end
    let(:json_schema) {'spec/fixtures/api2.json'}
    let(:documentation) {'api2.yaml'}

    context 'if not found in the tomogram' do
      it 'returns an empty string' do
        expect(subject.find_request(method: method, path: path)).to eq(nil)
      end
    end

    context 'if found in the tomogram' do
      let(:request1) {{'path' => '/status', 'method' => 'POST'}}
      let(:request2) {{'path' => '/status/{id}/test/{tid}.json', 'method' => 'DELETE'}}
      let(:tomogram) do
        [
          # Should not find these
          {'path' => '/status', 'method' => 'GET'},
          {'path' => '/status/{id}/test/{tid}.json', 'method' => 'GET'},
          {'path' => '/status/{id}/test/{tid}.csv', 'method' => 'DELETE'},
          {'path' => '/status/{id}/test/', 'method' => 'DELETE'},
          # Should find these
          request1,
          request2
        ]
      end

      context 'if slash at the end' do
        let(:path) {'/status/'}

        it 'return path withoud slash at the end' do
          expect(subject.find_request(method: method, path: path)).to include(request1)
        end
      end

      context 'if request with query parameters' do
        let(:path) {'/status/?a=b&c=d'}

        it 'ignores query parameters' do
          expect(subject.find_request(method: method, path: path)).to include(request1)
        end
      end

      context 'without parameters' do
        it 'return path' do
          expect(subject.find_request(method: method, path: path)).to include(request1)
        end
      end

      context 'with a parameter' do
        let(:path) {'/status/1/test/2.json'}
        let(:method) {'DELETE'}

        it 'returns the modified path' do
          expect(subject.find_request(method: method, path: path)).to include(request2)
        end
      end
    end

    context 'if inserted' do
      let(:request1) {MultiJson.load(File.read('spec/fixtures/request1.json'))}
      let(:request2) {MultiJson.load(File.read('spec/fixtures/request2.json'))}
      let(:request3) {MultiJson.load(File.read('spec/fixtures/request3.json'))}
      let(:tomogram) do
        [
          request1,
          request2,
          request3
        ]
      end
      let(:path) {'/users/37812539-99af-4d7c-b86f-b756e3d1a211/pokemons'}
      let(:method) {'GET'}

      it 'returns the modified path' do
        expect(subject.find_request(method: method, path: path)).to include(request3)
      end
    end
  end
end
