import { useEffect, useRef, useState, type ReactNode } from 'react'
import { Link } from 'react-router-dom'
import { ArrowRight, Keyboard, LayoutGrid, Search, TerminalSquare } from 'lucide-react'
import { useReducedMotion } from '@/hooks/use-reduced-motion'
import { DevBadge, Eyebrow } from './eyebrow'
import { TZAR_DISCORD } from './tzar-content'
import { Reveal, WordsReveal } from './reveal'

type Result = { name: string; args?: string; text: string; alias?: string }
type Scenario = {
  query: string
  typed: string
  group: string
  results: Result[]
  title: string
  usage: string
  text: string
  detail: ReactNode
}

function Kbd({ children }: { children: ReactNode }) {
  return (
    <kbd className="border-foreground/15 rounded-md border px-2 py-0.5 font-mono text-xs text-foreground">
      {children}
    </kbd>
  )
}

// Real commands and descriptions from public/tzar-admin-commands.json.
const scenarios: Scenario[] = [
  {
    query: 'speed',
    typed: 'sp',
    group: 'Character',
    results: [
      { name: 'speed', args: '<0-500>', text: 'Walk speed', alias: 'ws' },
      { name: 'flyspeed', args: '<1-500>', text: 'How fast fly moves' },
      { name: 'fly', args: '[speed]', text: 'Fly around, WASD to move' },
      { name: 'noclip', text: 'Walk through walls' },
    ],
    title: 'Speed',
    usage: 'speed <0-500>',
    text: 'Walk speed. Without a value it goes back to the game’s own.',
    detail: (
      <>
        <div className="mt-4 flex h-10 overflow-hidden rounded-lg bg-foreground/[0.06] text-sm">
          <span className="bg-primary flex w-[38%] items-center px-3 text-white">Speed</span>
          <span className="ml-auto flex items-center px-3 font-mono">96</span>
        </div>
        <dl className="mt-4 space-y-2 text-[13px] text-muted-foreground">
          <div className="flex items-center justify-between">
            <dt>Key</dt>
            <dd>
              <Kbd>G</Kbd>
            </dd>
          </div>
          <div className="flex items-center justify-between">
            <dt>Also</dt>
            <dd className="font-mono text-xs uppercase">ws · walkspeed</dd>
          </div>
        </dl>
      </>
    ),
  },
  {
    query: 'wear',
    typed: 'we',
    group: 'Avatar',
    results: [
      { name: 'wear', args: '<user>', text: 'Wear another player’s avatar' },
      { name: 'outfit', args: '<outfit>', text: 'Wear one of your saved outfits' },
      { name: 'bundle', args: '<bundle id>', text: 'Wear a body bundle from the catalog' },
      { name: 'saveoutfit', args: '[name]', text: 'Save what you are wearing now' },
    ],
    title: 'Wear',
    usage: 'wear <user>',
    text: 'Wear another player’s avatar, as they look in this server. Only you see it.',
    detail: (
      <>
        <p className="mt-4 font-mono text-[11px] uppercase tracking-wider text-muted-foreground">
          In this server
        </p>
        <ul className="mt-2 grid grid-cols-3 gap-2">
          {['Sparrow', 'NightOwl', 'kiro_7'].map((name, i) => (
            <li
              key={name}
              className={`rounded-xl p-2 text-center text-xs ${i === 0 ? 'bg-primary/15 ring-primary/50 ring-1' : 'bg-foreground/[0.06]'}`}
            >
              <span
                className={`mx-auto mb-1.5 block size-8 rounded-lg ${i === 0 ? 'bg-primary/70' : 'bg-foreground/15'}`}
              />
              {name}
            </li>
          ))}
        </ul>
      </>
    ),
  },
  {
    query: 'bind',
    typed: 'bi',
    group: 'Hub',
    results: [
      { name: 'bind', args: '<key> <command>', text: 'Bind a command line to a key' },
      { name: 'binds', text: 'Show key binds' },
      { name: 'unbind', args: '<key>', text: 'Remove a key bind' },
      { name: 'togglekey', args: '[key]', text: 'Key that shows and hides TZAR' },
    ],
    title: 'Bind',
    usage: 'bind <key> <command>',
    text: 'Put any command line on a key. Binds are saved and come back next time.',
    detail: (
      <ul className="mt-4 space-y-2 text-sm">
        {[
          ['F', 'fly'],
          ['G', 'speed 96'],
          ['V', 'noclip'],
        ].map(([key, line]) => (
          <li
            key={key}
            className="flex items-center gap-3 rounded-lg bg-foreground/[0.06] px-3 py-2"
          >
            <Kbd>{key}</Kbd>
            <span className="font-mono text-[13px]">{line}</span>
          </li>
        ))}
      </ul>
    ),
  },
]

