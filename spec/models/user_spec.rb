require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with a username and password" do
    user = User.new(username: "alice", password: "password123", password_confirmation: "password123")
    expect(user).to be_valid
  end

  it "is invalid without a username" do
    user = User.new(username: nil, password: "password123", password_confirmation: "password123")
    expect(user).not_to be_valid
  end

  it "is invalid without a password" do
    user = User.new(username: "alice", password: nil, password_confirmation: nil)
    expect(user).not_to be_valid
  end

  it "is invalid with a duplicate username" do
    User.create!(username: "alice", password: "password123", password_confirmation: "password123")
    user = User.new(username: "alice", password: "password456", password_confirmation: "password456")
    expect(user).not_to be_valid
  end
end
