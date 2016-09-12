RSpec.configure do |configuration|
  configuration.disable_monkey_patching!

  configuration.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true

    mocks.verify_partial_doubles = true
  end
end
