import React from 'react'
import ReactDOM from 'react-dom/client'
import App from '../react/App'

// Only render React if we're on the React UI page and the root element exists
const rootEl = document.getElementById('react-root')
if (rootEl && window.location.search.includes('ui=react')) {
  try {
    ReactDOM.createRoot(rootEl).render(<App />)
    console.log('React Quest Tracker loaded!')
  } catch (error) {
    console.error('Error rendering React app:', error)
  }
} else {
  console.log('React not loaded - Turbo UI or no react-root element')
} 
