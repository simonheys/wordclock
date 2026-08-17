export interface Manifest {
  files: string[]
  languages: Record<string, string>
}

export type { WordsGroup as Group, WordsJson } from '@wordclock/canvas'
