export class Shell {
  static async run(
    ...commandAndArgs: string[]
  ): Promise<{ stdout: string; stderr: string; statusCode: number; isSuccessful: boolean; }> {
    const process = Deno.run({cmd: commandAndArgs, stdout: 'piped', stderr: 'piped'})

    const output = await process.output()
    const error  = await process.stderrOutput()
    const code   = await process.status()

    process.close()

    return {
      stdout: new TextDecoder().decode(output),
      stderr: new TextDecoder().decode(error),
      statusCode: code.code,
      isSuccessful: code.success
    }
  }
}
