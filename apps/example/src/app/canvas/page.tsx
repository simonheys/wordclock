import type { Metadata } from 'next'
import Link from 'next/link'

import { CanvasPlayground } from './_components/CanvasPlayground'

export const metadata: Metadata = {
  title: 'WordClock Canvas Playground',
  description: 'Interactive layout, transition, RTL, fitting, and performance playground.',
}

export default function CanvasPage() {
  return (
    <main className="mx-auto flex min-h-screen max-w-[1600px] flex-col gap-6 p-4 sm:p-6 lg:p-8">
      <header className="flex flex-col gap-2">
        <Link className="w-fit text-sm underline underline-offset-4" href="/">
          ← React example
        </Link>
        <div>
          <p className="text-xs font-semibold tracking-[0.18em] text-slate-500 uppercase dark:text-slate-400">
            @wordclock/canvas
          </p>
          <h1 className="text-3xl font-semibold tracking-tight">Canvas playground</h1>
          <p className="mt-2 max-w-3xl text-sm leading-6 text-slate-600 dark:text-slate-300">
            Exercise rotary transitions, Arabic RTL, viewport fitting, and the allocation-free
            coordinate path in a real browser canvas. The uncapped render loop follows the
            display&apos;s native requestAnimationFrame cadence.
          </p>
        </div>
      </header>
      <CanvasPlayground />
    </main>
  )
}
