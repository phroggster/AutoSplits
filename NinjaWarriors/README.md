## AutoSplits for The Ninja Warriors

### About Game
[The Ninja Warriors](https://www.gamesdatabase.org/game/nintendo-snes/the-ninja-warriors) (US) and
[The Ninja Warriors Again](https://superfamicom.org/info/the-ninja-warriors-again) (JP) are a side-scrolling classic
beat 'em up game for the Super Nintendo/Super Famicom console that was developed by Natsume and released in 1994 by
Taito.

#### WRAM Addresses

| Address     | +/- |  Sz | End | Description                  |
|-------------|-----|-----|-----|------------------------------|
| `$7E:0000`  |  U  |  16 |  L  | Game state A (*gsa*)         |
| `$7E:0002`  |  U  |  16 |  L  | Game state B (*gsb*)         |
| `$7E:01AE`  |  U  |   8 |     | Game timer subframes (*tsf*) |
| `$7E:0278`  |  ?  |  ?? |  ?  | BGM audio track ID           |
| `$7E:18A2`  |  S  |  16 |  L  | Enemy 0 health               |
| `$7E:18A6`  |  S  |  16 |  ?  | Enemy 1 health               |
| `$7E:18B2`  |  S  |  16 |  L  | Player health                |
| `$7E:FC00`  |  S  |  16 |  L  | Signature Check              |

##### Game State A
`gsa`-`$7E:0000`: The current game mode, scene, or menu screen. Additional values *may* potentially be seen during
boot. Values:

| Value   | Description        |
|---------|--------------------|
| `$0000` | Teito logo         |
| `$0001` | *invalid*          |
| `$0002` | *invalid*          |
| `$0003` | Difficulty select  |
| `$0004` | Gameplay           |
| `$0005` | Character select   |
| `$0006` | Game over/continue |
| `$0007` | *not used*         |
| `$0008` | Attract mode       |
| `$0009` | Game over/win      |
| `$000A` | *not used*         |
| `$000B` | Sound test menu    |

##### Game State B
`gsb`-`$7E:0002`: The major state of the current game mode. Varies widely in use, but mainly used here to detect when
menu items are selected. In state 6 (*game over*), the value changes from 0 to 1 when ready for input, and from 1 to 2
or 3 when the selection has been made. In state 5 (*character select*), it changes from 0 to 1 when ready for input,
and from 1 to 2 when the selection has been made.

##### Game Timer Subframes
`tsf`-`$7E:01AE`: The in-game timer number of subframes, increased 60 times per second *while the timer is active*.
Acts as a divisor for counting in tenth-second increments. Range: 0-6.

##### BGM Audio Track
`bgm`-`$7E:0278`: The background music track being played. Notable ones are as follows, with Id being the number shown
in the sound test menu:

| Value | Id | Description           |
|-------|----|-----------------------|
| `$06` | 23 | Game over / win       |
| `$08` |  3 | Character select      |
| `$0A` | 22 | Game over / continue  |
| `$0B` | 21 | Boss defeat           |
| `$10` |  4 | Level 1               |
| `$11` |  5 | Gigant                |
| `$13` |  6 | Level 2               |
| `$14` |  7 | Chainsaw Bull         |
| `$1B` |  9 | Shadow Ghost Yamori   |
| `$1D` | 11 | Silverman             |
| `$1E` | 14 | Jubei                 |
| `$1F` | 16 | Phobos & Deimos       |
| `$20` | 18 | Zelos                 |
| `$21` | 20 | Banglar               |

#### Shoutouts
- [SuperFamicom.org](https://superfamicom.org/info/the-ninja-warriors-again) (ROM technical info)
- [SNESCentral.com](https://snescentral.com/pcbboards.php?chip=SHVC-2A0N-11) (PCB technical info)
- [Wikipedia.org](https://wikipedia.org/wiki/The_Ninja_Warriors_(1994_video_game)) (historical info)
- [MobyGames.com](https://www.mobygames.com/game/snes/ninja-warriors_)
- [GamesDatabase.org](https://www.gamesdatabase.org/game/nintendo-snes/the-ninja-warriors)

