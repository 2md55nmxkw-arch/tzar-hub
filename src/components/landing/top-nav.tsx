import { lazy, Suspense, useEffect, useRef, useState } from 'react'
import { flushSync } from 'react-dom'
import { Link, useLocation, useNavigate } from 'react-router-dom'
import { Command, Menu, X } from 'lucide-react'
import { motion } from 'motion/react'
import { items } from './nav-data'
import { TZAR_DISCORD } from './tzar-content'
import { useMenu } from '@/hooks/use-menu'
import {
  isMotionReduced,
  setMotionPaused,
  useMotionPaused,
  usePrefersReducedMotion,
} from '@/hooks/use-reduced-motion'
import { cn } from '@/lib/utils'

const CommandPalette = lazy(() => import('./command-palette'))

const desktopLink =
  'hidden items-center gap-0.5 rounded-md text-muted-foreground outline-offset-4 outline-ring transition-colors hover:text-foreground focus-visible:outline-1 md:flex'

function useTheme() {
  const [dark, setDark] = useState(() => document.documentElement.classList.contains('dark'))
  const changing = useRef(false)
  const toggle = () => {
    if (changing.current) return
    const next = !document.documentElement.classList.contains('dark')
    const apply = () => {
      flushSync(() => setDark(next))
      document.documentElement.classList.toggle('dark', next)
      document.documentElement.style.colorScheme = next ? 'dark' : 'light'
      document
        .querySelector('meta[name="theme-color"]')
        ?.setAttribute('content', next ? '#080808' : '#ffffff')
      try {
        localStorage.setItem('theme', next ? 'dark' : 'light')
      } catch {
        /* Theme still works without persistence. */
      }
    }
    if (!document.startViewTransition || isMotionReduced()) {
      apply()
      return
    }
    changing.current = true
    const transition = document.startViewTransition(apply)
    void transition.finished
      .catch(() => {})
      .finally(() => {
        changing.current = false
      })
  }
  return { dark, toggle }
}

