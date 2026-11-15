import { useEffect, useState, type CSSProperties } from 'react'
import FlameBackground from './flame-background'

// Soft brand wash for the light theme, where the dark smoke shader is disabled.
const lightWash =
  'radial-gradient(72% 58% at 50% 106%, rgba(229,57,69,0.22), rgba(229,57,69,0) 70%), radial-gradient(48% 42% at 6% 102%, rgba(229,57,69,0.14), rgba(229,57,69,0) 72%)'

// Shared entry point used by the hero, pricing and key page.
// `fade` dissolves the bottom edge into the page. The flame does it in the shader: a CSS mask
// over a WebGL layer tears into rectangular tiles in Chrome.
export function BackgroundVideo({
  className,
  style,
  height = 0.5,
  fade = 0,
}: {
  className: string
  style?: CSSProperties
  height?: number
  fade?: number
}) {
  const [enabled, setEnabled] = useState(() => document.documentElement.classList.contains('dark'))
  useEffect(() => {
    const observer = new MutationObserver(() =>
      setEnabled(document.documentElement.classList.contains('dark')),
    )
    observer.observe(document.documentElement, { attributes: true, attributeFilter: ['class'] })
    return () => observer.disconnect()
  }, [])
  if (!enabled) {
    const mask = fade
      ? `linear-gradient(to bottom, black ${(1 - fade) * 100}%, transparent)`
      : undefined
    return (
      <div
        aria-hidden="true"
        className={className}
        style={{
          position: 'absolute',
          inset: 0,
          width: '100%',
          height: '100%',
          pointerEvents: 'none',
          backgroundImage: lightWash,
          maskImage: mask,
          WebkitMaskImage: mask,
          ...style,
        }}
      />
    )
  }
  return (
    <FlameBackground
      background="#080808"
      height={height}
      fade={fade}
      className={className}
      style={style}
    />
  )
}
