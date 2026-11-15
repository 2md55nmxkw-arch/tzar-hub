import { useId, useState } from 'react'
import { ArrowRight, Check, Search, Ticket, Trophy } from 'lucide-react'
import { AnimatePresence, motion } from 'motion/react'
import { useReducedMotion } from '@/hooks/use-reduced-motion'

const modules = [
  'PARANORMAL',
  'Flee the Facility',
  'HUNTED',
  'Duck Duck (Tag)',
  'Prism Runway Show',
  'Sleep Paralysis',
  'Clean All The Leaves',
  'Carve Wood!',
  'Survive Overnight in a Mega Store',
  'Welcome to Bloxburg',
  'Sell Lemons',
  'Royale High',
  'Plus 1 Speed Keyboard Escape',
  'Ao Oni',
  'Murder Duels',
  'Search For The Needle',
  'Moo Moo Mystery',
  'Toons Universe',
  'Grow a Garden',
]
const extra: Record<string, string> = {
  'Toons Universe':
    '12/12 floors. Four rewards obtained, including the in-game Undead Rave skin for Discard.',
  'Murder Duels':
    'Hollow Exclusive in-game knife obtained. Secret quest unfinished; elite track at 23/2500 kills.',
  'Grow a Garden':
    'Sweet Fortune: 500/500 Candy Corn earned and badge obtained. Candy Corn is this game’s currency.',
  'Moo Moo Mystery': 'Ghost collection: 17/48. Additional tracks remain unfinished.',
  'Plus 1 Speed Keyboard Escape': 'The separate CG5 Concert has not been tested.',
}
const rewards = [
  ['Gourdlord: The Entangled', 'Hub shop · 100 tickets'],
  ['Haunted Harvest Crown', 'Hub shop · 20 tickets'],
  ['Lord Umberhallow BLOXikin', 'MazeLock puzzle'],
  ['The Beasthammer', 'Quest attribution being checked'],
  ['Little Plus-tergeist', 'Quest attribution being checked'],
  ['All-Seeking Antlers', 'Quest attribution being checked'],
]
const tabs = ['Games', 'Rewards', 'Progress'] as const

