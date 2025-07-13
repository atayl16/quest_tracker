require "rails_helper"

RSpec.describe "CheckIns", type: :request do
  let(:user) { create(:user) }
  let(:habit) { create(:habit, user: user) }

  describe "POST /habits/:habit_id/check_ins" do
    it "creates a check-in for today" do
      sign_in user
      expect {
        post habit_check_ins_path(habit)
      }.to change { habit.check_ins.count }.by(1)
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "DELETE /habits/:habit_id/check_ins/:id" do
    context "when user is authenticated" do
      before { sign_in user }

      it "deletes today's check-in" do
        check_in = habit.check_ins.create!(user: user, checked_in_at: Time.zone.today)
        expect {
          delete habit_check_in_path(habit, check_in)
        }.to change { habit.check_ins.count }.by(-1)
        expect(response).to redirect_to(habits_path)
        expect(flash[:notice]).to eq("Check-in undone!")
      end

      it "does not allow deleting another user's check-in" do
        other_user = create(:user)
        other_check_in = habit.check_ins.create!(user: other_user, checked_in_at: Time.zone.today)
        expect {
          delete habit_check_in_path(habit, other_check_in)
        }.not_to change { habit.check_ins.count }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is not authenticated" do
      let!(:check_in) { habit.check_ins.create!(user: user, checked_in_at: Time.zone.today) }
      it "redirects to sign in page" do
        delete habit_check_in_path(habit, check_in)
        expect(response).to redirect_to(signin_path)
      end
    end
  end
end
