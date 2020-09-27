# NORNS ATHENAEUM

A repository of study, spike, and sample scripts for [norns](https://monome.org/docs/norns/). Each was created as a means to learn different techiques or technologies myself. I am sharing it in the event others find them inspiring or useful.

## Scripts

- **arc.lua** - explores getting data from and updating the LEDs on an [arc](https://monome.org/docs/arc/). Handles linear "scaled rings", chunky "paginated rings", wrapping, "snap" LED aliasing, and encoder sensitivity. Additionally, arbitrary minimum and maximum values can be set for each encoder which will then scale out accordingly. Also, a utility function to map the current encoder value to a given segment.

- **delay.lua** - explores the concept of MIDI delay. Control rate and decay level of MIDI notes and get visual feedback as notes are toggled on and off. Requires an outboard MIDI device, preferrably one capable of polyphony. Made as a research spike for a new [arcologies](https://github.com/tyleretters/arcologies) structure.

## Credits

Software design by [Tyler Etters](https://nor.the-rn.info).

<a href="https://nor.the-rn.info"><img src="https://tyleretters.github.io/arcologies-docs/assets/images/northern-information.svg" alt="Northern Information" width="100"/></a>