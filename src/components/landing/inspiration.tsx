import { CircleArrowOutUpRight } from 'lucide-react'
import { Link } from 'react-router-dom'
import { TZAR_DISCORD } from './tzar-content'
import { Reveal, WordsReveal } from './reveal'
import { comps } from './components-data'

const legends = comps.map((game) => ({
  name: game.name,
  href: game.gameUrl ?? game.trailer ?? '/components',
}))

function DashedLine() {
  return (
    <svg height="2" className="w-full" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect
        x="1.08"
        y="1.39"
        width="100%"
        height="1"
        stroke="var(--color-foreground)"
        strokeOpacity="0.15"
        strokeDasharray="3 2"
      />
    </svg>
  )
}

function Marquee() {
  if (legends.length === 1)
    return (
      <div className="my-11 flex justify-center">
        <a
          href={legends[0].href}
          target="_blank"
          rel="noreferrer"
          className="inline-flex items-center gap-2 text-xl font-medium tracking-tight text-foreground/80 transition-colors hover:text-primary"
        >
          {legends[0].name}
          <CircleArrowOutUpRight className="size-4" />
        </a>
      </div>
    )
  return (
    <div className="group relative mx-auto my-11 flex max-w-4xl overflow-hidden p-2 [--gap:1rem] [gap:var(--gap)] [--duration:40s]">
      {[0, 1, 2, 3].map((k) => (
        <div
          key={k}
          className="marquee-track flex shrink-0 flex-row justify-around [gap:var(--gap)] group-hover:[animation-play-state:paused]"
        >
          {legends.map((l) => (
            <a
              key={l.name}
              target="_blank"
              className="text-foreground/70 mx-4 whitespace-nowrap text-lg font-semibold tracking-tight transition-colors ease-in-out hover:text-foreground md:text-2xl"
              href={l.href}
            >
              {l.name}
            </a>
          ))}
        </div>
      ))}
      <div className="from-background pointer-events-none absolute inset-y-0 left-0 w-12 bg-gradient-to-r md:w-24" />
      <div className="from-background pointer-events-none absolute inset-y-0 right-0 w-12 bg-gradient-to-l md:w-24" />
    </div>
  )
}

export function DevouringDetails() {
  return (
    <section className="flex w-full flex-col items-center overflow-hidden px-5">
      <Reveal className="-mb-6 w-56 md:w-72">
        {/* Generated for TZAR Hub (Figma, GPT Image); faded so it sits in the page. */}
        <img
          src="/tzar/art/launch.webp"
          alt=""
          width={1024}
          height={1024}
          loading="lazy"
          decoding="async"
          className="aspect-square w-full object-cover [mask-image:radial-gradient(closest-side,black_55%,transparent)]"
        />
      </Reveal>
      <div className="relative flex flex-col items-center gap-4">
        <div className="flex flex-col items-center gap-2 text-center">
          <WordsReveal
            text="Instant execution"
            className="max-w-lg px-5 text-[28px] font-semibold leading-[28px] tracking-tighter md:text-[38px] md:leading-11"
          />
          <Reveal delay={120}>
            <p className="max-w-md text-sm tracking-[-0.16px] md:text-[16px] md:leading-[24px]">
              Copy the loader and run it in any game. No key, no checkpoints. Follow the setup guide
              to get started.
            </p>
          </Reveal>
        </div>
      </div>

      <div className="relative mt-8 flex w-full max-w-lg flex-col gap-1 px-5 md:mt-10">
        <Reveal delay={100}>
          <Link
            className="flex w-full items-center gap-2 rounded-2xl px-4 py-2 text-foreground/70 transition-colors hover:bg-muted hover:text-foreground"
            to="/docs"
          >
            <span>Documentation</span>
            <div className="h-0.5 flex-1 bg-foreground/10" />
            <CircleArrowOutUpRight className="size-3.5" />
          </Link>
        </Reveal>
        <Reveal delay={220}>
          <Link
            className="flex w-full items-center gap-2 rounded-2xl px-4 py-2 text-foreground/70 transition-colors hover:bg-muted hover:text-foreground"
            to="/docs/avatar-changer"
          >
            <span>Avatar Changer guide</span>
            <div className="h-0.5 flex-1 bg-foreground/10" />
            <CircleArrowOutUpRight className="size-3.5" />
          </Link>
        </Reveal>
      </div>
    </section>
  )
}

