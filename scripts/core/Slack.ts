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
    )
  }
}
