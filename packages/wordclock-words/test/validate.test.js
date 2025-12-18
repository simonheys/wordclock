import { existsSync, readdirSync, readFileSync } from 'fs'
import { dirname, join } from 'path'
import { fileURLToPath } from 'url'
import { describe, expect, it } from 'vitest'

const __dirname = dirname(fileURLToPath(import.meta.url))
const jsonDir = join(__dirname, '../json')

const manifest = JSON.parse(readFileSync(join(jsonDir, 'Manifest.json'), 'utf-8'))

describe('wordclock-words JSON validation', () => {
  describe('Manifest.json', () => {
    it('should have a files array', () => {
      expect(manifest.files).toBeDefined()
      expect(Array.isArray(manifest.files)).toBe(true)
      expect(manifest.files.length).toBeGreaterThan(0)
    })

    it('should have a languages object', () => {
      expect(manifest.languages).toBeDefined()
      expect(typeof manifest.languages).toBe('object')
    })
  })

  describe('All manifest files exist', () => {
    manifest.files.forEach((filename) => {
      it(`${filename} should exist`, () => {
        const filePath = join(jsonDir, filename)
        expect(existsSync(filePath)).toBe(true)
      })
    })
  })

  describe('Language file structure', () => {
    manifest.files.forEach((filename) => {
      describe(filename, () => {
        const filePath = join(jsonDir, filename)
        let content

        try {
          content = JSON.parse(readFileSync(filePath, 'utf-8'))
        } catch {
          it('should be valid JSON', () => {
            expect.fail(`${filename} is not valid JSON`)
          })
          return
        }

        it('should have meta object with language', () => {
          expect(content.meta).toBeDefined()
          expect(content.meta.language).toBeDefined()
          expect(typeof content.meta.language).toBe('string')
        })

        it('should have groups array', () => {
          expect(content.groups).toBeDefined()
          expect(Array.isArray(content.groups)).toBe(true)
          expect(content.groups.length).toBeGreaterThan(0)
        })

        it('should have valid group structure', () => {
          content.groups.forEach((group, groupIndex) => {
            expect(Array.isArray(group)).toBe(true)
            group.forEach((item, itemIndex) => {
              expect(item.type).toBeDefined()
              expect(['item', 'sequence', 'space']).toContain(item.type)
            })
          })
        })
      })
    })
  })

  describe('All JSON files in directory are in manifest', () => {
    const jsonFiles = readdirSync(jsonDir).filter(
      (f) => f.endsWith('.json') && f !== 'Manifest.json',
    )

    jsonFiles.forEach((filename) => {
      it(`${filename} should be listed in Manifest.json`, () => {
        expect(manifest.files).toContain(filename)
      })
    })
  })
})
