# Description:
#   Takes screenshot with Browser Stack
#
# Commands:
#   hubot screenshot me <url> - Takes screenshot with Browser Stack.
path = require 'path'

module.exports = (robot) ->

  jsonPath = if process.env.HUBOT_BROWSER_STACK_DEFAULT_BROWSERS
    path.resolve process.cwd(), process.env.HUBOT_BROWSER_STACK_DEFAULT_BROWSERS
  else
    '../data/browsers.json'
  browsers = require jsonPath

  robot.respond /screenshot( me)? (https?:\/\/.*)$/i, (msg) ->
    me = msg.match[1] ? true : false
    url = msg.match[2]
    console.log "Try to get screenshots: #{url}"

    env = process.env
    robot.http("http://www.browserstack.com/screenshots")
      .header('Content-Type', 'application/json')
      .header('Accept', 'application/json')
      .auth(env.HUBOT_BROWSER_STACK_USERNAME, env.HUBOT_BROWSER_STACK_ACCESS_KEY)
      .post(JSON.stringify {
        browsers: browsers
        url: url
      }) (err, res, body) ->
        res = JSON.parse(body)
        message = "Started generating screenshorts in http://www.browserstack.com/screenshots/#{res.job_id}"
        if me
          msg.reply message
        else
          msg.send message
