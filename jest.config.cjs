module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/app/frontend/$1',
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
  },
  transform: {
    '^.+\\.(ts|tsx)$': 'ts-jest',
  },
  testMatch: [
    '<rootDir>/app/frontend/**/__tests__/**/*.(ts|tsx|js)',
    '<rootDir>/app/frontend/**/*.(test|spec).(ts|tsx|js)',
  ],
  collectCoverageFrom: [
    'app/frontend/**/*.{ts,tsx}',
    '!app/frontend/**/*.d.ts',
    '!app/frontend/entrypoints/**',
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  testTimeout: 10000,
}; 
