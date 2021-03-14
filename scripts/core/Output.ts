export class Output {
  static write(text: string): void {
    console.log(text)
  }

  static error(text: string): void {
    console.error(text)
  }
}
