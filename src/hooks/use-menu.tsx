import { createContext, useContext, useState, type ReactNode } from 'react'

type MenuCtx = { open: boolean; setOpen: (v: boolean) => void }
const Ctx = createContext<MenuCtx | null>(null)

export function MenuProvider({ children }: { children: ReactNode }) {
  const [open, setOpen] = useState(false)
  return <Ctx.Provider value={{ open, setOpen }}>{children}</Ctx.Provider>
}

export function useMenu() {
  const ctx = useContext(Ctx)
  if (!ctx) throw new Error('useMenu must be used within MenuProvider')
  return ctx
}
