import { Link } from 'react-router-dom'

import { TZAR_DISCORD, TZAR_REPO } from './tzar-content'
import {
  setMotionPaused,
  useMotionPaused,
  usePrefersReducedMotion,
} from '@/hooks/use-reduced-motion'

const productLinks = [
  { label: 'Docs', to: '/docs' },
  { label: 'Scripts', to: '/components' },
  { label: 'Cmdr Panel', to: '/docs/cmdr-panel' },
  { label: 'Modules', to: '/docs/modules' },
  { label: 'Changelog', to: '/changelog' },
  { label: 'Source', to: '/source' },
]

const legalLinks = [
  { label: 'Privacy', to: '/docs/privacy-policy' },
  { label: 'Terms', to: '/docs/terms-of-service' },
]

// py keeps every link at least 24px tall for touch (WCAG 2.5.8).
const linkClass = 'py-1.5 transition-colors hover:text-foreground'
const copyrightYear = new Date().getFullYear()

// WCAG 2.2.2: the flame, mascot and decorations loop forever, so every page
// offers a way to stop them. With the OS setting on, nothing loops.
function MotionToggle() {
  const paused = useMotionPaused()
  const systemReduced = usePrefersReducedMotion()
  if (systemReduced) return null
  return (
    <button
      type="button"
      onClick={() => setMotionPaused(!paused)}
      className={`${linkClass} cursor-pointer`}
    >
      {paused ? 'Play animations' : 'Pause animations'}
    </button>
  )
}

export function SiteFooter() {
  return (
    <footer className="w-full px-5 pb-36 pt-6 sm:pb-8">
      <div className="border-border text-muted-foreground mx-auto flex w-full max-w-6xl flex-col gap-3 border-t pt-5 text-xs sm:flex-row sm:items-center sm:justify-between">
        <div className="flex flex-wrap items-center gap-x-5">
          {productLinks.map((link) => (
            <Link key={link.to} to={link.to} className={linkClass}>
              {link.label}
            </Link>
          ))}
          <a href={TZAR_DISCORD} target="_blank" rel="noreferrer" className={linkClass}>
            Discord
          </a>
          <a href={TZAR_REPO} target="_blank" rel="noreferrer" className={linkClass}>
            GitHub
          </a>
        </div>
        <div className="flex flex-wrap items-center gap-x-5">
          {legalLinks.map((link) => (
            <Link key={link.to} to={link.to} className={linkClass}>
              {link.label}
            </Link>
          ))}
          <MotionToggle />
          <span>© {copyrightYear} TZAR Hub</span>
        </div>
      </div>
    </footer>
  )
}
