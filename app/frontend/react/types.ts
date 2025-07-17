export interface CheckIn {
  id: number;
  habit_id: number;
  user_id: number;
  created_at: string;
  updated_at: string;
}

export interface Habit {
  id: number;
  title: string;
  user_id: number;
  created_at: string;
  updated_at: string;
  check_ins: CheckIn[];
  current_streak: number;
  longest_streak: number;
} 
