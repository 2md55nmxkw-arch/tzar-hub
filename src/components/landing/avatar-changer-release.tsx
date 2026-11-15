import { ArrowUpRight, Bookmark, EyeOff, Layers, Search, Smile, UserRound } from 'lucide-react'
import { Eyebrow } from './eyebrow'

const features = [
  {
    icon: UserRound,
    title: 'Any avatar by username',
    text: 'Type a username and wear that player’s avatar, or copy anyone in your server.',
  },
  {
    icon: Search,
    title: 'Roblox catalog search',
    text: 'Find bundles and looks in the catalog and put them on in one click.',
  },
  {
    icon: Smile,
    title: 'Custom emote wheel',
    text: 'Add any emote from the catalog, search the wheel and preview a dance before playing it.',
  },
  {
    icon: Layers,
    title: 'Works like the original',
    text: 'R6 in R6 games, R15 in R15 games. Game scale and accessory rules are respected.',
  },
  {
    icon: Bookmark,
    title: 'Saved outfits',
    text: 'Keep your favorite looks and export any of them to autoexec to load on join.',
  },
  {
    icon: EyeOff,
    title: 'Only you see it',
    text: 'Everything is visual and local to your client. Your real avatar stays untouched.',
  },
]

const guides = [
  ['Wear any avatar', 'https://youtube.com/shorts/ze1e3YbN0XE'],
  ['Find looks in the catalog', 'https://youtube.com/shorts/16tsVg2Pymw'],
  ['Play any emote', 'https://youtube.com/shorts/78vhN_wQnyI'],
] as const

export function AvatarChangerRelease() {
  return (
    <section aria-label="Avatar Changer details" className="mt-14 max-w-4xl">
      <div className="flex flex-wrap items-end justify-between gap-5">
        <div>
          <Eyebrow className="mb-2">Inside the script</Eyebrow>
          <h2 className="text-3xl font-medium tracking-tight sm:text-4xl">One script. Any skin.</h2>
        </div>
        <p className="text-sm text-muted-foreground">Any game. No key. Just play.</p>
      </div>
      <div className="mt-8 aspect-video overflow-hidden rounded-2xl bg-muted">
        <iframe
          className="size-full"
          src="https://www.youtube-nocookie.com/embed/fzBt14vDAmU"
          title="Avatar Changer trailer"
          loading="lazy"
          allow="accelerometer; encrypted-media; gyroscope; picture-in-picture; fullscreen"
          referrerPolicy="strict-origin-when-cross-origin"
        />
      </div>
      <ul className="mt-10 grid gap-x-10 sm:grid-cols-2">
        {features.map(({ icon: Icon, title, text }) => (
          <li key={title} className="flex gap-3 border-b border-foreground/10 py-5">
            <Icon aria-hidden="true" className="mt-1 size-4 shrink-0 text-primary" />
            <div>
              <h3 className="text-sm font-medium">{title}</h3>
              <p className="mt-1 text-xs leading-5 text-muted-foreground">{text}</p>
            </div>
          </li>
        ))}
      </ul>
      <div className="mt-10">
        <h3 className="text-sm font-medium">15-second guides</h3>
        <div className="mt-4 flex flex-wrap gap-3">
          {guides.map(([label, href]) => (
            <a
              key={href}
              href={href}
              target="_blank"
              rel="noreferrer"
              className="inline-flex min-h-11 items-center gap-2 rounded-xl border px-4 text-sm transition-colors hover:bg-muted"
            >
              {label} <ArrowUpRight aria-hidden="true" className="size-4 shrink-0" />
            </a>
          ))}
        </div>
      </div>
      <p className="mt-8 border-t border-foreground/10 pt-4 text-xs text-muted-foreground">
        RightShift shows or hides the window. Available in six languages.
      </p>
    </section>
  )
}
