require('@testing-library/jest-dom');

// Mock fetch globally for API tests
global.fetch = jest.fn();

// Mock window.confirm for delete/undo operations
Object.defineProperty(window, 'confirm', {
  writable: true,
  value: jest.fn(() => true),
});

// Mock console methods to reduce noise in tests
global.console = {
  ...console,
  log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
}; 
