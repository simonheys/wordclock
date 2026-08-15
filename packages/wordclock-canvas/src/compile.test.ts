import { describe, expect, it } from 'vitest'

import { compile } from './compile'
import { getTimeProps } from './definition'
import type { TimeProps } from './types'

const at = (hours: number, minutes: number, seconds = 0): TimeProps =>
  getTimeProps(new Date(2026, 7, 15, hours, minutes, seconds))

describe('compile', () => {
  it('treats an empty expression as never highlighted', () => {
    expect(compile('').evaluate(at(9, 41))).toBe(false)
    expect(compile('   ').evaluate(at(9, 41))).toBe(false)
  })

  it("treats `else` as the word files' unconditional fallback", () => {
    expect(compile('else').evaluate(at(9, 41))).toBe(true)
    expect(compile('true').evaluate(at(9, 41))).toBe(true)
    expect(compile('false').evaluate(at(9, 41))).toBe(false)
  })

  it.each([
    ['minute==41', at(9, 41), true],
    ['minute==41', at(9, 42), false],
    ['minute!=41', at(9, 42), true],
    ['second>10', at(9, 41, 11), true],
    ['second>10', at(9, 41, 10), false],
    ['twentyfourhour<12', at(9, 41), true],
    ['twentyfourhour<12', at(13, 41), false],
    ['twentyfourhour>=12', at(12, 0), true],
    ['hour==0 && (minute==0)', at(12, 0), true],
    ['hour==0 && (minute>=1)', at(12, 0), false],
    ['hour==0 && (minute>=1)', at(12, 1), true],
    ['twentyfourhour>19 || twentyfourhour==0', at(20, 0), true],
    ['twentyfourhour>19 || twentyfourhour==0', at(0, 0), true],
    ['twentyfourhour>19 || twentyfourhour==0', at(19, 0), false],
    ['(twentyfourhour%10)==4 || twentyfourhour==0', at(14, 0), true],
    ['(second%10)==0 || (second>10 && second<21)', at(9, 41, 20), true],
    ['(second%10)==0 || (second>10 && second<21)', at(9, 41, 21), false],
    ['((minute%10)==0 && minute!=0) || (minute>10 && minute<21)', at(9, 30), true],
    ['((minute%10)==0 && minute!=0) || (minute>10 && minute<21)', at(9, 0), false],
    ['minute<=1 || minute==21 || minute==31 || minute==41 || minute==51', at(9, 31), true],
    ['minute<=1 || minute==21 || minute==31 || minute==41 || minute==51', at(9, 32), false],
  ])('evaluates %s', (source, time, expected) => {
    expect(compile(source).evaluate(time)).toBe(expected)
  })

  it('honours operator precedence over left-to-right order', () => {
    // && binds tighter than ||, so this is false || (true && false)
    expect(compile('minute==0 || minute==41 && second==5').evaluate(at(9, 41, 6))).toBe(false)
    expect(compile('minute==0 || minute==41 && second==5').evaluate(at(9, 41, 5))).toBe(true)
    // % binds tighter than ==
    expect(compile('minute%10==1').evaluate(at(9, 41))).toBe(true)
  })

  it('handles the deeply nested expressions in the corpus', () => {
    const source =
      '(minute>=1) && ((hour==2 && (minute%5 == 0) && minute <=30) || (hour==1 && (minute%5 == 0) && minute > 30))'
    const compiled = compile(source)
    expect(compiled.evaluate(at(14, 15))).toBe(true)
    expect(compiled.evaluate(at(13, 45))).toBe(true)
    expect(compiled.evaluate(at(14, 45))).toBe(false)
    expect(compiled.evaluate(at(14, 0))).toBe(false)
  })

  it('reports which time fields an expression reads', () => {
    expect([...compile('minute==5').fields]).toEqual(['minute'])
    expect([...compile('hour==1 && second>2').fields].sort()).toEqual(['hour', 'second'])
    expect([...compile('else').fields]).toEqual([])
  })

  it('rejects malformed expressions rather than silently returning a string', () => {
    expect(() => compile('minute ==')).toThrow(SyntaxError)
    expect(() => compile('(minute==1')).toThrow(SyntaxError)
    expect(() => compile('nonsense==1')).toThrow(SyntaxError)
  })

  it('compiles once and is reusable across evaluations', () => {
    const compiled = compile('second%2==0')
    expect(compiled.evaluate(at(9, 41, 4))).toBe(true)
    expect(compiled.evaluate(at(9, 41, 5))).toBe(false)
    expect(compiled.evaluate(at(9, 41, 6))).toBe(true)
  })
})
