# mario/love2d
Code adapted from https://github.com/games50/mario with the following new 
features added:

- Player is always dropped onto solid ground at the start
- A random pair of key and lock are generated, so that when the player 
  touches the key, the lock disappears
- Spawn a goal post once the lock disappears
- Regenerate the level and respawn the player when the player tocuhes the
  goal post
