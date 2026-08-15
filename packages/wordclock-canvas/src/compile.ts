import { TIME_FIELDS, type TimeField, type TimeProps } from './types'

/**
 * Highlight expressions are a small language: comparison, modulo, boolean
 * operators, parentheses, integers, and the time fields. Compiling once to a
 * closure tree beats re-interpreting the string on every tick — a word file has
 * a few hundred expressions and they are all re-evaluated whenever the clock
 * advances.
 */

type Evaluate = (time: TimeProps) => number | boolean

const PRECEDENCE: Record<string, number> = {
  '||': 1,
  '&&': 2,
  '==': 3,
  '===': 3,
  '!=': 3,
  '!==': 3,
  '<': 4,
  '>': 4,
  '<=': 4,
  '>=': 4,
  '+': 5,
  '-': 5,
  '*': 6,
  '/': 6,
  '%': 6,
}

const BINARY: Record<string, (a: Evaluate, b: Evaluate) => Evaluate> = {
  '||': (a, b) => (t) => Boolean(a(t)) || Boolean(b(t)),
  '&&': (a, b) => (t) => Boolean(a(t)) && Boolean(b(t)),
  '==': (a, b) => (t) => a(t) === b(t),
  '===': (a, b) => (t) => a(t) === b(t),
  '!=': (a, b) => (t) => a(t) !== b(t),
  '!==': (a, b) => (t) => a(t) !== b(t),
  '<': (a, b) => (t) => Number(a(t)) < Number(b(t)),
  '>': (a, b) => (t) => Number(a(t)) > Number(b(t)),
  '<=': (a, b) => (t) => Number(a(t)) <= Number(b(t)),
  '>=': (a, b) => (t) => Number(a(t)) >= Number(b(t)),
  '+': (a, b) => (t) => Number(a(t)) + Number(b(t)),
  '-': (a, b) => (t) => Number(a(t)) - Number(b(t)),
  '*': (a, b) => (t) => Number(a(t)) * Number(b(t)),
  '/': (a, b) => (t) => Number(a(t)) / Number(b(t)),
  '%': (a, b) => (t) => Number(a(t)) % Number(b(t)),
}

const TOKEN = /\s*(===|!==|==|!=|>=|<=|&&|\|\||[<>%*/+\-()!]|\d+|[A-Za-z_][A-Za-z0-9_]*)/y

const isTimeField = (token: string): token is TimeField =>
  (TIME_FIELDS as readonly string[]).includes(token)

export interface Compiled {
  evaluate: (time: TimeProps) => boolean
  /** Time fields the expression reads, used to pick a tick interval. */
  fields: Set<TimeField>
}

const ALWAYS_FALSE = () => false

export function compile(source: string): Compiled {
  const fields = new Set<TimeField>()

  if (!source.trim()) {
    return { evaluate: ALWAYS_FALSE, fields }
  }

  const tokens: string[] = []
  TOKEN.lastIndex = 0
  while (TOKEN.lastIndex < source.length) {
    const start = TOKEN.lastIndex
    const match = TOKEN.exec(source)
    if (match === null) {
      if (source.slice(start).trim() === '') {
        break
      }
      throw new SyntaxError(`Unexpected token at position ${start} in "${source}"`)
    }
    const token = match[1]
    if (token !== undefined) {
      tokens.push(token)
    }
  }

  let position = 0

  const parsePrimary = (): Evaluate => {
    const token = tokens[position]
    position += 1

    if (token === undefined) {
      throw new SyntaxError(`Unexpected end of expression in "${source}"`)
    }

    if (token === '(') {
      const inner = parseBinary(1)
      if (tokens[position] !== ')') {
        throw new SyntaxError(`Unbalanced parenthesis in "${source}"`)
      }
      position += 1
      return inner
    }

    if (token === '!') {
      const operand = parsePrimary()
      return (t) => !operand(t)
    }

    if (token === '-') {
      const operand = parsePrimary()
      return (t) => -Number(operand(t))
    }

    if (/^\d+$/.test(token)) {
      const value = Number.parseInt(token, 10)
      return () => value
    }

    // `else` is the word files' idiom for an unconditional fallback
    if (token === 'true' || token === 'else') {
      return () => true
    }

    if (token === 'false') {
      return () => false
    }

    if (isTimeField(token)) {
      fields.add(token)
      return (t) => t[token]
    }

    throw new SyntaxError(`Unknown identifier "${token}" in "${source}"`)
  }

  const parseBinary = (minimumPrecedence: number): Evaluate => {
    let left = parsePrimary()
    for (;;) {
      const operator = tokens[position]
      if (operator === undefined) {
        break
      }
      const precedence = PRECEDENCE[operator]
      if (precedence === undefined || precedence < minimumPrecedence) {
        break
      }
      const combine = BINARY[operator]
      if (combine === undefined) {
        break
      }
      position += 1
      left = combine(left, parseBinary(precedence + 1))
    }
    return left
  }

  const parsed = parseBinary(1)

  if (position !== tokens.length) {
    throw new SyntaxError(`Unexpected token "${tokens[position] ?? ''}" in "${source}"`)
  }

  return { evaluate: (time) => Boolean(parsed(time)), fields }
}
