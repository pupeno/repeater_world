# Copyright 2023, Flexpoint Tech
#
# This file is part of Repeater World.
#
# Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
# Public License as published by the Free Software Foundation, either version 3 of the License.
#
# Foobar is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License along with Repeater World. If not, see
# <https://www.gnu.org/licenses/>.

# https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#rspec
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

FactoryBot::SyntaxRunner.class_eval do
  # https://blog.eq8.eu/til/factory-bot-trait-for-active-storange-has_attached.html
  include ActionDispatch::TestProcess
end

FactoryBot.define do
  sequence(:call_sign) { |n| number_to_call_sign(n) }
end

# This method counts in call sign, so base 26 for 3 characters, then base 10 for a number, and then base 26 for another
# character. Sort of.
def number_to_call_sign(n)
  letters = ("A".."Z").to_a

  call_sign = StringIO.new
  call_sign << letters[n % 26]
  n /= 26
  call_sign << letters[n % 26]
  n /= 26
  call_sign << letters[n % 26]
  n /= 26
  call_sign << n % 10
  n /= 10
  call_sign << letters[n % 26]

  call_sign.string.reverse
end
