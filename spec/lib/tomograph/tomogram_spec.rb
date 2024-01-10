require 'spec_helper'

RSpec.describe Tomograph::Tomogram do
  context 'drafter 4' do
    describe '#to_json' do
      subject do
        JSON.parse(
          described_class.new(
            drafter_yaml_path: File.expand_path("spec/fixtures/drafter_4/#{documentation}"),
            prefix: ''
          ).to_json
        )
      end
      let(:parsed) { JSON.parse(File.read(json_schema)) }
      let(:documentation) { nil }

      context 'if one action' do
        let(:json_schema) { 'spec/fixtures/tomogram/api2.json' }
        let(:documentation) { 'api2.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'additional desription' do
        let(:json_schema) { 'spec/fixtures/tomogram/api16.json' }
        let(:documentation) { 'api16.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'if two actions' do
        let(:json_schema) { 'spec/fixtures/tomogram/api3.json' }
        let(:documentation) { 'api3.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'if two controllers and three actions' do
        let(:json_schema) { 'spec/fixtures/tomogram/api4.json' }
        let(:documentation) { 'api4.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end

        context 'and separated data structures' do
          let(:json_schema) { 'spec/fixtures/tomogram/separated_data_structures.json' }
          let(:documentation) { 'separated_data_structures.yaml' }

          it 'parses documents' do
            expect(subject).to eq(parsed)
          end
        end
      end

      context 'blank request' do
        let(:json_schema) { 'spec/fixtures/tomogram/api5.json' }
        let(:documentation) { 'api5.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'action with comment' do
        let(:json_schema) { 'spec/fixtures/tomogram/api6.json' }
        let(:documentation) { 'api6.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'action with his unique path' do
        let(:json_schema) { 'spec/fixtures/tomogram/api7.json' }
        let(:documentation) { 'api7.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'if there is a description of the project' do
        context 'action with his unique path' do
          let(:json_schema) { 'spec/fixtures/tomogram/api8.json' }
          let(:documentation) { 'api8.yaml' }

          it 'parses documents' do
            expect(subject).to eq(parsed)
          end
        end

        context 'action with his unique path' do
          let(:json_schema) { 'spec/fixtures/tomogram/api9.json' }
          let(:documentation) { 'api9.yaml' }

          it 'parses documents' do
            expect(subject).to eq(parsed)
          end
        end
      end

      context 'if the structure of the first' do
        let(:json_schema) { 'spec/fixtures/tomogram/api10.json' }
        let(:documentation) { 'api10.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'if the structure of the first' do
        let(:json_schema) { 'spec/fixtures/tomogram/api11.json' }
        let(:documentation) { 'api11.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'if two response with the same code' do
        let(:json_schema) { 'spec/fixtures/tomogram/api12.json' }
        let(:documentation) { 'api12.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'if you forget to specify the type of response' do
        let(:json_schema) { 'spec/fixtures/tomogram/api13.json' }
        let(:documentation) { 'api13.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'if you with to specify the type of request' do
        let(:json_schema) { 'spec/fixtures/tomogram/api14.json' }
        let(:documentation) { 'api14.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'if you with to specify the type of response' do
        let(:json_schema) { 'spec/fixtures/tomogram/api15.json' }
        let(:documentation) { 'api15.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'with request body' do
        let(:json_schema) { 'spec/fixtures/tomogram/api_builtin_scheme.json' }
        let(:documentation) { 'api_builtin_scheme.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'with a broken schema' do
        let(:json_schema) { 'spec/fixtures/tomogram/api_with_broken_schema.json' }
        let(:documentation) { 'api_with_broken_schema.yaml' }

        before { allow_any_instance_of(Kernel).to receive(:puts) }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'content-type' do
        let(:json_schema) { 'spec/fixtures/tomogram/content_type.json' }
        let(:documentation) { 'content_type.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'more than one request' do
        let(:json_schema) { 'spec/fixtures/tomogram/more_than_one_request.json' }
        let(:documentation) { 'more_than_one_request.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'oneOf' do
        let(:json_schema) { 'spec/fixtures/tomogram/api_oneOf.json' }
        let(:documentation) { 'api_oneOf.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end
    end

    describe '#find_request_with_content_type' do
      subject do
        described_class.new(
          drafter_yaml_path: File.expand_path("spec/fixtures/drafter_4/#{documentation}"),
          prefix: ''
        )
      end

      let(:method) { 'POST' }
      let(:tomogram) { [double(path: nil, method: nil)] }
      let(:path) { '/status' }
      let(:content_type) { 'application/json' }

      let(:parsed) { JSON.parse(File.read(json_schema)) }
      before do
        allow(Tomograph::ApiBlueprint::Drafter4::Yaml).to receive(:new).and_return(double(to_tomogram: tomogram))
      end
      let(:json_schema) { 'spec/fixtures/tomogram/api2.json' }
      let(:documentation) { 'api2.yaml' }

      context 'if not found in the tomogram' do
        it 'returns nil' do
          expect(subject.find_request_with_content_type(method: method,
                                                        path: path,
                                                        content_type: content_type)).to eq(nil)
        end
      end

      context 'without path' do
        it 'returns nil' do
          expect(subject.find_request_with_content_type(method: method,
                                                        path: nil,
                                                        content_type: content_type)).to eq(nil)
        end
      end

      context 'if found in the tomogram' do
        let(:request1) do
          double(method: 'POST', path: double(match: true, to_s: '/status'),
                 content_type: 'application/json')
        end
        let(:request2) do
          double(method: 'DELETE', path: double(match: true, to_s: '/status/{id}/test/{tid}.json'),
                 content_type: 'application/json')
        end
        let(:tomogram) do
          [
            # Should not find these
            double(path: '/status', method: 'GET'),
            double(path: '/status/{id}/test/{tid}.json', method: 'GET'),
            double(path: '/status/{id}/test/{tid}.csv', method: 'DELETE'),
            double(path: '/status/{id}/test/', method: 'DELETE'),
            # Should find these
            request1,
            request2
          ]
        end

        context 'if slash at the end' do
          let(:path) { '/status/' }

          it 'return path withoud slash at the end' do
            expect(subject.find_request_with_content_type(method: method,
                                                          path: path,
                                                          content_type: content_type)).to eq(request1)
          end
        end

        context 'if request with query parameters' do
          let(:path) { '/status/?a=b&c=d' }

          it 'ignores query parameters' do
            expect(subject.find_request_with_content_type(method: method,
                                                          path: path,
                                                          content_type: content_type)).to eq(request1)
          end
        end

        context 'without parameters' do
          it 'return path' do
            expect(subject.find_request_with_content_type(method: method,
                                                          path: path,
                                                          content_type: content_type)).to eq(request1)
          end
        end

        context 'with a parameter' do
          let(:path) { '/status/1/test/2.json' }
          let(:method) { 'DELETE' }

          it 'returns the modified path' do
            expect(subject.find_request_with_content_type(method: method,
                                                          path: path,
                                                          content_type: content_type)).to eq(request2)
          end
        end
      end

      context 'if inserted' do
        let(:req1) { JSON.parse(File.read('spec/fixtures/tomogram/request1.json')) }
        let(:req2) { JSON.parse(File.read('spec/fixtures/tomogram/request2.json')) }
        let(:req3) { JSON.parse(File.read('spec/fixtures/tomogram/request3.json')) }
        let(:request1) do
          double(
            path: req1['path'],
            method: req1['method'],
            content_type: 'application/json',
            request: req1['request'],
            responses: req1['responses']
          )
        end
        let(:request2) do
          double(
            path: req2['path'],
            method: req2['method'],
            content_type: 'application/json',
            request: req2['request'],
            responses: req2['responses']
          )
        end
        let(:request3) do
          double(
            method: req3['method'],
            content_type: 'application/json',
            request: req3['request'],
            responses: req3['responses'],
            path: double(match: true, to_s: req3['path'])
          )
        end
        let(:tomogram) do
          [
            request1,
            request2,
            request3
          ]
        end
        let(:path) { '/users/37812539-99af-4d7c-b86f-b756e3d1a211/pokemons' }
        let(:method) { 'GET' }

        it 'returns the modified path' do
          expect(subject.find_request_with_content_type(method: method,
                                                        path: path,
                                                        content_type: content_type)).to eq(request3)
        end
      end
    end

    describe '#find_request' do
      subject do
        described_class.new(
          drafter_yaml_path: File.expand_path("spec/fixtures/drafter_4/#{documentation}"),
          prefix: ''
        )
      end

      let(:method) { 'POST' }
      let(:tomogram) { [double(path: nil, method: nil)] }
      let(:path) { '/status' }
      let(:content_type) { 'application/json' }

      let(:parsed) { JSON.parse(File.read(json_schema)) }
      before do
        allow(Tomograph::ApiBlueprint::Drafter4::Yaml).to receive(:new).and_return(double(to_tomogram: tomogram))
      end
      let(:json_schema) { 'spec/fixtures/tomogram/api2.json' }
      let(:documentation) { 'api2.yaml' }

      context 'if not found in the tomogram' do
        it 'returns nil' do
          expect(subject.find_request(method: method, path: path)).to eq(nil)
        end
      end

      context 'without path' do
        it 'returns nil' do
          expect(subject.find_request(method: method, path: nil)).to eq(nil)
        end
      end

      context 'if found in the tomogram' do
        let(:request1) do
          double(method: 'POST', path: double(match: true, to_s: '/status'),
                 content_type: 'application/json')
        end
        let(:request2) do
          double(method: 'DELETE', path: double(match: true, to_s: '/status/{id}/test/{tid}.json'),
                 content_type: 'application/json')
        end
        let(:tomogram) do
          [
            # Should not find these
            double(path: '/status', method: 'GET'),
            double(path: '/status/{id}/test/{tid}.json', method: 'GET'),
            double(path: '/status/{id}/test/{tid}.csv', method: 'DELETE'),
            double(path: '/status/{id}/test/', method: 'DELETE'),
            # Should find these
            request1,
            request2
          ]
        end

        context 'if slash at the end' do
          let(:path) { '/status/' }

          it 'return path withoud slash at the end' do
            expect(subject.find_request(method: method, path: path)).to eq(request1)
          end
        end

        context 'if request with query parameters' do
          let(:path) { '/status/?a=b&c=d' }

          it 'ignores query parameters' do
            expect(subject.find_request(method: method, path: path)).to eq(request1)
          end
        end

        context 'without parameters' do
          it 'return path' do
            expect(subject.find_request(method: method, path: path)).to eq(request1)
          end
        end

        context 'with a parameter' do
          let(:path) { '/status/1/test/2.json' }
          let(:method) { 'DELETE' }

          it 'returns the modified path' do
            expect(subject.find_request(method: method, path: path)).to eq(request2)
          end
        end
      end

      context 'if inserted' do
        let(:req1) { JSON.parse(File.read('spec/fixtures/tomogram/request1.json')) }
        let(:req2) { JSON.parse(File.read('spec/fixtures/tomogram/request2.json')) }
        let(:req3) { JSON.parse(File.read('spec/fixtures/tomogram/request3.json')) }
        let(:request1) do
          double(
            path: req1['path'],
            method: req1['method'],
            content_type: 'application/json',
            request: req1['request'],
            responses: req1['responses']
          )
        end
        let(:request2) do
          double(
            path: req2['path'],
            method: req2['method'],
            content_type: 'application/json',
            request: req2['request'],
            responses: req2['responses']
          )
        end
        let(:request3) do
          double(
            method: req3['method'],
            content_type: 'application/json',
            request: req3['request'],
            responses: req3['responses'],
            path: double(match: true, to_s: req3['path'])
          )
        end
        let(:tomogram) do
          [
            request1,
            request2,
            request3
          ]
        end
        let(:path) { '/users/37812539-99af-4d7c-b86f-b756e3d1a211/pokemons' }
        let(:method) { 'GET' }

        it 'returns the modified path' do
          expect(subject.find_request(method: method, path: path)).to eq(request3)
        end
      end
    end

    describe '#to_resources' do
      subject do
        described_class.new(
          drafter_yaml_path: File.expand_path("spec/fixtures/drafter_4/#{documentation}"),
          prefix: ''
        ).to_resources
      end
      let(:parsed) { { '/sessions' => ['POST /sessions'] } }
      let(:documentation) { nil }

      context 'if one action' do
        let(:documentation) { 'api2.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end
    end

    describe '#prefix_match?' do
      subject { described_class.new(prefix: '/api/v2') }
      before { allow(Tomograph::ApiBlueprint::Drafter4::Yaml).to receive(:new) }

      it { expect(subject.prefix_match?('http://local/api/v2/users')).to be_truthy }
      it { expect(subject.prefix_match?('http://local/status')).to be_falsey }
    end
  end

  context 'crafter' do
    describe '#to_json' do
      subject do
        JSON.parse(
          described_class.new(
            crafter_yaml_path: File.expand_path("spec/fixtures/crafter/#{documentation}"),
            prefix: ''
          ).to_json
        )
      end
      let(:parsed) { JSON.parse(File.read(json_schema)) }
      let(:documentation) { nil }

      context 'if one action' do
        let(:json_schema) { 'spec/fixtures/tomogram/api2.json' }
        let(:documentation) { 'api2.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'additional desription' do
        let(:json_schema) { 'spec/fixtures/tomogram/api16.json' }
        let(:documentation) { 'api16.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'if two actions' do
        let(:json_schema) { 'spec/fixtures/tomogram/api3.json' }
        let(:documentation) { 'api3.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'if two controllers and three actions' do
        let(:json_schema) { 'spec/fixtures/tomogram/api4.json' }
        let(:documentation) { 'api4.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end

        context 'and separated data structures' do
          let(:json_schema) { 'spec/fixtures/tomogram/separated_data_structures.json' }
          let(:documentation) { 'separated_data_structures.yaml' }

          it 'parses documents' do
            expect(subject).to eq(parsed)
          end
        end
      end

      context 'blank request' do
        let(:json_schema) { 'spec/fixtures/tomogram/api5.json' }
        let(:documentation) { 'api5.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'action with comment' do
        let(:json_schema) { 'spec/fixtures/tomogram/api6.json' }
        let(:documentation) { 'api6.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'action with his unique path' do
        let(:json_schema) { 'spec/fixtures/tomogram/api7.json' }
        let(:documentation) { 'api7.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'if there is a description of the project' do
        context 'action with his unique path' do
          let(:json_schema) { 'spec/fixtures/tomogram/api8.json' }
          let(:documentation) { 'api8.yaml' }

          it 'parses documents' do
            expect(subject).to eq(parsed)
          end
        end

        context 'action with his unique path' do
          let(:json_schema) { 'spec/fixtures/tomogram/api9.json' }
          let(:documentation) { 'api9.yaml' }

          it 'parses documents' do
            expect(subject).to eq(parsed)
          end
        end
      end

      context 'if the structure of the first' do
        let(:json_schema) { 'spec/fixtures/tomogram/api10.json' }
        let(:documentation) { 'api10.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'if the structure of the first' do
        let(:json_schema) { 'spec/fixtures/tomogram/api11.json' }
        let(:documentation) { 'api11.yaml' }

        it 'parses documents' do
          skip
          expect(subject).to eq(parsed)
        end
      end

      context 'if two response with the same code' do
        let(:json_schema) { 'spec/fixtures/tomogram/api12.json' }
        let(:documentation) { 'api12.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'if you forget to specify the type of response' do
        let(:json_schema) { 'spec/fixtures/tomogram/api13.json' }
        let(:documentation) { 'api13.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'if you with to specify the type of request' do
        let(:json_schema) { 'spec/fixtures/tomogram/api14.json' }
        let(:documentation) { 'api14.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'if you with to specify the type of response' do
        let(:json_schema) { 'spec/fixtures/tomogram/api15.json' }
        let(:documentation) { 'api15.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'with request body' do
        let(:json_schema) { 'spec/fixtures/tomogram/api_builtin_scheme.json' }
        let(:documentation) { 'api_builtin_scheme.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'with a broken schema' do
        let(:json_schema) { 'spec/fixtures/tomogram/api_with_broken_schema.json' }
        let(:documentation) { 'api_with_broken_schema.yaml' }

        before { allow_any_instance_of(Kernel).to receive(:puts) }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'content-type' do
        let(:json_schema) { 'spec/fixtures/tomogram/content_type.json' }
        let(:documentation) { 'content_type.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'custom_header' do
        let(:json_schema) { 'spec/fixtures/tomogram/custom_header.json' }
        let(:documentation) { 'custom_header.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'more than one request' do
        let(:json_schema) { 'spec/fixtures/tomogram/more_than_one_request.json' }
        let(:documentation) { 'more_than_one_request.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end
    end

    describe '#find_request_with_content_type' do
      subject do
        described_class.new(
          crafter_yaml_path: File.expand_path("spec/fixtures/crafter/#{documentation}"),
          prefix: ''
        )
      end

      let(:method) { 'POST' }
      let(:tomogram) { [double(path: nil, method: nil)] }
      let(:path) { '/status' }
      let(:content_type) { 'application/json' }

      let(:parsed) { JSON.parse(File.read(json_schema)) }
      before do
        allow(Tomograph::ApiBlueprint::Crafter::Yaml).to receive(:new).and_return(double(to_tomogram: tomogram))
      end
      let(:json_schema) { 'spec/fixtures/tomogram/api2.json' }
      let(:documentation) { 'api2.yaml' }

      context 'if not found in the tomogram' do
        it 'returns nil' do
          expect(subject.find_request_with_content_type(method: method,
                                                        path: path,
                                                        content_type: content_type)).to eq(nil)
        end
      end

      context 'without path' do
        it 'returns nil' do
          expect(subject.find_request_with_content_type(method: method,
                                                        path: nil,
                                                        content_type: content_type)).to eq(nil)
        end
      end

      context 'if found in the tomogram' do
        let(:request1) do
          double(method: 'POST', path: double(match: true, to_s: '/status'),
                 content_type: 'application/json')
        end
        let(:request2) do
          double(method: 'DELETE', path: double(match: true, to_s: '/status/{id}/test/{tid}.json'),
                 content_type: 'application/json')
        end
        let(:tomogram) do
          [
            # Should not find these
            double(path: '/status', method: 'GET'),
            double(path: '/status/{id}/test/{tid}.json', method: 'GET'),
            double(path: '/status/{id}/test/{tid}.csv', method: 'DELETE'),
            double(path: '/status/{id}/test/', method: 'DELETE'),
            # Should find these
            request1,
            request2
          ]
        end

        context 'if slash at the end' do
          let(:path) { '/status/' }

          it 'return path withoud slash at the end' do
            expect(subject.find_request_with_content_type(method: method,
                                                          path: path,
                                                          content_type: content_type)).to eq(request1)
          end
        end

        context 'if request with query parameters' do
          let(:path) { '/status/?a=b&c=d' }

          it 'ignores query parameters' do
            expect(subject.find_request_with_content_type(method: method,
                                                          path: path,
                                                          content_type: content_type)).to eq(request1)
          end
        end

        context 'without parameters' do
          it 'return path' do
            expect(subject.find_request_with_content_type(method: method,
                                                          path: path,
                                                          content_type: content_type)).to eq(request1)
          end
        end

        context 'with a parameter' do
          let(:path) { '/status/1/test/2.json' }
          let(:method) { 'DELETE' }

          it 'returns the modified path' do
            expect(subject.find_request_with_content_type(method: method,
                                                          path: path,
                                                          content_type: content_type)).to eq(request2)
          end
        end
      end

      context 'if inserted' do
        let(:req1) { JSON.parse(File.read('spec/fixtures/tomogram/request1.json')) }
        let(:req2) { JSON.parse(File.read('spec/fixtures/tomogram/request2.json')) }
        let(:req3) { JSON.parse(File.read('spec/fixtures/tomogram/request3.json')) }
        let(:request1) do
          double(
            path: req1['path'],
            method: req1['method'],
            content_type: 'application/json',
            request: req1['request'],
            responses: req1['responses']
          )
        end
        let(:request2) do
          double(
            path: req2['path'],
            method: req2['method'],
            content_type: 'application/json',
            request: req2['request'],
            responses: req2['responses']
          )
        end
        let(:request3) do
          double(
            method: req3['method'],
            content_type: 'application/json',
            request: req3['request'],
            responses: req3['responses'],
            path: double(match: true, to_s: req3['path'])
          )
        end
        let(:tomogram) do
          [
            request1,
            request2,
            request3
          ]
        end
        let(:path) { '/users/37812539-99af-4d7c-b86f-b756e3d1a211/pokemons' }
        let(:method) { 'GET' }

        it 'returns the modified path' do
          expect(subject.find_request_with_content_type(method: method,
                                                        path: path,
                                                        content_type: content_type)).to eq(request3)
        end
      end
    end

    describe '#find_request' do
      subject do
        described_class.new(
          crafter_yaml_path: File.expand_path("spec/fixtures/crafter/#{documentation}"),
          prefix: ''
        )
      end

      let(:method) { 'POST' }
      let(:tomogram) { [double(path: nil, method: nil)] }
      let(:path) { '/status' }
      let(:content_type) { 'application/json' }

      let(:parsed) { JSON.parse(File.read(json_schema)) }
      before do
        allow(Tomograph::ApiBlueprint::Crafter::Yaml).to receive(:new).and_return(double(to_tomogram: tomogram))
      end
      let(:json_schema) { 'spec/fixtures/tomogram/api2.json' }
      let(:documentation) { 'api2.yaml' }

      context 'if not found in the tomogram' do
        it 'returns nil' do
          expect(subject.find_request(method: method, path: path)).to eq(nil)
        end
      end

      context 'without path' do
        it 'returns nil' do
          expect(subject.find_request(method: method, path: nil)).to eq(nil)
        end
      end

      context 'if found in the tomogram' do
        let(:request1) do
          double(method: 'POST', path: double(match: true, to_s: '/status'),
                 content_type: 'application/json')
        end
        let(:request2) do
          double(method: 'DELETE', path: double(match: true, to_s: '/status/{id}/test/{tid}.json'),
                 content_type: 'application/json')
        end
        let(:tomogram) do
          [
            # Should not find these
            double(path: '/status', method: 'GET'),
            double(path: '/status/{id}/test/{tid}.json', method: 'GET'),
            double(path: '/status/{id}/test/{tid}.csv', method: 'DELETE'),
            double(path: '/status/{id}/test/', method: 'DELETE'),
            # Should find these
            request1,
            request2
          ]
        end

        context 'if slash at the end' do
          let(:path) { '/status/' }

          it 'return path withoud slash at the end' do
            expect(subject.find_request(method: method, path: path)).to eq(request1)
          end
        end

        context 'if request with query parameters' do
          let(:path) { '/status/?a=b&c=d' }

          it 'ignores query parameters' do
            expect(subject.find_request(method: method, path: path)).to eq(request1)
          end
        end

        context 'without parameters' do
          it 'return path' do
            expect(subject.find_request(method: method, path: path)).to eq(request1)
          end
        end

        context 'with a parameter' do
          let(:path) { '/status/1/test/2.json' }
          let(:method) { 'DELETE' }

          it 'returns the modified path' do
            expect(subject.find_request(method: method, path: path)).to eq(request2)
          end
        end
      end

      context 'if inserted' do
        let(:req1) { JSON.parse(File.read('spec/fixtures/tomogram/request1.json')) }
        let(:req2) { JSON.parse(File.read('spec/fixtures/tomogram/request2.json')) }
        let(:req3) { JSON.parse(File.read('spec/fixtures/tomogram/request3.json')) }
        let(:request1) do
          double(
            path: req1['path'],
            method: req1['method'],
            content_type: 'application/json',
            request: req1['request'],
            responses: req1['responses']
          )
        end
        let(:request2) do
          double(
            path: req2['path'],
            method: req2['method'],
            content_type: 'application/json',
            request: req2['request'],
            responses: req2['responses']
          )
        end
        let(:request3) do
          double(
            method: req3['method'],
            content_type: 'application/json',
            request: req3['request'],
            responses: req3['responses'],
            path: double(match: true, to_s: req3['path'])
          )
        end
        let(:tomogram) do
          [
            request1,
            request2,
            request3
          ]
        end
        let(:path) { '/users/37812539-99af-4d7c-b86f-b756e3d1a211/pokemons' }
        let(:method) { 'GET' }

        it 'returns the modified path' do
          expect(subject.find_request(method: method, path: path)).to eq(request3)
        end
      end
    end

    describe '#to_resources' do
      subject do
        described_class.new(
          crafter_yaml_path: File.expand_path("spec/fixtures/crafter/#{documentation}"),
          prefix: ''
        ).to_resources
      end
      let(:parsed) { { '/sessions' => ['POST /sessions'] } }
      let(:documentation) { nil }

      context 'if one action' do
        let(:documentation) { 'api2.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end
    end

    describe '#prefix_match?' do
      subject { described_class.new(prefix: '/api/v2') }
      before { allow(Tomograph::ApiBlueprint::Drafter4::Yaml).to receive(:new) }

      it { expect(subject.prefix_match?('http://local/api/v2/users')).to be_truthy }
      it { expect(subject.prefix_match?('http://local/status')).to be_falsey }
    end
  end

  context 'openapi2' do
    describe '#to_json' do
      subject do
        JSON.parse(
          described_class.new(
            openapi2_json_path: File.expand_path("spec/fixtures/openapi2/#{documentation}"),
            prefix: ''
          ).to_json
        )
      end
      let(:parsed) { JSON.parse(File.read(json_schema)) }
      let(:documentation) { nil }

      context 'if chatwoot20201024' do
        let(:json_schema) { 'spec/fixtures/tomogram/chatwoot20201024.json' }
        let(:documentation) { 'chatwoot20201024.json' }

        it 'parses documents' do
          # File.open('spec/fixtures/tomogram/chatwoot20201024.json', 'w') do |file|
          #   file.write(JSON.pretty_generate(subject))
          # end
          expect(subject).to eq(parsed)
        end
      end

      context 'if chatwoot20230201' do
        let(:json_schema) { 'spec/fixtures/tomogram/chatwoot20230201.json' }
        let(:documentation) { 'chatwoot20230201.json' }

        it 'parses documents' do
          # File.open('spec/fixtures/tomogram/chatwoot20230201.json', 'w') do |file|
          #   file.write(JSON.pretty_generate(subject))
          # end
          expect(subject).to eq(parsed)
        end
      end
    end
  end

  context 'openapi3' do
    describe '#to_json' do
      subject do
        JSON.parse(
          described_class.new(
            openapi3_yaml_path: File.expand_path("spec/fixtures/openapi3/#{documentation}"),
            prefix: ''
          ).to_json
        )
      end
      let(:parsed) { JSON.parse(File.read(json_schema)) }
      let(:documentation) { nil }

      context 'if one action' do
        let(:json_schema) { 'spec/fixtures/tomogram/spree.json' }
        let(:documentation) { 'spree.yaml' }

        it 'parses documents' do
          # File.open('spec/fixtures/tomogram/spree.json', 'w') do |file|
          #   file.write(JSON.pretty_generate(subject))
          # end
          expect(subject).to eq(parsed)
          # puts JSON.dump(subject[0]['responses'][0]['body'])
          subject.each do |sub|
            sub['responses'].each do |response|
              expect do
                JSON::Validator.fully_validate(response['body'], {})
              end.not_to raise_exception
            end
          end
        end
      end

      context 'if one response is a ref, others are described inline with and without schema ref' do
        let(:json_schema) { 'spec/fixtures/openapi3/response_as_ref_and_plain.json' }
        let(:documentation) { 'response_as_ref_and_plain.yml' }

        it 'parses documents right' do
          expect(subject).to eq(parsed)
        end
      end

      context 'if action has two responses with one code and different content-types' do
        let(:json_schema) { 'spec/fixtures/openapi3/one_code_two_content_types.json' }
        let(:documentation) { 'one_code_two_content_types.yml' }

        it 'parses documents right' do
          expect(subject).to eq(parsed)
        end

        context 'and response is defined in components/responses section' do
          let(:json_schema) { 'spec/fixtures/openapi3/response_is_a_ref.json' }
          let(:documentation) { "response_is_a_ref.yml" }

          it 'parses documents right' do
            expect(subject).to eq(parsed)
          end
        end
      end
    end
  end
end
