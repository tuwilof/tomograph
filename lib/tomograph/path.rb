module Tomograph
  class Path
    attr_reader :path

    def initialize(path)
      unless path && !path.empty?
        @path = ''
        return
      end
      @path = path
      @path = delete_till_the_end('{&')
      @path = delete_till_the_end('{?')
      @path = cut_off_query_params
      @path = remove_the_slash_at_the_end
    end

    def match(find_path)
      regexp =~ find_path
    end

    def regexp
      return @regexp if @regexp

      str = Regexp.escape(to_s)
      str = str.gsub(/\\{\w+\\}/, '[^&=\/]+')
      str = "\\A#{str}\\z"
      @regexp = Regexp.new(str)
    end

    def to_s
      @path
    end

    def ==(other)
      other.instance_of?(self.class) && (other.path == path)
    end

    private

    def delete_till_the_end(beginning_with)
      path_index = @path.index(beginning_with)
      path_index ||= 0
      path_index -= 1
      @path.slice(0..path_index)
    end

    def remove_the_slash_at_the_end
      if @path[-1] == '/'
        @path[0..-2]
      else
        @path
      end
    end

    def cut_off_query_params
      @path.gsub(/\?.*\z/, '')
    end
  end
end