export function HollowRelease() {
  const [tab, setTab] = useState<(typeof tabs)[number]>('Games')
  const [query, setQuery] = useState('')
  const [selected, setSelected] = useState('Toons Universe')
  const reduced = useReducedMotion()
  const id = useId()
  const filtered = modules.filter((name) => name.toLowerCase().includes(query.trim().toLowerCase()))
  const current = filtered.includes(selected) ? selected : filtered[0]
  return (
    <section aria-label="The Hollow preview details" className="mt-14 max-w-4xl">
      <div className="flex flex-wrap items-end justify-between gap-5">
        <div>
          <p className="mb-2 text-xs text-primary">INSIDE THE PREVIEW</p>
          <h2 className="text-3xl font-medium tracking-tight sm:text-4xl">Explore The Hollow.</h2>
        </div>
        <p className="text-sm text-muted-foreground">19 modules. No key. Just play.</p>
      </div>
      <div
        role="tablist"
        aria-label="Preview information"
        className="mt-8 flex gap-7 border-b border-foreground/10"
      >
        {tabs.map((name, index) => (
          <button
            key={name}
            type="button"
            role="tab"
            id={`${id}-${name}`}
            aria-controls={`${id}-panel`}
            aria-selected={tab === name}
            tabIndex={tab === name ? 0 : -1}
            onClick={() => setTab(name)}
            onKeyDown={(event) => {
              let next: number
              if (event.key === 'ArrowRight') next = (index + 1) % tabs.length
              else if (event.key === 'ArrowLeft') next = (index + tabs.length - 1) % tabs.length
              else if (event.key === 'Home') next = 0
              else if (event.key === 'End') next = tabs.length - 1
              else return
              event.preventDefault()
              setTab(tabs[next])
              document.getElementById(`${id}-${tabs[next]}`)?.focus()
            }}
            className={`relative pb-4 text-sm transition-colors focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-ring ${tab === name ? 'text-foreground' : 'text-muted-foreground hover:text-foreground'}`}
          >
            {name}
            {tab === name && (
              <motion.span
                layoutId={`${id}-underline`}
                transition={{ duration: reduced ? 0 : 0.2 }}
                className="absolute inset-x-0 -bottom-px h-px bg-primary"
              />
            )}
          </button>
        ))}
      </div>
      <div
        role="tabpanel"
        id={`${id}-panel`}
        aria-labelledby={`${id}-${tab}`}
        tabIndex={0}
        className="pt-6 focus-visible:outline-ring"
      >
        <AnimatePresence mode="wait" initial={false}>
          <motion.div
            key={tab}
            initial={{ opacity: reduced ? 1 : 0, y: reduced ? 0 : 5 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: reduced ? 1 : 0 }}
            transition={{ duration: reduced ? 0 : 0.15 }}
          >
            {tab === 'Games' && (
              <>
                <div className="grid gap-7 sm:grid-cols-[1fr_1.1fr] sm:gap-10">
                  <div className="min-w-0">
                    <label className="mb-3 flex items-center gap-2 border-b border-foreground/15 pb-3 text-muted-foreground transition-colors focus-within:border-ring focus-within:shadow-[0_1px_0_var(--ring)]">
                      <Search aria-hidden="true" className="size-4 shrink-0" />
                      <input
                        aria-label="Search game modules"
                        type="search"
                        value={query}
                        onChange={(event) => setQuery(event.target.value)}
                        placeholder="Find your game"
                        className="min-w-0 w-full bg-transparent text-sm text-foreground outline-none placeholder:text-muted-foreground"
                      />
                      <span aria-live="polite" className="text-xs">
                        {filtered.length}/19
                      </span>
                    </label>
                    <div className="max-h-64 overflow-y-auto overscroll-contain pr-2 sm:max-h-80">
                      {filtered.map((name) => (
                        <button
                          key={name}
                          type="button"
                          aria-pressed={current === name}
                          onClick={() => setSelected(name)}
                          className={`flex min-h-11 w-full items-center justify-between gap-3 rounded-lg px-3 py-2 text-left text-sm transition-colors focus-visible:outline-ring ${current === name ? 'bg-muted text-foreground' : 'text-muted-foreground hover:bg-muted/60 hover:text-foreground'}`}
                        >
                          {name}
                          <ArrowRight
                            aria-hidden="true"
                            className={`size-3.5 shrink-0 ${current === name ? 'text-primary' : 'opacity-25'}`}
                          />
                        </button>
                      ))}
                      {!filtered.length && (
                        <p className="py-8 text-sm text-muted-foreground">
                          No matching modules. Try another name.
                        </p>
                      )}
                    </div>
                  </div>
                  <div
                    className="flex min-w-0 flex-col rounded-2xl bg-muted p-6 sm:p-7"
                    aria-live="polite"
                  >
                    {current ? (
                      <>
                        <span className="mb-8 flex items-center gap-2 text-xs text-primary">
                          <Check aria-hidden="true" className="size-3.5" /> Included in the cluster
                        </span>
                        <h3 className="text-2xl font-medium leading-tight tracking-tight">
                          {current}
                        </h3>
                        <p className="mt-3 text-sm leading-6 text-muted-foreground">
                          Main quest completed. Main badge confirmed in the reported test run.
                        </p>
                        {extra[current] && (
                          <p className="mt-5 border-t border-foreground/10 pt-5 text-sm leading-6 text-muted-foreground">
                            {extra[current]}
                          </p>
                        )}
                        <p className="mt-auto pt-8 text-xs text-muted-foreground">
                          Additional rewards are tracked separately.
                        </p>
                      </>
                    ) : (
                      <p className="text-sm text-muted-foreground">
                        Search the 19 included games to explore their results.
                      </p>
                    )}
                  </div>
                </div>
                <p className="mt-6 text-xs leading-6 text-muted-foreground">
                  Creatures of Sonaria uses a separate helper. DOORS was completed earlier and
                  excluded from repeat runs. 21 main badges confirmed on the test account, including
                  DOORS.
                </p>
              </>
            )}
            {tab === 'Rewards' && (
              <>
                <p className="mb-5 text-sm text-muted-foreground">
                  Six Roblox accessories confirmed in the test account’s inventory.
                </p>
                <ul className="grid gap-x-10 sm:grid-cols-2">
                  {rewards.map(([name, source]) => (
                    <li key={name} className="flex gap-3 border-b border-foreground/10 py-5">
                      <Trophy aria-hidden="true" className="mt-1 size-4 shrink-0 text-primary" />
                      <div>
                        <h3 className="text-sm font-medium">{name}</h3>
                        <p className="mt-1 text-xs leading-5 text-muted-foreground">{source}</p>
                      </div>
                    </li>
                  ))}
                </ul>
                <p className="mt-6 text-xs leading-6 text-muted-foreground">
                  In-game rewards and unfinished extra tracks are listed under each game. Not all
                  event UGC or additional quests are complete.
                </p>
              </>
            )}
            {tab === 'Progress' && (
              <div className="grid gap-8 sm:grid-cols-2">
                <div>
                  <p className="flex items-center gap-2 text-xs text-muted-foreground">
                    <Ticket aria-hidden="true" className="size-4 text-primary" /> Test account · hub
                    tickets
                  </p>
                  <p className="mt-4 text-6xl font-medium tracking-tight">
                    20
                    <span className="ml-2 text-sm font-normal tracking-normal text-muted-foreground">
                      remaining
                    </span>
                  </p>
                  <p className="mt-3 text-sm text-muted-foreground">140 credited / 120 spent</p>
                  <p className="mt-6 text-sm leading-6 text-muted-foreground">
                    Payouts for 14 other obtained main badges are unconfirmed. Hub ticket
                    synchronization is being investigated.
                  </p>
                </div>
                <div className="space-y-5 text-sm leading-6 text-muted-foreground">
                  <div>
                    <h3 className="mb-1 font-medium text-foreground">Automation controls</h3>
                    <p>
                      Start, pause, resume, stop, status reporting and cleanup of its own handlers.
                      Some game transitions still require an external launch.
                    </p>
                  </div>
                  <div>
                    <h3 className="mb-1 font-medium text-foreground">
                      Dandy’s World · experimental
                    </h3>
                    <p>Not included in the cluster. Run unfinished; no badge or UGC obtained.</p>
                  </div>
                  <p>TDS was skipped. Extra quests and reward delivery remain unfinished.</p>
                </div>
              </div>
            )}
          </motion.div>
        </AnimatePresence>
      </div>
      <p className="mt-8 border-t border-foreground/10 pt-4 text-xs text-muted-foreground">
        Preview results supplied by the TZAR team.
      </p>
    </section>
  )
}
