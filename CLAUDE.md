# Star Dodger

A Godot 4.5+ game, started blank with Playmark (https://github.com/barmoshe/playmark).

## The loop

1. Build a small step of the game (one mechanic, one enemy, one screen at a time).
2. Ask the player to playtest: run the game from Godot (or `godot --path .`).
3. While playing they press **Ctrl+Shift+M**, pin or box what they mean and write a note.
   Marks land in `.playmark/inbox/`, and the next prompt mentions them.
4. Run `/playmark:triage`: read each mark's `annotated.png` and `clip_sheet.png`, find the code
   from the nodes under each pin, propose fixes, apply the ones the player picks, then
   `inbox.mjs resolve <id> --note "..."`. The running game shows "Fixed #N".
5. Repeat. Commit after each step that works.

## Conventions

- `main.tscn` / `main.gd` is the entry scene. Keep scripts typed GDScript.
- Register state worth seeing in every mark: `Playmark.add_context("name", func(): return {...})`.
- Rooms or levels in one scene: `Playmark.set_scope(func(): return "level/%d" % level)` keeps ghosts in place.
- `.playmark/` stays out of git.
