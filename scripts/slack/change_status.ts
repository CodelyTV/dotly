import { Dotly }  from '../core/Dotly.ts'
import { Slack }  from '../core/Slack.ts'
import { Env }    from '../core/Env.ts'
import { Args }   from '../core/Args.ts'
import { Output } from '../core/Output.ts'

await Dotly.script('Change your Slack status', ['arg'], async (args: Args) => {
  const slack = new Slack(Env.get('SLACK_TOKEN'))

  await slack.changeStatus(args.get('text'), args.get('emoji'))
    .then(
      (response) => response.json(),
      (error) => Output.error(error)
    )
    .then(
      (response) => {
        if (response.ok) {
          Output.write('✅ Slack status changed correctly')
        } else {
          Output.error('🚨 Slack status not changed due to an error:')
          console.error(response)
        }
      }
    )
})
