import { TZAR_DISCORD } from './tzar-content'

export const items = [
  { label: 'Docs', note: '[Setup guide]', href: '/docs', internal: true },
  { label: 'Scripts', note: '[Supported games]', href: '/components', internal: true },
  { label: 'Cmdr Panel', note: '[In development]', href: '/docs/cmdr-panel', internal: true },
  { label: 'Modules', note: '[For authors]', href: '/docs/modules', internal: true },
  { label: 'Changelog', note: '[What’s new]', href: '/changelog', internal: true },
  { label: 'Source', note: '[All the code]', href: '/source', internal: true },
  { label: 'Discord', note: '[Help & community]', href: TZAR_DISCORD, internal: false },
  { label: 'Toggle theme', note: '[dark / light]', href: '#theme', internal: false },
]
