import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import App from '../App';
import { Habit } from '../types';

// Mock fetch globally
const mockFetch = jest.fn();
global.fetch = mockFetch;

// Mock window.confirm
const mockConfirm = jest.fn();
Object.defineProperty(window, 'confirm', {
  value: mockConfirm,
  writable: true,
});

// Mock CSRF token
const mockCSRFToken = 'test-csrf-token';
Object.defineProperty(document, 'querySelector', {
  value: jest.fn(() => ({
    getAttribute: jest.fn(() => mockCSRFToken),
  })),
  writable: true,
});

describe('App Integration Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockConfirm.mockReturnValue(true);
  });

  const mockHabits: Habit[] = [
    {
      id: 1,
      title: 'Morning Exercise',
      user_id: 1,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
      check_ins: [],
      current_streak: 0,
      longest_streak: 0
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

  const mockCheckIn = {
    id: 3,
    habit_id: 1,
    user_id: 1,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  };

  describe('Initial Load', () => {
    it('shows loading state initially', () => {
      mockFetch.mockImplementation(() => new Promise(() => {})); // Never resolves
      
      render(<App />);
      
      expect(screen.getByText('Loading your quests...')).toBeInTheDocument();
    });

    it('loads and displays habits successfully', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockHabits
      });

      render(<App />);

      await waitFor(() => {
        expect(screen.getByText('Morning Exercise')).toBeInTheDocument();
        expect(screen.getByText('Read 30 minutes')).toBeInTheDocument();
      });

      expect(screen.queryByText('Loading your quests...')).not.toBeInTheDocument();
    });

    it('shows empty state when no habits exist', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => []
      });

      render(<App />);

      await waitFor(() => {
        expect(screen.getByText('No active quests yet')).toBeInTheDocument();
        expect(screen.getByText('Start your journey by creating your first habit quest!')).toBeInTheDocument();
      });
    });

    it('handles fetch errors gracefully', async () => {
      mockFetch.mockRejectedValueOnce(new Error('Network error'));

      render(<App />);

      await waitFor(() => {
        expect(screen.getByText('Error: Network error')).toBeInTheDocument();
      });
    });

    it('handles non-ok response', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 500,
        statusText: 'Internal Server Error',
        text: async () => 'Server error'
      });

      render(<App />);

      await waitFor(() => {
        expect(screen.getByText(/Failed to fetch habits/)).toBeInTheDocument();
      });
    });
  });

  describe('Creating Habits', () => {
    beforeEach(() => {
      // Mock initial habits fetch
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockHabits
      });
    });

    it('creates a new habit successfully', async () => {
      const newHabit = {
        id: 3,
        title: 'New Habit',
        user_id: 1,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-01T00:00:00Z',
        check_ins: [],
        current_streak: 0,
        longest_streak: 0
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => newHabit
      });

      render(<App />);

      await waitFor(() => {
        expect(screen.getByText('Morning Exercise')).toBeInTheDocument();
      });

      const input = screen.getByPlaceholderText('Enter your new habit quest...');
      const submitButton = screen.getByRole('button', { name: /create new habit/i });

      fireEvent.change(input, { target: { value: 'New Habit' } });
      fireEvent.click(submitButton);

      await waitFor(() => {
        expect(mockFetch).toHaveBeenCalledWith('/habits.json', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': mockCSRFToken,
          },
          body: JSON.stringify({ habit: { title: 'New Habit' } }),
        });
      });

      await waitFor(() => {
        expect(screen.getByText('New Habit')).toBeInTheDocument();
      });
    });

    it('handles habit creation errors', async () => {
      mockFetch.mockRejectedValueOnce(new Error('Creation failed'));

      render(<App />);

      await waitFor(() => {
        expect(screen.getByText('Morning Exercise')).toBeInTheDocument();
      });

      const input = screen.getByPlaceholderText('Enter your new habit quest...');
      const submitButton = screen.getByRole('button', { name: /create new habit/i });

      fireEvent.change(input, { target: { value: 'New Habit' } });
      fireEvent.click(submitButton);

      await waitFor(() => {
        expect(screen.getByText('Error: Creation failed')).toBeInTheDocument();
      });
    });

    it('clears form after successful creation', async () => {
      const newHabit = {
        id: 3,
        title: 'New Habit',
        user_id: 1,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-01T00:00:00Z',
        check_ins: [],
        current_streak: 0,
        longest_streak: 0
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => newHabit
      });

      render(<App />);

      await waitFor(() => {
        expect(screen.getByText('Morning Exercise')).toBeInTheDocument();
      });

      const input = screen.getByPlaceholderText('Enter your new habit quest...');
      const submitButton = screen.getByRole('button', { name: /create new habit/i });

      fireEvent.change(input, { target: { value: 'New Habit' } });
      fireEvent.click(submitButton);

      await waitFor(() => {
        expect(input).toHaveValue('');
      });
    });
  });

  describe('Checking In Habits', () => {
    beforeEach(() => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockHabits
      });
    });

    it('checks in a habit successfully', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockCheckIn
      });

      render(<App />);

      await waitFor(() => {
        expect(screen.getByText('Morning Exercise')).toBeInTheDocument();
      });

      const checkInButton = screen.getByRole('button', { name: /mark 'morning exercise' as completed for today/i });
      fireEvent.click(checkInButton);

      await waitFor(() => {
        expect(mockFetch).toHaveBeenCalledWith('/habits/1/check_ins.json', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': mockCSRFToken,
          },
        });
      });
    });

    it('handles check-in errors', async () => {
      mockFetch.mockRejectedValueOnce(new Error('Check-in failed'));

      render(<App />);

      await waitFor(() => {
        expect(screen.getByText('Morning Exercise')).toBeInTheDocument();
      });

      const checkInButton = screen.getByRole('button', { name: /mark 'morning exercise' as completed for today/i });
      fireEvent.click(checkInButton);

      await waitFor(() => {
        expect(screen.getByText('Error: Check-in failed')).toBeInTheDocument();
      });
    });
  });

  describe('Undoing Check-ins', () => {
    const habitWithCheckIn = {
      ...mockHabits[0],
      check_ins: [mockCheckIn],
      current_streak: 1,
      longest_streak: 1
    };

    beforeEach(() => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => [habitWithCheckIn]
      });
    });

    it('undos a check-in successfully', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ success: true })
      });

      render(<App />);

      await waitFor(() => {
        expect(screen.getByText('Completed Today!')).toBeInTheDocument();
      });

      const undoButton = screen.getByRole('button', { name: /undo/i });
      fireEvent.click(undoButton);

      await waitFor(() => {
        expect(mockConfirm).toHaveBeenCalledWith("Undo today's check-in?");
        expect(mockFetch).toHaveBeenCalledWith('/habits/1/check_ins/3.json', {
          method: 'DELETE',
          headers: {
            'X-CSRF-Token': mockCSRFToken,
          },
        });
      });
    });

    it('cancels undo when user declines confirmation', async () => {
      mockConfirm.mockReturnValueOnce(false);

      render(<App />);

      await waitFor(() => {
        expect(screen.getByText('Completed Today!')).toBeInTheDocument();
      });

      const undoButton = screen.getByRole('button', { name: /undo/i });
      fireEvent.click(undoButton);

      expect(mockConfirm).toHaveBeenCalledWith("Undo today's check-in?");
      expect(mockFetch).not.toHaveBeenCalledWith('/habits/1/check_ins/3.json', expect.any(Object));
    });
  });

  describe('Deleting Habits', () => {
    beforeEach(() => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockHabits
      });
    });

    it('deletes a habit successfully', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ success: true })
      });

      render(<App />);

      await waitFor(() => {
        expect(screen.getByText('Morning Exercise')).toBeInTheDocument();
      });

      const deleteButtons = screen.getAllByRole('button', { name: /delete/i });
      fireEvent.click(deleteButtons[0]);

      await waitFor(() => {
        expect(mockConfirm).toHaveBeenCalledWith('Are you sure you want to delete this habit?');
        expect(mockFetch).toHaveBeenCalledWith('/habits/1.json', {
          method: 'DELETE',
          headers: {
            'X-CSRF-Token': mockCSRFToken,
          },
        });
      });

      // Wait for the state to update after successful deletion
      await waitFor(() => {
        expect(screen.queryByText('Morning Exercise')).not.toBeInTheDocument();
      });
    });

    it('cancels deletion when user declines confirmation', async () => {
      mockConfirm.mockReturnValueOnce(false);

      render(<App />);

      await waitFor(() => {
        expect(screen.getByText('Morning Exercise')).toBeInTheDocument();
      });

      const deleteButtons = screen.getAllByRole('button', { name: /delete/i });
      fireEvent.click(deleteButtons[0]);

      expect(mockConfirm).toHaveBeenCalledWith('Are you sure you want to delete this habit?');
      expect(mockFetch).not.toHaveBeenCalledWith('/habits/1.json', expect.any(Object));
      expect(screen.getByText('Morning Exercise')).toBeInTheDocument();
    });
  });

  describe('Full User Flow', () => {
    it('completes a full user journey: create, check-in, undo, delete', async () => {
      // Initial load
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => []
      });

      render(<App />);

      await waitFor(() => {
        expect(screen.getByText('No active quests yet')).toBeInTheDocument();
      });

      // Create habit
      const newHabit = {
        id: 1,
        title: 'Test Habit',
        user_id: 1,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-01T00:00:00Z',
        check_ins: [],
        current_streak: 0,
        longest_streak: 0
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => newHabit
      });

      const input = screen.getByPlaceholderText('Enter your new habit quest...');
      const submitButton = screen.getByRole('button', { name: /create new habit/i });

      fireEvent.change(input, { target: { value: 'Test Habit' } });
      fireEvent.click(submitButton);

      await waitFor(() => {
        expect(screen.getByText('Test Habit')).toBeInTheDocument();
      });

      // Check in habit
      const checkIn = {
        id: 1,
        habit_id: 1,
        user_id: 1,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => checkIn
      });

      const checkInButton = screen.getByRole('button', { name: /mark 'test habit' as completed for today/i });
      fireEvent.click(checkInButton);

      await waitFor(() => {
        expect(screen.getByText('Completed Today!')).toBeInTheDocument();
      });

      // Undo check-in
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ success: true })
      });

      const undoButton = screen.getByRole('button', { name: /undo/i });
      fireEvent.click(undoButton);

      await waitFor(() => {
        expect(screen.getByText('Ready to complete')).toBeInTheDocument();
      });

      // Delete habit
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ success: true })
      });

      const deleteButton = screen.getByRole('button', { name: /delete/i });
      fireEvent.click(deleteButton);

      await waitFor(() => {
        expect(screen.getByText('No active quests yet')).toBeInTheDocument();
      });
    });
  });

  describe('Accessibility Integration', () => {
    beforeEach(() => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockHabits
      });
    });

    it('has proper heading hierarchy', async () => {
      render(<App />);

      await waitFor(() => {
        expect(screen.getByRole('heading', { name: /quest tracker/i })).toBeInTheDocument();
        expect(screen.getByRole('heading', { name: /my active quests/i })).toBeInTheDocument();
      });
    });

    it('has proper form labels and accessible names', async () => {
      render(<App />);

      await waitFor(() => {
        expect(screen.getByPlaceholderText('Enter your new habit quest...')).toBeInTheDocument();
        expect(screen.getByRole('button', { name: /create new habit/i })).toBeInTheDocument();
      });
    });

    it('has proper semantic structure', async () => {
      render(<App />);

      await waitFor(() => {
        expect(screen.getByRole('banner')).toBeInTheDocument(); // Header
        expect(screen.getByRole('main')).toBeInTheDocument();
        expect(screen.getByRole('contentinfo')).toBeInTheDocument(); // Footer
      });
    });
  });
}); 
