import React, { useState, useEffect } from 'react';
import { Habit, CheckIn } from './types';
import HabitList from './components/HabitList';
import NewHabitForm from './components/NewHabitForm';

const App: React.FC = () => {
  const [habits, setHabits] = useState<Habit[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchHabits();
  }, []);

  const fetchHabits = async () => {
    try {
      setLoading(true);
      console.log('Fetching quests from /habits.json...');
      const response = await fetch('/habits.json');
      console.log('Response status:', response.status);
      console.log('Response headers:', response.headers);
      
      if (!response.ok) {
        const errorText = await response.text();
        console.error('Response error:', errorText);
        throw new Error(`Failed to fetch quests: ${response.status} ${response.statusText}`);
      }
      
      const data = await response.json();
      console.log('Fetched quests:', data);
      setHabits(Array.isArray(data) ? data : []);
    } catch (err) {
      console.error('Error fetching habits:', err);
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  };

  const createHabit = async (title: string) => {
    try {
      const response = await fetch('/habits.json', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': getCSRFToken(),
        },
        body: JSON.stringify({ habit: { title } }),
      });

      if (!response.ok) throw new Error('Failed to create habit');
      const newHabit = await response.json();
      setHabits(prev => [...prev, newHabit]);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to create quest');
    }
  };

  const deleteHabit = async (habitId: number) => {
    try {
      const response = await fetch(`/habits/${habitId}.json`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': getCSRFToken(),
        },
      });

      if (!response.ok) throw new Error('Failed to delete habit');
      setHabits(prev => prev.filter(habit => habit.id !== habitId));
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to delete quest');
    }
  };

  const checkInHabit = async (habitId: number) => {
    try {
      const response = await fetch(`/habits/${habitId}/check_ins.json`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': getCSRFToken(),
        },
      });

      if (!response.ok) throw new Error('Failed to check in habit');
      const checkIn = await response.json();
      
      // Update the habit with the new check-in
      setHabits(prev => prev.map(habit => 
        habit.id === habitId 
          ? { ...habit, check_ins: [...habit.check_ins, checkIn] }
          : habit
      ));
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to complete quest');
    }
  };

  const undoCheckIn = async (habitId: number, checkInId: number) => {
    try {
      const response = await fetch(`/habits/${habitId}/check_ins/${checkInId}.json`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': getCSRFToken(),
        },
      });

      if (!response.ok) throw new Error('Failed to undo check-in');
      
      // Remove the check-in from the habit
      setHabits(prev => prev.map(habit => 
        habit.id === habitId 
          ? { ...habit, check_ins: habit.check_ins.filter(ci => ci.id !== checkInId) }
          : habit
      ));
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to undo quest completion');
    }
  };

  const getCSRFToken = (): string => {
    const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
    return token || '';
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-white text-xl">Preparing your quest log...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-red-400 text-xl">Error: {error}</div>
      </div>
    );
  }

  return (
    <div>
      <main className="max-w-4xl mx-auto" aria-labelledby="active-quests-heading">
        <div className="bg-slate-800/50 backdrop-blur-sm rounded-2xl border border-slate-700/50 p-4 sm:p-6 md:p-8">
          <h2 id="active-quests-heading" className="text-xl sm:text-2xl font-semibold text-white mb-6 flex items-center">
            <span className="text-purple-400 mr-3" aria-hidden="true">⚔️</span>
            My Active Quests
          </h2>
          
          <HabitList 
            habits={habits}
            onDeleteHabit={deleteHabit}
            onCheckInHabit={checkInHabit}
            onUndoCheckIn={undoCheckIn}
          />
          
          <div className="mt-8">
            <NewHabitForm onCreateHabit={createHabit} />
          </div>
        </div>
      </main>

      <footer className="text-center mt-12">
        <p className="text-slate-500 text-sm">Level up your life, one habit at a time</p>
      </footer>
    </div>
  );
};

export default App; 
