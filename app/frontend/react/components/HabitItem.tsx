import React, { useState } from 'react';
import { Habit } from '../types';

interface HabitItemProps {
  habit: Habit;
  onDeleteHabit: (habitId: number) => Promise<void>;
  onCheckInHabit: (habitId: number) => Promise<void>;
  onUndoCheckIn: (habitId: number, checkInId: number) => Promise<void>;
}

// Utility functions
const isToday = (dateString: string): boolean => {
  const date = new Date(dateString).toDateString();
  const today = new Date().toDateString();
  return date === today;
};

const formatStreak = (count: number): string => {
  return `${count} day${count === 1 ? '' : 's'}`;
};

const pluralize = (count: number, singular: string, plural: string): string => {
  return count === 1 ? singular : plural;
};

// Custom hook for async operations
const useAsyncOperation = () => {
  const [isLoading, setIsLoading] = useState(false);

  const executeOperation = async (operation: () => Promise<void>) => {
    setIsLoading(true);
    try {
      await operation();
    } catch (error) {
      console.error('Operation failed:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return { isLoading, executeOperation };
};

const HabitItem: React.FC<HabitItemProps> = ({ 
  habit, 
  onDeleteHabit, 
  onCheckInHabit, 
  onUndoCheckIn 
}) => {
  const { isLoading: isCheckingIn, executeOperation: executeCheckIn } = useAsyncOperation();
  const { isLoading: isDeleting, executeOperation: executeDelete } = useAsyncOperation();
  const { isLoading: isUndoing, executeOperation: executeUndo } = useAsyncOperation();

  const checkIns = habit.check_ins || [];
  const completedToday = checkIns.some(checkIn => isToday(checkIn.created_at));
  const todaysCheckIn = checkIns.find(checkIn => isToday(checkIn.created_at));

  const handleCheckIn = () => {
    executeCheckIn(() => onCheckInHabit(habit.id));
  };

  const handleDelete = () => {
    if (!window.confirm('Are you sure you want to delete this habit?')) return;
    executeDelete(() => onDeleteHabit(habit.id));
  };

  const handleUndo = () => {
    if (!todaysCheckIn) return;
    if (!window.confirm("Undo today's check-in?")) return;
    executeUndo(() => onUndoCheckIn(habit.id, todaysCheckIn.id));
  };

  const renderActionButtons = () => {
    if (completedToday) {
      return (
        <div className="flex items-center space-x-2" title="You have completed this habit today" aria-label="Completed today">
          <span className="text-xs sm:text-sm text-green-400 font-medium" aria-hidden="true">✅</span>
          <span className="text-xs sm:text-sm text-green-400 font-medium">Completed Today!</span>
          <div className="w-2 h-2 bg-green-500 rounded-full" aria-hidden="true"></div>
          <button
            onClick={handleUndo}
            disabled={isUndoing}
            className="ml-2 bg-slate-600 hover:bg-slate-700 disabled:bg-slate-800 text-white text-xs sm:text-sm font-semibold py-2 px-3 rounded-lg transition-all duration-200"
          >
            {isUndoing ? 'Undoing...' : 'Undo'}
          </button>
        </div>
      );
    }

    return (
      <div className="flex flex-col sm:flex-row items-center space-y-2 sm:space-y-0 sm:space-x-3">
        <span className="text-xs sm:text-sm text-slate-400">Ready to complete</span>
        <button
          onClick={handleCheckIn}
          disabled={isCheckingIn}
          className="bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700 disabled:from-slate-600 disabled:to-slate-600 text-white font-semibold py-2 px-3 sm:px-4 rounded-lg transition-all duration-200 transform hover:scale-105 text-xs sm:text-sm disabled:transform-none"
          aria-label={`Mark '${habit.title}' as completed for today`}
        >
          {isCheckingIn ? 'Completing...' : 'Complete Quest'}
        </button>
      </div>
    );
  };

  const renderStatBadge = (
    icon: string,
    label: string,
    value: string,
    bgColor: string,
    borderColor: string,
    textColor: string
  ) => (
    <div 
      className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${bgColor} border ${borderColor} ${textColor}`}
      title={label}
      aria-label={label}
    >
      <span className="mr-1" aria-hidden="true">{icon}</span>
      <span>{value}</span>
    </div>
  );

  return (
    <section 
      className="bg-slate-700/30 rounded-xl p-4 sm:p-6 border border-slate-600/30 hover:border-purple-500/50 transition-all duration-300" 
      aria-labelledby={`habit-title-${habit.id}`}
    >
      <div className="flex flex-col space-y-4">
        {/* Header with title and status */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-3 sm:space-y-0">
          <div className="flex items-center">
            <div className="w-3 h-3 bg-purple-500 rounded-full mr-4" aria-hidden="true"></div>
            <h3 id={`habit-title-${habit.id}`} className="text-lg font-medium text-white">
              {habit.title}
            </h3>
          </div>
          
          <div className="flex items-center justify-center sm:justify-end space-x-2 sm:space-x-4">
            {renderActionButtons()}
            
            {/* Delete button */}
            <button
              onClick={handleDelete}
              disabled={isDeleting}
              className="ml-2 bg-red-600 hover:bg-red-700 disabled:bg-slate-800 text-white text-xs sm:text-sm font-semibold py-2 px-3 rounded-lg transition-all duration-200"
            >
              {isDeleting ? 'Deleting...' : 'Delete'}
            </button>
          </div>
        </div>

        {/* Stats row with badges */}
        <div className="flex flex-wrap items-center gap-2 sm:gap-3" aria-label={`Habit stats for ${habit.title}`}>
          {renderStatBadge(
            '🔥',
            `Current streak: ${formatStreak(habit.current_streak)}`,
            `${formatStreak(habit.current_streak)} streak`,
            'bg-orange-500/20',
            'border-orange-500/50',
            'text-orange-300'
          )}
          
          {renderStatBadge(
            '🏆',
            `Longest streak: ${formatStreak(habit.longest_streak)}`,
            `Best: ${formatStreak(habit.longest_streak)}`,
            'bg-purple-500/20',
            'border-purple-500/50',
            'text-purple-300'
          )}
          
          {renderStatBadge(
            '📅',
            `Total check-ins: ${checkIns.length}`,
            `${checkIns.length} total`,
            'bg-slate-500/20',
            'border-slate-500/50',
            'text-slate-300'
          )}
        </div>
      </div>
    </section>
  );
};

export default HabitItem; 
