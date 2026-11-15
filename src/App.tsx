import { lazy, Suspense, useEffect, useRef, type ReactNode } from 'react'
import { Navigate, Route, Routes, useLocation, useParams } from 'react-router-dom'
import { Landing } from '@/components/landing/landing'
import { Button } from '@/components/ui/button'
import { Link } from 'react-router-dom'
import { useDocumentTitle } from '@/hooks/use-document-title'
import { MenuProvider } from '@/hooks/use-menu'
import { TopNav } from '@/components/landing/top-nav'
import { ComponentsGrid } from '@/components/landing/components-grid'
import { comps } from '@/components/landing/components-data'
import { SCRIPTS_AVAILABLE, TZAR_SITE } from '@/components/landing/tzar-content'
import { TetoAssistant } from '@/components/landing/teto-assistant'
import { SiteFooter } from '@/components/landing/site-footer'
import {
  AvatarChangerGuide,
  CmdrPanelGuide,
  DocsHome,
  Executors,
  Faq,
  ModulesGuide,
  PrivacyPolicy,
  QuickStart,
  TermsOfService,
} from '@/components/docs/docs'
import { AvatarChangerRelease } from '@/components/landing/avatar-changer-release'
import { ChangelogList } from '@/components/landing/changelog'
import { ArrowLeft, ArrowUpRight } from 'lucide-react'

// The code viewer and its file chunks load only on /source.
const SourcePage = lazy(() => import('@/components/source/source-page'))

function Page({ title, children }: { title: string; children: ReactNode }) {
  useDocumentTitle(title)
  return (
    <MenuProvider>
      <TopNav />
      <main className="mx-auto min-h-svh w-full max-w-6xl px-5 pb-20 pt-28">
        <Link
          to="/"
          className="mb-8 inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground"
        >
          <ArrowLeft aria-hidden="true" className="size-4 shrink-0" /> Back home
        </Link>
        <h1 className="mb-8 text-3xl font-semibold tracking-tight sm:text-5xl">{title}</h1>
        {children}
      </main>
      <SiteFooter />
    </MenuProvider>
  )
}

function ComponentPage() {
  const { slug } = useParams()
  if (!SCRIPTS_AVAILABLE)
    return (
      <Page title="Scripts">
        <ComponentsGrid />
      </Page>
    )
  const component = comps.find((item) => item.slug === slug)
  if (!component) return <NotFound />
  return (
    <Page title={component.name}>
      <p className="mb-6 text-muted-foreground">
        {component.event ?? 'Supported by TZAR'}
        {component.release && <span className="ml-3">{component.release}</span>}
        {component.keyless && <span className="ml-3 text-primary">Keyless · No key required</span>}
      </p>
      <img
        src={component.image}
        alt={component.name}
        className="max-h-[65svh] w-full rounded-2xl bg-muted object-contain"
      />
      {component.description && (
        <p className="mt-6 max-w-2xl text-base leading-7 text-muted-foreground">
          {component.description}
        </p>
      )}
      <div className="mt-6 flex flex-wrap gap-3">
        <a
          className="inline-flex items-center gap-2 rounded-xl bg-foreground px-5 py-3 text-background"
          href={component.gameUrl ?? component.trailer ?? '/components'}
          target="_blank"
          rel="noreferrer"
        >
          {component.gameUrl
            ? `Play ${component.name}`
            : component.trailer
              ? 'Watch the trailer'
              : 'Open supported games on TZAR'}
          <ArrowUpRight aria-hidden="true" className="size-4 shrink-0" />
        </a>
        <Link to="/docs/quick-start" className="rounded-xl border px-5 py-3">
          Get script / setup guide
        </Link>
      </div>
      {component.slug === 'avatar-changer' && <AvatarChangerRelease />}
    </Page>
  )
}

function ScrollToTop() {
  const { pathname } = useLocation()
  const previous = useRef(pathname)
  useEffect(() => {
    window.scrollTo({ top: 0, behavior: 'instant' })
    // Keep the canonical link in sync with the client-side route.
    const canonical = document.querySelector<HTMLLinkElement>('link[rel="canonical"]')
    if (canonical) canonical.href = TZAR_SITE + pathname
    // Client-side navigation doesn't reset focus the way a page load does, so
    // move it to the new page's heading. Lazy routes render their heading
    // after the chunk loads, hence the short retry. Timers, not frames: rAF
    // never fires in a hidden tab.
    if (previous.current === pathname) return
    previous.current = pathname
    // Back/Forward with the menu open: leave focus inside the open dialog.
    if (document.activeElement?.closest('[aria-modal="true"]')) return
    let timer = 0
    let attempts = 0
    const focusHeading = () => {
      const heading = document.querySelector<HTMLElement>('main h1')
      // A closing palette keeps the page aria-hidden for its exit animation;
      // focusing inside a hidden subtree is ignored by some screen readers.
      if (heading && !heading.closest('[aria-hidden="true"]')) {
        heading.tabIndex = -1
        heading.focus({ preventScroll: true })
      } else if (++attempts < 60) {
        timer = window.setTimeout(focusHeading, 50)
      }
    }
    focusHeading()
    return () => clearTimeout(timer)
  }, [pathname])
  return null
}

function NotFound() {
  useDocumentTitle('Page not found')
  return (
    <>
      <main className="grid min-h-svh place-items-center bg-background px-4">
        <div className="flex flex-col items-center gap-4 text-center">
          <h1 className="text-2xl font-semibold tracking-tighter">404</h1>
          <p className="text-muted-foreground text-sm">This page does not exist (yet).</p>
          <Button asChild>
            <Link to="/">Back home</Link>
          </Button>
        </div>
      </main>
      {/* Also carries the pause-animations switch for the global decorations. */}
      <SiteFooter />
    </>
  )
}

export default function App() {
  return (
    <>
      <ScrollToTop />
      <Routes>
        <Route path="/" element={<Landing />} />
        <Route
          path="/components"
          element={
            <Page title="Supported scripts">
              <ComponentsGrid />
            </Page>
          }
        />
        <Route
          path="/changelog"
          element={
            <Page title="Changelog">
              <ChangelogList />
            </Page>
          }
        />
        <Route
          path="/source"
          element={
            <Suspense
              fallback={
                <main className="grid min-h-svh place-items-center text-sm text-muted-foreground">
                  Opening the source…
                </main>
              }
            >
              <SourcePage />
            </Suspense>
          }
        />
        <Route path="/docs" element={<DocsHome />} />
        <Route path="/docs/quick-start" element={<QuickStart />} />
        <Route path="/docs/avatar-changer" element={<AvatarChangerGuide />} />
        <Route path="/docs/cmdr-panel" element={<CmdrPanelGuide />} />
        <Route path="/docs/modules" element={<ModulesGuide />} />
        <Route path="/docs/executors" element={<Executors />} />
        <Route path="/docs/faq" element={<Faq />} />
        <Route path="/docs/privacy-policy" element={<PrivacyPolicy />} />
        <Route path="/docs/terms-of-service" element={<TermsOfService />} />
        <Route path="/v1/:slug" element={<ComponentPage />} />
        {/* The hub is keyless and free: old key, plan and account links land on the guide. */}
        {['/key', '/user', '/login', '/purchase'].map((path) => (
          <Route key={path} path={path} element={<Navigate to="/docs/quick-start" replace />} />
        ))}
        <Route path="/pricing" element={<Navigate to="/" replace />} />
        <Route path="*" element={<NotFound />} />
      </Routes>
      <TetoAssistant />
    </>
  )
}
