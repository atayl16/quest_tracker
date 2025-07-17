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

  describe "POST /habits" do
    context "when user is authenticated" do
      let(:user) { create(:user) }

      before { sign_in user }

      context "with valid attributes" do
        it "creates a new habit" do
          expect {
            post habits_path, params: { habit: { title: "Drink water" } }
          }.to change(Habit, :count).by(1)

          expect(response).to redirect_to(habits_path)
          expect(response).to have_http_status(:redirect)
        end

        it "associates the habit with the current user" do
          post habits_path, params: { habit: { title: "Exercise daily" } }

          expect(Habit.last.user).to eq(user)
        end
      end

      context "with invalid attributes" do
        it "does not create a habit with empty title" do
          expect {
            post habits_path, params: { habit: { title: "" } }
          }.not_to change(Habit, :count)

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "does not create a habit with nil title" do
          expect {
            post habits_path, params: { habit: { title: nil } }
          }.not_to change(Habit, :count)

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "renders the index page with error messages" do
          post habits_path, params: { habit: { title: "" } }

          expect(response.body).to include("Title can&#39;t be blank")
        end
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in page" do
        post habits_path, params: { habit: { title: "New habit" } }

        expect(response).to redirect_to(signin_path)
      end
    end
  end

  describe "DELETE /habits/:id" do
    context "when user is authenticated" do
      let(:user) { create(:user) }
      let!(:habit) { create(:habit, user: user, title: "Test habit") }

      before { sign_in user }

      it "deletes the habit" do
        expect {
          delete habit_path(habit)
        }.to change(Habit, :count).by(-1)

        expect(response).to redirect_to(habits_path)
        expect(response).to have_http_status(:redirect)
      end

      it "only allows users to delete their own habits" do
        other_user = create(:user)
        other_habit = create(:habit, user: other_user, title: "Other user's habit")

        expect {
          delete habit_path(other_habit)
        }.not_to change(Habit, :count)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is not authenticated" do
      let!(:habit) { create(:habit, title: "Test habit") }

      it "redirects to sign in page" do
        delete habit_path(habit)

        expect(response).to redirect_to(signin_path)
      end
    end
  end
end
