import type { ReactNode } from 'react'
import { motion } from 'motion/react'
import { useReducedMotion } from '@/hooks/use-reduced-motion'

type Props = { children: ReactNode; className?: string; delay?: number; y?: number }

export function Reveal({ children, className, delay = 0, y = 10 }: Props) {
  const reduced = useReducedMotion()
  return (
    <motion.div
      className={className}
      initial={{ opacity: reduced ? 1 : 0, y: reduced ? 0 : y }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      transition={{
        duration: reduced ? 0 : 1,
        ease: [0, -0.07, 0.11, 1],
        delay: reduced ? 0 : delay / 1000,
      }}
    >
      {children}
    </motion.div>
  )
}

export function WordsReveal({
  text,
  className,
  delay = 0,
  extra,
}: {
  text: string
  className?: string
  delay?: number
  extra?: ReactNode
}) {
  const reduced = useReducedMotion()
  return (
    <motion.h2
      aria-label={text}
      className={className}
      initial={reduced ? 'visible' : 'hidden'}
      whileInView="visible"
      viewport={{ once: true }}
      variants={{
        hidden: { opacity: 0 },
        visible: {
          opacity: 1,
          transition: {
            duration: reduced ? 0 : 1,
            delay: reduced ? 0 : delay / 1000,
            staggerChildren: reduced ? 0 : 0.05,
          },
        },
      }}
    >
      {extra}
      {text.split(' ').map((word, index, words) => (
        <motion.span
          key={index}
          className="inline-block"
          variants={{
            hidden: { opacity: 0, y: 10 },
            visible: {
              opacity: 1,
              y: 0,
              transition: { y: { duration: reduced ? 0 : 0.5, ease: 'easeOut' } },
            },
          }}
        >
          {word}
          {index < words.length - 1 ? '\u00a0' : ''}
        </motion.span>
      ))}
    </motion.h2>
  )
}
