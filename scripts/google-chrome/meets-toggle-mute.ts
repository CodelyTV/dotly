import { Dotly }        from '../core/Dotly.ts'
import { GoogleChrome } from '../core/GoogleChrome.ts'
import { Modifier }     from '../core/Shortcut.ts'

await Dotly.script('Toggle the mute for Google Meets', async () => {
  await GoogleChrome.executeShortcutInTab('https://meet.google.com', {modifier: Modifier.Command, key: 'd'})
})
