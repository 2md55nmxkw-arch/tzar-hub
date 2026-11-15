import { chromium } from 'playwright'
import assert from 'node:assert/strict'

const browser = await chromium.launch()
const errors = []
const base = process.env.AUDIT_URL || 'http://127.0.0.1:5173'
async function selectTheme(page, theme) {
  await page.getByRole('button', { name: 'Command + K', exact: true }).click()
  await page.getByRole('option', { name: `Switch to ${theme} theme`, exact: true }).click()
  await page.waitForFunction(
    (theme) => document.documentElement.classList.contains('dark') === (theme === 'dark'),
    theme,
  )
}
try {
  const page = await browser.newPage()
  page.on('pageerror', (e) => errors.push(e.message))
  await page.addInitScript(() => {
    window.themeTransitionCalls = 0
    const start = document.startViewTransition.bind(document)
    document.startViewTransition = (callback) => {
      window.themeTransitionCalls++
      return (window.lastThemeTransition = start(callback))
    }
  })
  await page.goto(base)
  for (const theme of ['light', 'dark']) {
    await selectTheme(page, theme)
    await page.evaluate(() => window.lastThemeTransition.ready)
    const animation = await page.evaluate(() => {
      const style = getComputedStyle(document.documentElement, '::view-transition-new(root)')
      return { name: style.animationName, duration: style.animationDuration }
    })
    assert.equal(animation.name, 'theme-reveal-bottom-up')
    assert.equal(animation.duration, '0.7s')
    await page.evaluate(() => window.lastThemeTransition.finished)
    assert.equal(await page.evaluate(() => localStorage.getItem('theme')), theme)
    console.log(theme, animation)
  }
  assert.equal(await page.evaluate(() => window.themeTransitionCalls), 2)
  for (const mode of ['fallback', 'reduced']) {
    const context = await browser.newContext(mode === 'reduced' ? { reducedMotion: 'reduce' } : {})
    await context.addInitScript((mode) => {
      if (mode === 'fallback')
        Object.defineProperty(document, 'startViewTransition', { value: undefined })
      else
        document.startViewTransition = () => {
          throw Error('Reduced motion must skip transitions')
        }
    }, mode)
    const check = await context.newPage()
    check.on('pageerror', (e) => errors.push(e.message))
    await check.goto(base)
    await selectTheme(check, 'light')
    console.log(mode, 'OK')
    await context.close()
  }
  assert.deepEqual(errors, [])
  console.log(
    'PASS: both 700ms transitions, preference persistence, fallback, reduced motion; no JS errors',
  )
} finally {
  await browser.close()
}
