require "ruby_parser"

module ParserUtil
  class << self
    def gemfile(text)
      sexps = RubyParser.new.parse(text)

      dependencies = []

      sexps.each_of_type :call do |sexp|
        values = sexp.values.rest
        if values.first == :gem
          args = values.rest.map do |type, *values|
            if type == :str
              values.first
            elsif type == :hash
              values.map do |key, value|
                value
              end
            end
          end

          dependencies.push args
        end
      end

      return dependencies
    end
  end
end
