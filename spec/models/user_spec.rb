# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  allow_password_change  :boolean          default(FALSE)
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  image                  :string
#  name                   :string
#  provider               :string           default("email"), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  tokens                 :json
#  uid                    :string           default(""), not null
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_uid_and_provider      (uid,provider) UNIQUE
#
require "rails_helper"

RSpec.describe User, type: :model do
  context "name, email, password カラムに値が存在する"
  it "validationを通過し、userが作成される" do
    user = build(:user)
    expect(user).to be_valid
  end

  context "name カラムに値が存在しない時"
  it "name が存在しないので、エラーになる" do
    user = build(:user, name: "")
    expect(user).to be_invalid
  end

  context "name カラムの文字数が 14 字以上である時"
  it "name が 14 以上なので、エラーになる" do
    user = build(:user, name: "lokijuhygtfrdesw")
    expect(user).to be_invalid
  end

  context "email カラムに値が存在しない時"
  it "email が存在しないので、エラーになる" do
    user = build(:user, email: "")
    expect(user).to be_invalid
  end

  context "password カラムに値が存在しない時"
  it "password が存在しないので、エラーになる" do
    user = build(:user, password: "")
    expect(user).to be_invalid
  end
end
