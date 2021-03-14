import { parse }  from 'https://deno.land/std/flags/mod.ts'
import { Output } from './Output.ts'

export class Dotly {
  static async script(name: string, documentation: string, argsDefinition: string[], body: (args: object) => void): Promise<void> {
    const args = parse(Deno.args)

    if (args.hasOwnProperty('h')) {
      Output.write(this.buildDocumentation(name, documentation, argsDefinition))
      Deno.exit(0)
    }

    body(args)
    Deno.exit(0)
  }

  private static buildDocumentation(name: string, documentation: string, argsDefinition: string[]): string {
    return `${documentation}

Usage:
   ${name}
    `
  }
}
