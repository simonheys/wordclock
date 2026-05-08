import englishSimpleFragmentedJson from '@simonheys/wordclock-words/json/English_simple_fragmented.json'

import type { WordsJson } from '../components/types'
import { parseJson } from './WordsFileParser'

describe('WordsFileParser', () => {
  it('normalizes item, sequence, and space entries into parallel label and logic groups', () => {
    const words = {
      meta: {
        language: 'en',
        title: 'Parser characterization fixture',
      },
      groups: [
        [
          {
            type: 'item',
            items: [
              {
                highlight: 'minute==0',
                text: 'zero',
              },
              {
                highlight: 'minute==1',
              },
            ],
          },
          {
            type: 'sequence',
            bind: 'minute',
            first: 2,
            text: ['two', 'three'],
          },
          {
            type: 'space',
            count: 2,
          },
        ],
      ],
    } satisfies WordsJson

    expect(parseJson(words)).toEqual({
      label: [['zero', '', 'two', 'three', '', '']],
      logic: [['minute==0', 'minute==1', 'minute==2', 'minute==3', '', '']],
    })
  })

  it('preserves the current shape of a fragmented words file', () => {
    const { label, logic } = parseJson(englishSimpleFragmentedJson as WordsJson)

    expect(label[0]).toEqual([
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
    ])
    expect(logic[0]).toEqual([
      'hour==1',
      'hour==2',
      'hour==3',
      'hour==4',
      'hour==5',
      'hour==6',
      'hour==7',
      'hour==8',
      'hour==9',
      'hour==10',
      'hour==11',
      'hour==12',
    ])
    const minuteLabels = label[3]
    const minuteLogic = logic[3]
    if (!minuteLabels || !minuteLogic) {
      throw new Error('Expected parsed minute groups')
    }
    expect(minuteLabels).toHaveLength(60)
    expect(minuteLogic).toHaveLength(60)
    expect(minuteLabels[1]).toBe('and')
    expect(minuteLogic[1]).toBe('second!=0')
  })
})
