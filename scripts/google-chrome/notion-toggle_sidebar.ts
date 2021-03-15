import { Dotly }        from '../core/Dotly.ts'
import { GoogleChrome } from '../core/GoogleChrome.ts'
import { Modifier }     from '../core/Shortcut.ts'

await Dotly.script('Toggle the sidebar of Notion', async () => {
  await GoogleChrome.executeShortcutInTab('https://notion.so', {modifier: Modifier.Command, key: '\\'})
})
