import type { ReactNode } from 'react'
import { cn } from '@/lib/utils'

// The small spaced label above a heading. Medeo Serif, as the type rules in the README say.
export function Eyebrow({ children, className }: { children: ReactNode; className?: string }) {
  return (
    <p className={cn('font-roman text-xs uppercase tracking-widest text-foreground/70', className)}>
      {children}
    </p>
  )
}

// Marks something that works but is not finished yet, such as the Cmdr Panel.
export function DevBadge({ className }: { className?: string }) {
  return (
    <span
      className={cn(
        'border-primary/40 bg-primary/10 text-primary inline-flex items-center gap-1.5 rounded-full border px-2.5 py-0.5 text-xs font-medium',
        className,
      )}
    >
      <span aria-hidden="true" className="bg-primary size-1.5 animate-pulse rounded-full" />
      In development
    </span>
  )
}
