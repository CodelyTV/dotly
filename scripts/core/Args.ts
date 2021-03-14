export class Args {
  constructor(readonly value: any) {
  }

  get(name: string): string {
    return this.value[name]
  }
}
