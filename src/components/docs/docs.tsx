import { lazy, Suspense, useEffect, useState, type ReactNode } from 'react'
import { Link, NavLink } from 'react-router-dom'
import { ArrowRight } from 'lucide-react'
import { MenuProvider } from '@/hooks/use-menu'
import { useDocumentTitle } from '@/hooks/use-document-title'
import { TopNav } from '@/components/landing/top-nav'
import { DevBadge } from '@/components/landing/eyebrow'
import { SiteFooter } from '@/components/landing/site-footer'
import {
  TZAR_ADMIN_LOADER,
  TZAR_DISCORD,
  TZAR_LOADER,
  TZAR_SITE,
} from '@/components/landing/tzar-content'

// The highlighter ships with the docs pages only.
const LoaderCode = lazy(() => import('@/components/landing/loader-code'))

const UPDATED = 'November 15, 2026'

const pages = [
  { to: '/docs', label: 'Overview', text: 'Where to start and what is covered.' },
  {
    to: '/docs/quick-start',
    label: 'Quick start',
    text: 'Copy the loader and open Avatar Changer in any game.',
  },
  {
    to: '/docs/avatar-changer',
    label: 'Avatar Changer',
    text: 'Every part of the window: avatars, catalog, outfits, emotes and settings.',
  },
  {
    to: '/docs/cmdr-panel',
    label: 'Cmdr Panel',
    text: 'The in-game panel, still in development: command bar, binds, panels and game modules.',
  },
  {
    to: '/docs/modules',
    label: 'Game modules',
    text: 'How modules for one game are built, and how authors get theirs into the panel.',
  },
  {
    to: '/docs/executors',
    label: 'Executors',
    text: 'What your executor needs for the script to run.',
  },
  { to: '/docs/faq', label: 'FAQ', text: 'Short answers to the common questions.' },
  {
    to: '/docs/privacy-policy',
    label: 'Privacy policy',
    text: 'What the site and the script store, and where.',
  },
  {
    to: '/docs/terms-of-service',
    label: 'Terms of service',
    text: 'The rules for using TZAR Hub and its scripts.',
  },
]

function DocsShell({
  title,
  description,
  children,
}: {
  title: string
  description?: string
  children: ReactNode
}) {
  useDocumentTitle(title)
  return (
    <MenuProvider>
      <TopNav />
      <main className="mx-auto min-h-svh w-full max-w-6xl px-5 pb-20 pt-28">
        <div className="grid gap-10 md:grid-cols-[190px_minmax(0,1fr)] md:gap-14">
          <nav aria-label="Documentation" className="md:sticky md:top-28 md:self-start">
            <p className="font-roman mb-3 text-xs uppercase tracking-widest text-foreground/70">
              Docs
            </p>
            <ul className="flex flex-wrap gap-x-5 gap-y-1 md:flex-col md:gap-0.5">
              {pages.map((page) => (
                <li key={page.to}>
                  <NavLink
                    to={page.to}
                    end
                    className={({ isActive }) =>
                      `block rounded-lg py-1.5 text-sm transition-colors md:px-3 ${isActive ? 'text-foreground md:bg-muted' : 'text-muted-foreground hover:text-foreground'}`
                    }
                  >
                    {page.label}
                  </NavLink>
                </li>
              ))}
            </ul>
          </nav>
          <article className="min-w-0 max-w-2xl">
            <h1 className="text-3xl font-semibold tracking-tight sm:text-5xl">{title}</h1>
            {description && (
              <p className="mt-4 text-base leading-7 text-muted-foreground">{description}</p>
            )}
            <div className="mt-10 space-y-12">{children}</div>
          </article>
        </div>
      </main>
      <SiteFooter />
    </MenuProvider>
  )
}

function Section({ title, children }: { title: string; children: ReactNode }) {
  return (
    <section>
      <h2 className="text-xl font-medium tracking-tight">{title}</h2>
      <div className="mt-3 space-y-3 text-sm leading-7 text-muted-foreground [&_strong]:font-medium [&_strong]:text-foreground">
        {children}
      </div>
    </section>
  )
}

function Key({ children }: { children: ReactNode }) {
  return (
    <kbd className="rounded-md border border-foreground/15 bg-muted px-1.5 py-0.5 font-mono text-xs text-foreground">
      {children}
    </kbd>
  )
}

