require "rails_helper"

RSpec.describe CompleteHabit do
  let(:user) { create(:user) }
  let(:habit) { create(:habit, user: user) }
  let(:service) { described_class.new(user: user, habit: habit) }

  describe "#call" do
    context "with valid inputs" do
      it "creates a check-in and returns success" do
        result = service.call

        expect(result.success?).to be true
        expect(result.check_in).to be_persisted
        expect(result.check_in.user).to eq(user)
        expect(result.check_in.habit).to eq(habit)
        expect(result.check_in.checked_in_at).to be_within(1.second).of(Time.current)
        expect(result.errors).to be_empty
      end

      it "sets the checked_in_at timestamp to current time" do
        freeze_time do
          result = service.call
          expect(result.check_in.checked_in_at).to eq(Time.current)
        end
      end
    end

    context "when user is nil" do
      let(:service) { described_class.new(user: nil, habit: habit) }

      it "returns failure with error message" do
        result = service.call

        expect(result.success?).to be false
        expect(result.check_in).to be_nil
        expect(result.errors).to include("User is required")
      end
    end

    context "when habit is nil" do
      let(:service) { described_class.new(user: user, habit: nil) }

      it "returns failure with error message" do
        result = service.call

        expect(result.success?).to be false
        expect(result.check_in).to be_nil
        expect(result.errors).to include("Habit is required")
      end
    end

    context "when habit does not belong to user" do
      let(:other_user) { create(:user) }
      let(:other_habit) { create(:habit, user: other_user) }
      let(:service) { described_class.new(user: user, habit: other_habit) }

      it "returns failure with error message" do
        result = service.call

        expect(result.success?).to be false
        expect(result.check_in).to be_nil
        expect(result.errors).to include("Habit does not belong to user")
      end
    end

    context "when check-in validation fails" do
      before do
        # Create a check-in for today to trigger the one-per-day validation
        create(:check_in, user: user, habit: habit, checked_in_at: Time.current)
      end

      it "returns failure with validation errors" do
        result = service.call

        expect(result.success?).to be false
        expect(result.check_in).not_to be_persisted
        expect(result.errors).to include("You have already checked in for this habit today")
      end
    end
  end

  describe "#success?" do
    it "returns true when check-in was created successfully" do
      service.call
      expect(service.success?).to be true
    end

    it "returns false when check-in was not created" do
      service = described_class.new(user: nil, habit: habit)
      service.call
      expect(service.success?).to be false
    end
  end

  describe "result object structure" do
    it "returns an OpenStruct with expected attributes" do
      result = service.call

      expect(result).to respond_to(:success?)
      expect(result).to respond_to(:check_in)
      expect(result).to respond_to(:errors)
    end
  end
end 
