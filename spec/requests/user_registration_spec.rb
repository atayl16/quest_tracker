require "rails_helper"

RSpec.describe "User Registration", type: :request do
  describe "GET /signup" do
    it "shows the sign up form" do
      get signup_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sign Up")
    end
  end

  describe "POST /signup" do
    context "with valid credentials" do
      it "creates a new user and signs them in" do
        user_params = {
          user: {
            username: "testuser",
            password: DEFAULT_PASSWORD,
            password_confirmation: DEFAULT_PASSWORD
          }
        }

        expect {
          post signup_path, params: user_params
        }.to change(User, :count).by(1)

        expect(response).to redirect_to(root_path)

        # Follow the redirect to verify user is signed in
        follow_redirect!
        expect(response.body).to include("testuser")
      end
    end

    context "with invalid credentials" do
      it "does not create a user and shows errors" do
        user_params = {
          user: {
            username: "",
            password: DEFAULT_PASSWORD,
            password_confirmation: "different"
          }
        }

        expect {
          post signup_path, params: user_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Sign Up")
      end
    end
  end
end
