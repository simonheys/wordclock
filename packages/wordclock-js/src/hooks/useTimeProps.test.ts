import { getTimeProps } from './useTimeProps'

describe('getTimeProps', () => {
  it('returns the date parts used by word-clock logic', () => {
    expect(getTimeProps(new Date(2024, 0, 7, 23, 59, 58))).toEqual({
      day: 0,
      daystartingmonday: 6,
      date: 7,
      month: 0,
      hour: 11,
      twentyfourhour: 23,
      minute: 59,
      second: 58,
    })
  })

  it('maps Monday to zero for daystartingmonday', () => {
    expect(getTimeProps(new Date(2024, 0, 8))).toMatchObject({
      day: 1,
      daystartingmonday: 0,
    })
  })

  it('keeps twelve-hour midnight and noon as zero', () => {
    expect(getTimeProps(new Date(2024, 0, 8, 0))).toMatchObject({
      hour: 0,
      twentyfourhour: 0,
    })
    expect(getTimeProps(new Date(2024, 0, 8, 12))).toMatchObject({
      hour: 0,
      twentyfourhour: 12,
    })
  })
})
