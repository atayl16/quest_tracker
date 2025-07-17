console.log("React entry loaded!");
import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';

const container = document.getElementById('react-root');
console.log("Container:", container);
if (container) {
  const root = createRoot(container);
  root.render(<App />);
  console.log("App rendered!");
} 
