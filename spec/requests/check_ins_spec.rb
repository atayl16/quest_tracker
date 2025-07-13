require "rails_helper"

RSpec.describe "CheckIns", type: :request do
  describe "POST /habits/:habit_id/check_ins" do
    let(:user) { create(:user) }
    let(:habit) { create(:habit, user: user) }

    context "when user is authenticated" do
      before { sign_in user }

      context "with Turbo request" do
        it "creates a check-in for today" do
          expect {
            post habit_check_ins_path(habit), headers: { "Accept" => "text/vnd.turbo-stream.html" }
          }.to change(CheckIn, :count).by(1)

          check_in = CheckIn.last
          expect(check_in.user).to eq(user)
          expect(check_in.habit).to eq(habit)
          expect(check_in.checked_in_at.to_date).to eq(Date.current)
        end

        it "responds with turbo_stream format" do
          post habit_check_ins_path(habit), headers: { "Accept" => "text/vnd.turbo-stream.html" }

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to include("text/vnd.turbo-stream.html")
        end

        it "updates the habit card via turbo stream" do
          post habit_check_ins_path(habit), headers: { "Accept" => "text/vnd.turbo-stream.html" }

          expect(response.body).to include("turbo-stream")
          expect(response.body).to include("habit_#{habit.id}")
        end

        it "prevents duplicate check-ins for the same day" do
          # Create existing check-in for today
          create(:check_in, user: user, habit: habit, checked_in_at: Time.current)

          expect {
            post habit_check_ins_path(habit), headers: { "Accept" => "text/vnd.turbo-stream.html" }
          }.not_to change(CheckIn, :count)

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "without Turbo (traditional request)" do
        it "creates a check-in and redirects to habits page" do
          expect {
            post habit_check_ins_path(habit)
          }.to change(CheckIn, :count).by(1)

          expect(response).to redirect_to(habits_path)
        end
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign-in page" do
        post habit_check_ins_path(habit)

        expect(response).to redirect_to(signin_path)
      end
    end

    context "with invalid habit" do
      before { sign_in user }

      it "returns 404 for non-existent habit" do
        post habit_check_ins_path(habit_id: 999), headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
