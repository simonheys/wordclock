import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'WordClock Example',
  description: 'Next.js example app for exercising @simonheys/wordclock.',
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-background text-foreground antialiased">{children}</body>
    </html>
  )
}
