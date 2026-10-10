extends RefCounted
## Star Dodger's numbers and colors, in one place.

const SHIP_SPEED := 220.0
## 0 snaps the ship to full speed; higher values ease in and out (pixels per second, squared).
const SHIP_ACCEL := 900.0
const SHIP_COLOR := "#7fd1ff"

const METEOR_COLOR := "#ff5a3c"
const METEOR_GLOW := true
const METEOR_SPEED := 120.0
## Extra meteor speed per point of score.
const METEOR_SPEED_PER_POINT := 6.0
const METEOR_EVERY := 0.45

const STAR_COLOR := "#ffd23f"
const STAR_SPEED := 110.0
const STAR_EVERY := 0.9

const LIVES := 3
const HIT_SHAKE := 0.0
const HIT_SPARKS := 0