function Next({ to, label }: { to: string; label: string }) {
  return (
    <Link
      to={to}
      className="group inline-flex items-center gap-1 text-sm font-semibold transition-opacity hover:opacity-70"
    >
      {label}
      <ArrowRight className="size-3.5 transition-transform group-hover:translate-x-[3px]" />
    </Link>
  )
}

function Loader({ code = TZAR_LOADER, title }: { code?: string; title?: string }) {
  return (
    <Suspense
      fallback={
        <pre className="mt-3 overflow-x-auto rounded-lg border border-input bg-muted p-3 font-mono text-sm leading-relaxed">
          <code>{code}</code>
        </pre>
      }
    >
      <LoaderCode code={code} title={title} />
    </Suspense>
  )
}

function External({ href, children }: { href: string; children: ReactNode }) {
  return (
    <a className="underline" href={href} target="_blank" rel="noreferrer">
      {children}
    </a>
  )
}

export function DocsHome() {
  return (
    <DocsShell
      title="Documentation"
      description="Everything about TZAR Hub, Avatar Changer and the Cmdr Panel: how to run them, what every button does and what happens to your data."
    >
      <ul className="grid gap-3 sm:grid-cols-2">
        {pages.slice(1).map((page) => (
          <li key={page.to}>
            <Link
              to={page.to}
              className="group flex h-full flex-col rounded-2xl bg-muted p-5 transition-colors hover:bg-muted2"
            >
              <span className="flex items-center justify-between gap-3 font-medium">
                {page.label}
                <ArrowRight className="size-4 shrink-0 text-muted-foreground transition-transform group-hover:translate-x-[3px]" />
              </span>
              <span className="mt-2 text-sm leading-6 text-muted-foreground">{page.text}</span>
            </Link>
          </li>
        ))}
      </ul>
      <Section title="Free, keyless and open source">
        <p>
          Every TZAR Hub script runs without a key, checkpoints, ads or an account. The code of the
          hub is on the{' '}
          <Link className="underline" to="/source">
            Source
          </Link>{' '}
          page: read it, build it and send changes. Game modules written by outside authors are the
          one exception; the TZAR team reviews and publishes them.
        </p>
      </Section>
      <Section title="Need a hand?">
        <p>
          Ask in the <External href={TZAR_DISCORD}>TZAR Hub Discord</External>. Updates and new
          scripts are announced there first.
        </p>
      </Section>
    </DocsShell>
  )
}

export function QuickStart() {
  return (
    <DocsShell
      title="Quick start"
      description="Avatar Changer is free and keyless. It takes three steps and works in any Roblox game."
    >
      <Section title="1. Open your executor">
        <p>
          Start Roblox and your executor. Avatar Changer is built and tested on Potassium. For other
          executors, check{' '}
          <Link className="underline" to="/docs/executors">
            what they need
          </Link>
          .
        </p>
      </Section>
      <Section title="2. Copy the loader">
        <p>Paste this line into your executor:</p>
        <Loader />
        <p>
          The loader always fetches the latest version from {TZAR_SITE.replace('https://', '')}.
        </p>
      </Section>
      <Section title="3. Execute it in any game">
        <p>
          Join any Roblox game and execute. The Avatar Changer window appears on the left. No key,
          no checkpoints.
        </p>
        <p>
          Press <Key>RightShift</Key> to hide or show the window at any time.
        </p>
      </Section>
      <Next to="/docs/avatar-changer" label="Learn every part of the window" />
    </DocsShell>
  )
}

