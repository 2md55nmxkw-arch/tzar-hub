import { Component, type ErrorInfo, type ReactNode } from 'react'

type Props = { children: ReactNode }
type State = { error: Error | null }

// Keeps a single broken section from blanking the whole page.
export class ErrorBoundary extends Component<Props, State> {
  state: State = { error: null }

  static getDerivedStateFromError(error: Error): State {
    return { error }
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    console.error('Unhandled render error', error, info.componentStack)
  }

  render() {
    const { error } = this.state

    if (!error) {
      return this.props.children
    }

    return (
      <main className="grid min-h-svh place-items-center px-5">
        <div className="flex max-w-md flex-col items-center gap-4 text-center">
          <p className="text-muted-foreground text-[10px] uppercase tracking-[0.2em]">TZAR Hub</p>
          <h1 className="text-2xl font-semibold tracking-tighter">Something broke</h1>
          <p className="text-muted-foreground text-sm leading-6">
            The page failed to render. Reloading usually fixes it — if it keeps happening, tell us
            on Discord.
          </p>
          <button
            type="button"
            onClick={() => window.location.reload()}
            className="bg-foreground text-background rounded-xl px-5 py-3 text-sm font-medium"
          >
            Reload the page
          </button>
        </div>
      </main>
    )
  }
}
