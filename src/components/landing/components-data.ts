export type Comp = {
  name: string
  slug: string
  keyless?: boolean
  release?: string
  span?: string
  image: string
  description?: string
  features?: string[]
  gameUrl?: string
  trailer?: string
  event?: string
}

export const comps: Comp[] = [
  {
    name: 'Avatar Changer',
    slug: 'avatar-changer',
    keyless: true,
    release: 'New',
    image: '/tzar/games/avatar-changer.webp',
    description:
      'Wear any player’s avatar by username or any look from the Roblox catalog. R6 and R15, game rules, saved outfits and a custom emote wheel. Visual only — only you see it.',
    features: ['Any avatar by username', 'Roblox catalog search', 'Custom emote wheel'],
    trailer: 'https://youtu.be/fzBt14vDAmU',
    event: 'Universal · any game',
  },
]

// Retained for future releases; these scripts are not in the live catalog.
export const archivedComps: Comp[] = [
  {
    name: 'The Hollow',
    slug: 'the-hollow',
    keyless: true,
    release: 'Preview',
    image: '/tzar/games/the-hollow.webp',
    description:
      '19 automation modules for The Hollow’s main quests. Additional rewards and hub ticket synchronization are still in development.',
    features: [
      'Main quest automation',
      'Start, pause, resume and stop',
      'Live status and handler cleanup',
    ],
    gameUrl: 'https://www.roblox.com/games/116463962153167/The-Hollow',
    event: 'Halloween event',
  },
  { name: 'Sailor Piece', slug: 'sailor-piece', image: '/tzar/games/game-0.webp' },
  {
    name: 'Dive Down',
    slug: 'dive-down',
    span: 'lg:col-span-2',
    image: '/tzar/games/game-1.webp',
  },
  {
    name: 'Volleyball Legends',
    slug: 'volleyball-legends',
    image: '/tzar/games/game-2.webp',
  },
  {
    name: 'Death Ball',
    slug: 'death-ball',
    span: 'lg:col-span-2',
    image: '/tzar/games/game-3.webp',
  },
  { name: 'Evade', slug: 'evade', image: '/tzar/games/game-4.webp' },
  { name: '3008', slug: '3008', image: '/tzar/games/game-5.webp' },
]
