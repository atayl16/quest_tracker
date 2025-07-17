// LocalStorage Service for production environment
class LocalStorageService {
  constructor() {
    this.storageKey = 'quest_tracker_data';
    this.initializeStorage();
  }

  initializeStorage() {
    if (!localStorage.getItem(this.storageKey)) {
      const initialData = {
        users: [
          {
            id: 1,
            username: 'demo',
            email: 'demo@example.com',
            password_hash: 'demo_password_hash' // In real app, this would be hashed
          }
        ],
        habits: [],
        check_ins: [],
        current_user: null
      };
      localStorage.setItem(this.storageKey, JSON.stringify(initialData));
    }
  }

  getData() {
    return JSON.parse(localStorage.getItem(this.storageKey) || '{}');
  }

  setData(data) {
    localStorage.setItem(this.storageKey, JSON.stringify(data));
  }

  // User management
  authenticateUser(username, password) {
    const data = this.getData();
    const user = data.users.find(u => u.username === username);
    
    if (user && (username === 'demo' && password === 'password')) {
      data.current_user = user;
      this.setData(data);
      return { success: true, user };
    }
    return { success: false, error: 'Invalid credentials' };
  }

  getCurrentUser() {
    const data = this.getData();
    return data.current_user;
  }

  logout() {
    const data = this.getData();
    data.current_user = null;
    this.setData(data);
  }

  // Habit management
  getHabitsForUser(userId) {
    const data = this.getData();
    const userHabits = data.habits.filter(h => h.user_id === userId);
    
    // Add check-ins to each habit
    return userHabits.map(habit => ({
      ...habit,
      check_ins: data.check_ins.filter(c => c.habit_id === habit.id)
    }));
  }

  createHabit(attributes) {
    const data = this.getData();
    const habit = {
      id: this.generateId(),
      title: attributes.title,
      user_id: attributes.user_id,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    
    data.habits.push(habit);
    this.setData(data);
    return { success: true, habit };
  }

  deleteHabit(habitId, userId) {
    const data = this.getData();
    const habitIndex = data.habits.findIndex(h => h.id === habitId && h.user_id === userId);
    
    if (habitIndex !== -1) {
      data.habits.splice(habitIndex, 1);
      // Also delete related check-ins
      data.check_ins = data.check_ins.filter(c => c.habit_id !== habitId);
      this.setData(data);
      return { success: true };
    }
    return { success: false, error: 'Habit not found' };
  }

  // Check-in management
  createCheckIn(habitId, userId) {
    const data = this.getData();
    const today = new Date().toDateString();
    
    // Check if already checked in today
    const existingCheckIn = data.check_ins.find(c => 
      c.habit_id === habitId && 
      c.user_id === userId && 
      new Date(c.checked_in_at).toDateString() === today
    );
    
    if (existingCheckIn) {
      return { success: false, error: 'Already checked in today' };
    }
    
    const checkIn = {
      id: this.generateId(),
      habit_id: habitId,
      user_id: userId,
      checked_in_at: new Date().toISOString(),
      created_at: new Date().toISOString()
    };
    
    data.check_ins.push(checkIn);
    this.setData(data);
    return { success: true, check_in: checkIn };
  }

  deleteCheckIn(checkInId, userId) {
    const data = this.getData();
    const checkInIndex = data.check_ins.findIndex(c => c.id === checkInId && c.user_id === userId);
    
    if (checkInIndex !== -1) {
      data.check_ins.splice(checkInIndex, 1);
      this.setData(data);
      return { success: true };
    }
    return { success: false, error: 'Check-in not found' };
  }

  // Helper methods
  generateId() {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
  }

  // Calculate streaks
  calculateStreaks(habitId, userId) {
    const data = this.getData();
    const habitCheckIns = data.check_ins
      .filter(c => c.habit_id === habitId && c.user_id === userId)
      .map(c => new Date(c.checked_in_at))
      .sort((a, b) => b - a); // Sort descending
    
    if (habitCheckIns.length === 0) {
      return { current_streak: 0, longest_streak: 0 };
    }
    
    let currentStreak = 0;
    let longestStreak = 0;
    let tempStreak = 0;
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    // Calculate current streak
    let checkDate = today;
    for (let i = 0; i < habitCheckIns.length; i++) {
      const checkInDate = new Date(habitCheckIns[i]);
      checkInDate.setHours(0, 0, 0, 0);
      
      if (checkDate.getTime() === checkInDate.getTime()) {
        currentStreak++;
        checkDate.setDate(checkDate.getDate() - 1);
      } else {
        break;
      }
    }
    
    // Calculate longest streak
    for (let i = 0; i < habitCheckIns.length; i++) {
      if (i === 0) {
        tempStreak = 1;
      } else {
        const prevDate = new Date(habitCheckIns[i - 1]);
        const currDate = new Date(habitCheckIns[i]);
        const diffDays = Math.floor((prevDate - currDate) / (1000 * 60 * 60 * 24));
        
        if (diffDays === 1) {
          tempStreak++;
        } else {
          longestStreak = Math.max(longestStreak, tempStreak);
          tempStreak = 1;
        }
      }
    }
    longestStreak = Math.max(longestStreak, tempStreak);
    
    return { current_streak: currentStreak, longest_streak: longestStreak };
  }

  // Check if habit is completed today
  isCompletedToday(habitId, userId) {
    const data = this.getData();
    const today = new Date().toDateString();
    
    return data.check_ins.some(c => 
      c.habit_id === habitId && 
      c.user_id === userId && 
      new Date(c.checked_in_at).toDateString() === today
    );
  }

  // Get today's check-in for a habit
  getTodaysCheckIn(habitId, userId) {
    const data = this.getData();
    const today = new Date().toDateString();
    
    return data.check_ins.find(c => 
      c.habit_id === habitId && 
      c.user_id === userId && 
      new Date(c.checked_in_at).toDateString() === today
    );
  }
}

// Export for use in other files
window.LocalStorageService = LocalStorageService; 
