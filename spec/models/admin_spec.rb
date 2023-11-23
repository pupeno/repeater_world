require "rails_helper"

RSpec.describe Admin, type: :model do
  context "An admin" do
    before { @admin = create(:admin) }

    it "is readable" do
      expect(@admin.to_s).to include(@admin.class.name)
      expect(@admin.to_s).to include(@admin.id)
      expect(@admin.to_s).to include(@admin.email)
    end

    it "should remember me by default" do
      expect(@admin.remember_me).to eq("1") # HTML input values are strings, even when they are numbers
      @admin.remember_me = "0"
      expect(@admin.remember_me).to eq("0")
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
