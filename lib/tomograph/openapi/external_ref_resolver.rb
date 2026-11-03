require 'yaml'

module Tomograph
  module OpenApi
    # Loads an OpenAPI document and rewrites external $ref (./paths/auth.yaml,
    # ../components/schemas.yaml#/LoginRequest) into internal #/components/... pointers.
    class ExternalRefResolver
      COMPONENT_KINDS = {
        'schema' => 'schemas',
        'schemas' => 'schemas',
        'response' => 'responses',
        'responses' => 'responses',
        'parameter' => 'parameters',
        'parameters' => 'parameters'
      }.freeze

      def self.load(path)
        new.load(path)
      end

      def initialize
        @cache = {}
        @registered = {}
        @stack = []
        @components = {
          'schemas' => {},
          'responses' => {},
          'parameters' => {}
        }
      end

      def load(path)
        path = File.expand_path(path)
        resolved = resolve_node(read_yaml(path), File.dirname(path))
        merge_components(resolved)
      end

      private

      def merge_components(doc)
        @components.each do |kind, values|
          next if values.empty?

          doc['components'] ||= {}
          doc['components'][kind] = values.merge(doc['components'][kind] || {})
        end
        doc
      end

      def resolve_node(node, base_dir)
        case node
        when Hash
          resolved = {}
          node.each { |key, value| resolved[key] = resolve_node(value, base_dir) }
          ref = node['$ref']
          return resolved unless ref.is_a?(String) && external_ref?(ref)

          target = resolve_external(ref, base_dir)
          extra = resolved.reject { |key, _| key == '$ref' }
          target.is_a?(Hash) ? target.merge(extra) : target
        when Array
          node.map { |value| resolve_node(value, base_dir) }
        else
          node
        end
      end

      def resolve_external(ref, base_dir)
        abs_ref = absolute_ref(ref, base_dir)
        return { '$ref' => ref } if @stack.include?(abs_ref)

        @stack.push(abs_ref)
        begin
          file, fragment = split_external(ref, base_dir)
          data = read_yaml(file)
          segments = pointer_segments(fragment)
          kind = component_kind(file)
          if kind && segments.length == 1 && data.is_a?(Hash) && data.key?(segments[0])
            register_component_file(file, kind, data)
            { '$ref' => "#/components/#{kind}/#{segments[0]}" }
          else
            target = segments.empty? ? data : dig_pointer(data, segments)
            resolve_node(deepcopy(target), File.dirname(file))
          end
        ensure
          @stack.pop
        end
      end

      def register_component_file(file, kind, data)
        return if @registered[file]

        @registered[file] = true
        names = data.keys
        names.each do |name|
          rewritten = rewrite_local_refs(deepcopy(data[name]), names, kind)
          @components[kind][name] = resolve_node(rewritten, File.dirname(file))
        end
      end

      def rewrite_local_refs(node, names, kind)
        case node
        when Hash
          node.each_with_object({}) do |(key, value), result|
            if key == '$ref' && local_component_ref?(value, names)
              result[key] = "#/components/#{kind}/#{value[2..-1]}"
            else
              result[key] = rewrite_local_refs(value, names, kind)
            end
          end
        when Array
          node.map { |value| rewrite_local_refs(value, names, kind) }
        else
          node
        end
      end

      def local_component_ref?(value, names)
        value.is_a?(String) && value =~ /\A#\/([^\/]+)\z/ && names.include?(value[2..-1])
      end

      def external_ref?(ref)
        !ref.start_with?('#')
      end

      def absolute_ref(ref, base_dir)
        file, fragment = ref.split('#', 2)
        "#{File.expand_path(file, base_dir)}##{fragment}"
      end

      def split_external(ref, base_dir)
        file, fragment = ref.split('#', 2)
        [File.expand_path(file, base_dir), fragment]
      end

      def component_kind(path)
        COMPONENT_KINDS[File.basename(path, '.*')]
      end

      def pointer_segments(fragment)
        return [] if fragment.nil? || fragment.empty? || fragment == '/'

        fragment.sub(%r{\A/}, '').split('/').map { |segment| segment.gsub('~1', '/').gsub('~0', '~') }
      end

      def dig_pointer(data, segments)
        segments.reduce(data) do |memo, segment|
          case memo
          when Hash then memo[segment]
          when Array then memo[segment.to_i]
          end
        end
      end

      def read_yaml(path)
        return @cache[path] if @cache.key?(path)

        @cache[path] = YAML.safe_load(File.read(path)) || {}
      end

      def deepcopy(obj)
        case obj
        when Hash then obj.each_with_object({}) { |(key, value), copy| copy[key] = deepcopy(value) }
        when Array then obj.map { |value| deepcopy(value) }
        else obj
        end
      end
    end
  end
end
