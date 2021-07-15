export class Args {
  constructor(readonly value: any) {
  }

  get(name: string): string {
    return this.value[name]
  }

  has(name: string): boolean {
    return this.value.hasOwnProperty(name)
  }
}
