import { expect, type Locator, test } from '@playwright/test'

type CanvasMetrics = {
  backingHeight: number
  backingWidth: number
  clientHeight: number
  clientWidth: number
}

test.use({
  deviceScaleFactor: 2,
  viewport: {
    height: 916,
    width: 570,
  },
})

const getCanvasMetrics = async (locator: Locator) =>
  locator.evaluate((canvas: HTMLCanvasElement): CanvasMetrics => ({
    backingHeight: canvas.height,
    backingWidth: canvas.width,
    clientHeight: canvas.clientHeight,
    clientWidth: canvas.clientWidth,
  }))

test('word clock resizes its canvas with its container and device pixel ratio', async ({
  page,
}) => {
  await page.goto('/')

  const frame = page.getByTestId('word-clock-frame')
  const canvas = page.getByTestId('word-clock-words').locator('canvas')

  await expect
    .poll(async () => {
      const metrics = await getCanvasMetrics(canvas)
      return metrics.backingWidth / metrics.clientWidth
    })
    .toBe(2)
  const initial = await getCanvasMetrics(canvas)

  await frame.evaluate((element: HTMLElement) => {
    element.style.width = '320px'
  })
  await expect
    .poll(async () => (await getCanvasMetrics(canvas)).backingWidth)
    .toBeLessThan(initial.backingWidth)

  await frame.evaluate((element: HTMLElement) => {
    element.style.width = '100%'
  })
  await expect.poll(async () => (await getCanvasMetrics(canvas)).backingWidth).toBeGreaterThan(640)
})

test('word clock loads the selected word file', async ({ page }) => {
  await page.goto('/')

  const languageSelect = page.getByLabel('Select language and style:')
  const words = page.getByTestId('word-clock-words')

  await languageSelect.selectOption('French_simple_fragmented.json')

  await expect(languageSelect).toHaveValue('French_simple_fragmented.json')
  await expect(page.getByText('Unable to load word file')).toHaveCount(0)
  await expect(words).toHaveAttribute('data-word-clock-language', 'fr')
  await expect(words).toHaveAttribute(
    'data-word-clock-title',
    '(Fragmented) Trois heures, quatre minutes, une second',
  )
  await expect(words.getByRole('timer')).not.toHaveText('')
})
