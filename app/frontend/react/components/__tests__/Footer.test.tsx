import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import Footer from '../Footer';

describe('Footer', () => {
  it('renders the footer with correct text', () => {
    render(<Footer />);
    
    expect(screen.getByText('Level up your life, one habit at a time')).toBeInTheDocument();
  });

  it('has proper semantic structure', () => {
    render(<Footer />);
    
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('has correct styling classes', () => {
    render(<Footer />);
    
    const footer = screen.getByRole('contentinfo');
    expect(footer).toHaveClass('text-center', 'mt-12');
  });

  it('renders as a paragraph element', () => {
    render(<Footer />);
    
    expect(screen.getByText('Level up your life, one habit at a time')).toHaveClass('text-slate-500', 'text-sm');
  });
}); 
