require "rails_helper"

RSpec.describe "User Authentication", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "User login and habit viewing flow" do
    let(:user) { create(:user, username: "questmaster") }
    let!(:habit) { create(:habit, user: user, title: "Morning Meditation") }

    it "allows user to sign in and view their habit list" do
      # Visit the habits page while not signed in
      visit habits_path

      # Should be redirected to sign in page
      expect(page).to have_current_path(signin_path)
      expect(page).to have_content("Sign In")
      expect(page).to have_content("Welcome back, adventurer!")

      # Fill in the sign in form
      fill_in "Username", with: user.username
      fill_in "Password", with: DEFAULT_PASSWORD
      click_button "Continue Your Quest"

      # Should be redirected to habits index
      expect(page).to have_current_path(root_path)
      expect(page).to have_content("Quest Tracker")
      expect(page).to have_content("Welcome back, questmaster!")
      expect(page).to have_content("My Active Quests")
      expect(page).to have_content("Morning Meditation")
    end

    it "shows appropriate message when user has no habits" do
      user_without_habits = create(:user, username: "newbie")

      visit signin_path
      fill_in "Username", with: user_without_habits.username
      fill_in "Password", with: DEFAULT_PASSWORD
      click_button "Continue Your Quest"

      expect(page).to have_content("Welcome back, newbie!")
      expect(page).to have_content("My Active Quests")
      expect(page).to have_content("No active quests yet")
      expect(page).to have_content("Start your journey by creating your first habit quest!")
    end

    it "shows error message with invalid credentials" do
      visit signin_path

      fill_in "Username", with: "nonexistent"
      fill_in "Password", with: "wrongpassword"
      click_button "Continue Your Quest"

      expect(page).to have_current_path(signin_path)
      expect(page).to have_content("Invalid username or password")
    end
  end
end
