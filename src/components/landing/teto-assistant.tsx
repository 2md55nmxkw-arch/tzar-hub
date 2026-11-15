import { useEffect, useRef, useState } from 'react'
import { Link, useLocation } from 'react-router-dom'
import { ArrowUpRight, BookOpen, CodeXml, MessageCircle, X } from 'lucide-react'
import { TZAR_DISCORD } from './tzar-content'
import './teto-assistant.css'

function TetoCharacter() {
  return (
    <span aria-hidden="true" className="teto-character">
      <span className="teto-sprite" />
    </span>
  )
}

export function TetoAssistant() {
  const [open, setOpen] = useState(false)
  const root = useRef<HTMLDivElement>(null)
  const trigger = useRef<HTMLButtonElement>(null)
  const close = useRef<HTMLButtonElement>(null)
  const { pathname } = useLocation()
  useEffect(() => {
    if (!open) return
    close.current?.focus({ preventScroll: true })
    const key = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        setOpen(false)
        trigger.current?.focus({ preventScroll: true })
      }
    }
    const outside = (event: PointerEvent) => {
      if (!root.current?.contains(event.target as Node)) setOpen(false)
    }
    document.addEventListener('keydown', key)
    document.addEventListener('pointerdown', outside)
    return () => {
      document.removeEventListener('keydown', key)
      document.removeEventListener('pointerdown', outside)
    }
  }, [open])
  // Keep the floating mascot clear of the long legal text and the code viewer.
  if (['/docs/privacy-policy', '/docs/terms-of-service', '/source'].includes(pathname)) return null

  return (
    <div ref={root} className="teto-assistant" data-active={open} key={pathname}>
      {open && (
        <section className="teto-panel" aria-label="Teto assistant">
          <div className="teto-panel-top">
            <span>
              TETO <small> / TZAR</small>
            </span>
            <button
              ref={close}
              onClick={() => {
                setOpen(false)
                trigger.current?.focus()
              }}
              aria-label="Close Teto assistant"
            >
              <X size={16} />
            </button>
          </div>
          <p>Hey! Where are we going?</p>
          <Link to="/docs/quick-start" onClick={() => setOpen(false)}>
            <BookOpen size={16} />
            <span>Setup guide</span>
            <ArrowUpRight size={14} />
          </Link>
          <Link to="/source" onClick={() => setOpen(false)}>
            <CodeXml size={16} />
            <span>Read the source</span>
            <ArrowUpRight size={14} />
          </Link>
          <a href={TZAR_DISCORD} target="_blank" rel="noreferrer">
            <MessageCircle size={16} />
            <span>Ask the community</span>
            <ArrowUpRight size={14} />
          </a>
          <span className="teto-note">
            Everything here is free and keyless. No key needed, ever.
          </span>
        </section>
      )}
      <button
        ref={trigger}
        className="teto-trigger focus-halo"
        aria-label={open ? 'Hide Teto assistant' : 'Open Teto assistant'}
        aria-expanded={open}
        onClick={() => setOpen((value) => !value)}
      >
        <TetoCharacter />
        <span className="teto-label">{open ? 'Hey!' : 'Need a hand?'}</span>
      </button>
    </div>
  )
}