export function AvatarChangerGuide() {
  return (
    <DocsShell
      title="Avatar Changer"
      description="Wear any avatar or catalog look, keep your favorites and play any emote. Your appearance changes only on your screen."
    >
      <Section title="Only you see it">
        <p>
          Avatar Changer rebuilds your character on your own client. Other players keep seeing your
          real avatar, and nothing is bought or added to your inventory.{' '}
          <strong>Emotes are the exception:</strong> animations of your own character replicate, so
          everyone sees you dance.
        </p>
      </Section>
      <Section title="Wear an avatar by username">
        <p>
          On the <strong>Outfit</strong> tab, type a username, display name or user ID into the
          field and press <strong>Wear</strong>. Matching players appear in the side panel as you
          type. <strong>Reset to mine</strong> brings your own look back.
        </p>
      </Section>
      <Section title="Copy a player in your server">
        <p>
          <strong>In this server</strong> lists everyone in your game. Click an avatar to copy how
          that player looks right now. With the same rig the copy is exact, including the game’s own
          morphs and accessories.
        </p>
      </Section>
      <Section title="Search the catalog">
        <p>
          Press <strong>Find</strong>, open <strong>Catalog</strong> and search. Click any look to
          wear it. <strong>Players</strong> searches Roblox users, <strong>Saved</strong> shows your
          own outfits.
        </p>
      </Section>
      <Section title="Saved outfits">
        <p>
          <strong>Save</strong> keeps the look you are wearing under <strong>Outfits</strong>. The
          first tile is always your original avatar. Right-click a tile for more:{' '}
          <strong>Wear</strong>, <strong>Rename</strong>, <strong>Delete</strong>,{' '}
          <strong>As in this server</strong> or <strong>From profile</strong> for players, and{' '}
          <strong>Export to autoexec</strong>.
        </p>
      </Section>
      <Section title="Load an outfit on join">
        <p>
          <strong>Export to autoexec</strong> writes a small script to your executor’s{' '}
          <code>workspace/AvatarExports</code> folder and copies it to the clipboard. Put it into
          your executor’s autoexec folder and the outfit is applied every time you join a game. If
          Avatar Changer is not in your workspace, the script loads it from this site.
        </p>
      </Section>
      <Section title="R6, R15 and game rules">
        <p>
          The look follows your character’s rig: R6 in R6 games, R15 in R15 games. With{' '}
          <strong>Game rules</strong> on, the game’s avatar settings apply too: allowed scales,
          accessory size limits and forced body parts or clothing. Turn it off to see the look
          exactly as on the profile.
        </p>
        <p>
          <strong>Keep on respawn</strong> puts the look back on after you die or reset.
        </p>
      </Section>
      <Section title="Emote wheel">
        <p>
          On the <strong>Emotes</strong> tab, <strong>Add</strong> searches the emote catalog. Click
          a result to play it, right-click to add it to your wheel. The wheel has no slot limit.
        </p>
        <p>
          Press <Key>.</Key> or <strong>Open wheel</strong> to open it, <Key>Q</Key> and{' '}
          <Key>E</Key> to switch pages. Search inside the wheel and hover an emote to preview the
          dance before playing it. Emotes need an R15 character.
        </p>
        <p>
          <strong>From outfit</strong> uses the emotes that come with the worn look,{' '}
          <strong>Custom wheel</strong> uses your own list.
        </p>
      </Section>
      <Section title="Settings">
        <p>
          The gear at the top opens settings: the language (English, Russian, Ukrainian, Spanish,
          Portuguese, German), the intro animation and the Discord notification.
        </p>
      </Section>
      <Next to="/docs/faq" label="Read the FAQ" />
    </DocsShell>
  )
}

export function Executors() {
  return (
    <DocsShell
      title="Executors"
      description="Avatar Changer is built and tested on Potassium. Other executors work if they offer the same functions."
    >
      <Section title="What the script needs">
        <ul className="list-disc space-y-1 pl-5">
          <li>
            <code>loadstring</code> and <code>game:HttpGet</code> to run the loader
          </li>
          <li>
            <code>readfile</code>, <code>writefile</code>, <code>isfile</code> and{' '}
            <code>makefolder</code> for settings and saved outfits
          </li>
          <li>
            <code>getgenv</code>, <code>gethui</code> and <code>getcustomasset</code> for the window
            and its fonts
          </li>
          <li>
            <code>request</code> for catalog and avatar lookups, and <code>sethiddenproperty</code>{' '}
            for accurate body scaling
          </li>
        </ul>
      </Section>
      <Section title="Other executors">
        <p>
          Solara, Fluxus, Delta and Wave are popular choices, but they have not been tested with
          Avatar Changer yet. If something does not work, tell us in the{' '}
          <a className="underline" href={TZAR_DISCORD} target="_blank" rel="noreferrer">
            Discord
          </a>{' '}
          with the executor name and the error from its console.
        </p>
      </Section>
      <Next to="/docs/quick-start" label="Back to the quick start" />
    </DocsShell>
  )
}

