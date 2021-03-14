import { Dotly }    from '../core/Dotly.ts'
import { Args }     from '../core/Args.ts'
import { Window }   from '../core/Window.ts'
import { Displays } from '../core/Displays.ts'

await Dotly.script('Move the active window', async (args: Args) => {
  const activeWindows      = await Window.active()
  const displayResolutions = await Displays.resolutions()

  // @todo add multiscreen support
  const resolution = displayResolutions[0]

  if (args.has('left_half')) {
    await activeWindows.reposition(0, 0, resolution.width / 2, resolution.height)
  } else if (args.has('right_half')) {
    await activeWindows.reposition(resolution.width / 2, 0, resolution.width / 2, resolution.height)
  } else if (args.has('top_half')) {
    await activeWindows.reposition(0, 0, resolution.width, resolution.height / 2)
  } else if (args.has('bottom_half')) {
    await activeWindows.reposition(0, resolution.height / 2, resolution.width, resolution.height / 2)
  } else if (args.has('fullscreen')) {
    await activeWindows.reposition(0, 0, resolution.width, resolution.height)
  }
})
