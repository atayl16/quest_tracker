require "rails_helper"

RSpec.describe "Habits", type: :request do
  describe "GET /habits" do
    it "shows a habit title for an authenticated user" do
      user = create(:user)
      create(:habit, user: user, title: "Take vitamins")
      sign_in user

      get habits_path

      expect(response.body).to include("Take vitamins")
      expect(response).to have_http_status(:ok)
    end
  end
end
