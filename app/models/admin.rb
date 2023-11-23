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

# == Schema Information
#
# Table name: admins
#
#  id                     :uuid             not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_admins_on_confirmation_token    (confirmation_token) UNIQUE
#  index_admins_on_email                 (email) UNIQUE
#  index_admins_on_reset_password_token  (reset_password_token) UNIQUE
#  index_admins_on_unlock_token          (unlock_token) UNIQUE
#
