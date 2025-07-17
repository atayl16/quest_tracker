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

      expect(page).to have_content("Signed in successfully!")
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
      click_button "Create Habit"

      expect(page).to have_content("Habit created successfully!", wait: 5)
      expect(page).to have_content("Drink 8 glasses of water", wait: 5)
    end

    it "shows error when creating habit with empty title" do
      fill_in "habit_title", with: ""
      click_button "Create Habit"

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
      click_button "Delete"

      expect(page).to have_content("Habit deleted successfully!", wait: 5)
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
        accept_turbo_confirm
        click_button "Undo"
      end
      expect(page).to have_content("Check-in undone!", wait: 5)
      expect(page).to have_button("Complete Quest", wait: 5)
    end
  end
end
