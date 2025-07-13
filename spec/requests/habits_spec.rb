require "rails_helper"

RSpec.describe "Habits", type: :request do
  describe "GET /habits" do
    context "when user is authenticated" do
      it "shows a habit title for an authenticated user" do
        user = create(:user)
        create(:habit, user: user, title: "Take vitamins")
        sign_in user

        get habits_path

        expect(response.body).to include("Take vitamins")
        expect(response).to have_http_status(:ok)
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in page" do
        get habits_path

        expect(response).to redirect_to(signin_path)
      end
    end
  end
end
