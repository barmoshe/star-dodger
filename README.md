# Star Dodger

A small arcade game built from a blank project with [Playmark](https://github.com/barmoshe/playmark):
`/playmark:new`, then a step at a time, played and marked along the way. Every mark that led to a
change is a commit (`git log`): what was marked, and the one change that answered it.

Steer the ship with WASD or the arrows, collect stars, dodge meteors. R restarts.

```bash
godot --path .                 # play (Godot 4.5+)
godot --path . -- --autoplay   # a simple pilot flies (used for recordings)
```

The numbers and colors live in `tune.gd`.
