import { Shell } from './Shell.ts'

export class Platform {
  static async isMacOS(): Promise<boolean> {
    const output = Shell.run('[[ $(uname -s) == "Darwin" ]]')

    return output.then((a) => a.isSuccessful)
  }
}
