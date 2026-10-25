import { spawn } from 'node:child_process'
import { existsSync, readFileSync, writeFileSync } from 'node:fs'
import { dirname, resolve } from 'node:path'
import { createInterface } from 'node:readline'
import { fileURLToPath } from 'node:url'

const packageRoot = fileURLToPath(new URL('..', import.meta.url))
const compiler = fileURLToPath(new URL('../node_modules/typescript/bin/tsc', import.meta.url))
const args = [compiler, '-p', 'tsconfig.build.json', '--listEmittedFiles']
if (process.argv.includes('--watch')) args.push('--watch', '--preserveWatchOutput')

const child = spawn(process.execPath, args, {
  cwd: packageRoot,
  stdio: ['inherit', 'pipe', 'inherit'],
})
let failed = false

function rewriteImports(file) {
  const source = readFileSync(file, 'utf8')
  const updated = source.replace(
    /(\b(?:from\s+|import\s*(?:\(\s*)?)["'])(\.{1,2}\/[^"']+)(["'])/g,
    (match, before, specifier, after) => {
      if (/\.(?:[cm]?js|json|[cm]?ts|tsx|jsx)$/.test(specifier)) return match
      for (const [declaration, runtime] of [
        ['.d.ts', '.js'],
        ['.d.mts', '.mjs'],
        ['.d.cts', '.cjs'],
      ]) {
        for (const path of [specifier, `${specifier}/index`]) {
          if (existsSync(resolve(dirname(file), `${path}${declaration}`))) {
            return `${before}${path}${runtime}${after}`
          }
        }
      }
      throw new Error(`Cannot resolve declaration import ${specifier} in ${file}`)
    },
  )
  if (updated !== source) writeFileSync(file, updated)
}

// Normalize each emitted declaration in both one-shot builds and compiler watch mode.
createInterface({ input: child.stdout }).on('line', (line) => {
  if (!line.startsWith('TSFILE: ')) return console.log(line)
  const file = line.slice('TSFILE: '.length)
  if (!/\.d\.[cm]?ts$/.test(file)) return
  try {
    rewriteImports(file)
  } catch (error) {
    failed = true
    console.error(error)
    child.kill()
  }
})

child.on('error', (error) => {
  console.error(error)
  process.exitCode = 1
})
child.on('close', (code) => {
  process.exitCode = failed ? 1 : (code ?? 1)
})
for (const signal of ['SIGINT', 'SIGTERM']) process.once(signal, () => child.kill(signal))
