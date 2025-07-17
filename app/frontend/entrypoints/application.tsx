import React from 'react'
import ReactDOM from 'react-dom/client'
import App from '../react/App'

const rootEl = document.getElementById('react-root')
if (rootEl) {
  ReactDOM.createRoot(rootEl).render(<App />)
  console.log('React Quest Tracker!')
} 
