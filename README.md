# OmniAuth Heroku

OmniAuth strategy for authenticating to Heroku.

Heroku's support for OAuth is still private/experimental.


## Basic Usage

    use OmniAuth::Builder do
      provider :heroku, ENV['HEROKU_KEY'], ENV['HEROKU_SECRET']
    end


## Meta

Released under the MIT license.

Created by Pedro Belo.