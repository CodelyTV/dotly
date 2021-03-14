import { Dotly }  from '../core/Dotly.ts'
import { Output } from '../core/Output.ts'

await Dotly.script('demo', 'Demo script for whatever', ['hola'], (args: object) => {
  console.log(args)
  Output.write('holaaaa')
})
