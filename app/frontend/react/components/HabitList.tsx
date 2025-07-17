import React from 'react';
import { Habit } from '../types';
import HabitItem from './HabitItem';

interface HabitListProps {
  habits: Habit[];
  onDeleteHabit: (habitId: number) => Promise<void>;
  onCheckInHabit: (habitId: number) => Promise<void>;
  onUndoCheckIn: (habitId: number, checkInId: number) => Promise<void>;
}

const HabitList: React.FC<HabitListProps> = ({ 
  habits, 
  onDeleteHabit, 
  onCheckInHabit, 
  onUndoCheckIn 
}) => {
  if (habits.length === 0) {
    return (
      <div className="text-center py-8 sm:py-12">
        <div className="text-4xl sm:text-6xl mb-4" role="img" aria-label="Castle">🏰</div>
        <h3 className="text-lg sm:text-xl font-medium text-slate-300 mb-2">No active quests yet</h3>
        <p className="text-slate-400 mb-6 text-sm sm:text-base">Start your journey by creating your first habit quest!</p>
        <a 
          href="#new-habit-form"
          className="bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 text-white font-semibold py-2 sm:py-3 px-4 sm:px-6 rounded-lg transition-all duration-200 transform hover:scale-105 text-sm sm:text-base"
          aria-label="Begin your first quest"
        >
          Begin Your Quest
        </a>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {habits.map((habit) => (
        <HabitItem
          key={habit.id}
          habit={habit}
          onDeleteHabit={onDeleteHabit}
          onCheckInHabit={onCheckInHabit}
          onUndoCheckIn={onUndoCheckIn}
        />
      ))}
    </div>
  );
};

export default HabitList; 
