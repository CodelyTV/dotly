import { parse }  from 'https://deno.land/std/flags/mod.ts'
import { Output } from './Output.ts'
import { Args }   from './Args.ts'

export class Dotly {
  static async script(
    documentation: string,
    argsDefinition: string[],
    body: (args: Args) => void
  ): Promise<void> {
    const name = this.scriptName()
    const args = new Args(parse(Deno.args))

    if (args.has('h')) {
      Output.write(this.buildDocumentation(name, documentation, argsDefinition))

      this.exit(0)
    }

    await body(args)

    this.exit(0)
  }

  static exit(status: number) {
    Deno.exit(status)
  }

  private static buildDocumentation(name: string, documentation: string, argsDefinition: string[]): string {
    return `${documentation}

Usage:
   ${name}
    `
  }

  private static scriptName(): string {
    const mainModulePath = Deno.mainModule.split('/')

    return mainModulePath[mainModulePath.length - 1].replace('.ts', '')
  }
}
