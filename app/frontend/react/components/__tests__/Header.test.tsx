import React from 'react';
import { render, screen } from '@testing-library/react';
import Header from '../Header';

describe('Header', () => {
  it('renders the main title', () => {
    render(<Header />);
    
    const title = screen.getByText('Quest Tracker');
    expect(title).toBeInTheDocument();
  });

  it('renders the subtitle', () => {
    render(<Header />);
    
    const subtitle = screen.getByText('Your personal journey to building better habits');
    expect(subtitle).toBeInTheDocument();
  });

  it('applies correct styling classes', () => {
    render(<Header />);
    
    const title = screen.getByText('Quest Tracker');
    expect(title).toHaveClass('text-3xl', 'sm:text-4xl', 'md:text-5xl', 'font-bold');
    
    const subtitle = screen.getByText('Your personal journey to building better habits');
    expect(subtitle).toHaveClass('text-slate-300', 'text-base', 'sm:text-lg');
  });

  it('has proper semantic structure', () => {
    render(<Header />);
    
    const header = screen.getByRole('banner');
    expect(header).toBeInTheDocument();
    
    const title = screen.getByRole('heading', { level: 1 });
    expect(title).toBeInTheDocument();
    expect(title).toHaveTextContent('Quest Tracker');
  });

  it('has proper accessibility attributes', () => {
    render(<Header />);
    
    const title = screen.getByText('Quest Tracker');
    expect(title).toHaveClass('text-transparent', 'bg-clip-text', 'bg-gradient-to-r');
  });
}); 
