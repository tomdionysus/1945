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

Arrow Keys `Left`, `Right`, `Up` and `Down` to steer, `s` to shoot.

## Heroku Config

| ENV          | Value   |
|:-------------|:--------|
| `BUILDPACK_URL` | https://github.com/ddollar/heroku-buildpack-multi.git |
| `PATH`          | bin:node_modules/.bin:/usr/local/bin:/usr/bin:/bin |

## Roadmap / Wishlist

* JSON state should send a diff and not simply load the entire screen to the client every tick
* Lots of bugs with the power-ups
* Auto-wrap screen to avoid the edge-of-map jump.

## Code of Conduct

The crud-service project is committed to the [Contributor Covenant](http://contributor-covenant.org). Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before making any contributions or comments.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request