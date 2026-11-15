import { useEffect, useRef, useState, type CSSProperties } from 'react'
import { Link } from 'react-router-dom'
import { motion, AnimatePresence, useAnimationControls } from 'motion/react'
import { useReducedMotion } from '@/hooks/use-reduced-motion'
import { Copy, Check } from 'lucide-react'
import { BackgroundVideo } from './background-video'
import { TZAR_LOADER } from './tzar-content'

const MotionLink = motion.create(Link)

// Ported from the public home-page client module (RollingText): counts,
// displacement, duration, cubic-bezier and per-column delay are unchanged.
function RollingLine({ text }: { text: string }) {
  const reduced = useReducedMotion()
  const middle = Math.floor(text.length / 2)
  return (
    <div
      aria-hidden="true"
      className="font-custom flex text-5xl font-bold uppercase sm:text-7xl lg:text-8xl"
    >
      {text.split('').map((letter, index) => {
        const distance = Math.abs(index - middle)
        const count = Math.floor(4 / (0.2 + 0.15 * distance))
        return (
          <div
            key={index}
            className="relative inline-block overflow-hidden"
            style={{ height: '1em' }}
          >
            <motion.div
              className="flex flex-col"
              initial={{ y: reduced ? `-${1.2 * count}em` : 0 }}
              whileInView={{ y: `-${1.2 * count}em` }}
              transition={{
                duration: reduced ? 0 : 4,
                ease: [0.15, 1, 0.1, 1],
                delay: reduced ? 0 : distance * 0.05,
              }}
            >
              {Array.from({ length: count + 2 }, (_, i) => (
                <span
                  key={i}
                  className="flex shrink-0 items-center justify-center"
                  style={{ height: '1.2em' }}
                >
                  {letter}
                </span>
              ))}
            </motion.div>
          </div>
        )
      })}
    </div>
  )
}

function CopySpinner() {
  return (
    <div
      aria-hidden="true"
      className="wrapper"
      style={
        { '--spinner-size': '16px', '--spinner-color': 'var(--color-foreground)' } as CSSProperties
      }
    >
      <div className="spinner">
        {Array.from({ length: 12 }, (_, i) => (
          <div key={i} className="bar" />
        ))}
      </div>
    </div>
  )
}

function CopyCommand() {
  const [status, setStatus] = useState<'idle' | 'loading' | 'done' | 'error'>('idle')
  const timers = useRef<ReturnType<typeof setTimeout>[]>([])
  useEffect(() => () => timers.current.forEach(clearTimeout), [])
  const copy = async () => {
    timers.current.forEach(clearTimeout)
    try {
      await navigator.clipboard.writeText(TZAR_LOADER)
      setStatus('loading')
      timers.current = [
        setTimeout(() => {
          setStatus('done')
          timers.current.push(setTimeout(() => setStatus('idle'), 1000))
        }, 1000),
      ]
    } catch {
      setStatus('error')
    }
  }
  return (
    <motion.button
      type="button"
      aria-label="Copy TZAR loader"
      title={TZAR_LOADER}
      onClick={copy}
      initial={{ padding: '0px 20px' }}
      whileHover={{ padding: '0px 32px' }}
      whileTap={{ padding: '0px 20px' }}
      transition={{ duration: 1, bounce: 0.6, type: 'spring' }}
      className="fc focus-halo text-foreground bg-muted group relative h-12 cursor-pointer rounded-2xl font-mono"
    >
      <span className="fc text-sm group-active:scale-[0.999]">
        loadstring(game:HttpGet
        <span className="fc gap-2 text-muted-foreground">
          (…))()
          <AnimatePresence mode="wait">
            <motion.span
              key={status}
              className="hidden lg:block"
              initial={{ scale: 0, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 1.2, opacity: 0 }}
              transition={{ duration: 0.5, type: 'spring', bounce: 0.3 }}
            >
              {status === 'loading' ? (
                <CopySpinner />
              ) : status === 'done' ? (
                <Check className="size-4" />
              ) : (
                <Copy className="size-4" />
              )}
            </motion.span>
          </AnimatePresence>
        </span>
      </span>
      <span role="status" className="sr-only">
        {status === 'done'
          ? 'Copied!'
          : status === 'error'
            ? `Copy unavailable. Loader: ${TZAR_LOADER}`
            : ''}
      </span>
    </motion.button>
  )
}

export function Hero() {
  const reduced = useReducedMotion()
  const [mobile, setMobile] = useState(() => matchMedia('(max-width: 767px)').matches)
  const flame = useAnimationControls()
  useEffect(() => {
    const media = matchMedia('(max-width: 767px)')
    const update = () => setMobile(media.matches)
    media.addEventListener('change', update)
    return () => media.removeEventListener('change', update)
  }, [])
  // The flame's 5s slide-in is the one long intro motion; pausing mid-flight
  // jumps it to rest instead of letting it finish.
  useEffect(() => {
    if (reduced) {
      flame.stop()
      flame.set({ opacity: 1, y: 0 })
      return
    }
    void flame.start({
      opacity: 1,
      y: 0,
      transition: { opacity: { duration: 2, delay: 2 }, y: { duration: 5, delay: 2 } },
    })
  }, [reduced, flame])
  return (
    // min-h (not a fixed height) lets the hero grow at 200–400% zoom instead of
    // clipping the copy and Quick Start actions; py keeps their focus rings
    // inside the overflow clip when the hero is exactly content height.
    <section className="text-foreground fc relative min-h-[88svh] w-full overflow-hidden px-5 py-6">
      <div className="fcc relative z-10 mt-20">
        <p className="font-roman text-halo my-4 text-sm tracking-widest">KEYLESS · OPEN SOURCE</p>
        <h1 className="sr-only">Un-common scripts for Roblox</h1>
        <RollingLine text="un-common" />
        <RollingLine text="scripts" />
        <motion.p
          initial={{ opacity: reduced ? 1 : 0, y: 0 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: reduced ? 0 : 1, ease: 'easeOut', delay: reduced ? 0 : 2 }}
          className="font-roman text-halo my-4 text-sm tracking-widest"
        >
          FOR ROBLOX
        </motion.p>
        <motion.div
          initial={{ opacity: reduced ? 1 : 0, y: 0 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: reduced ? 0 : 1, ease: 'easeOut' }}
          className="mt-24 flex flex-col items-center justify-center gap-2 md:flex-row lg:mt-24"
        >
          <CopyCommand />
          {/* The link itself animates: a whileTap child would get its own
              tabindex and become a dead tab stop. */}
          <MotionLink
            to="/docs/quick-start"
            initial={{ padding: '0px 20px' }}
            whileHover={{ padding: '0px 32px' }}
            whileTap={{ padding: '0px 20px' }}
            className="fc focus-halo bg-foreground h-12 w-fit cursor-pointer rounded-2xl text-[15px] font-medium text-background"
          >
            Quick start
          </MotionLink>
        </motion.div>
      </div>
      <motion.div
        aria-hidden="true"
        initial={{ opacity: reduced ? 1 : 0, y: mobile || reduced ? 0 : 100 }}
        animate={flame}
        className="pointer-events-none absolute inset-0 h-full w-full object-cover"
      >
        <BackgroundVideo className="h-full w-full object-cover" fade={0.08} />
      </motion.div>
    </section>
  )
}
