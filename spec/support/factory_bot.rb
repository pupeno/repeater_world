# https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#rspec
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

FactoryBot::SyntaxRunner.class_eval do
  # https://blog.eq8.eu/til/factory-bot-trait-for-active-storange-has_attached.html
  include ActionDispatch::TestProcess
end
