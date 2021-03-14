import { MacOS } from './MacOS.ts'

export type Resolution = {
  width: number,
  height: number,
}

export class Displays {
  static async resolutions(): Promise<Resolution[]> {
    const output = await MacOS.runAppleScript(`tell application "Finder" to get bounds of window of desktop`)

    return output.stdout.split('\n').filter((_) => _.length !== 0).map((resolutions) => {
      const splitted = resolutions.split(',')

      return {
        width: Number(splitted[2]),
        height: Number(splitted[3])
      }
    })
  }
}
