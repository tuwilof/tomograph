module Tomograph
  class Path
    def initialize(path)
      @path = path
      @path = delete_till_the_end('{&')
      @path = delete_till_the_end('{?')
      @path = cut_off_query_params
      @path = remove_the_slash_at_the_end
    end

    def to_s
      @path
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
