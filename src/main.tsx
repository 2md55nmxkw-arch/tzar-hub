import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
// Medeo (OFL 1.1): Sans for text and headings, Mono for code, Serif for labels.
import 'medeo-font/sans.css'
import 'medeo-font/mono.css'
import 'medeo-font/serif.css'
import './index.css'
import App from './App.tsx'
import { ErrorBoundary } from '@/components/error-boundary'

// The theme is applied by the inline script in index.html before the first
// paint; this bundle only mounts the app.
createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ErrorBoundary>
      <BrowserRouter>
        <App />
      </BrowserRouter>
    </ErrorBoundary>
  </StrictMode>,
)
