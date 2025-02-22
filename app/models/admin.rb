# Copyright 2023-2024, Pablo Fernandez
#
# This file is part of Repeater World.
#
# Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
# Public License as published by the Free Software Foundation, either version 3 of the License.
#
# Repeater World is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along with Repeater World. If not, see
# <https://www.gnu.org/licenses/>.

class Admin < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :confirmable, :lockable, :timeoutable, :trackable, :async # :registerable, :omniauthable

  def to_s
    super(email)
  end

  # https://github.com/heartcombo/devise/issues/1513
  def remember_me
    super.nil? ? "1" : super
  end

  rails_admin do
    object_label_method { :email }
    list do
      field :email
      field :last_sign_in_at
      field :current_sign_in_at
      field :current_sign_in_ip
      field :sign_in_count
      field :locked_at
    end
  end
end
