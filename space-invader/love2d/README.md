# space-invader/love2d
Classic space invader shooter game implemented in Lua's love2d framework

## Gameplay

- Each level has an array of aliens arranged in a rectangle and moving
  side to side, gradually towards the player
- The alien randomly shoots projectiles at the player
- The Player can move left to right at the bottom of the screen, and
  shoots at the aliens
- Once all aliens are cleared, the player proceeds to the next level,
  where aliens move faster and shoot more often
- The player has 3 lives, which once used up the game is over
- Each alien destroyed give some scores, and the highscore is persisted to
  file

## Development
```love . # invoke the game with love```

## License
MIT
