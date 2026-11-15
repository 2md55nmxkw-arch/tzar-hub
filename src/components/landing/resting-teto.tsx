import { useEffect, useRef, useState } from 'react'
import { isMotionReduced, useReducedMotion } from '@/hooks/use-reduced-motion'

export function RestingTeto({ className }: { className?: string } = {}) {
  // Reduced motion at load shows the still; the pause switch at runtime just
  // stops the video, so the mascot does not jump to the still's position.
  const reduced = useReducedMotion()
  const [reducedAtMount] = useState(isMotionReduced)
  const [failed, setFailed] = useState(false)
  const ref = useRef<HTMLVideoElement>(null)
  useEffect(() => {
    const video = ref.current
    if (!video) return
    let visible = false
    const sync = () => {
      if (!reduced && visible && !document.hidden) void video.play().catch(() => {})
      else video.pause()
    }
    const observer = new IntersectionObserver(([entry]) => {
      visible = entry.isIntersecting
      sync()
    })
    observer.observe(video)
    document.addEventListener('visibilitychange', sync)
    return () => {
      observer.disconnect()
      document.removeEventListener('visibilitychange', sync)
      video.pause()
    }
  }, [reduced, failed])
  if (reducedAtMount || failed)
    return (
      <img
        src="/tzar/mascot/teto-pricing.webp"
        alt="Chibi Teto resting on the card"
        className={className ?? 'resting-teto'}
        width={180}
        height={77}
        loading="lazy"
      />
    )
  return (
    <video
      ref={ref}
      src="/tzar/mascot/teto-pricing-loop.webm"
      poster="/tzar/mascot/teto-pricing.webp"
      className={className ?? 'resting-teto-video'}
      aria-label="Chibi Teto resting on the card"
      width={180}
      height={77}
      muted
      loop
      playsInline
      preload="metadata"
      onError={() => setFailed(true)}
    />
  )
}
