# 1945 

A multiplayer implementation of the retro 1943 game in Node/Mozart.

## Installation

  git clone git@github.com:tomdionysus/1945.git
  cd 1945
  npm install
  grunt run

## Play

Navigate to `localhost:8080`, and supply your IP to other players who should connect on the same port. For best results, use Chrome.

## Controls

Arrow Keys `Left`, `Right`, `Up` and `Down` to steer, `S` to shoot.

## Heroku Config

| ENV          | Value   |
|:-------------|:--------|
| `BUILDPACK_URL` | https://github.com/ddollar/heroku-buildpack-multi.git |
| `PATH`          | bin:node_modules/.bin:/usr/local/bin:/usr/bin:/bin |

## Roadmap / Wishlist

* JSON state should send a diff and not simply load the entire screen to the client every tick
* Lots of bugs with the power-ups
* Auto-wrap screen to avoid the edge-of-map jump.