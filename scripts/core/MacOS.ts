import { CommandOutput, Shell } from './Shell.ts'

export class MacOS {
  static runAppleScript(script: string): Promise<CommandOutput> {
    return Shell.run('/usr/bin/osascript', '-e', script)
  }
}
