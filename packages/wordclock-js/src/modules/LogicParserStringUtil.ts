export const OPERATORS = '!%&*()-+=|/<>'

const objectToString = Object.prototype.toString
const isString = (value: unknown): value is string =>
  typeof value === 'string' || objectToString.call(value) === '[object String]'

type BraceTerms = [leftOfBraces: string, insideBraces: string, rightOfBraces: string]
type PivotTerms = [
  beforeLeftTerm: string,
  leftTerm: string,
  rightTerm: string,
  afterRightTerm: string,
]

export const isNumericString = (string: string) => {
  return /^-?\d+$/.test(string)
}

export function extractStringContainedInOutermostBraces(source: string): BraceTerms
export function extractStringContainedInOutermostBraces(source?: string): BraceTerms | ''
export function extractStringContainedInOutermostBraces(source?: string): BraceTerms | '' {
  if (!isString(source)) {
    return ''
  }

  let rightOfBraces: string
  let count
  let i
  let c

  const firstBrace = source.indexOf('(')
  i = 1 + firstBrace

  const leftOfBraces = source.substr(0, firstBrace)
  count = 1

  while (count > 0 && i < source.length) {
    c = source.substr(i, 1)
    if (c === '(') {
      count++
    }
    if (c === ')') {
      count--
    }
    i++
  }
  if (i < source.length) {
    rightOfBraces = source.substr(i)
  } else {
    rightOfBraces = ''
  }

  const insideBraces = source.substr(1 + firstBrace, i - 1 - (1 + firstBrace))
  return [leftOfBraces, insideBraces, rightOfBraces]
}

export const scanForInstanceOf = ({
  source,
  array,
}: {
  source?: string
  array?: string[] | readonly string[]
} = {}) => {
  if (!isString(source) || !Array.isArray(array)) {
    return -1
  }
  return array.findIndex((instance) => source.indexOf(instance) !== -1)
}

export const extractTermsAroundPivot = ({
  source,
  pivot,
}: {
  source: string
  pivot: string
}): PivotTerms => {
  let leftTerm: string
  let rightTerm: string
  let beforeLeftTerm: string
  let afterRightTerm: string
  let c
  let i

  const pivotLocation = source.indexOf(pivot)

  const leftOfPivot = source.substr(0, pivotLocation)
  const rightOfPivot = source.substr(pivotLocation + pivot.length)

  // left term
  leftTerm = ''
  i = leftOfPivot.length - 1
  c = leftOfPivot.substr(i, 1)

  while (i > 0 && OPERATORS.indexOf(c) === -1) {
    i--
    c = leftOfPivot.substr(i, 1)
  }

  if (OPERATORS.indexOf(c) !== -1) {
    leftTerm = leftOfPivot.substr(i + 1)
    beforeLeftTerm = leftOfPivot.substr(0, i + 1)
  } else {
    leftTerm = leftOfPivot.substr(i)
    beforeLeftTerm = leftOfPivot.substr(0, i)
  }

  // right term
  rightTerm = ''
  if (rightOfPivot.length > 0) {
    i = 0
    c = rightOfPivot.substr(i, 1)

    while (i < rightOfPivot.length && OPERATORS.indexOf(c) === -1) {
      i++
      if (i < rightOfPivot.length) {
        c = rightOfPivot.substr(i, 1)
      }
    }
  }

  if (i < rightOfPivot.length) {
    rightTerm = rightOfPivot.substr(0, i)
    afterRightTerm = rightOfPivot.substr(i)
  } else {
    rightTerm = rightOfPivot
    afterRightTerm = ''
  }

  return [beforeLeftTerm, leftTerm, rightTerm, afterRightTerm]
}

export const countInstancesOf = ({
  source,
  instance,
}: {
  source?: string
  instance?: string
} = {}) => {
  if (!isString(source) || !isString(instance)) {
    return 0
  }
  let count = 0
  let i = 0
  while (i < source.length) {
    if (source.substr(i, 1) === instance) {
      count++
    }
    i++
  }
  return count
}

export const checkBalancedBraces = (source: string) => {
  if (!containsBraces(source)) {
    return false
  }
  const leftInstances = countInstancesOf({ source, instance: '(' })
  const rightInstances = countInstancesOf({ source, instance: ')' })
  return leftInstances === rightInstances
}

export const contains = ({
  source,
  instance,
}: {
  source?: string
  instance?: string
} = {}) => {
  if (!isString(source) || !isString(instance)) {
    return false
  }
  return source.indexOf(instance) !== -1
}

export const containsBraces = (source: string) => {
  return contains({ source, instance: '(' }) || contains({ source, instance: ')' })
}
