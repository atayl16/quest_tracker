import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import HabitList from '../HabitList';
import { Habit } from '../../types';

// Mock data
const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD format
const mockHabits: Habit[] = [
  {
    id: 1,
    title: 'Morning Exercise',
    user_id: 1,
    created_at: '2024-01-01T00:00:00Z',
    updated_at: '2024-01-01T00:00:00Z',
    check_ins: [
      { id: 1, habit_id: 1, user_id: 1, created_at: `${today}T00:00:00Z`, updated_at: `${today}T00:00:00Z` }
    ],
    current_streak: 1,
    longest_streak: 1
  },
  {
    id: 2,
    title: 'Read 30 minutes',
    user_id: 1,
    created_at: '2024-01-01T00:00:00Z',
    updated_at: '2024-01-01T00:00:00Z',
    check_ins: [],
    current_streak: 0,
    longest_streak: 0
  }
];

const mockProps = {
  habits: mockHabits,
  onDeleteHabit: jest.fn(),
  onCheckInHabit: jest.fn(),
  onUndoCheckIn: jest.fn()
};

describe('HabitList', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders empty state when no habits', () => {
    render(<HabitList {...mockProps} habits={[]} />);
    
    expect(screen.getByText('No active quests yet')).toBeInTheDocument();
    expect(screen.getByText('Start your journey by creating your first habit quest!')).toBeInTheDocument();
    expect(screen.getByRole('link', { name: /begin your first quest/i })).toBeInTheDocument();
  });

  it('renders list of habits when habits exist', () => {
    render(<HabitList {...mockProps} />);
    
    expect(screen.getByText('Morning Exercise')).toBeInTheDocument();
    expect(screen.getByText('Read 30 minutes')).toBeInTheDocument();
  });

  it('displays habit stats correctly', () => {
    render(<HabitList {...mockProps} />);
    
    // Check for streak information
    expect(screen.getByText(/1 day streak/)).toBeInTheDocument();
    expect(screen.getByText(/Best: 1 day/)).toBeInTheDocument();
    expect(screen.getByText('1 total')).toBeInTheDocument();
    
    // Second habit should show 0 streak
    expect(screen.getByText((content, element) => {
      return element?.textContent === '0 days streak';
    })).toBeInTheDocument();
  });

  it('shows completed state for habits checked in today', () => {
    render(<HabitList {...mockProps} />);
    
    expect(screen.getByText('Completed Today!')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /undo/i })).toBeInTheDocument();
  });

  it('shows check-in button for habits not completed today', () => {
    render(<HabitList {...mockProps} />);
    
    expect(screen.getByRole('button', { name: /mark 'read 30 minutes' as completed for today/i })).toBeInTheDocument();
  });

  it('calls onCheckInHabit when check-in button is clicked', () => {
    render(<HabitList {...mockProps} />);
    
    const checkInButton = screen.getByRole('button', { name: /mark 'read 30 minutes' as completed for today/i });
    fireEvent.click(checkInButton);
    
    expect(mockProps.onCheckInHabit).toHaveBeenCalledWith(2);
  });

  it('calls onUndoCheckIn when undo button is clicked', () => {
    render(<HabitList {...mockProps} />);
    
    const undoButton = screen.getByRole('button', { name: /undo/i });
    fireEvent.click(undoButton);
    
    expect(mockProps.onUndoCheckIn).toHaveBeenCalledWith(1, 1);
  });

  it('calls onDeleteHabit when delete button is clicked', () => {
    render(<HabitList {...mockProps} />);
    
    const deleteButtons = screen.getAllByRole('button', { name: /delete/i });
    fireEvent.click(deleteButtons[0]); // Click first delete button
    
    expect(mockProps.onDeleteHabit).toHaveBeenCalledWith(1);
  });

  it('displays correct accessibility labels', () => {
    render(<HabitList {...mockProps} />);
    
    expect(screen.getByLabelText(/habit stats for morning exercise/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/habit stats for read 30 minutes/i)).toBeInTheDocument();
  });

  it('handles multiple check-ins correctly', () => {
    const habitWithMultipleCheckIns: Habit = {
      ...mockHabits[0],
      check_ins: [
        { id: 1, habit_id: 1, user_id: 1, created_at: `${today}T00:00:00Z`, updated_at: `${today}T00:00:00Z` },
        { id: 2, habit_id: 1, user_id: 1, created_at: '2024-01-02T00:00:00Z', updated_at: '2024-01-02T00:00:00Z' }
      ]
    };
    
    render(<HabitList {...mockProps} habits={[habitWithMultipleCheckIns]} />);
    
    expect(screen.getByText('2 total')).toBeInTheDocument();
  });

  it('renders with proper semantic structure', () => {
    render(<HabitList {...mockProps} />);
    
    // Check for habit items (sections)
    const habitItems = screen.getAllByRole('region');
    expect(habitItems).toHaveLength(2);
    
    // Check for habit titles
    expect(screen.getByText('Morning Exercise')).toBeInTheDocument();
    expect(screen.getByText('Read 30 minutes')).toBeInTheDocument();
  });
}); 