// Types the query, holds, erases, then moves to the next scenario. It only runs while the
// preview is on screen; with reduced motion or paused animations it shows the first scenario.
function useTypedScenario(reduced: boolean) {
  const ref = useRef<HTMLDivElement>(null)
  const [visible, setVisible] = useState(false)
  const [index, setIndex] = useState(0)
  const [chars, setChars] = useState(scenarios[0].typed.length)
  const [phase, setPhase] = useState<'typing' | 'hold' | 'erasing'>('hold')
  useEffect(() => {
    const el = ref.current
    if (!el) return
    const observer = new IntersectionObserver(([entry]) => setVisible(entry.isIntersecting))
    observer.observe(el)
    return () => observer.disconnect()
  }, [])
  useEffect(() => {
    if (reduced || !visible) return
    const typed = scenarios[index].typed
    let timer: number
    if (phase === 'typing') {
      timer = window.setTimeout(
        () => (chars < typed.length ? setChars(chars + 1) : setPhase('hold')),
        chars < typed.length ? 140 : 0,
      )
    } else if (phase === 'hold') {
      timer = window.setTimeout(() => setPhase('erasing'), 3200)
    } else {
      timer = window.setTimeout(() => {
        if (chars > 0) setChars(chars - 1)
        else {
          setIndex((index + 1) % scenarios.length)
          setPhase('typing')
        }
      }, 70)
    }
    return () => clearTimeout(timer)
  }, [reduced, visible, index, chars, phase])
  const scenario = reduced ? scenarios[0] : scenarios[index]
  const shown = reduced ? scenario.typed.length : chars
  return { ref, scenario, shown, settled: reduced || phase === 'hold' }
}

// A drawing of the in-game command bar, after the Admin page of the TZAR Hub UI library in Figma.
function CommandBarPreview() {
  const reduced = useReducedMotion()
  const { ref, scenario, shown, settled } = useTypedScenario(reduced)
  const empty = shown === 0
  return (
    <div
      ref={ref}
      role="img"
      aria-label="The Cmdr Panel command bar suggesting commands as you type, with details for the selected one."
      className="border-foreground/10 bg-background/80 w-full overflow-hidden rounded-2xl border text-left shadow-2xl shadow-black/60 backdrop-blur-xl"
    >
      <div className="flex items-center justify-between px-5 pt-4 font-mono text-[11px] uppercase tracking-wider text-muted-foreground">
        <span className="flex items-center gap-2">
          <img src="/tzar/Frame-2-red.svg" alt="" width={14} height={14} />
          TZAR · Commands
        </span>
        <span className="hidden sm:inline">43 commands · 2 on</span>
      </div>
      <div className="flex items-center gap-3 border-b border-foreground/10 px-5 py-4">
        <Search aria-hidden="true" className="size-4 shrink-0 text-muted-foreground" />
        <span className="text-xl tracking-tight">
          {scenario.typed.slice(0, shown)}
          <span className="bg-primary ml-px inline-block h-5 w-px translate-y-1 animate-pulse" />
          {!empty && <span className="text-muted-foreground">{scenario.query.slice(shown)}</span>}
          {empty && <span className="text-muted-foreground">Type a command</span>}
        </span>
        <span className="ml-auto">
          <Kbd>Tab</Kbd>
        </span>
      </div>
      <div className="grid min-h-[320px] md:grid-cols-2">
        <ul
          key={scenario.query}
          className={`space-y-1 p-2 transition-opacity duration-300 ${empty ? 'opacity-30' : 'opacity-100'}`}
        >
          <li className="px-3 pb-1 pt-2 font-mono text-[11px] uppercase tracking-wider text-muted-foreground">
            {scenario.group}
          </li>
          {scenario.results.map((item, i) => (
            <li
              key={item.name}
              className={`rounded-xl px-3 py-2 ${i === 0 ? 'bg-foreground/[0.06]' : ''}`}
            >
              <p className="flex items-center gap-2 text-sm">
                {i === 0 && <span className="bg-primary size-1.5 rounded-full" />}
                {item.name}
                {item.args && (
                  <span className="font-mono text-xs text-muted-foreground">{item.args}</span>
                )}
                {item.alias && (
                  <span className="ml-auto font-mono text-xs text-muted-foreground">
                    {item.alias}
                  </span>
                )}
              </p>
              <p className="mt-0.5 text-[13px] text-muted-foreground">{item.text}</p>
            </li>
          ))}
        </ul>
        <div
          className={`hidden border-l border-foreground/10 p-5 transition-opacity duration-300 md:block ${settled ? 'opacity-100' : 'opacity-0'}`}
        >
          <p className="text-xl font-medium tracking-tight">{scenario.title}</p>
          <p className="mt-2 font-mono text-sm text-muted-foreground">{scenario.usage}</p>
          <p className="mt-3 text-[13px] leading-5 text-muted-foreground">{scenario.text}</p>
          {scenario.detail}
        </div>
      </div>
      <div className="flex justify-between border-t border-foreground/10 px-5 py-3 font-mono text-[11px] uppercase tracking-wider text-muted-foreground">
        <span>↑↓ select · Tab complete · Enter run</span>
        <span className="hidden sm:inline">Esc close</span>
      </div>
    </div>
  )
}

