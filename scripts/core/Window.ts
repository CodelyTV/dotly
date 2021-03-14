import { MacOS } from './MacOS.ts'

export type WindowBounds = {
  x: number;
  y: number;
  width: number;
  height: number;
}

export class Window {
  constructor(readonly application: string, readonly title: string) {
  }

  static async active(): Promise<Window> {
    const output = await MacOS.runAppleScript(`global frontApp, frontAppName, windowTitle
set windowTitle to ""
tell application "System Events"
    set frontApp to first application process whose frontmost is true
    set frontAppName to name of frontApp
    set frontAppNameJson to "\\"app\\":\\"" & frontAppName as string & "\\""
    tell process frontAppName
        tell (1st window whose value of attribute "AXMain" is true)
            set windowTitle to value of attribute "AXTitle"
            set windowTitleJson to "\\"title\\":\\"" & windowTitle as string & "\\""
        end tell
    end tell
end tell
    
set response to "{" & frontAppNameJson as string &  "," & windowTitleJson as string &  "}"

return response`)

    const jsonOutput = JSON.parse(output.stdout)

    return new Window(jsonOutput.app, jsonOutput.title)
  }

  async reposition(x: number, y: number, width: number, height: number): Promise<void> {
    const response = await MacOS.runAppleScript(`
tell application "System Events"
    set theProcessWindow to window of process "${this.application}"
    repeat with theWindow in theProcessWindow
        if name of theWindow contains "${this.title}" then
          set position of theWindow to {${x}, ${y}}
          set size of theWindow to {${width}, ${height}}
        end if
    end repeat
end tell`)
  }

}
