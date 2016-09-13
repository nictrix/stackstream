require 'docile'

module Stackstream
  # Shared methods
  module Shared
    def classify(class_name)
      class_name.split('_').collect(&:capitalize).join.freeze
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
