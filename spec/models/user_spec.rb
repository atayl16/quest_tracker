require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with a username and password" do
    user = build(:user)
    expect(user).to be_valid
  end

  it "is invalid without a username" do
    user = build(:user, username: nil)
    expect(user).not_to be_valid
  end

  it "is invalid without a password" do
    user = build(:user, password: nil, password_confirmation: nil)
    expect(user).not_to be_valid
  end

  it "is invalid with a duplicate username" do
    create(:user, username: "alice")
    user = build(:user, username: "alice")
    expect(user).not_to be_valid
  end
end
