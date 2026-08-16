import { expect, test } from '@playwright/test'

test('canvas playground exercises Arabic rotary fitting and layout transitions', async ({
  page,
}) => {
  const pageErrors: Error[] = []
  page.on('pageerror', (error) => pageErrors.push(error))

  await page.goto('/canvas')

  const canvas = page.getByTestId('canvas-clock')
  const stats = page.getByTestId('canvas-stats')
  await expect(canvas).toBeVisible()
  await expect.poll(async () => stats.textContent()).toContain('fps')

  const backingSize = await canvas.evaluate((element: HTMLCanvasElement) => ({
    height: element.height,
    width: element.width,
  }))
  expect(backingSize.width).toBeGreaterThan(0)
  expect(backingSize.height).toBeGreaterThan(0)

  await page.getByRole('button', { name: 'Show longest real phrase' }).click()
  await expect(page.getByLabel('Show phrase bounds')).toBeChecked()
  await expect(page.getByTestId('resolved-phrase')).toContainText('seconds')
  await expect(page.getByText('Type divisor', { exact: true })).toHaveCount(0)

  await page.getByLabel('Language').selectOption('Arabic')
  await page.getByLabel('Rotary fit').selectOption('phrase-wheel-centred')
  await page.getByLabel('Viewport').selectOption('portrait')
  await page.getByLabel('Show reading guides').check()

  await expect.poll(async () => stats.textContent()).toContain('305 slots')
  await page.getByRole('button', { name: 'linear' }).click()
  await expect(page.getByRole('button', { name: 'linear' })).toHaveAttribute('aria-pressed', 'true')
  await page.getByRole('button', { name: 'rotary' }).click()
  await expect(page.getByRole('button', { name: 'rotary' })).toHaveAttribute('aria-pressed', 'true')

  expect(pageErrors).toEqual([])
})
