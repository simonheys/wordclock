import {
  checkBalancedBraces,
  countInstancesOf,
  extractStringContainedInOutermostBraces,
  extractTermsAroundPivot,
  isNumericString,
  scanForInstanceOf,
} from './LogicParserStringUtil'

describe('LogicParserStringUtil', () => {
  describe('isNumericString', () => {
    describe('when valid', () => {
      describe('when string contains only digits', () => {
        it('returns true', () => {
          expect(isNumericString('123')).toBeTruthy()
        })
      })
      describe('when string contains characters other than digits', () => {
        it('returns false', () => {
          expect(isNumericString('24/3')).toBeFalsy()
        })
      })
    })
  })

  describe('extractStringContainedInOutermostBraces', () => {
    describe('when valid', () => {
      it('returns the string contained in outermost braces', () => {
        expect(extractStringContainedInOutermostBraces('foo(((bar)))')[1]).toEqual('((bar))')
        expect(extractStringContainedInOutermostBraces('foo((bar))foo')[1]).toEqual('(bar)')
        expect(extractStringContainedInOutermostBraces('(bar)foo')[1]).toEqual('bar')
      })
    })
    describe('when invalid', () => {
      it('returns an empty string', () => {
        // @ts-expect-error testing invalid input
        expect(extractStringContainedInOutermostBraces()).toEqual('')
      })
    })
  })

  describe('extractTermsAroundPivot', () => {
    describe('when valid', () => {
      it('returns the expected terms', () => {
        const [beforeLeftTerm, leftTerm, rightTerm, afterRightTerm] = extractTermsAroundPivot({
          source: '23-foo*25+6',
          pivot: '*',
        })
        expect(beforeLeftTerm).toEqual('23-')
        expect(leftTerm).toEqual('foo')
        expect(rightTerm).toEqual('25')
        expect(afterRightTerm).toEqual('+6')
      })
    })
    describe('when invalid', () => {
      it('throws an error', () => {
        // @ts-expect-error testing invalid input
        expect(() => extractTermsAroundPivot()).toThrow()
      })
    })
  })

  describe('countInstancesOf', () => {
    describe('when valid', () => {
      it('returns the count of instance in source', () => {
        expect(countInstancesOf({ source: '123456789009000', instance: '0' })).toEqual(5)
      })
    })
    describe('when invalid', () => {
      it('return 0', () => {
        expect(countInstancesOf()).toEqual(0)
      })
    })
  })

  describe('checkBalancedBraces', () => {
    describe('when valid', () => {
      describe('when braces are balanced', () => {
        it('returns true', () => {
          expect(checkBalancedBraces('((foo))')).toBeTruthy()
        })
      })
      describe('when braces are unbalanced', () => {
        it('returns false', () => {
          expect(checkBalancedBraces('(((foo))')).toBeFalsy()
        })
      })
    })
    describe('when invalid', () => {
      it('return false', () => {
        // @ts-expect-error testing invalid input
        expect(checkBalancedBraces()).toBeFalsy()
      })
    })
  })

  describe('scanForInstanceOf', () => {
    describe('when array contains instance', () => {
      it('returns the index of the instance in the array', () => {
        expect(scanForInstanceOf({ source: 'foo=bar', array: ['*', '='] })).toEqual(1)
      })
    })
    describe('when array does not contains instance', () => {
      it('returns -1', () => {
        expect(scanForInstanceOf({ source: 'foo=bar', array: ['/', '*'] })).toEqual(-1)
      })
    })
    describe('when invalid', () => {
      it('return -1', () => {
        expect(scanForInstanceOf()).toEqual(-1)
      })
    })
  })
})
