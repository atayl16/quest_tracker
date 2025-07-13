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
        post signin_path, params: {
          username: user.username,
          password: "password123"
        }

        expect(response).to redirect_to(root_path)

        # Follow the redirect to verify user is signed in
        follow_redirect!
        expect(response.body).to include("testuser")
      end
    end

    context "with invalid username" do
      it "does not sign in and shows error message" do
        post signin_path, params: {
          username: "nonexistent",
          password: "password123"
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
        password: "password123"
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
