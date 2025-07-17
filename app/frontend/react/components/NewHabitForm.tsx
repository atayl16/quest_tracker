import React, { useState } from 'react';

interface NewHabitFormProps {
  onCreateHabit: (title: string) => Promise<void>;
}

const NewHabitForm: React.FC<NewHabitFormProps> = ({ onCreateHabit }) => {
  const [title, setTitle] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) return;

    setIsSubmitting(true);
    try {
      await onCreateHabit(title.trim());
      setTitle('');
    } catch (error) {
      console.error('Failed to create quest:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="mt-8 p-4 sm:p-6 bg-slate-700/20 rounded-xl border border-slate-600/30" id="new-quest-form">
      <h3 className="text-lg font-medium text-white mb-4 flex items-center">
        <span className="text-green-400 mr-2" aria-hidden="true">✨</span>
        Add New Quest
      </h3>
      
      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="flex flex-col sm:flex-row gap-3">
          <div className="flex-1">
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Enter your new quest..."
              className="w-full px-4 py-3 bg-slate-600/50 border border-slate-500/50 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all duration-200"
              aria-label="New quest title"
              disabled={isSubmitting}
            />
          </div>
          <button
            type="submit"
            disabled={isSubmitting || !title.trim()}
            className="bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 disabled:from-slate-600 disabled:to-slate-600 text-white font-semibold py-3 px-6 rounded-lg transition-all duration-200 transform hover:scale-105 whitespace-nowrap disabled:transform-none"
            aria-label="Create new quest"
          >
            {isSubmitting ? 'Creating...' : 'Create Quest'}
          </button>
        </div>
      </form>
    </div>
  );
};

export default NewHabitForm; 
