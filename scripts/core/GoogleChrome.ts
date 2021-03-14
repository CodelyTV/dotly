import { MacOS }    from './MacOS.ts'
import { Shortcut } from './Shortcut.ts'

export class GoogleChrome {
  static async executeJsInTab(tabUrlStarts: string, jsCommand: string) {
    return await MacOS.runAppleScript(`tell application "Google Chrome"
  set i to 0
  repeat with w in (windows)
      set j to 1 
      repeat with t in (tabs of w) 
        if URL of t starts with "${tabUrlStarts}" then
              tell tab j of window i to execute javascript "${jsCommand}"
              return
          end if
          set j to j + 1
      end repeat
      set i to i + 1
  end repeat
end tell
    `)
  }

  static async executeShortcutInTab(tabUrlStartsWith: string, shortcut: Shortcut) {
    return await MacOS.runAppleScript(`tell application "Google Chrome"
  set i to 0
  repeat with w in (windows)
      set j to 1 
      repeat with t in (tabs of w) 
        if URL of t starts with "${tabUrlStartsWith}" then
            set (active tab index of w) to j 
            set index of w to 1 
            do shell script "open -a 'Google Chrome'"
            tell application "System Events" to tell process "Google Chrome" to keystroke "${shortcut.key}" using ${shortcut.modifier} down
            return
          end if
          set j to j + 1
      end repeat
      set i to i + 1
  end repeat
end tell
    `)
  }
}
