import { Link } from 'react-router-dom'
import { ArrowRight } from 'lucide-react'
import { changelog, formatDate, type ChangelogEntry } from './changelog-data'
import { Eyebrow } from './eyebrow'
import { Reveal, WordsReveal } from './reveal'

export function ChangelogEntryView({
  entry,
  headingLevel = 'h3',
}: {
  entry: ChangelogEntry
  headingLevel?: 'h2' | 'h3'
}) {
  const Heading = headingLevel
  return (
    <article className="grid gap-2 py-6 sm:grid-cols-[170px_minmax(0,1fr)] sm:gap-8">
      <time dateTime={entry.date} className="font-mono text-xs text-muted-foreground sm:pt-1.5">
        {formatDate(entry.date)}
      </time>
      <div>
        <Heading className="flex flex-wrap items-center gap-x-3 gap-y-1 text-lg font-medium tracking-tight">
          {entry.title}
          {entry.tag && (
            <span className="rounded-full border border-foreground/15 px-2.5 py-0.5 text-xs font-normal text-muted-foreground">
              {entry.tag}
            </span>
          )}
        </Heading>
        <ul className="mt-2 list-disc space-y-1 pl-5 text-sm leading-6 text-muted-foreground marker:text-foreground/30">
          {entry.items.map((item) => (
            <li key={item}>{item}</li>
          ))}
        </ul>
      </div>
    </article>
  )
}

// The home page slot: the latest three entries and a link to the full history.
export function ChangelogSection() {
  return (
    <section className="flex w-full flex-col items-center px-5">
      <div className="flex flex-col items-center gap-3 text-center">
        <Eyebrow>Changelog</Eyebrow>
        <WordsReveal
          text="What’s new"
          className="text-[28px] font-semibold leading-[28px] tracking-tighter md:text-[38px] md:leading-[38px]"
        />
      </div>
      <Reveal delay={120} className="mt-8 w-full max-w-[896px]">
        <div className="divide-y divide-foreground/10 border-y border-foreground/10">
          {changelog.slice(0, 3).map((entry) => (
            <ChangelogEntryView key={entry.date + entry.title} entry={entry} />
          ))}
        </div>
      </Reveal>
      <Reveal delay={200}>
        <Link
          to="/changelog"
          className="group mt-8 flex items-center gap-1 text-sm font-semibold transition-opacity hover:opacity-70"
        >
          Full changelog
          <ArrowRight className="size-3.5 transition-transform group-hover:translate-x-[3px]" />
        </Link>
      </Reveal>
    </section>
  )
}

export function ChangelogList() {
  return (
    <div className="max-w-[896px] divide-y divide-foreground/10 border-y border-foreground/10">
      {changelog.map((entry) => (
        <ChangelogEntryView key={entry.date + entry.title} entry={entry} headingLevel="h2" />
      ))}
    </div>
  )
}
