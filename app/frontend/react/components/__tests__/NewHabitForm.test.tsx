import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import NewHabitForm from '../NewHabitForm';

describe('NewHabitForm', () => {
  const mockOnCreateHabit = jest.fn();

  beforeEach(() => {
    mockOnCreateHabit.mockClear();
  });

  it('renders the form with title and input', () => {
    render(<NewHabitForm onCreateHabit={mockOnCreateHabit} />);
    
    expect(screen.getByText('Add New Quest')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Enter your new habit quest...')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Create new habit' })).toBeInTheDocument();
  });

  it('allows user to type in the input field', async () => {
    const user = userEvent.setup();
    render(<NewHabitForm onCreateHabit={mockOnCreateHabit} />);
    
    const input = screen.getByPlaceholderText('Enter your new habit quest...');
    await user.type(input, 'Drink 8 glasses of water');
    
    expect(input).toHaveValue('Drink 8 glasses of water');
  });

  it('calls onCreateHabit when form is submitted with valid input', async () => {
    const user = userEvent.setup();
    render(<NewHabitForm onCreateHabit={mockOnCreateHabit} />);
    
    const input = screen.getByPlaceholderText('Enter your new habit quest...');
    const submitButton = screen.getByRole('button', { name: 'Create new habit' });
    
    await user.type(input, 'Drink 8 glasses of water');
    await user.click(submitButton);
    
    expect(mockOnCreateHabit).toHaveBeenCalledWith('Drink 8 glasses of water');
  });

  it('clears the input after successful submission', async () => {
    const user = userEvent.setup();
    mockOnCreateHabit.mockResolvedValue(undefined);
    
    render(<NewHabitForm onCreateHabit={mockOnCreateHabit} />);
    
    const input = screen.getByPlaceholderText('Enter your new habit quest...');
    const submitButton = screen.getByRole('button', { name: 'Create new habit' });
    
    await user.type(input, 'Drink 8 glasses of water');
    await user.click(submitButton);
    
    await waitFor(() => {
      expect(input).toHaveValue('');
    });
  });

  it('does not submit when input is empty', async () => {
    const user = userEvent.setup();
    render(<NewHabitForm onCreateHabit={mockOnCreateHabit} />);
    
    const submitButton = screen.getByRole('button', { name: 'Create new habit' });
    expect(submitButton).toBeDisabled();
    
    await user.click(submitButton);
    expect(mockOnCreateHabit).not.toHaveBeenCalled();
  });

  it('submits when Enter key is pressed', async () => {
    const user = userEvent.setup();
    render(<NewHabitForm onCreateHabit={mockOnCreateHabit} />);
    
    const input = screen.getByPlaceholderText('Enter your new habit quest...');
    await user.type(input, 'Drink 8 glasses of water{enter}');
    
    expect(mockOnCreateHabit).toHaveBeenCalledWith('Drink 8 glasses of water');
  });

  it('shows loading state during submission', async () => {
    const user = userEvent.setup();
    let resolvePromise: (value: unknown) => void;
    const promise = new Promise((resolve) => {
      resolvePromise = resolve;
    });
    mockOnCreateHabit.mockReturnValue(promise);
    
    render(<NewHabitForm onCreateHabit={mockOnCreateHabit} />);
    
    const input = screen.getByPlaceholderText('Enter your new habit quest...');
    const submitButton = screen.getByRole('button', { name: 'Create new habit' });
    
    await user.type(input, 'Drink 8 glasses of water');
    await user.click(submitButton);
    
    expect(screen.getByText('Creating...')).toBeInTheDocument();
    expect(submitButton).toBeDisabled();
    expect(input).toBeDisabled();
    
    resolvePromise!(undefined);
  });
}); 
