require 'docile'

module Stackstream
  # Shared methods
  module Shared
    module Builder
      refine Object do
        def to_hash
          hash = {}

          instance_variables.each do |variable|
            hash[variable.to_s.delete("@")] = instance_variable_get(variable)
          end

          hash
        end

        def stringify
          return self.reduce({}) do |memo, (k, v)|
            memo.tap { |m| m[k.to_s] = v.stringify }
          end if self.is_a? Hash

          return self.reduce([]) do |memo, v|
            memo << v.stringify
            memo
          end if self.is_a? Array

          self
        end
      end
    end
  end

  module Stack
    module Shared
      def define_local_method(named_object, object)
        define_singleton_method(named_object) do
          instance_variable_get("@__#{named_object}")
        end
        instance_variable_set("@__#{named_object}", object)
      end
    end
  end
end
