# breakout/love2d
Code and assets adapted from https://github.com/games50/breakout - with the following feature updates:

- A powerup will spawn after a certain amount of time into the game, and 
  if it collides with the paddle, two more balls will be spawned for the 
  current level only

- The paddle will shrink on losing hearts, and grow on scoring certain 
  amount of points

- Add a locked brick to the level - which can only be broken by the ball 
  if the player has the key powerup (spawned randomly like the ball powerup)
