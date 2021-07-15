import { Dotly } from '../core/Dotly.ts'
import { Slack } from '../core/Slack.ts'
import { Env }   from '../core/Env.ts'
import { Args }  from '../core/Args.ts'

await Dotly.script('Change your Slack status', async (args: Args) => {
  const slack = new Slack(Env.get('SLACK_TOKEN'))

  await slack.changeStatus(args.get('text'), args.get('emoji'))
})
