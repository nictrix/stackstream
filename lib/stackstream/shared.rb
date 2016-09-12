require 'docile'

module Stackstream
  # Shared methods
  module Shared
    def classify(class_name)
      class_name.split('_').collect(&:capitalize).join.freeze
    end
  end
end
