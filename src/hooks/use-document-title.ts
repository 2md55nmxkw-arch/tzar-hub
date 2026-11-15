import { useEffect } from 'react'

const HOME_TITLE = 'TZAR Hub — Roblox script hub'

// Every route names itself, so screen readers and tabs never show a stale title
// after client-side navigation. Without a title the home title is used.
export function useDocumentTitle(title?: string) {
  useEffect(() => {
    document.title = title ? `${title} — TZAR Hub` : HOME_TITLE
  }, [title])
}
