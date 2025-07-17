import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import HabitItem from '../HabitItem';
import { Habit } from '../../types';

// Mock window.confirm
const mockConfirm = jest.fn();
Object.defineProperty(window, 'confirm', {
  value: mockConfirm,
  writable: true,
});

// Mock data
const today = new Date().toISOString().split('T')[0];
const mockHabit: Habit = {
  id: 1,
  title: 'Morning Exercise',
  user_id: 1,
  created_at: '2024-01-01T00:00:00Z',
  updated_at: '2024-01-01T00:00:00Z',
  check_ins: [
    { id: 1, habit_id: 1, user_id: 1, created_at: `${today}T00:00:00Z`, updated_at: `${today}T00:00:00Z` }
  ],
  current_streak: 5,
  longest_streak: 10
};

const mockHabitNotCompleted: Habit = {
  id: 2,
  title: 'Read 30 minutes',
  user_id: 1,
  created_at: '2024-01-01T00:00:00Z',
  updated_at: '2024-01-01T00:00:00Z',
  check_ins: [],
  current_streak: 0,
  longest_streak: 0
};

const mockProps = {
  onDeleteHabit: jest.fn(),
  onCheckInHabit: jest.fn(),
  onUndoCheckIn: jest.fn()
};

describe('HabitItem', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockConfirm.mockReturnValue(true);
  });

  describe('Rendering', () => {
    it('renders habit title and basic information', () => {
      render(<HabitItem habit={mockHabit} {...mockProps} />);
      
      expect(screen.getByText('Morning Exercise')).toBeInTheDocument();
      expect(screen.getByRole('heading', { name: 'Morning Exercise' })).toBeInTheDocument();
    });

    it('displays habit stats correctly', () => {
      render(<HabitItem habit={mockHabit} {...mockProps} />);
      
      expect(screen.getByText('5 days streak')).toBeInTheDocument();
      expect(screen.getByText('Best: 10 days')).toBeInTheDocument();
      expect(screen.getByText('1 total')).toBeInTheDocument();
    });

    it('shows completed state when habit is checked in today', () => {
      render(<HabitItem habit={mockHabit} {...mockProps} />);
      
      expect(screen.getByText('Completed Today!')).toBeInTheDocument();
      expect(screen.getByRole('button', { name: /undo/i })).toBeInTheDocument();
      expect(screen.queryByText('Ready to complete')).not.toBeInTheDocument();
    });

    it('shows check-in state when habit is not completed today', () => {
      render(<HabitItem habit={mockHabitNotCompleted} {...mockProps} />);
      
      expect(screen.getByText('Ready to complete')).toBeInTheDocument();
      expect(screen.getByRole('button', { name: /mark 'read 30 minutes' as completed for today/i })).toBeInTheDocument();
      expect(screen.queryByText('Completed Today!')).not.toBeInTheDocument();
    });

    it('displays delete button for all habits', () => {
      render(<HabitItem habit={mockHabit} {...mockProps} />);
      
      expect(screen.getByRole('button', { name: /delete/i })).toBeInTheDocument();
    });
  });

  describe('Check-in functionality', () => {
    it('calls onCheckInHabit when check-in button is clicked', async () => {
      render(<HabitItem habit={mockHabitNotCompleted} {...mockProps} />);
      
      const checkInButton = screen.getByRole('button', { name: /mark 'read 30 minutes' as completed for today/i });
      fireEvent.click(checkInButton);
      
      await waitFor(() => {
        expect(mockProps.onCheckInHabit).toHaveBeenCalledWith(2);
      });
    });

    it('shows loading state during check-in', async () => {
      mockProps.onCheckInHabit.mockImplementation(() => new Promise(resolve => setTimeout(resolve, 100)));
      
      render(<HabitItem habit={mockHabitNotCompleted} {...mockProps} />);
      
      const checkInButton = screen.getByRole('button', { name: /mark 'read 30 minutes' as completed for today/i });
      fireEvent.click(checkInButton);
      
      expect(screen.getByText('Completing...')).toBeInTheDocument();
      expect(checkInButton).toBeDisabled();
    });

    it('handles check-in errors gracefully', async () => {
      const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
      mockProps.onCheckInHabit.mockRejectedValue(new Error('Network error'));
      
      render(<HabitItem habit={mockHabitNotCompleted} {...mockProps} />);
      
      const checkInButton = screen.getByRole('button', { name: /mark 'read 30 minutes' as completed for today/i });
      fireEvent.click(checkInButton);
      
      await waitFor(() => {
        expect(consoleSpy).toHaveBeenCalledWith('Operation failed:', expect.any(Error));
      });
      
      consoleSpy.mockRestore();
    });
  });

  describe('Undo functionality', () => {
    it('calls onUndoCheckIn when undo button is clicked', async () => {
      render(<HabitItem habit={mockHabit} {...mockProps} />);
      
      const undoButton = screen.getByRole('button', { name: /undo/i });
      fireEvent.click(undoButton);
      
      await waitFor(() => {
        expect(mockProps.onUndoCheckIn).toHaveBeenCalledWith(1, 1);
      });
    });

    it('shows confirmation dialog before undoing', async () => {
      mockConfirm.mockReturnValue(false); // User cancels
      
      render(<HabitItem habit={mockHabit} {...mockProps} />);
      
      const undoButton = screen.getByRole('button', { name: /undo/i });
      fireEvent.click(undoButton);
      
      expect(mockConfirm).toHaveBeenCalledWith("Undo today's check-in?");
      expect(mockProps.onUndoCheckIn).not.toHaveBeenCalled();
    });

    it('shows loading state during undo', async () => {
      mockProps.onUndoCheckIn.mockImplementation(() => new Promise(resolve => setTimeout(resolve, 100)));
      
      render(<HabitItem habit={mockHabit} {...mockProps} />);
      
      const undoButton = screen.getByRole('button', { name: /undo/i });
      fireEvent.click(undoButton);
      
      expect(screen.getByText('Undoing...')).toBeInTheDocument();
      expect(undoButton).toBeDisabled();
    });

    it('handles undo errors gracefully', async () => {
      const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
      mockProps.onUndoCheckIn.mockRejectedValue(new Error('Network error'));
      
      render(<HabitItem habit={mockHabit} {...mockProps} />);
      
      const undoButton = screen.getByRole('button', { name: /undo/i });
      fireEvent.click(undoButton);
      
      await waitFor(() => {
        expect(consoleSpy).toHaveBeenCalledWith('Operation failed:', expect.any(Error));
      });
      
      consoleSpy.mockRestore();
    });
  });

  describe('Delete functionality', () => {
    it('calls onDeleteHabit when delete button is clicked', async () => {
      render(<HabitItem habit={mockHabit} {...mockProps} />);
      
      const deleteButton = screen.getByRole('button', { name: /delete/i });
      fireEvent.click(deleteButton);
      
      await waitFor(() => {
        expect(mockProps.onDeleteHabit).toHaveBeenCalledWith(1);
      });
    });

    it('shows confirmation dialog before deleting', async () => {
      mockConfirm.mockReturnValue(false); // User cancels
      
      render(<HabitItem habit={mockHabit} {...mockProps} />);
      
      const deleteButton = screen.getByRole('button', { name: /delete/i });
      fireEvent.click(deleteButton);
      
      expect(mockConfirm).toHaveBeenCalledWith('Are you sure you want to delete this habit?');
      expect(mockProps.onDeleteHabit).not.toHaveBeenCalled();
    });

    it('shows loading state during delete', async () => {
      mockProps.onDeleteHabit.mockImplementation(() => new Promise(resolve => setTimeout(resolve, 100)));
      
      render(<HabitItem habit={mockHabit} {...mockProps} />);
      
      const deleteButton = screen.getByRole('button', { name: /delete/i });
      fireEvent.click(deleteButton);
      
      expect(screen.getByText('Deleting...')).toBeInTheDocument();
      expect(deleteButton).toBeDisabled();
    });

    it('handles delete errors gracefully', async () => {
      const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
      mockProps.onDeleteHabit.mockRejectedValue(new Error('Network error'));
      
      render(<HabitItem habit={mockHabit} {...mockProps} />);
      
      const deleteButton = screen.getByRole('button', { name: /delete/i });
      fireEvent.click(deleteButton);
      
      await waitFor(() => {
        expect(consoleSpy).toHaveBeenCalledWith('Operation failed:', expect.any(Error));
      });
      
      consoleSpy.mockRestore();
    });
  });

  describe('Accessibility', () => {
    it('has proper ARIA labels and roles', () => {
      render(<HabitItem habit={mockHabit} {...mockProps} />);
      
      expect(screen.getByRole('region')).toHaveAttribute('aria-labelledby', 'habit-title-1');
      expect(screen.getByLabelText(/habit stats for morning exercise/i)).toBeInTheDocument();
      expect(screen.getByLabelText(/current streak: 5 days/i)).toBeInTheDocument();
      expect(screen.getByLabelText(/longest streak: 10 days/i)).toBeInTheDocument();
      expect(screen.getByLabelText(/total check-ins: 1/i)).toBeInTheDocument();
    });

    it('has proper button accessible names', () => {
      render(<HabitItem habit={mockHabitNotCompleted} {...mockProps} />);
      
      expect(screen.getByRole('button', { name: /mark 'read 30 minutes' as completed for today/i })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: /delete/i })).toBeInTheDocument();
    });

    it('has proper semantic structure', () => {
      render(<HabitItem habit={mockHabit} {...mockProps} />);
      
      expect(screen.getByRole('region')).toBeInTheDocument();
      expect(screen.getByRole('heading', { name: 'Morning Exercise' })).toBeInTheDocument();
    });
  });

  describe('Edge cases', () => {
    it('handles habit with no check-ins gracefully', () => {
      const habitWithNoCheckIns = { ...mockHabitNotCompleted, check_ins: undefined as any };
      render(<HabitItem habit={habitWithNoCheckIns} {...mockProps} />);
      
      expect(screen.getByText('0 total')).toBeInTheDocument();
      expect(screen.getByText('Ready to complete')).toBeInTheDocument();
    });

    it('handles habit with multiple check-ins', () => {
      const habitWithMultipleCheckIns = {
        ...mockHabit,
        check_ins: [
          { id: 1, habit_id: 1, user_id: 1, created_at: `${today}T00:00:00Z`, updated_at: `${today}T00:00:00Z` },
          { id: 2, habit_id: 1, user_id: 1, created_at: '2024-01-02T00:00:00Z', updated_at: '2024-01-02T00:00:00Z' }
        ]
      };
      
      render(<HabitItem habit={habitWithMultipleCheckIns} {...mockProps} />);
      
      expect(screen.getByText('2 total')).toBeInTheDocument();
      expect(screen.getByText('Completed Today!')).toBeInTheDocument();
    });

    it('handles single day streak correctly', () => {
      const singleDayStreak = { ...mockHabit, current_streak: 1, longest_streak: 1 };
      render(<HabitItem habit={singleDayStreak} {...mockProps} />);
      
      expect(screen.getByText('1 day streak')).toBeInTheDocument();
      expect(screen.getByText('Best: 1 day')).toBeInTheDocument();
    });
  });
}); 
