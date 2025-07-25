require "rails_helper"

RSpec.describe "User Authentication", type: :request do
  describe "GET /signin" do
    it "shows the sign in form" do
      get signin_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sign In")
    end
  end

  describe "POST /signin" do
    let(:user) { create(:user, username: "testuser") }

    context "with valid credentials" do
      it "signs in the user and redirects to root" do
        post signin_path, params: { username: user.username, password: user.password }

        expect(session[:user_id]).to eq(user.id)
        expect(response).to redirect_to(habits_path)
      end
    end

    context "with invalid username" do
      it "does not sign in and shows error message" do
        post signin_path, params: {
          username: "nonexistent",
          password: DEFAULT_PASSWORD
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Invalid username or password")
      end
    end

    context "with invalid password" do
      it "does not sign in and shows error message" do
        post signin_path, params: {
          username: user.username,
          password: "wrongpassword"
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Invalid username or password")
      end
    end
  end

  describe "DELETE /signout" do
    let(:user) { create(:user) }

    it "signs out the user and redirects to root" do
      # Sign in first
      post signin_path, params: {
        username: user.username,
        password: DEFAULT_PASSWORD
      }

      # Then sign out
      delete signout_path

      expect(response).to redirect_to(root_path)

      # Follow redirect to verify user is signed out
      follow_redirect!
      expect(response.body).not_to include(user.username)
    end
  end
end