const features = [
  {
    icon: TerminalSquare,
    title: 'Command bar',
    text: 'Press ; and type. Tab completes, Enter runs. Players, outfits and waypoints complete too.',
  },
  {
    icon: Keyboard,
    title: 'Binds',
    text: 'Put any command line on a key: “F → fly”, “G → speed 96”. Binds stay between sessions.',
  },
  {
    icon: LayoutGrid,
    title: 'Game modules',
    text: 'Dozens of features for one game, saved sets and a routine you can pause. Authors’ modules are reviewed and published by TZAR.',
  },
]

export function CmdrPanel() {
  return (
    <section className="flex w-full flex-col items-center px-5">
      <div className="flex flex-col items-center gap-3 text-center">
        <div className="flex flex-wrap items-center justify-center gap-3">
          <Eyebrow>Cmdr Panel</Eyebrow>
          <DevBadge />
        </div>
        <WordsReveal
          text="Every command, one key away"
          className="max-w-xl text-[28px] font-semibold leading-[28px] tracking-tighter md:text-[38px] md:leading-[38px]"
        />
        <Reveal delay={120}>
          <p className="max-w-md text-sm text-muted-foreground md:text-base">
            The in-game panel of TZAR Hub. Avatar, character and hub commands, key binds and full
            game modules in one place.
          </p>
        </Reveal>
      </div>
      {/* The panel floats over a flat horizon; the red sun shows below it. Art generated for TZAR Hub (Figma, GPT Image). */}
      <Reveal delay={160} className="relative mt-10 w-full max-w-[1130px]">
        <div className="relative overflow-hidden rounded-[28px] border border-foreground/10 bg-[#080808] px-3 pb-24 pt-10 sm:px-10 md:px-16 md:pb-40 md:pt-16">
          <img
            src="/tzar/art/horizon.webp"
            alt=""
            width={1536}
            height={864}
            loading="lazy"
            decoding="async"
            className="absolute inset-0 size-full object-cover object-bottom"
          />
          <div className="relative mx-auto max-w-[896px]">
            <CommandBarPreview />
          </div>
          <p className="relative mt-5 text-center font-mono text-[11px] uppercase tracking-wider text-white/75">
            ; opens the bar · RightShift hides TZAR
          </p>
        </div>
        <p className="mx-auto mt-4 max-w-xl text-center text-sm text-muted-foreground">
          The Cmdr Panel is still in development. Commands, keys and modules can change between
          updates, and some things may break. Report bugs in the{' '}
          <a className="underline" href={TZAR_DISCORD} target="_blank" rel="noreferrer">
            Discord
          </a>
          .
        </p>
      </Reveal>
      <div className="mt-10 grid w-full max-w-[896px] gap-6 sm:grid-cols-3">
        {features.map(({ icon: Icon, title, text }, i) => (
          <Reveal key={title} delay={200 + i * 70}>
            <span className="bg-primary/10 ring-primary/25 flex size-10 items-center justify-center rounded-xl ring-1">
              <Icon aria-hidden="true" className="text-primary size-5" />
            </span>
            <h3 className="mt-4 font-medium">{title}</h3>
            <p className="mt-1 text-sm leading-6 text-muted-foreground">{text}</p>
          </Reveal>
        ))}
      </div>
      <Reveal delay={260}>
        <Link
          to="/docs/cmdr-panel"
          className="group mt-10 flex items-center gap-1 text-sm font-semibold transition-opacity hover:opacity-70"
        >
          Read the panel guide
          <ArrowRight className="size-3.5 transition-transform group-hover:translate-x-[3px]" />
        </Link>
      </Reveal>
    </section>
  )
}