const faq = [
  [
    'Will other players see my new avatar?',
    'No. The look changes only on your screen. Emotes are the exception: other players see your character dance.',
  ],
  [
    'Do I get the items?',
    'No. Nothing is bought, gifted or added to your inventory. It is a visual change for you.',
  ],
  [
    'Is it free?',
    'Yes, and it stays that way. Every TZAR Hub script is free and keyless: no key, no checkpoints, no ads, no account.',
  ],
  [
    'Is the code really open?',
    'Yes. Every file of the hub is on the Source page of this site, so you can read exactly what runs in your game. Game modules from outside authors are the exception: they are reviewed and published by the TZAR team.',
  ],
  [
    'I had a TZAR key. Do I still need it?',
    'No. Keys are gone. Run the loader and the script starts right away.',
  ],
  [
    'Why does a look differ from the profile?',
    'Game rules are on: the game limits scales, accessory sizes or body parts. Turn Game rules off to see the profile look.',
  ],
  [
    'Why do emotes not play?',
    'Roblox emotes only work on R15 characters. In R6 games they are disabled.',
  ],
  [
    'Where are my outfits stored?',
    'In your executor’s workspace, in the AvatarChanger folder. Nothing is uploaded.',
  ],
  [
    'Can I get banned?',
    'Executors break the Roblox Terms of Use, and any game can detect them. Use them at your own risk and avoid accounts you cannot lose.',
  ],
] as const

export function Faq() {
  return (
    <DocsShell title="FAQ" description="Short answers to the questions we get most.">
      {faq.map(([question, answer]) => (
        <Section key={question} title={question}>
          <p>{answer}</p>
        </Section>
      ))}
    </DocsShell>
  )
}

export function PrivacyPolicy() {
  return (
    <DocsShell title="Privacy policy" description={`Last updated ${UPDATED}.`}>
      <Section title="The short version">
        <p>
          TZAR Hub has no accounts, no keys, no analytics and no tracking. The site and the scripts
          do not collect anything about you.
        </p>
      </Section>
      <Section title="This website">
        <p>
          The site stores two values in your browser’s local storage: your theme and whether
          animations are paused. They never leave your browser, and clearing site data removes them.
          The site sets no cookies.
        </p>
        <p>
          Our hosting provider may keep standard server logs, such as IP addresses and requested
          pages, to run and protect the service.
        </p>
      </Section>
      <Section title="Third parties">
        <p>
          The Avatar Changer page embeds a YouTube video through youtube-nocookie.com, and links
          lead to YouTube and Discord. These services have their own privacy policies.
        </p>
      </Section>
      <Section title="The scripts">
        <p>
          Avatar Changer and the Cmdr Panel save settings, binds, saved outfits, waypoints and an
          emote cache in your executor’s workspace folder, and exported scripts in{' '}
          <code>AvatarExports</code>. They talk only to Roblox services (avatars, catalog, users and
          assets) and to this site to load themselves and their icons. They do not send your data
          anywhere else, and the public source lets you check that.
        </p>
      </Section>
      <Section title="Contact">
        <p>
          Questions about this policy go to the{' '}
          <a className="underline" href={TZAR_DISCORD} target="_blank" rel="noreferrer">
            TZAR Hub Discord
          </a>
          .
        </p>
      </Section>
    </DocsShell>
  )
}

export function TermsOfService() {
  return (
    <DocsShell title="Terms of service" description={`Last updated ${UPDATED}.`}>
      <Section title="Using TZAR Hub">
        <p>
          By using this site or its scripts you accept these terms. If you do not agree, do not use
          them.
        </p>
      </Section>
      <Section title="Not affiliated with Roblox">
        <p>
          TZAR Hub is an independent project. It is not made, endorsed or supported by Roblox
          Corporation. Roblox is a trademark of Roblox Corporation.
        </p>
      </Section>
      <Section title="Your responsibility">
        <p>
          Running scripts through an executor breaks the Roblox Terms of Use and can lead to
          moderation of your account. You use TZAR Hub scripts at your own risk and are responsible
          for your accounts and devices.
        </p>
        <p>Do not use the scripts to harass other players or to break the rules of a game.</p>
      </Section>
      <Section title="No warranty">
        <p>
          The scripts and the site are provided as is, without any warranty. They may change, break
          after Roblox updates or be removed at any time. We are not liable for any loss caused by
          using them.
        </p>
      </Section>
      <Section title="Free and open source">
        <p>
          TZAR Hub scripts are free and need no key. The source of the hub is published on the{' '}
          <Link className="underline" to="/source">
            Source
          </Link>{' '}
          page and released under the MIT License. The TZAR name and logos, the Teto artwork and
          game images are not covered by it. Game modules from outside authors belong to their
          authors and may come with their own terms.
        </p>
      </Section>
      <Section title="Changes">
        <p>
          We may update these terms. The date at the top shows the latest version. Announcements go
          to the{' '}
          <a className="underline" href={TZAR_DISCORD} target="_blank" rel="noreferrer">
            Discord
          </a>
          .
        </p>
      </Section>
    </DocsShell>
  )
}