export function UsedBy() {
  return (
    <section className="flex w-full flex-col items-center overflow-hidden px-5">
      <div className="flex flex-col items-center gap-4">
        <div className="flex flex-col items-center gap-2 text-center">
          <WordsReveal
            text="Supporting your favorite executors"
            className="max-w-lg px-5 text-[28px] font-semibold leading-[28px] tracking-tighter md:text-[38px] md:leading-[38px]"
          />
        </div>
      </div>

      <div className="relative mt-[34px] w-full px-5">
        <div className="mx-auto flex h-3 w-full max-w-xl items-center gap-3">
          <DashedLine />
          <p className="font-roman text-foreground/70 flex min-w-fit text-xs uppercase tracking-widest">
            Roblox script hub
          </p>
          <DashedLine />
        </div>
        <Reveal className="flex w-full justify-center py-11">
          <a
            target="_blank"
            aria-label="TZAR Hub community"
            className="flex cursor-help items-center justify-center gap-2 transition-opacity hover:opacity-50"
            href={TZAR_DISCORD}
          >
            <img src="/tzar/Frame-2-red.svg" className="size-6 md:size-10" alt="" loading="lazy" />
            <p className="text-lg font-medium tracking-tight md:text-2xl md:tracking-tighter">
              TZAR Hub
            </p>
          </a>
        </Reveal>
        <div className="mx-auto flex h-3 w-full max-w-xl items-center gap-3">
          <DashedLine />
          <p className="font-roman text-foreground/70 flex min-w-fit text-xs uppercase tracking-widest">
            Supported games
          </p>
          <DashedLine />
        </div>
        <Marquee />
        <div className="mx-auto flex h-3 w-full max-w-xl items-center gap-3">
          <DashedLine />
          <p className="font-roman text-foreground/70 flex min-w-fit text-xs uppercase tracking-widest">
            Executors
          </p>
          <DashedLine />
        </div>
        <div className="flex w-full flex-wrap items-center justify-center gap-x-6 gap-y-3 pt-11 md:gap-x-12">
          {['Potassium', 'Solara', 'Fluxus', 'Delta', 'Wave'].map((name) => (
            <Link
              key={name}
              to="/docs/executors"
              aria-label={name}
              className="cursor-help transition-all ease-in-out hover:opacity-50"
            >
              <p className="font-medium tracking-tighter md:text-xl">{name}</p>
            </Link>
          ))}
        </div>
        <p className="text-muted-foreground pb-11 pt-4 text-center text-xs">
          Built and tested on Potassium. The others should work too.
        </p>
        <div className="mx-auto flex h-3 w-full max-w-xl items-center gap-3">
          <DashedLine />
        </div>
        <div className="mt-[20px] flex cursor-pointer flex-col items-center justify-center gap-1 text-sm transition-all ease-in-out md:flex-row">
          <p className="text-foreground/70 text-center text-sm">
            Get help and follow updates in our community
          </p>
          <a
            className="text-foreground flex cursor-pointer items-center gap-1 pl-1 font-semibold transition-opacity hover:opacity-70"
            href={TZAR_DISCORD}
          >
            join us
            <ArrowInline />
          </a>
        </div>
      </div>
    </section>
  )
}

function ArrowInline() {
  return (
    <span className="transition-all ease-in-out group-hover:translate-x-[3px]">
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        className="lucide lucide-arrow-right size-3.5"
        aria-hidden="true"
      >
        <path d="M5 12h14" />
        <path d="m12 5 7 7-7 7" />
      </svg>
    </span>
  )
}
