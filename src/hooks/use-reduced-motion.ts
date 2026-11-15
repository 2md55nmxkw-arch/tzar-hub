import { useSyncExternalStore } from 'react'

// The site's own "pause animations" switch (WCAG 2.2.2) sits next to the OS
// prefers-reduced-motion setting: either one stops looping motion. The flag
// lives on <html data-motion="paused"> so CSS can react to it too; index.html
// restores it before the first paint.
const STORAGE = 'motion'
const QUERY = '(prefers-reduced-motion: reduce)'
const EVENT = 'tzar:motion'

export function isMotionPaused() {
  return document.documentElement.dataset.motion === 'paused'
}

export function prefersReducedMotion() {
  return matchMedia(QUERY).matches
}

export function isMotionReduced() {
  return isMotionPaused() || prefersReducedMotion()
}

export function setMotionPaused(paused: boolean) {
  if (paused) document.documentElement.dataset.motion = 'paused'
  else delete document.documentElement.dataset.motion
  try {
    if (paused) localStorage.setItem(STORAGE, 'paused')
    else localStorage.removeItem(STORAGE)
  } catch {
    /* The switch still works for this visit without persistence. */
  }
  window.dispatchEvent(new Event(EVENT))
}

export function subscribeMotion(callback: () => void) {
  const media = matchMedia(QUERY)
  media.addEventListener('change', callback)
  window.addEventListener(EVENT, callback)
  return () => {
    media.removeEventListener('change', callback)
    window.removeEventListener(EVENT, callback)
  }
}

/** True when either the OS setting or the site switch asks for less motion. */
export function useReducedMotion() {
  return useSyncExternalStore(subscribeMotion, isMotionReduced)
}

export function useMotionPaused() {
  return useSyncExternalStore(subscribeMotion, isMotionPaused)
}

export function usePrefersReducedMotion() {
  return useSyncExternalStore(subscribeMotion, prefersReducedMotion)
}
