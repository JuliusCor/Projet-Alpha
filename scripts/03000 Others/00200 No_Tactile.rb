unless ARGV.include?('--tags') or ARGV.include?('--worldmap')
  module Mouse
    module_function
    
    def trigger?(*)
      return false
    end
    
    def press?(*)
      return false
    end
  end
end