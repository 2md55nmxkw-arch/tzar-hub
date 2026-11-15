// What changed for players, newest first. The home page shows the first three entries.
export type ChangelogEntry = {
  date: string // YYYY-MM-DD
  title: string
  tag?: string
  items: string[]
}

export const changelog: ChangelogEntry[] = [
  {
    date: '2026-11-15',
    title: 'Keyless and open source',
    tag: 'Cmdr Panel preview',
    items: [
      'No more keys, checkpoints, paid plans or accounts. Every script just runs.',
      'A first look at the Cmdr Panel, still in development: a command bar on ;, key binds, panels and game modules in one place.',
      'The whole hub is readable on the new Source page, file by file.',
      'Old key and pricing links still work and lead to the guide or the home page.',
    ],
  },
  {
    date: '2026-11-12',
    title: 'Accessories stay on with game rules',
    tag: 'Avatar Changer',
    items: ['Turning on Game rules no longer drops the accessories of the look you wear.'],
  },
  {
    date: '2026-11-01',
    title: 'Docs and the TZAR Hub name',
    items: [
      'Quick start, a full Avatar Changer guide, executors, FAQ, privacy policy and terms.',
      'The site is now TZAR Hub.',
      'The published Avatar Changer script is leaner, with comments removed.',
    ],
  },
  {
    date: '2026-11-01',
    title: 'Avatar Changer is out',
    tag: 'Avatar Changer',
    items: [
      'Wear any player’s avatar by username or any look from the Roblox catalog.',
      'R6 and R15, game rules, saved outfits and a custom emote wheel. Only you see it.',
    ],
  },
  {
    date: '2026-10-21',
    title: 'Meet Teto',
    items: [
      'An animated Teto helps you find the guide and the community.',
      'The red TZAR look with the flame background.',
    ],
  },
  {
    date: '2026-10-18',
    title: 'The new TZAR site',
    items: ['A fresh site with one loader for every supported game.'],
  },
]

export function formatDate(date: string) {
  return new Date(`${date}T12:00:00Z`).toLocaleDateString('en-US', {
    month: 'long',
    day: 'numeric',
    year: 'numeric',
    timeZone: 'UTC',
  })
}