type CommandArg = { name: string; kind: string; optional?: boolean; min?: number; max?: number }
type AdminCommand = {
  name: string
  category: string
  aliases: string[] | Record<string, never>
  args: CommandArg[] | Record<string, never>
  description: Record<string, string>
}
type AdminCommands = {
  categories: { id: string; title: Record<string, string> }[]
  commands: AdminCommand[]
}

function argLabel(arg: CommandArg) {
  const inner =
    arg.kind === 'number' && arg.min !== undefined && arg.max !== undefined
      ? `${arg.min}-${arg.max}`
      : arg.name
  return arg.optional ? `[${inner}]` : `<${inner}>`
}

// The list is generated by the admin build (public/tzar-admin-commands.json), so the docs never
// drift from what the panel really has.
function CommandList() {
  const [data, setData] = useState<AdminCommands | null>(null)
  const [failed, setFailed] = useState(false)
  useEffect(() => {
    let live = true
    fetch('/tzar-admin-commands.json')
      .then((response) => (response.ok ? response.json() : Promise.reject(response.status)))
      .then((json: AdminCommands) => live && setData(json))
      .catch(() => live && setFailed(true))
    return () => {
      live = false
    }
  }, [])
  if (failed)
    return (
      <p>
        The list did not load. Type <code>help</code> in the command bar to see every command.
      </p>
    )
  if (!data) return <p>Loading the command list…</p>
  return (
    <div className="space-y-8">
      {data.categories.map((category) => {
        const commands = data.commands.filter((command) => command.category === category.id)
        if (commands.length === 0) return null
        return (
          <div key={category.id}>
            <h3 className="font-medium text-foreground">{category.title.en}</h3>
            <dl className="mt-2 divide-y divide-foreground/10">
              {commands.map((command) => (
                <div key={command.name} className="grid gap-1 py-2.5 sm:grid-cols-[220px_1fr]">
                  <dt className="font-mono text-[13px] text-foreground">
                    {command.name}
                    {Array.isArray(command.args) &&
                      command.args.map((arg) => (
                        <span key={arg.name} className="text-muted-foreground">
                          {' '}
                          {argLabel(arg)}
                        </span>
                      ))}
                  </dt>
                  <dd>
                    {command.description.en}
                    {Array.isArray(command.aliases) && command.aliases.length > 0 && (
                      <span className="block font-mono text-xs">
                        also {command.aliases.join(', ')}
                      </span>
                    )}
                  </dd>
                </div>
              ))}
            </dl>
          </div>
        )
      })}
    </div>
  )
}

export function CmdrPanelGuide() {
  return (
    <DocsShell
      title="Cmdr Panel"
      description="The in-game panel of TZAR Hub: a command bar, key binds, panels and game modules. Free, keyless and open source."
    >
      <div
        role="note"
        className="border-primary/30 bg-primary/5 rounded-2xl border p-5 text-sm leading-6 text-muted-foreground"
      >
        <DevBadge />
        <p className="mt-3">
          The Cmdr Panel is still in development. Commands, keys and modules can change between
          updates, and some things may break. Report what you find in the{' '}
          <External href={TZAR_DISCORD}>Discord</External>. For something stable today, use{' '}
          <Link className="underline" to="/docs/quick-start">
            Avatar Changer
          </Link>
          .
        </p>
      </div>
      <Section title="Run it">
        <p>Paste this line into your executor and execute it in any game:</p>
        <Loader code={TZAR_ADMIN_LOADER} title="tzar-admin.lua" />
        <p>
          A note in the corner says when the panel is ready. Avatar Changer is built in: the{' '}
          <code>avatar</code> command opens it.
        </p>
      </Section>
      <Section title="The command bar">
        <p>
          Press <Key>;</Key> and start typing. Matching commands appear as you type, with their
          arguments. <Key>↑</Key> <Key>↓</Key> select, <Key>Tab</Key> completes, <Key>Enter</Key>{' '}
          runs and <Key>Esc</Key> closes. Players, outfits, waypoints, keys and modules complete
          too, so <code>wear sp</code> finds the player whose name starts with “sp”.
        </p>
        <p>
          With chat commands on in settings, a chat message that starts with <code>;</code> runs as
          a command.
        </p>
      </Section>
      <Section title="Show and hide">
        <p>
          <Key>RightShift</Key> hides and shows everything TZAR draws. <code>togglekey</code>{' '}
          changes that key; without a key it goes back to RightShift. <code>unload</code> turns the
          hub off and undoes everything it changed.
        </p>
      </Section>
      <Section title="Binds">
        <p>
          Put any command line on a key: <code>bind F fly</code>, <code>bind G speed 96</code>.{' '}
          <code>binds</code> lists them and <code>unbind F</code> removes one. Binds are saved and
          come back next time.
        </p>
      </Section>
      <Section title="Game modules">
        <p>
          A game module brings dozens of features for one game, grouped into sections, plus saved
          sets and, for some games, a routine you can start, pause and stop. <code>module</code>{' '}
          opens the module for the game you are in, and <code>preset</code> turns a set on or off.
          Turning a feature off undoes exactly what it changed.
        </p>
        <p>
          Some modules come from outside authors.{' '}
          <Link className="underline" to="/docs/modules">
            Game modules
          </Link>{' '}
          explains how they are made and published.
        </p>
      </Section>
      <Section title="On a phone">
        <p>
          The <strong>T</strong> button opens the command bar. Hold a dock button to adjust its
          value.
        </p>
      </Section>
      <Section title="Every command">
        <CommandList />
      </Section>
      <Section title="Source">
        <p>
          The panel is open source. Every file is on the{' '}
          <Link className="underline" to="/source">
            Source
          </Link>{' '}
          page, with how to build and test it.
        </p>
      </Section>
    </DocsShell>
  )
}

