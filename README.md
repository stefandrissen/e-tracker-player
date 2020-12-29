# E-Tracker Player
Disassembly of ESI's [E-Tracker](https://www.worldofsam.org/products/e-tracker) compiled module player (1992) for the SAM Coupé.
Initial disassembly created with [dZ80](http://www.inkland.org.uk/dz80/).

I created this disassembly to track down a bug that is incorrectly retriggering notes when an instrument is provided without a note. The player in the editor does not retrigger, the compiled player does. See for example [Sam n Bass](https://youtu.be/tytdytuiNEs).

While investigating, DTA pointed out another bug in the envelope generator selection. I do not have an example module illustrating this yet.

## Ant targets
* verify - assembles the e-tracker player using [pyz80](https://github.com/simonowen/pyz80) and compares the assembled binary with a reference binary
* execute - assembles a wrapper including the e-tracker player, a compiled module and a simple play loop, and then opens the resulting dsk image in [SimCoupe](https://github.com/simonowen/simcoupe)
