hero-shorten
============

A zero-configuration URL shortener for Heroku. More info coming soon.

The goal is to create a live URL shortener doing only the following:

    git clone git://github.com/kyleslattery/hero-shorten.git
    cd hero-shorten
    heroku create
    git push heroku master
    
And then be able to access it by going to http://some-sub-domain.heroku.com/-/.

Authentication
--------------
If you would like to password protect the admin section (http://your-shortener/-/), you can set the `ADMIN_USERNAME` and `ADMIN_PASSWORD` heroku env variables by using the `heroku config:add` command:

    heroku config:add ADMIN_USERNAME=someusername ADMIN_PASSWORD=somepassword

To-do
-----
1. Add bookmarklet