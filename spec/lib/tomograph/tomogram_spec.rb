require 'spec_helper'

RSpec.describe Tomograph::Tomogram do
  describe '#json' do
    subject { JSON.parse(described_class.new.json) }
    let(:parsed) { MultiJson.load(File.read(json_schema)) }
    let(:documentation) { nil }

    before do
      allow(Rails).to receive(:root).and_return("#{ENV['RBENV_DIR']}/spec/fixtures")
      allow(Tomograph).to receive(:configuration).and_return(
        double(documentation: documentation, prefix: '', drafter_yaml: nil))
    end

    context 'if one action' do
      let(:json_schema) { 'spec/fixtures/api2.json' }
      let(:documentation) { 'api2.yaml' }

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'additional desription' do
      let(:json_schema) { 'spec/fixtures/api16.json' }
      let(:documentation) { 'api16.yaml' }

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'if two actions' do
      let(:json_schema) { 'spec/fixtures/api3.json' }
      let(:documentation) { 'api3.yaml' }

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'if two controllers and three actions' do
      let(:json_schema) { 'spec/fixtures/api4.json' }
      let(:documentation) { 'api4.yaml' }

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end

      context 'and separated data structures' do
        let(:json_schema) { 'spec/fixtures/separated_data_structures.json' }
        let(:documentation) { 'separated_data_structures.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end
    end

    context 'blank request' do
      let(:json_schema) { 'spec/fixtures/api5.json' }
      let(:documentation) { 'api5.yaml' }

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'action with comment' do
      let(:json_schema) { 'spec/fixtures/api6.json' }
      let(:documentation) { 'api6.yaml' }

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'action with his unique path' do
      let(:json_schema) { 'spec/fixtures/api7.json' }
      let(:documentation) { 'api7.yaml' }

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'if there is a description of the project' do
      context 'action with his unique path' do
        let(:json_schema) { 'spec/fixtures/api8.json' }
        let(:documentation) { 'api8.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end

      context 'action with his unique path' do
        let(:json_schema) { 'spec/fixtures/api9.json' }
        let(:documentation) { 'api9.yaml' }

        it 'parses documents' do
          expect(subject).to eq(parsed)
        end
      end
    end

    context 'if the structure of the first' do
      let(:json_schema) { 'spec/fixtures/api10.json' }
      let(:documentation) { 'api10.yaml' }

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'if the structure of the first' do
      let(:json_schema) { 'spec/fixtures/api11.json' }
      let(:documentation) { 'api11.yaml' }

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'if two response with the same code' do
      let(:json_schema) { 'spec/fixtures/api12.json' }
      let(:documentation) { 'api12.yaml' }

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'if you forget to specify the type of response' do
      let(:json_schema) { 'spec/fixtures/api13.json' }
      let(:documentation) { 'api13.yaml' }

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'if you with to specify the type of request' do
      let(:json_schema) { 'spec/fixtures/api14.json' }
      let(:documentation) { 'api14.yaml' }

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'if you with to specify the type of response' do
      let(:json_schema) { 'spec/fixtures/api15.json' }
      let(:documentation) { 'api15.yaml' }

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'with request body' do
      let(:json_schema) { 'spec/fixtures/api_builtin_scheme.json' }
      let(:documentation) { 'api_builtin_scheme.yaml' }

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end

    context 'with a broken schema' do
      let(:json_schema) { 'spec/fixtures/api_with_broken_schema.json' }
      let(:documentation) { 'api_with_broken_schema.yaml' }

      it 'parses documents' do
        expect(subject).to eq(parsed)
      end
    end
  end

  describe '#delete_query_and_last_slash' do
    context 'if without query' do
      let(:path) { '/status/' }
      let(:stump) { '/status' }

      it 'no changes' do
        expect(described_class.new.delete_query_and_last_slash(path)).to eq(stump)
      end
    end

    context 'if there is' do
      let(:path1) { '/status/{&search}{&page}' }
      let(:path2) { '/status/{?search,page}' }
      let(:stump) { '/status' }

      it 'delete query' do
        expect(described_class.new.delete_query_and_last_slash(path1)).to eq(stump)
        expect(described_class.new.delete_query_and_last_slash(path2)).to eq(stump)
      end

      context 'and a parameter' do
        let(:path1) { '/users/{id}/pokemons/{&search}{&page}' }
        let(:path2) { '/users/{id}/pokemons/{?search,page}' }
        let(:stump) { '/users/{id}/pokemons' }

        it 'delete query' do
          expect(described_class.new.delete_query_and_last_slash(path1)).to eq(stump)
          expect(described_class.new.delete_query_and_last_slash(path2)).to eq(stump)
        end
      end
    end
  end
end
