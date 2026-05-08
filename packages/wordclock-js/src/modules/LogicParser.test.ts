import type { WordsJson } from '../components/types'
import { performOperation, processTerm, term } from './LogicParser'
import { parseJson } from './WordsFileParser'

const wordFileModules = import.meta.glob<{ default: WordsJson }>(
  '../../../wordclock-words/json/*.json',
  { eager: true },
)
const timePropNames = [
  'date',
  'day',
  'daystartingmonday',
  'hour',
  'minute',
  'month',
  'second',
  'twentyfourhour',
] as const
const timeValues = [
  0, 1, 2, 3, 4, 5, 10, 11, 12, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 29, 30, 31, 39, 40,
  41, 47, 49, 50, 51, 52, 55, 56, 57, 58, 59,
]
const javaScriptExpressionPattern = /^[\s!%&*()+\-/<>=|A-Za-z0-9_]+$/

type TimePropName = (typeof timePropNames)[number]
type TimeProps = Record<TimePropName, number>

const createTimeProps = (value: number): TimeProps => ({
  date: value,
  day: value % 7,
  daystartingmonday: value % 7,
  hour: value % 12 || 12,
  minute: value % 60,
  month: (value % 12) + 1,
  second: value % 60,
  twentyfourhour: value % 24,
})

const getWordFileExpressions = () => {
  const expressions = new Set<string>()

  for (const [file, module] of Object.entries(wordFileModules)) {
    if (file.endsWith('/Manifest.json')) {
      continue
    }

    const { logic } = parseJson(module.default)

    for (const logicGroup of logic) {
      for (const expression of logicGroup) {
        const trimmedExpression = expression.trim()
        if (trimmedExpression) {
          expressions.add(trimmedExpression)
        }
      }
    }
  }

  return [...expressions].sort()
}

const createJavaScriptEvaluator = (expression: string) => {
  const javaScriptExpression = expression.replace(/\belse\b/g, 'true')
  if (!javaScriptExpressionPattern.test(javaScriptExpression)) {
    throw new Error(`Unexpected expression characters: ${expression}`)
  }

  return Function(...timePropNames, `return (${javaScriptExpression})`) as (
    ...values: number[]
  ) => unknown
}

describe('LogicParser', () => {
  describe('processTerm', () => {
    describe('when valid', () => {
      describe('when the term is negative string', () => {
        it('returns negative', () => {
          expect(processTerm('-123')).toEqual(-123)
          expect(processTerm('--123')).toEqual(123)
        })
      })
      describe('when the term is a boolean string', () => {
        it('returns boolean value', () => {
          expect(processTerm('true')).toEqual(true)
          expect(processTerm('false')).toEqual(false)
        })
      })
      it('accepts String objects', () => {
        // @ts-expect-error testing compatibility with previous string guard behavior
        expect(processTerm(new String(' true '))).toEqual(true)
      })
    })
    describe('when invalid', () => {
      it('returns empty string', () => {
        expect(processTerm()).toEqual('')
      })
    })
  })

  describe('performOperation', () => {
    describe('when valid', () => {
      it('returns the expected result', () => {
        expect(performOperation({ termOne: '2', termTwo: '3', operator: '*' })).toEqual(6)
        expect(performOperation({ termOne: '6', termTwo: '3', operator: '/' })).toEqual(2)
        expect(
          performOperation({
            termOne: 'foo',
            termTwo: 'bar',
            operator: '+',
            props: { foo: '3', bar: 2 },
          }),
        ).toEqual(5)
      })
    })
    describe('when invalid', () => {
      it('returns zero', () => {
        expect(performOperation()).toEqual(0)
      })
    })
  })

  describe('term', () => {
    describe('when valid', () => {
      describe('when using only numbers', () => {
        it('returns the expected result', () => {
          expect(term('2*3')).toEqual(6)
          expect(term('2*3')).toEqual(6)
          expect(term('24/3*2')).toEqual(4)
          expect(term('(24/3)*2')).toEqual(16)
          expect(term('(27*3+(5+10))%(7*2)')).toEqual(12)
        })
      })
      describe('when using unary operators', () => {
        it('returns the expected result', () => {
          expect(term('-2')).toEqual(-2)
          expect(term('--2')).toEqual(2)
          expect(term('-2*3')).toEqual(-6)
          expect(term('2*-3')).toEqual(-6)
          expect(term('-2-3')).toEqual(-5)
          expect(term('2--3')).toEqual(5)
          expect(term('2 - -3')).toEqual(5)
          expect(term('!false')).toEqual(true)
          expect(term('2*!false')).toEqual(2)
        })
      })
      describe('when using numbers and props', () => {
        it('returns the expected result', () => {
          const props = {
            day: 2,
            month: 3,
          }
          expect(term('day', props)).toEqual(2)
          expect(term('month', props)).toEqual(3)
          expect(term('day*month', props)).toEqual(6)
          expect(term('day%2', props)).toEqual(0)
          expect(term('day*2', props)).toEqual(4)
          expect(term('day==2', props)).toEqual(true)
          expect(term('day!=month', props)).toEqual(true)
          expect(term('(day*month)==(1+day+month)', props)).toEqual(true)

          expect(term('(second%10)==2 || (second>10 && second<21)', { second: 2 })).toEqual(true)
          expect(term('(second%10)==2 || (second>10 && second<21)', { second: 12 })).toEqual(true)
          expect(term('(second%10)==2 || (second>10 && second<21)', { second: 22 })).toEqual(true)

          expect(term('(second%10)==2 && (second>10 && second<21)', { second: 2 })).toEqual(false)
          expect(term('(second%10)==2 && (second>10 && second<21)', { second: 12 })).toEqual(true)
          expect(term('(second%10)==2 && (second>10 && second<21)', { second: 22 })).toEqual(false)

          expect(term('(second%10)==2 && !(second>10 && second<21)', { second: 2 })).toEqual(true)
          expect(term('(second%10)==2 && !(second>10 && second<21)', { second: 12 })).toEqual(false)
          expect(term('(second%10)==2 && !(second>10 && second<21)', { second: 22 })).toEqual(true)
        })
      })
      describe('when braces are malformed', () => {
        it('leaves the malformed term intact', () => {
          expect(term('(true')).toEqual('(true')
          expect(term('true)')).toEqual('true)')
          expect(term(')(')).toEqual(')(')
        })
      })
    })
    describe('when invalid', () => {
      it('returns empty string', () => {
        // @ts-expect-error testing invalid input
        expect(term()).toEqual('')
      })
    })
  })

  describe('word file expressions', () => {
    it('matches JavaScript evaluation for the checked-in word files', () => {
      const expressions = getWordFileExpressions()
      const samples = timeValues.map(createTimeProps)

      expect(expressions).toHaveLength(470)
      expect(samples).toHaveLength(37)

      for (const expression of expressions) {
        const evaluateWithJavaScript = createJavaScriptEvaluator(expression)

        for (const props of samples) {
          const expected = evaluateWithJavaScript(...timePropNames.map((name) => props[name]))
          const actual = term(expression, props)

          expect(actual, `${expression} with ${JSON.stringify(props)}`).toEqual(expected)
        }
      }
    })
  })
})
