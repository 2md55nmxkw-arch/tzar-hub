import {
  CommandDialog,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
  CommandSeparator,
} from '@/components/ui/command'
import { items } from './nav-data'

type Props = {
  open: boolean
  onOpenChange: (open: boolean) => void
  onCloseAutoFocus: (event: Event) => void
  /** The pause-animations switch; null when the OS already reduces motion. */
  motion: { paused: boolean; toggle: () => void } | null
  dark: boolean
  toggle: () => void
  run: (item: (typeof items)[number]) => void
}

export default function CommandPalette({
  open,
  onOpenChange,
  onCloseAutoFocus,
  motion,
  dark,
  toggle,
  run,
}: Props) {
  return (
    <CommandDialog
      open={open}
      onOpenChange={onOpenChange}
      onCloseAutoFocus={onCloseAutoFocus}
      className="z-[100]"
      title="Command Palette"
      description="Search for a command to run..."
    >
      <CommandInput placeholder="Type a command or search..." />
      <CommandList>
        <CommandEmpty>No results found.</CommandEmpty>
        <CommandGroup heading="Menu">
          {items.map((item) => (
            <CommandItem key={item.label} onSelect={() => run(item)}>
              {item.label}
              <span className="ml-auto text-xs text-muted-foreground">{item.note}</span>
            </CommandItem>
          ))}
        </CommandGroup>
        <CommandSeparator />
        <CommandGroup heading="Theme">
          <CommandItem
            onSelect={() => {
              toggle()
              onOpenChange(false)
            }}
          >
            {dark ? 'Switch to light theme' : 'Switch to dark theme'}
          </CommandItem>
        </CommandGroup>
        {motion && (
          <CommandGroup heading="Motion">
            <CommandItem
              onSelect={() => {
                motion.toggle()
                onOpenChange(false)
              }}
            >
              {motion.paused ? 'Play animations' : 'Pause animations'}
            </CommandItem>
          </CommandGroup>
        )}
      </CommandList>
    </CommandDialog>
  )
}
