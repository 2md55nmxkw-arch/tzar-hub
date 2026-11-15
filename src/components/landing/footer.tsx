import { useRef } from 'react'
import { motion, useAnimationControls } from 'motion/react'
import { useReducedMotion } from '@/hooks/use-reduced-motion'
import { WordsReveal } from './reveal'
import badgeSvg from '@/assets/tzar-badge.svg?raw'
import { TZAR_DISCORD } from './tzar-content'

export function ProBadgeCTA() {
  const controls = useAnimationControls()
  const spinning = useRef(false)
  const reduced = useReducedMotion()
  const spin = async () => {
    if (spinning.current || reduced) return
    spinning.current = true
    controls.set({ rotateY: 0 })
    await controls.start({ rotateY: 360, transition: { duration: 1, ease: 'easeInOut' } })
    spinning.current = false
    controls.set({ rotateY: 0 })
  }
  return (
    <section className="fcc mb-3 overflow-hidden px-5">
      <div className="fcc gap-4">
        <motion.div
          initial={{ opacity: reduced ? 1 : 0, y: reduced ? 0 : 10 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{
            duration: reduced ? 0 : 0.5,
            ease: [0, -0.07, 0.11, 1],
            delay: reduced ? 0 : 0.1,
          }}
          className="r bg-muted px-3 py-1 text-xs"
        >
          <p className="opacity-60">JOIN US</p>
        </motion.div>
        <div className="fcc gap-2 text-center">
          <WordsReveal
            text="Build TZAR Hub with us"
            className="max-w-lg px-5 text-[28px] font-semibold leading-[28px] tracking-tighter md:text-[38px] md:leading-[38px]"
          />
          <p className="text-muted-foreground max-w-sm text-sm md:text-base">
            Ideas, bug reports and new commands come from the community.
          </p>
        </div>
      </div>
      <div className="fc relative mt-[-30px] h-[300px] w-screen gap-3 sm:mt-[34px]">
        <a
          href={TZAR_DISCORD}
          target="_blank"
          rel="noreferrer"
          className="fc"
          aria-label="Join the TZAR Hub Discord"
        >
          <motion.div
            onMouseEnter={spin}
            animate={controls}
            whileInView={{ rotateY: reduced ? 0 : 360 }}
            initial={{ rotateY: reduced ? 0 : 180 }}
            transition={{ duration: reduced ? 0 : 0.5, ease: 'easeInOut' }}
            className="fc relative z-10 scale-75 cursor-pointer sm:scale-85 lg:scale-100"
          >
            <span className="contents" dangerouslySetInnerHTML={{ __html: badgeSvg }} />
            <img
              src="/tzar/Frame-2-red.svg"
              alt=""
              className="r absolute mb-1"
              width={52}
              height={52}
              loading="lazy"
            />
          </motion.div>
        </a>
        <motion.div
          initial={{
            translateX: reduced ? 20 : 10,
            opacity: reduced ? 1 : 0.5,
            scale: reduced ? 1 : 0.8,
            rotate: reduced ? 0 : 10,
          }}
          whileInView={{ translateX: 20, opacity: 1, scale: 1, rotate: 0 }}
          transition={{ duration: reduced ? 0 : 1, ease: [0, 0.69, 0.5, 1] }}
          className="pointer-events-none absolute top-24 h-[500px] w-full max-w-[1300px] translate-x-10 overflow-hidden sm:top-16 lg:top-8"
        >
          <img
            width={1400}
            height={788}
            className="pointer-events-none absolute right-0 w-1/2"
            style={{ filter: 'var(--invert)' }}
            src="/tzar/art/hand-right.webp"
            alt=""
            loading="lazy"
          />
          <div className="from-background pointer-events-none absolute inset-y-0 right-0 w-1/4 bg-gradient-to-l" />
        </motion.div>
        <motion.div
          initial={{
            translateX: reduced ? 0 : -10,
            opacity: reduced ? 1 : 0.5,
            scale: reduced ? 1 : 0.8,
            rotate: reduced ? 0 : -10,
          }}
          whileInView={{ translateX: 0, opacity: 1, scale: 1, rotate: 0 }}
          transition={{ duration: reduced ? 0 : 1, ease: [0, 0.69, 0.5, 1] }}
          className="pointer-events-none absolute top-24 h-[500px] w-full max-w-[1300px] -translate-x-14 overflow-hidden sm:top-16 lg:top-8"
        >
          <img
            width={1400}
            height={788}
            style={{ filter: 'var(--invert)' }}
            className="pointer-events-none absolute left-0 w-1/2"
            src="/tzar/art/hand-left.webp"
            alt=""
            loading="lazy"
          />
          <div className="from-background pointer-events-none absolute inset-y-0 left-0 w-1/4 bg-gradient-to-r" />
        </motion.div>
      </div>
      <div className="fc mb-2 gap-1 text-sm opacity-50 sm:mt-24">
        Join the community at{' '}
        <a
          href={TZAR_DISCORD}
          target="_blank"
          rel="noreferrer"
          className="group relative flex items-center before:pointer-events-none before:absolute before:left-0 before:top-[1.5em] before:h-[0.05em] before:w-full before:bg-current before:content-[''] before:origin-right before:scale-x-0 before:transition-transform before:duration-300 before:ease-[cubic-bezier(0.4,0,0.2,1)] hover:before:origin-left hover:before:scale-x-100"
        >
          TZAR Hub
          <svg
            className="ml-[0.3em] size-[0.55em] translate-y-1 opacity-0 transition-all duration-300 group-hover:translate-y-0 group-hover:opacity-100"
            fill="none"
            viewBox="0 0 10 10"
            aria-hidden="true"
          >
            <path
              d="M1.004 9.166 9.337.833m0 0v8.333m0-8.333H1.004"
              stroke="currentColor"
              strokeWidth="1"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
        </a>
      </div>
    </section>
  )
}