export function ModulesGuide() {
  return (
    <DocsShell
      title="Game modules"
      description="A game module adds features for one game to the Cmdr Panel. This page is the short version; the full guide is in the repository."
    >
      <Section title="Three files">
        <p>
          A module lives in <code>src/games/&lt;id&gt;/</code> and has three files:{' '}
          <strong>Spec.luau</strong> (plain data: sections, features, sets),{' '}
          <strong>Impl.luau</strong> (the Roblox code) and <strong>Strings.luau</strong>{' '}
          (translations). Spec and Strings are read by the build outside Roblox, so they cannot call
          Roblox APIs. The <code>sandbox</code> module is a complete example that works in any
          place.
        </p>
      </Section>
      <Section title="The spec">
        <ul className="list-disc space-y-1 pl-5">
          <li>
            <code>id</code>, the <code>places</code> it runs in (or every place), and a short{' '}
            <code>badge</code>
          </li>
          <li>
            <code>sections</code> in display order; each becomes a tab with an on/total count
          </li>
          <li>
            <code>features</code>: a <code>toggle</code>, a <code>number</code> with{' '}
            <code>min</code>, <code>max</code> and <code>step</code>, or a <code>choice</code>{' '}
            between <code>options</code>. A feature can also drive an existing hub command, such as{' '}
            <code>speed</code>, without any code
          </li>
          <li>
            <code>presets</code>: named sets of values that players turn on with one click, a bind
            or the <code>preset</code> command
          </li>
          <li>
            <code>runner</code>: a routine with start, pause and stop, a status line and a progress
            bar
          </li>
        </ul>
      </Section>
      <Section title="The cleanup rule">
        <p>
          Everything a feature creates or changes goes into its Janitor. Turning the feature off,
          changing its value or unloading the hub undoes it in reverse order, so the game is left as
          it was. A feature that throws stays off and the error appears as a note.
        </p>
      </Section>
      <Section title="Translations">
        <p>
          Every title, section, feature, option and set needs text in all six languages: English,
          Russian, Ukrainian, Spanish, Portuguese and German. The build fails if one is missing.
        </p>
      </Section>
      <Section title="Publishing">
        <p>
          Authors do not upload modules themselves. Send yours to the TZAR team in the{' '}
          <External href={TZAR_DISCORD}>Discord</External>; the owner reviews it and publishes it
          into the panel.
        </p>
        <p>
          Code that an executor runs ends up on the player’s machine. A closed module can be
          obfuscated, but its code cannot be fully hidden.
        </p>
      </Section>
      <Section title="Full guide">
        <p>
          Every field, the Impl interface and how to register a module are in{' '}
          <Link className="underline" to="/source?file=admin/docs/modules.md">
            docs/modules.md
          </Link>{' '}
          on the Source page.
        </p>
      </Section>
    </DocsShell>
  )
}
