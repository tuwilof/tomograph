module Tomograph
  class Path
    def initialize(path)
      path = delete_till_the_end(path, '{&')
      path = delete_till_the_end(path, '{?')

      @path = remove_the_slash_at_the_end(path)
    end

    def delete_till_the_end(path, beginning_with)
      path_index = path.index(beginning_with)
      path_index ||= 0
      path_index -= 1
      path.slice(0..path_index)
    end

    def remove_the_slash_at_the_end(path)
      if path[-1] == '/'
        path[0..-2]
      else
        path
      end
    end

    def to_s
      @path
    end
  end
end
