import { Output } from './Output.ts'
import { Dotly }  from './Dotly.ts'

export class Env {
  static get(name: string): string {
    const env = Deno.env.get(name)

    if (env === undefined) {
      Output.error(`You need to define an ${name} environment variable`)
      Dotly.exit(1)
    }

    return env!
  }
}
