import React from 'react';

const Header: React.FC = () => {
  return (
    <header className="text-center mb-8 sm:mb-12 px-4 pt-8">
      <h1 className="text-3xl sm:text-4xl md:text-5xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-purple-400 to-pink-400 mb-4">
        Quest Tracker
      </h1>
      <p className="text-slate-300 text-base sm:text-lg">Your personal journey to building better habits</p>
    </header>
  );
};

export default Header; 
