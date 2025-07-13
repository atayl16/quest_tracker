# Quest Tracker 🧙‍♀️✨

A Rails 8 app for tracking daily habits like a fantasy quest log. Built with TDD using RSpec, service objects for business logic, Turbo for interactivity, and Tailwind for styling.

## 🌟 Vision

Track habits as if they were epic quests. Check off tasks, maintain streaks, and stay motivated with a themed experience inspired by Old School RuneScape and classic RPGs.

## 🛠 Tech Stack

- Ruby on Rails 8 (Turbo / Stimulus)
- RSpec (TDD-first)
- Tailwind CSS
- Hotwire interactivity
- React (optional UI version planned)

## 🚧 Status

🧪 Currently building the MVP using strict TDD. UI is minimalist but styled. Features and tests come first — polish later.

## 📂 Features in Progress

- [x] Habit model with validations and user association
- [x] Index view (styled with Tailwind)
- [ ] Habit completion tracking
- [ ] Streak calculation and rewards
- [ ] Themed dashboards ("My Quest Log")

## 🏗 Architecture

- **Models**: User and Habit with proper validations and associations
- **Controllers**: RESTful with thin controllers, business logic in services
- **Views**: Fantasy-themed with Tailwind CSS
- **Testing**: Comprehensive RSpec coverage with FactoryBot and Shoulda Matchers
- **Code Quality**: RuboCop compliance, clean architecture principles

## 🚀 Getting Started

```bash
# Clone the repository
git clone <repository-url>
cd quest_tracker

# Install dependencies
bundle install

# Setup database
rails db:create db:migrate

# Run tests
bundle exec rspec

# Start the server
rails server
```

Visit `http://localhost:3000` to see your quest log!

## 🧪 Testing

This project follows strict TDD principles:

```bash
# Run all tests
bundle exec rspec

# Run with documentation
bundle exec rspec --format documentation

# Run specific test file
bundle exec rspec spec/models/habit_spec.rb
```

## 🎨 Development

- **TDD First**: All features start with failing tests
- **Clean Code**: RuboCop compliance, meaningful commits
- **Service Objects**: Business logic separated from controllers
- **Fantasy Theme**: UI uses quest/quest log terminology while keeping backend realistic

## 📈 Roadmap

- [ ] User authentication and authorization
- [ ] Habit completion tracking with streaks
- [ ] Quest rewards and achievements
- [ ] React frontend option
- [ ] Mobile-responsive design
- [ ] Performance optimizations
