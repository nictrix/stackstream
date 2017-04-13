RSpec.configure do |configuration|
  configuration.disable_monkey_patching!

  configuration.mock_with :rspec do |mocks|
    ENV['AWS_ACCESS_KEY'] = '00x'
    ENV['AWS_SECRET_ACCESS_KEY'] = '00x'

    mocks.verify_doubled_constant_names = true
    mocks.verify_partial_doubles = true
  end
end
