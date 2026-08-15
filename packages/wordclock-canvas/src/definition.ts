import { compile } from './compile'
import type {
  Definition,
  Direction,
  TimeField,
  TimeProps,
  Word,
  WordGroup,
  WordsJson,
} from './types'

const RTL_LANGUAGES = new Set(['ar', 'he', 'fa', 'ur'])

/**
 * No token in the bundled corpus mixes scripts — every one is uniformly LTR or
 * RTL — so direction is a per-file property and the full Unicode bidirectional
 * algorithm is not needed. Mixed-direction tokens would change that.
 */
const directionForLanguage = (language: string): Direction =>
  RTL_LANGUAGES.has(language) ? 'rtl' : 'ltr'

export function parseWords(json: WordsJson): Definition {
  const groups: WordGroup[] = []
  const words: Word[] = []
  const fields = new Set<TimeField>()

  json.groups.forEach((group, groupIndex) => {
    const groupWords: Word[] = []

    const push = (text: string, logic: string) => {
      const compiled = compile(logic)
      compiled.fields.forEach((field) => fields.add(field))
      const word: Word = {
        index: words.length,
        text,
        logic,
        isSpace: text.length === 0,
        groupIndex,
        indexInGroup: groupWords.length,
        evaluate: compiled.evaluate,
        width: 0,
      }
      groupWords.push(word)
      words.push(word)
    }

    group.forEach((entry) => {
      if (entry.type === 'item') {
        entry.items.forEach((item) => push(item.text ?? '', item.highlight))
      } else if (entry.type === 'sequence') {
        entry.text.forEach((text, index) => push(text, `${entry.bind}==${entry.first + index}`))
      } else {
        for (let i = 0; i < entry.count; i++) {
          push('', '')
        }
      }
    })

    groups.push({ index: groupIndex, words: groupWords })
  })

  return {
    meta: json.meta,
    groups,
    words,
    fields,
    direction: directionForLanguage(json.meta?.language ?? 'en'),
    granularity: fields.has('second') ? 'second' : 'minute',
    referenceSize: 0,
    spaceWidth: 0,
    ascent: 0,
    descent: 0,
    emHeight: 0,
  }
}

export function getTimeProps(date: Date = new Date()): TimeProps {
  const day = date.getDay()
  return {
    day,
    daystartingmonday: (day + 6) % 7,
    date: date.getDate(),
    month: date.getMonth(),
    hour: date.getHours() % 12,
    twentyfourhour: date.getHours(),
    minute: date.getMinutes(),
    second: date.getSeconds(),
  }
}

/**
 * Evaluates every word for a given time. At most one word per group is
 * highlighted — the first match wins, matching the existing behaviour.
 */
export function resolve(definition: Definition, time: TimeProps, out?: Uint8Array): Uint8Array {
  const mask = out ?? new Uint8Array(definition.words.length)
  mask.fill(0)
  for (const group of definition.groups) {
    for (const word of group.words) {
      if (word.isSpace) {
        continue
      }
      if (word.evaluate(time)) {
        mask[word.index] = 1
        break
      }
    }
  }
  return mask
}

/**
 * Milliseconds until the definition could next change, so callers can schedule
 * a tick rather than poll. Files that never mention `second` change at most
 * once a minute.
 */
export function millisecondsUntilNextChange(
  definition: Definition,
  date: Date = new Date(),
): number {
  if (definition.granularity === 'second') {
    return 1000 - date.getMilliseconds()
  }
  return (60 - date.getSeconds()) * 1000 - date.getMilliseconds()
}
