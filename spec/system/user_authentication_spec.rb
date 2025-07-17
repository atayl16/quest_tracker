require "rails_helper"

RSpec.describe "User Authentication", type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "sign in" do
    it "allows user to sign in with valid credentials" do
      visit signin_path

      fill_in "Username", with: user.username
      fill_in "Password", with: user.password
      click_button "Continue Your Quest"

      expect(page).to have_current_path(habits_path)
      expect(page).to have_current_path(habits_path)
    end

    it "shows error with invalid credentials" do
      visit signin_path

      fill_in "Username", with: user.username
      fill_in "Password", with: "wrong_password"
      click_button "Continue Your Quest"

      expect(page).to have_content("Invalid username or password")
      expect(page).to have_current_path(signin_path)
    end
  end

  describe "habit creation" do
    before do
      # Sign in through the UI instead of using the helper
      visit signin_path
      fill_in "Username", with: user.username
      fill_in "Password", with: user.password
      click_button "Continue Your Quest"
      expect(page).to have_current_path(habits_path)
    end

    it "allows user to create a new habit" do
      fill_in "habit_title", with: "Drink 8 glasses of water"
      click_button "Create Quest"

      expect(page).to have_content("Drink 8 glasses of water", wait: 5)
      expect(page).to have_content("Drink 8 glasses of water", wait: 5)
    end

    it "shows error when creating habit with empty title" do
      fill_in "habit_title", with: ""
      click_button "Create Quest"

      expect(page).to have_content("Title can't be blank", wait: 5)
    end
  end

  describe "habit deletion" do
    let!(:habit) { create(:habit, user: user, title: "Test habit to delete") }

    before do
      # Sign in through the UI
      visit signin_path
      fill_in "Username", with: user.username
      fill_in "Password", with: user.password
      click_button "Continue Your Quest"
      expect(page).to have_current_path(habits_path)
    end

    it "allows user to delete a habit" do
      expect(page).to have_content("Test habit to delete")

      # Accept Turbo confirmation and click delete
      accept_turbo_confirm
      click_button "Abandon"

      expect(page).not_to have_content("Test habit to delete", wait: 5)
      expect(page).not_to have_content("Test habit to delete", wait: 5)
    end
  end

  describe "check-in undo (uncheck)" do
    let!(:habit) { create(:habit, user: user, title: "Habit to uncheck") }

    before do
      # Sign in through the UI
      visit signin_path
      fill_in "Username", with: user.username
      fill_in "Password", with: user.password
      click_button "Continue Your Quest"
      expect(page).to have_current_path(habits_path)
    end

    it "allows user to check in and then undo (uncheck)" do
      # Check in
      within("#habit_#{habit.id}") do
        click_button "Complete Quest"
      end
      expect(page).to have_content("Completed Today!", wait: 5)

      # Undo check-in
      within("#habit_#{habit.id}") do
        click_button "Undo"
      end
      expect(page).to have_button("Complete Quest", wait: 5)
      expect(page).to have_button("Complete Quest", wait: 5)
    end
  end

  describe "Begin Your Quest button" do
    let(:empty_user) { create(:user, username: "empty_user") }

    before do
      # Ensure the user has no habits
      empty_user.habits.destroy_all

      # Sign in through the UI
      visit signin_path
      fill_in "Username", with: empty_user.username
      fill_in "Password", with: empty_user.password
      click_button "Continue Your Quest"
      expect(page).to have_current_path(habits_path)
    end

    context "when user has no habits" do
      it "shows the Begin Your Quest button" do
        expect(page).to have_link("Begin Your Quest")
        expect(page).to have_content("No active quests yet")
      end

      it "scrolls to and focuses the form when Begin Your Quest is clicked" do
        click_link "Begin Your Quest"
        # The form should be visible
        expect(page).to have_field("habit_title")
      end

      it "allows creating a habit after clicking Begin Your Quest" do
        click_link "Begin Your Quest"

        fill_in "habit_title", with: "New habit from button"
        click_button "Create Quest"

        expect(page).to have_content("New habit from button", wait: 5)
        expect(page).not_to have_link("Begin Your Quest")
      end
    end

    context "when user has existing habits" do
      let!(:habit) { create(:habit, user: empty_user, title: "Existing habit") }

      before do
        # Sign in through the UI
        visit signin_path
        fill_in "Username", with: empty_user.username
        fill_in "Password", with: empty_user.password
        click_button "Continue Your Quest"
        expect(page).to have_current_path(habits_path)
      end

      it "does not show the Begin Your Quest button" do
        expect(page).not_to have_button("Begin Your Quest")
        expect(page).to have_content("Existing habit")
      end

      it "shows the form directly" do
        expect(page).to have_field("habit_title")
        expect(page).to have_button("Create Quest")
      end
    end
  end
end
