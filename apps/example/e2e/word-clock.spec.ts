import { expect, type Locator, test } from '@playwright/test'

type FitMetrics = {
  clientHeight: number
  fontSize: number
  scrollHeight: number
}

const fitTolerance = 1
const fontSizeTolerance = 0.5
const minimumFittedFontSize = 20

test.use({
  deviceScaleFactor: 2,
  viewport: {
    height: 916,
    width: 570,
  },
})

const getFitMetrics = async (locator: Locator) =>
  locator.evaluate((element: HTMLElement): FitMetrics => {
    return {
      clientHeight: element.clientHeight,
      fontSize: Number.parseFloat(getComputedStyle(element).fontSize),
      scrollHeight: element.scrollHeight,
    }
  })

const expectToFit = async (locator: Locator) => {
  await expect
    .poll(async () => {
      const { clientHeight, scrollHeight } = await getFitMetrics(locator)
      return scrollHeight - clientHeight
    })
    .toBeLessThanOrEqual(fitTolerance)
}

const expectFontSizeGreaterThan = async (locator: Locator, fontSize: number) => {
  await expect
    .poll(async () => {
      const { fontSize } = await getFitMetrics(locator)
      return fontSize
    })
    .toBeGreaterThan(fontSize)
}

const expectFontSizeLessThan = async (locator: Locator, fontSize: number) => {
  await expect
    .poll(async () => {
      const { fontSize } = await getFitMetrics(locator)
      return fontSize
    })
    .toBeLessThan(fontSize)
}

test('word clock refits when its container width changes', async ({ page }) => {
  await page.goto('/')

  const frame = page.getByTestId('word-clock-frame')
  const words = page.getByTestId('word-clock-words')

  await expectFontSizeGreaterThan(words, minimumFittedFontSize)
  await expectToFit(words)
  const initialMetrics = await getFitMetrics(words)

  await frame.evaluate((element: HTMLElement) => {
    element.style.width = '320px'
  })

  await expectFontSizeLessThan(words, initialMetrics.fontSize - fontSizeTolerance)
  await expectToFit(words)
  const narrowMetrics = await getFitMetrics(words)

  await frame.evaluate((element: HTMLElement) => {
    element.style.width = '100%'
  })

  await expectFontSizeGreaterThan(words, narrowMetrics.fontSize + fontSizeTolerance)
  await expectToFit(words)
})

test('word clock loads the selected word file', async ({ page }) => {
  await page.goto('/')

  const languageSelect = page.getByLabel('Select language and style:')
  const words = page.getByTestId('word-clock-words')

  await languageSelect.selectOption('French_simple_fragmented.json')

  await expect(languageSelect).toHaveValue('French_simple_fragmented.json')
  await expect(page.getByText('Unable to load word file')).toHaveCount(0)
  await expect.poll(async () => words.innerText()).toContain('Zéro')
})
