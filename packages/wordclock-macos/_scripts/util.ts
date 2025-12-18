import { execSync, spawn } from 'child_process'
import { glob } from 'glob'
import path from 'path'

export const cwd = path.join(__dirname, '../')

export const getSourceFiles = async () => {
  const files = await glob(['**/*.pch', '**/*.h', '**/*.m'], {
    cwd: cwd,
    ignore: ['node_modules/**/*', 'Pods/**/*'],
  })
  return files
}

export const executeCommand = (command: string, mute = true) => {
  console.log(command)
  const result = execSync(command).toString().trim()
  if (!mute) {
    console.log(result)
  }
  return result
}

const hasWhiteSpace = (s: string) => {
  return s && s.indexOf(' ') >= 0
}

export const spawnCommand = async (
  command: string,
  args: string[] = [],
): Promise<{ stdout: string; stderr: string }> => {
  return new Promise((resolve, reject) => {
    console.log(command, args.map((arg) => (hasWhiteSpace(arg) ? `"${arg}"` : arg)).join(' '))

    const child = spawn(command, args)
    let stdOutResult = ''
    let stdErrResult = ''

    child.stdout.on('data', (data) => {
      const dataString = data.toString()
      stdOutResult += dataString
      console.log('stdout:', dataString)
    })

    child.stderr.on('data', (data) => {
      const dataString = data.toString()
      stdErrResult += dataString
      console.log('stderr:', dataString)
    })

    child.on('exit', (code, signal) => {
      if (code === 0) {
        resolve({
          stdout: stdOutResult,
          stderr: stdErrResult,
        })
      }
      console.log(`Child exited with code ${code} signal ${signal}`)
      console.log('stdOutResult', stdOutResult)
      console.log('stdErrResult', stdErrResult)
      reject({
        stdout: stdOutResult,
        stderr: stdErrResult,
      })
    })
  })
}
