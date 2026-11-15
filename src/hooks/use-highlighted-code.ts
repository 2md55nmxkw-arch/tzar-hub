import * as React from 'react'

import { loadHighlighter } from '@/lib/highlighter'

type Highlighter = NonNullable<Awaited<ReturnType<typeof loadHighlighter>>>
type GrammarState = Parameters<Highlighter['highlight']>[1]

// Complete lines are tokenized once and kept in state; only the line that is
// still being written gets re-tokenized, starting from the last grammar state.
type Cache = {
  highlighter: Highlighter | null
  text: string
  lines: React.ReactNode[][]
  state: GrammarState
}

const empty: Cache = { highlighter: null, text: '', lines: [], state: undefined }

export function useHighlightedCode(value: string, language: string) {
  // A trailing newline would render as an extra empty line.
  const code = value.endsWith('\n') ? value.slice(0, -1) : value
  const [loaded, setLoaded] = React.useState<{
    language: string
    highlighter: Awaited<ReturnType<typeof loadHighlighter>>
  } | null>(null)
  const highlighter = loaded?.language === language ? loaded.highlighter : null

  React.useEffect(() => {
    let cancelled = false

    loadHighlighter(language)
      .then((next) => {
        if (!cancelled) {
          setLoaded({ language, highlighter: next })
        }
      })
      .catch((error) => {
        // An unknown or failed grammar still renders as plain text, but it
        // should not fail silently.
        console.warn(`No syntax highlighting for "${language}"`, error)
      })

    return () => {
      cancelled = true
    }
  }, [language])

  const [done, setDone] = React.useState<Cache>(empty)
  let next = done

  // Reset when the highlighter or the code itself changed.
  if (next.highlighter !== highlighter || !code.startsWith(next.text)) {
    next = { highlighter, text: '', lines: [], state: undefined }
  }

  const end = code.lastIndexOf('\n') + 1

  if (highlighter && end > next.text.length) {
    const result = highlighter.highlight(code.slice(next.text.length, end - 1), next.state)

    next = {
      highlighter,
      text: code.slice(0, end),
      lines: [...next.lines, ...result.lines],
      state: result.state,
    }
  }

  if (next !== done) {
    setDone(next)
  }

  // The last line is still being written, so it is tokenized on every render.
  const tail = code.slice(end)

  return React.useMemo(() => {
    if (!highlighter) {
      return code.split('\n')
    }

    return [...next.lines, highlighter.highlight(tail, next.state).lines[0]]
  }, [code, highlighter, next, tail])
}
