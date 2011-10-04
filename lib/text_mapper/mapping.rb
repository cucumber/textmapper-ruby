require 'text_mapper/pattern'
require 'text_mapper/target'

module TextMapper
  class Mapping
    def self.from_fluent(dsl_args)
      from, to = dsl_args.shift
      meth_name, *types = to
      pattern = [:map, from].flatten
      new(pattern, meth_name, types)
    end

    attr_reader :from, :to, :name

    def initialize(from, to, types=[])
      @name = from
      @from = Pattern.new(from)
      @to = to # MethodSignature.new(to) ???
      @types = types
    end

    def match(raw_pattern)
      from === raw_pattern
    end

    def captures_from(raw_pattern)
      if captures = from.match(raw_pattern)
        if @types.empty?
          captures
        else
          captures.zip(@types).collect do |capture, type|
            # FIXME: Add other built-ins with idiosyncratic build protocols
            if Integer == type
              capture.to_i
            elsif Float == type
              capture.to_f
            else
              type.new(capture)
            end
          end
        end
      else
        []
      end
    end

    def call(receiver, action=[])
      args = captures_from(action)
      receiver.send(to, *args)
    end
  end
end