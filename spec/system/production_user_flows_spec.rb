require "rails_helper"

RSpec.describe "Production User Flows", type: :system do
  let(:user) { create(:user, username: "test_user") }

  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "Complete user journey" do
    it "allows a user to sign in, create habits, check in, and manage their quests" do
      # 1. Sign in
      visit signin_path
      fill_in "Username", with: user.username
      fill_in "Password", with: user.password
      click_button "Continue Your Quest"
      expect(page).to have_current_path(habits_path)
      expect(page).to have_content("Welcome back, #{user.username}!")

      # 2. Verify empty state and "Begin Your Quest" button
      expect(page).to have_content("No active quests yet")
      expect(page).to have_link("Begin Your Quest")

      # 3. Create first habit using "Begin Your Quest" button
      click_link "Begin Your Quest"
      expect(page).to have_field("habit_title")
      fill_in "habit_title", with: "Drink 8 glasses of water daily"
      click_button "Create Quest"
      expect(page).to have_content("Drink 8 glasses of water daily", wait: 5)
      expect(page).not_to have_link("Begin Your Quest")

      # 4. Create second habit using the form
      fill_in "habit_title", with: "Exercise for 30 minutes"
      click_button "Create Quest"
      expect(page).to have_content("Exercise for 30 minutes", wait: 5)

      # 5. Check in on first habit
      within("#habit_#{user.habits.first.id}") do
        click_button "Complete Quest"
      end
      expect(page).to have_content("Completed Today!", wait: 5)

      # 6. Verify check-in can be undone
      within("#habit_#{user.habits.first.id}") do
        click_button "Undo"
      end
      expect(page).to have_button("Complete Quest", wait: 5)

      # 7. Check in again and verify streak
      within("#habit_#{user.habits.first.id}") do
        click_button "Complete Quest"
      end
      expect(page).to have_content("Completed Today!", wait: 5)
      expect(page).to have_content("1 day streak")

      # 8. Delete a habit
      accept_turbo_confirm
      within("#habit_#{user.habits.last.id}") do
        click_button "Abandon"
      end
      expect(page).not_to have_content("Exercise for 30 minutes", wait: 5)

      # 9. Verify remaining habit is still there
      expect(page).to have_content("Drink 8 glasses of water daily")
    end
  end

  describe "React UI functionality" do
    it "allows switching to React UI and using all features" do
      # Sign in first
      visit signin_path
      fill_in "Username", with: user.username
      fill_in "Password", with: user.password
      click_button "Continue Your Quest"

      # Switch to React UI
      click_link "React UI"
      expect(page).to have_current_path("/habits?ui=react")
      expect(page).to have_content("Welcome back, #{user.username}!")

      # Create a habit in React UI (using the input field directly)
      find("input[placeholder='Enter your new quest...']").set("React test habit")
      click_button "Create Quest"
      expect(page).to have_content("React test habit", wait: 5)

      # Check in on the habit (using the first Complete Quest button)
      first("button", text: "Complete Quest").click
      # Switch back to Turbo UI
      click_link "Turbo UI"
      expect(page).to have_current_path("/habits")
      expect(page).to have_content("React test habit")
      expect(page).to have_content("Completed Today!", wait: 5)
    end
  end

  describe "Error handling" do
    it "handles authentication errors properly" do
      visit signin_path
      fill_in "Username", with: "nonexistent"
      fill_in "Password", with: "wrong"
      click_button "Continue Your Quest"
      expect(page).to have_content("Invalid username or password")
      expect(page).to have_current_path(signin_path)
    end

    it "handles empty habit creation gracefully" do
      visit signin_path
      fill_in "Username", with: user.username
      fill_in "Password", with: user.password
      click_button "Continue Your Quest"

      # Try to create habit with empty title
      fill_in "habit_title", with: ""
      click_button "Create Quest"
      expect(page).to have_content("Title can't be blank", wait: 5)
    end
  end

  describe "Data persistence" do
    it "maintains data between page refreshes" do
      # Create habit in first session
      visit signin_path
      fill_in "Username", with: user.username
      fill_in "Password", with: user.password
      click_button "Continue Your Quest"

      fill_in "habit_title", with: "Persistent habit"
      click_button "Create Quest"
      expect(page).to have_content("Persistent habit", wait: 5)

      # Refresh page and verify habit still exists
      visit habits_path
      expect(page).to have_content("Persistent habit")
    end
  end

  describe "Accessibility and UX" do
    it "provides proper focus management and keyboard navigation" do
      visit signin_path
      fill_in "Username", with: user.username
      fill_in "Password", with: user.password
      click_button "Continue Your Quest"

      # Test "Begin Your Quest" button accessibility
      expect(page).to have_link("Begin Your Quest")
      click_link "Begin Your Quest"
      expect(page).to have_field("habit_title")

      # Test form submission with Enter key
      fill_in "habit_title", with: "Keyboard test"
      find("#habit_title").send_keys(:return)
      expect(page).to have_content("Keyboard test", wait: 5)
    end

    it "shows proper loading states and feedback" do
      visit signin_path
      fill_in "Username", with: user.username
      fill_in "Password", with: user.password
      click_button "Continue Your Quest"

      # Verify page loads completely
      expect(page).to have_content("My Active Quests")
      expect(page).to have_content("Add New Quest")
      expect(page).to have_button("Create Quest")
    end
  end
end
