# Quest Tracker 🏰

A beautiful, gamified habit tracking application built with Ruby on Rails and Tailwind CSS. Transform your daily habits into epic quests and track your progress with streaks, completion rates, and visual feedback.

![Quest Tracker](https://img.shields.io/badge/Rails-7.1+-red.svg)
![Ruby](https://img.shields.io/badge/Ruby-3.2+-red.svg)
![Tailwind](https://img.shields.io/badge/Tailwind-4.0+-blue.svg)
![Tests](https://img.shields.io/badge/Tests-59%20passing-brightgreen.svg)

## ✨ Features

### 🎯 Core Functionality
- **User Authentication**: Secure login/signup with bcrypt
- **Habit Management**: Create and track personal habits
- **Daily Check-ins**: Mark habits as completed with one click
- **Streak Tracking**: Visual feedback for current and longest streaks
- **Completion Analytics**: Track completion rates and total check-ins
- **Real-time Updates**: Turbo Streams for instant UI updates

### 🎨 User Experience
- **Responsive Design**: Beautiful on mobile, tablet, and desktop
- **Gamified Interface**: Quest-themed UI with emojis and badges
- **Visual Feedback**: Color-coded status indicators and progress badges
- **Smooth Animations**: Hover effects and transitions throughout

### 🏗️ Architecture
- **Service Objects**: Clean separation of business logic
- **TDD Approach**: Comprehensive test coverage (59 tests)
- **Code Quality**: RuboCop and Tailwind linting
- **API-Ready**: Structured for future React/JSON API integration

## 🚀 Quick Start

### Prerequisites
- Ruby 3.2 or higher
- Rails 7.1 or higher
- PostgreSQL
- Node.js (for Tailwind CSS)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/atayl16/quest_tracker.git
   cd quest_tracker
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Set up the database**
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed
   ```

4. **Start the development server**
   ```bash
   bin/dev
   ```

5. **Visit the application**
   ```
   http://localhost:3000
   ```

## 🧪 Testing

### Run the full test suite
```bash
bundle exec rspec
```

### Run specific test files
```bash
bundle exec rspec spec/models/habit_spec.rb
bundle exec rspec spec/services/complete_habit_spec.rb
bundle exec rspec spec/requests/check_ins_spec.rb
```

### Code quality checks
```bash
# Run RuboCop
bundle exec rubocop

# Auto-fix RuboCop violations
bundle exec rubocop -A

# Check Tailwind compilation
bin/rails assets:precompile
```

## 📊 Test Coverage

- **59 tests** across models, services, and requests
- **100% model coverage** with comprehensive edge cases
- **Service object testing** with success/failure scenarios
- **Request specs** covering Turbo Stream functionality
- **System tests** for user authentication flows

### Test Categories
- ✅ User authentication and registration
- ✅ Habit creation and validation
- ✅ Check-in functionality with service objects
- ✅ Streak calculation and completion rates
- ✅ Turbo Stream real-time updates
- ✅ Mobile-responsive design

## 🏗️ Technical Stack

### Backend
- **Ruby on Rails 7.1+**: Modern Rails with importmaps
- **PostgreSQL**: Production-ready database
- **bcrypt**: Secure password hashing
- **RSpec**: Comprehensive testing framework
- **FactoryBot**: Test data factories

### Frontend
- **Tailwind CSS 4.0+**: Utility-first CSS framework
- **Turbo**: Real-time updates without JavaScript
- **Hotwire**: Modern Rails frontend stack
- **Importmaps**: JavaScript module management

### Development Tools
- **RuboCop**: Ruby code style enforcement
- **Brakeman**: Security vulnerability scanning
- **Docker**: Containerized development environment

## 🎯 Current Status

### ✅ Completed Features
- [x] User authentication system
- [x] Habit creation and management
- [x] Daily check-in functionality
- [x] Streak tracking and analytics
- [x] Service object architecture
- [x] Comprehensive test suite
- [x] Responsive design
- [x] Turbo Stream real-time updates
- [x] Code quality enforcement

### 🚧 In Progress
- [ ] Habit creation interface
- [ ] User profile management
- [ ] Advanced analytics dashboard

### 🔮 Future Roadmap

#### MVP Phase
- [ ] Habit categories (Health, Mind, Spirit)
- [ ] Calendar view for habit tracking
- [ ] Export functionality for progress data
- [ ] Email reminders and notifications

#### Advanced Features
- [ ] React frontend with JSON API
- [ ] Mobile app with React Native
- [ ] Social features and habit sharing
- [ ] Advanced analytics and insights
- [ ] Habit templates and challenges

## 🏛️ Architecture Overview

### Models
- **User**: Authentication and user management
- **Habit**: Core habit entity with streak calculations
- **CheckIn**: Daily habit completion tracking

### Services
- **CompleteHabit**: Business logic for habit check-ins
- **Future**: Additional services for analytics, notifications, etc.

### Controllers
- **SessionsController**: User authentication
- **UsersController**: User registration
- **HabitsController**: Habit management
- **CheckInsController**: Check-in functionality

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for new functionality
4. Ensure all tests pass (`bundle exec rspec`)
5. Run code quality checks (`bundle exec rubocop`)
6. Commit your changes (`git commit -m 'feat: Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## 📝 Development Workflow

### Pre-commit Checklist
- [ ] All tests passing (`bundle exec rspec`)
- [ ] RuboCop clean (`bundle exec rubocop`)
- [ ] Tailwind compilation successful (`bin/rails assets:precompile`)
- [ ] Assets cleaned up (`rm -rf public/assets`)

### Commit Message Format
```
type(scope): Brief description

- Detailed bullet points
- Additional context
- Breaking changes if any
```

Types: `feat`, `fix`, `refactor`, `style`, `test`, `docs`

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ using Ruby on Rails
- Inspired by gamification principles
- Designed for maximum user engagement
- Focused on code quality and maintainability
