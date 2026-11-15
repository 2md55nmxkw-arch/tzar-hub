import { useDocumentTitle } from '@/hooks/use-document-title'
import { MenuProvider } from '@/hooks/use-menu'
import { TopNav } from '@/components/landing/top-nav'
import { Hero } from '@/components/landing/hero'
import { DevouringDetails, UsedBy } from '@/components/landing/inspiration'
import { ChangelogSection } from '@/components/landing/changelog'
import { CmdrPanel } from '@/components/landing/cmdr-panel'
import { OpenSource } from '@/components/landing/open-source'
import { ProBadgeCTA } from '@/components/landing/footer'
import { SiteFooter } from '@/components/landing/site-footer'

export function Landing() {
  useDocumentTitle()
  return (
    <MenuProvider>
      <div className="fade-top pointer-events-none fixed top-0 z-20 h-60 w-full" />
      <TopNav />
      <main className="flex w-screen flex-col items-center justify-center space-y-24 overflow-hidden md:space-y-32">
        <Hero />
        <CmdrPanel />
        <ChangelogSection />
        <DevouringDetails />
        <UsedBy />
        <OpenSource />
        <ProBadgeCTA />
      </main>
      <SiteFooter />
    </MenuProvider>
  )
}
