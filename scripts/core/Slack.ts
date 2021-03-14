import { Output } from './Output.ts'

export class Slack {
  constructor(private readonly token: string) {
  }

  async changeStatus(text: string, emoji: string): Promise<any> {
    return await fetch(
      'https://slack.com/api/users.profile.set',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': `Bearer ${this.token}`
        },
        body: JSON.stringify(
          {
            'profile': {
              'status_text': text,
              'status_emoji': emoji
            }
          }
        )
      }
    ).then(
      (response) => response.json(),
      (error) => Output.error(error)
    ).then(
      (response) => {
        if (response.ok) {
          Output.write('✅ Slack status changed correctly')
        } else {
          Output.error('🚨 Slack status not changed due to an error:')
          console.error(response)
        }
      }
    )
  }
}