export function TopNav() {
  const { open, setOpen } = useMenu()
  const [cmdOpen, setCmdOpen] = useState(false)
  // Once loaded, the palette stays mounted so its exit animation and close
  // focus handler run instead of being cut off by an unmount.
  const [cmdMounted, setCmdMounted] = useState(false)
  const cmdButtonRef = useRef<HTMLButtonElement>(null)
  const returnFocus = useRef<HTMLElement | null>(null)
  const navigated = useRef(false)
  const { dark, toggle } = useTheme()
  const motionPaused = useMotionPaused()
  // With the OS setting on nothing loops, so there is nothing to pause.
  const systemReduced = usePrefersReducedMotion()
  const navigate = useNavigate()
  const { pathname } = useLocation()
  const menuRef = useRef<HTMLDivElement>(null)
  const triggerRef = useRef<HTMLButtonElement>(null)

  useEffect(() => {
    if (!open) return
    const trigger = triggerRef.current
    const previous = document.body.style.overflow
    document.body.style.overflow = 'hidden'
    const links = () =>
      Array.from(menuRef.current?.querySelectorAll<HTMLElement>('a[href], button') ?? []).filter(
        (el) => el.getClientRects().length > 0,
      )
    links()[0]?.focus()
    const keydown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        event.preventDefault()
        setOpen(false)
      }
      if (event.key !== 'Tab') return
      const elements = links()
      const first = elements[0],
        last = elements.at(-1)
      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault()
        last?.focus()
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault()
        first?.focus()
      }
    }
    document.addEventListener('keydown', keydown)
    return () => {
      document.body.style.overflow = previous
      document.removeEventListener('keydown', keydown)
      trigger?.focus()
    }
  }, [open, setOpen])

  // Radix sends focus back to a DialogTrigger on close, and the palette has
  // none, so remember what it was opened from.
  const rememberFocus = () => {
    const active = document.activeElement
    // Ctrl+K inside the palette closes it; keep the original element.
    if (active instanceof HTMLElement && active.closest('[cmdk-root]')) return
    returnFocus.current =
      active instanceof HTMLElement && active !== document.body ? active : cmdButtonRef.current
  }

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key.toLowerCase() === 'k' && (e.metaKey || e.ctrlKey)) {
        e.preventDefault()
        setOpen(false)
        rememberFocus()
        setCmdMounted(true)
        setCmdOpen((o) => !o)
      }
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [setOpen])

  const run = (it: (typeof items)[number]) => {
    setCmdOpen(false)
    if (it.href === '#theme') {
      toggle()
      return
    }
    if (it.internal) {
      // Only a real route change focuses the new heading; a command for the
      // current page is a plain close.
      navigated.current = it.href !== pathname
      navigate(it.href)
    } else {
      window.open(it.href, it.href.startsWith('http') ? '_blank' : '_self')
    }
  }
  const closeAutoFocus = (event: Event) => {
    event.preventDefault()
    // After a navigation command the route change focuses the new page's heading.
    if (!navigated.current) {
      // A link in the just-closed menu is inert by now; fall back to its trigger.
      const target = returnFocus.current
      const usable = target?.isConnected && !target.closest('[inert]')
      ;(usable ? target : (triggerRef.current ?? cmdButtonRef.current))?.focus()
    }
    navigated.current = false
  }

  return (
    <>
      <motion.div
        ref={menuRef}
        role={open ? 'dialog' : undefined}
        aria-modal={open || undefined}
        aria-label={open ? 'Navigation menu' : undefined}
        initial={false}
        animate={{ height: open ? '100vh' : '63px' }}
        transition={{ duration: 0.3 }}
        className="fixed left-1/2 top-0 z-[90] flex w-full -translate-x-1/2 justify-center overflow-hidden md:max-w-3xl"
      >
        <motion.div
          initial={false}
          animate={{ gap: open ? '8px' : '3px' }}
          className="absolute flex h-[100dvh] w-full flex-col px-3 py-2"
        >
          <nav className="bg-muted shadow-glass border-muted2 flex w-full items-center justify-between rounded-2xl border px-5 py-2.5 pr-2.5 backdrop-blur-md">
            <div className="flex items-center gap-2 py-1 text-sm font-semibold">
              <img src="/tzar/Frame-2-red.svg" alt="" className="size-6" />
              <Link to="/">TZAR HUB</Link>
            </div>
            <div className="fc gap-4 text-[13px]">
              <Link className={desktopLink} to="/docs">
                Docs
              </Link>
              <Link className={desktopLink} to="/components">
                Scripts
              </Link>
              <Link className={desktopLink} to="/changelog">
                Changelog
              </Link>
              <Link className={desktopLink} to="/source">
                Source
              </Link>
              <div className="flex gap-2">
                <a
                  href={TZAR_DISCORD}
                  target="_blank"
                  rel="noreferrer"
                  aria-label="TZAR Hub Discord"
                  className="bg-muted4 flex size-8 items-center justify-center rounded-[12px] p-1 transition-opacity hover:opacity-70"
                >
                  <span
                    className="relative flex size-6 items-center justify-center overflow-hidden rounded-lg ring-1 ring-white/10"
                    style={{
                      background:
                        'repeating-linear-gradient(135deg, transparent 0 5px, #ffffff0a 5px 6px), radial-gradient(circle at 50% 25%, #a85d2e, #572e1d 65%, #28170f)',
                    }}
                  >
                    <img
                      src="/tzar/mascot/teto-avatar-hd.webp"
                      alt=""
                      width={24}
                      height={24}
                      className="relative size-6 object-contain"
                    />
                  </span>
                </a>
                {/* Ctrl+K is a keyboard shortcut; on touch screens the menu covers the same links. */}
                <div className="bg-muted4 flex size-8 items-center justify-center rounded-[12px] [@media(pointer:coarse)]:hidden">
                  <button
                    ref={cmdButtonRef}
                    type="button"
                    className="flex size-full items-center justify-center rounded-2xl"
                    onClick={() => {
                      setOpen(false)
                      rememberFocus()
                      setCmdMounted(true)
                      setCmdOpen(true)
                    }}
                  >
                    <span className="flex size-full cursor-pointer items-center justify-center transition-all ease-in-out active:scale-95">
                      <Command className="size-4" />
                    </span>
                    <span className="sr-only">Command + K</span>
                  </button>
                </div>
                <div className="bg-muted4 flex size-8 items-center justify-center rounded-[12px]">
                  <button
                    ref={triggerRef}
                    type="button"
                    className="flex size-full items-center justify-center"
                    onClick={() => setOpen(!open)}
                    aria-expanded={open}
                    aria-controls="navigation-links"
                  >
                    <span className="flex size-full cursor-pointer items-center justify-center transition-all ease-in-out active:scale-95">
                      {open ? <X className="size-4" /> : <Menu className="size-4" />}
                    </span>
                    <span className="sr-only">{open ? 'Hide Menu' : 'Show Menu'}</span>
                  </button>
                </div>
              </div>
            </div>
          </nav>

          {/* The list scrolls on short viewports (and at high zoom) instead of
              spilling over the bar; safe centering keeps the first items reachable. */}
          <ul
            id="navigation-links"
            inert={!open}
            className={cn(
              'bg-muted/80 flex min-h-0 w-full flex-1 flex-col items-center justify-center-safe gap-1.5 overflow-x-hidden overflow-y-auto overscroll-contain scroll-py-3 rounded-2xl px-7 py-3 backdrop-blur-sm',
            )}
          >
            {items
              .filter((it) => it.href !== '#theme')
              .map((it) => (
                <li key={it.label} className="relative flex cursor-pointer flex-col items-center">
                  {it.internal ? (
                    <Link
                      to={it.href}
                      className="group relative flex items-start"
                      onClick={() => setOpen(false)}
                    >
                      <span className="text-4xl font-extrabold uppercase leading-[0.8] tracking-[-0.03em] transition-opacity hover:opacity-50 lg:text-5xl">
                        {it.label}
                      </span>
                      <span className="absolute -right-1 translate-x-full text-xs leading-[0.9] tracking-tighter opacity-0 transition-opacity group-hover:opacity-50 max-sm:hidden lg:text-sm">
                        {it.note}
                      </span>
                    </Link>
                  ) : (
                    <a
                      href={it.href}
                      target={it.href.startsWith('http') ? '_blank' : undefined}
                      rel="noreferrer"
                      className="group relative flex items-start"
                      onClick={() => setOpen(false)}
                    >
                      <span className="text-4xl font-extrabold uppercase leading-[0.8] tracking-[-0.03em] transition-opacity hover:opacity-50 lg:text-5xl">
                        {it.label}
                      </span>
                      <span className="absolute -right-1 translate-x-full text-xs leading-[0.9] tracking-tighter opacity-0 transition-opacity group-hover:opacity-50 max-sm:hidden lg:text-sm">
                        {it.note}
                      </span>
                    </a>
                  )}
                </li>
              ))}
          </ul>

          <div
            inert={!open}
            className="bg-muted/80 flex w-full items-center justify-between rounded-2xl p-4 text-sm uppercase tracking-tight backdrop-blur-sm"
          >
            <Link
              className="opacity-50 hover:opacity-100"
              to="/docs/privacy-policy"
              onClick={() => setOpen(false)}
            >
              Privacy Policy
            </Link>
            <Link
              className="opacity-50 hover:opacity-100"
              to="/docs/terms-of-service"
              onClick={() => setOpen(false)}
            >
              Terms of Service
            </Link>
          </div>
          <div
            inert={!open}
            className="bg-muted/80 flex w-full items-center justify-between rounded-2xl p-4 text-sm tracking-tight backdrop-blur-sm [@media(max-height:500px)]:hidden"
          >
            <span>KEYLESS</span>
            <span className="uppercase opacity-60">Free and open source</span>
          </div>
        </motion.div>
      </motion.div>

      {cmdMounted && (
        <Suspense fallback={null}>
          <CommandPalette
            open={cmdOpen}
            onOpenChange={setCmdOpen}
            onCloseAutoFocus={closeAutoFocus}
            motion={
              systemReduced
                ? null
                : { paused: motionPaused, toggle: () => setMotionPaused(!motionPaused) }
            }
            dark={dark}
            toggle={toggle}
            run={run}
          />
        </Suspense>
      )}
    </>
  )
}
