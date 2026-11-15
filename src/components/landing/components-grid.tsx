import { Link } from 'react-router-dom'
import { ArrowRight, Plus } from 'lucide-react'
import { Reveal, WordsReveal } from './reveal'
import { cn } from '@/lib/utils'
import { comps } from './components-data'
import { SCRIPTS_AVAILABLE, TZAR_DISCORD } from './tzar-content'

export function ComponentsGrid() {
  return SCRIPTS_AVAILABLE ? <ScriptCatalog /> : <CatalogNotice />
}

function CatalogNotice() {
  return (
    <section
      className="flex min-h-[65svh] w-full flex-col items-center justify-center overflow-hidden px-5"
      aria-label="Script catalog status"
    >
      <div className="flex flex-col items-center gap-2 text-center">
        <WordsReveal
          text="Starting from zero."
          className="max-w-lg px-5 text-[28px] font-semibold leading-[28px] tracking-tighter md:text-[38px] md:leading-[38px]"
        />
        <Reveal delay={120}>
          <p className="max-w-md text-sm leading-relaxed tracking-[-0.16px] text-foreground/60 md:text-[16px] md:leading-[24px]">
            TZAR is being rebuilt from scratch.
            <br />
            No scripts yet. Follow our progress on Discord.
          </p>
        </Reveal>
      </div>
      <Reveal delay={200}>
        <a
          href={TZAR_DISCORD}
          target="_blank"
          rel="noreferrer"
          className="group mt-[34px] flex items-center gap-1 text-sm font-semibold transition-opacity hover:opacity-70"
        >
          Join the community{' '}
          <ArrowRight className="size-3.5 transition-transform group-hover:translate-x-[3px]" />
        </a>
      </Reveal>
    </section>
  )
}

function ScriptCatalog() {
  if (comps.length === 1) {
    const game = comps[0]
    return (
      <section className="flex w-full flex-col items-center px-5" aria-label="Supported scripts">
        <WordsReveal
          text="Any skin. Any game."
          className="max-w-2xl text-center text-[28px] font-semibold leading-tight tracking-tight md:text-[38px]"
        />
        <Reveal className="mt-9 w-full max-w-4xl">
          <article className="grid overflow-hidden rounded-3xl border border-foreground/10 bg-muted md:grid-cols-[1.2fr_1fr]">
            <Link
              to={`/v1/${game.slug}`}
              aria-label={`View ${game.name}`}
              className="group relative block overflow-hidden"
            >
              <img
                src={game.image}
                alt={`${game.name} preview`}
                width={768}
                height={432}
                className="aspect-video h-auto w-full object-cover transition-transform duration-500 group-hover:scale-[1.03] motion-reduce:transform-none md:aspect-auto md:h-full"
                loading="lazy"
              />
              <span className="absolute left-4 top-4 rounded-full bg-background/90 px-3 py-1.5 text-xs font-medium text-primary backdrop-blur-sm">
                {game.event}
              </span>
            </Link>
            <div className="flex flex-col items-start justify-center p-6 sm:p-8">
              <p className="text-xs text-muted-foreground">
                Roblox script
                {game.release && <span> · {game.release}</span>}
                {game.keyless && <span className="text-primary"> · Keyless</span>}
              </p>
              <h2 className="mt-3 text-3xl font-semibold tracking-tight">{game.name}</h2>
              <p className="mt-3 text-sm leading-6 text-muted-foreground">{game.description}</p>
              <Link
                to={`/v1/${game.slug}`}
                className="mt-6 inline-flex min-h-11 items-center gap-6 rounded-xl bg-foreground px-5 text-sm font-medium text-background transition-opacity hover:opacity-80"
              >
                Get script <ArrowRight className="size-4" />
              </Link>
            </div>
          </article>
        </Reveal>
      </section>
    )
  }
  return (
    <section className="flex w-full flex-col items-center overflow-hidden px-5">
      <div className="flex flex-col items-center gap-4">
        <div className="flex flex-col items-center gap-2 text-center">
          <WordsReveal
            text="Outstanding scripts for Roblox"
            className="max-w-2xl px-5 text-[28px] font-semibold leading-[28px] tracking-tighter md:text-[38px] md:leading-[38px]"
          />
          <Reveal delay={120}>
            <p className="text-sm tracking-[-0.16px] md:text-[16px] md:leading-[21px]">
              One loader for your favorite supported games,
              <br />
              copy it and run it with your favorite executor.
            </p>
          </Reveal>
        </div>
      </div>

      <div className="relative mt-[34px] grid w-full max-w-[1130px] grid-cols-1 justify-center gap-[10px] md:auto-rows-[310px] md:grid-cols-2 lg:grid-cols-4">
        {comps.map((c, i) => (
          <Reveal key={c.slug} delay={i * 70} className={cn('min-w-0', c.span)}>
            <div
              className={cn(
                'bg-muted border-muted shadow-glass hover:bg-muted2 group relative flex h-full cursor-pointer flex-col overflow-hidden rounded-[20px] border p-3',
                '',
              )}
            >
              <div className="absolute right-5 top-5 z-[2] flex size-8 justify-end">
                <span
                  className={cn(
                    'r group/icon flex size-6 items-center justify-center transition-colors',
                    [0, 1, 4, 6].includes(i)
                      ? 'bg-[#121212] text-white hover:bg-black'
                      : 'bg-[#f5f4f3] text-black hover:bg-white',
                  )}
                >
                  <Link to={`/v1/${c.slug}`} aria-label={`View ${c.name}`}>
                    <Plus className="size-4 transition-all duration-300 ease-in-out group-hover/icon:scale-115 group-hover/icon:rotate-45" />
                  </Link>
                </span>
              </div>
              <Link
                aria-label={c.name}
                to={`/v1/${c.slug}`}
                className="relative w-full flex-1 overflow-hidden"
              >
                <ComponentPreview image={c.image} />
              </Link>
              <p className="pl-2 pt-2 font-medium">{c.name}</p>
            </div>
          </Reveal>
        ))}
      </div>

      <Reveal delay={200}>
        <Link
          className="group mt-[20px] flex cursor-pointer items-center gap-1 text-sm font-semibold transition-all ease-in-out hover:opacity-70"
          to="/components"
        >
          Explore all scripts <ArrowRight className="size-3.5" />
        </Link>
      </Reveal>
    </section>
  )
}

function ComponentPreview({ image }: { image: string }) {
  return (
    <div className="border-muted4 relative aspect-square h-full w-full overflow-hidden rounded-2xl border md:absolute md:inset-0 md:aspect-auto">
      <img
        className="relative h-full w-full object-cover"
        src={image}
        alt=""
        loading="lazy"
        decoding="async"
      />
    </div>
  )
}
