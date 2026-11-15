import { Link } from 'react-router-dom'
import { ArrowRight, Check } from 'lucide-react'
import { BackgroundVideo } from './background-video'
import { Eyebrow } from './eyebrow'
import { Reveal, WordsReveal } from './reveal'
import { RestingTeto } from './resting-teto'
import './resting-teto.css'

const free = [
  'Every script, in any game',
  'No keys and no checkpoints',
  'No ads and no account',
  'Updates load on their own',
]

const open = [
  'Every file, readable on this site',
  'Send fixes and new commands',
  'Build and test it yourself',
  'Authors’ game modules, reviewed by TZAR',
]

const primary =
  'focus-halo bg-foreground text-background flex min-h-11 w-full items-center justify-center gap-2 rounded-xl text-[15px] font-semibold tracking-tight transition-opacity hover:opacity-80'

function Points({ items }: { items: string[] }) {
  return (
    <ul className="mt-[26px] space-y-[10px]">
      {items.map((text) => (
        <li key={text} className="flex items-center gap-2">
          <Check aria-hidden="true" className="text-foreground/50 size-4 shrink-0" />
          <span className="text-foreground/85 text-[15px] font-medium tracking-tight">{text}</span>
        </li>
      ))}
    </ul>
  )
}

export function OpenSource() {
  return (
    <section className="flex w-full flex-col items-center overflow-hidden px-5">
      <div className="flex flex-col items-center gap-3 px-6 text-center">
        <Eyebrow>Keyless · Open source</Eyebrow>
        <WordsReveal
          text="Free to use. Open to read."
          className="max-w-lg text-[28px] font-semibold leading-[28px] tracking-tighter md:text-[38px] md:leading-11"
        />
        <p className="max-w-md text-sm text-muted-foreground md:text-base">
          Nothing stands between you and a script, and every line of the hub is public. Game modules
          from outside authors are the one exception.
        </p>
      </div>

      <div className="mt-[110px] flex w-full max-w-2xl flex-col gap-24 sm:min-h-[460px] sm:flex-row sm:gap-3">
        <Reveal className="bg-muted relative flex-1 overflow-hidden rounded-3xl p-[30px]">
          <BackgroundVideo
            height={0.65}
            className="absolute inset-0 h-full w-full"
            style={{
              opacity: 'var(--var-opacity)',
              transform: 'translate(-14%, 18%) rotate(45deg) scale(1.8)',
              maskImage: 'linear-gradient(to top, black 0%, black 38%, transparent 78%)',
            }}
          />
          <div className="relative z-10 flex h-full flex-col justify-between gap-12">
            <div>
              <h3 className="text-md font-semibold">Free</h3>
              <p className="mt-[11px] text-4xl font-semibold tracking-tight">
                $0<span className="text-muted-foreground text-sm font-normal"> / forever</span>
              </p>
              <p className="text-muted-foreground mt-1.5 text-xs">Copy the loader and play</p>
              <Points items={free} />
            </div>
            <Link to="/docs/quick-start" className={primary}>
              Quick start <ArrowRight aria-hidden="true" className="size-4" />
            </Link>
          </div>
        </Reveal>

        <Reveal delay={200} className="bg-muted relative flex-1 rounded-3xl p-[30px]">
          <RestingTeto />
          <div className="relative z-10 flex h-full flex-col justify-between gap-12">
            <div>
              <h3 className="text-md font-semibold">Open source</h3>
              <p className="mt-[11px] text-4xl font-semibold tracking-tight">
                100%<span className="text-muted-foreground text-sm font-normal"> of the hub</span>
              </p>
              <p className="text-muted-foreground mt-1.5 text-xs">
                Read it, learn from it, improve it
              </p>
              <Points items={open} />
            </div>
            <div className="space-y-3">
              <Link to="/source" className={primary}>
                View the source <ArrowRight aria-hidden="true" className="size-4" />
              </Link>
              <Link
                to="/docs/modules"
                className="focus-halo flex min-h-11 items-center justify-center rounded-xl border border-foreground/15 text-sm font-medium transition-colors hover:bg-foreground/5"
              >
                Write a game module
              </Link>
            </div>
          </div>
        </Reveal>
      </div>
    </section>
  )
}
