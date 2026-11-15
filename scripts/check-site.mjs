import { chromium } from 'playwright'
import assert from 'node:assert/strict'
import fs from 'node:fs/promises'

const base = process.env.AUDIT_URL || 'http://127.0.0.1:5173'
const output = 'audit-output/site'
await fs.mkdir(output, { recursive: true })
const browser = await chromium.launch()
const errors = []
try {
  const context = await browser.newContext({
    viewport: { width: 1440, height: 1000 },
    permissions: ['clipboard-read', 'clipboard-write'],
  })
  const page = await context.newPage()
  page.on('pageerror', (error) => errors.push(error.message))
  await page.goto(base)
  await page.waitForTimeout(4700)
  assert.equal(await page.locator('main > section').count(), 7)
  assert.equal(
    await page.getByRole('heading', { level: 1 }).innerText(),
    'Un-common scripts for Roblox',
  )
  await page.screenshot({ path: `${output}/hero-desktop.png` })
  await page.getByRole('button', { name: 'Copy TZAR loader' }).click()
  assert.equal(
    await page.evaluate(() => navigator.clipboard.readText()),
    'loadstring(game:HttpGet("https://hub.2md.space/avatar-changer.lua"))()',
  )
  await page.getByRole('button', { name: 'Show Menu' }).click()
  await page.waitForTimeout(400)
  assert(await page.getByRole('dialog', { name: 'Navigation menu' }).isVisible())
  await page.screenshot({ path: `${output}/menu-desktop.png` })
  await page.keyboard.press('Escape')
  assert(
    await page
      .getByRole('button', { name: 'Show Menu' })
      .evaluate((el) => el === document.activeElement),
  )
  await page.keyboard.press('Control+k')
  await page.getByPlaceholder('Type a command or search...').waitFor()
  await page.keyboard.press('Escape')
  for (const width of [320, 375, 768, 1024, 1440]) {
    await page.setViewportSize({ width, height: 900 })
    await page.evaluate(async () => {
      for (let y = 0; y < document.body.scrollHeight; y += 700) {
        window.scrollTo({ top: y, behavior: 'instant' })
        await new Promise((resolve) => setTimeout(resolve, 60))
      }
    })
    await page.waitForTimeout(1200)
    assert.equal(
      await page.evaluate(() => document.documentElement.scrollWidth > innerWidth),
      false,
      `Overflow at ${width}`,
    )
    assert(
      await page.locator('main > section:first-child .font-custom').evaluateAll(
        (rows) =>
          rows.length === 2 &&
          rows.every((el) => {
            const r = el.getBoundingClientRect()
            return r.left >= 0 && r.right <= innerWidth
          }),
      ),
      `Headline at ${width}`,
    )
    assert.equal(
      await page
        .locator('img[src^="/tzar/"]')
        .evaluateAll((images) => images.filter((el) => !el.complete || !el.naturalWidth).length),
      0,
    )
    // The changelog took the script card's place on the home page.
    assert.equal(await page.getByRole('heading', { name: 'What’s new', exact: true }).count(), 1)
    assert.equal(await page.locator('main section time').count(), 3)
    await page.screenshot({ path: `${output}/page-${width}.png`, fullPage: true })
    console.log(`Layout and TZAR assets OK: ${width}`)
  }
  // The hub is keyless and free: nothing on the page sends people to a key, a plan or a payment.
  assert.equal(
    await page
      .locator('a[href="/key"], a[href="/pricing"], a[href="/purchase"], a[href="/user"]')
      .count(),
    0,
  )
  assert.equal(await page.getByText(/premium|get your key|checkpoint ads/i).count(), 0)
  // The animated Teto from the old pricing cards now rests on the open-source card.
  assert.equal(await page.locator('.resting-teto, .resting-teto-video').count(), 1)
  const localRoutes = await page
    .locator('a[href^="/"]')
    .evaluateAll((links) => [...new Set(links.map((el) => el.getAttribute('href')))])
  for (const href of localRoutes) {
    await page.goto(base + href)
    assert.notEqual(await page.getByRole('heading', { level: 1 }).innerText(), '404', href)
  }
  // Retired routes land on a real page instead of a 404.
  for (const href of [
    '/key',
    '/pricing',
    '/purchase',
    '/user',
    '/login',
    '/changelog',
    '/source',
  ]) {
    await page.goto(base + href)
    assert.notEqual(await page.getByRole('heading', { level: 1 }).innerText(), '404', href)
  }
  await page.goto(base)
  await page.setViewportSize({ width: 375, height: 812 })
  await page.waitForTimeout(4700)
  await page.screenshot({ path: `${output}/hero-mobile.png` })
  await page.getByRole('button', { name: 'Show Menu' }).click()
  await page.locator('#navigation-links a[href="/components"]').click()
  assert.equal(new URL(page.url()).pathname, '/components')
  const light = await browser.newContext({
    viewport: { width: 375, height: 812 },
    reducedMotion: 'reduce',
  })
  await light.addInitScript(() => localStorage.setItem('theme', 'light'))
  const lightPage = await light.newPage()
  lightPage.on('pageerror', (error) => errors.push(error.message))
  await lightPage.goto(base)
  assert.equal(await lightPage.locator('video').count(), 0)
  for (const track of await lightPage.locator('.marquee-track').all())
    assert.equal(await track.evaluate((el) => getComputedStyle(el).animationName), 'none')
  await lightPage.screenshot({ path: `${output}/hero-light-reduced.png` })
  assert.deepEqual(errors, [])
  console.log(
    'PASS: seven-section layout, menu, clipboard, palette, keyless copy, retired routes, routes, mobile navigation, light theme, reduced motion; no JS errors',
  )
} finally {
  await browser.close()
}
