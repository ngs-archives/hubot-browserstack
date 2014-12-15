# Description:
#   Takes screenshot with Browser Stack
#
# Commands:
#   hubot screenshot me <url> - Takes screenshot with Browser Stack.
path = require 'path'

BASE_URL = 'http://www.browserstack.com/screenshots'

module.exports = (robot) ->

  if process.env.HUBOT_BROWSER_STACK_SETTINGS
    settings = require path.resolve process.cwd(), process.env.HUBOT_BROWSER_STACK_SETTINGS
  else
    settings = {}

  jsonPath = if process.env.HUBOT_BROWSER_STACK_DEFAULT_BROWSERS
    path.resolve process.cwd(), process.env.HUBOT_BROWSER_STACK_DEFAULT_BROWSERS
  else
    '../data/browsers.json'
  browsers = require jsonPath
  settings.browsers = browsers

  robot.respond /\s*screenshot(\s+me)?\s+<?(https?:\/\/[^\s>]+)>?\s*$/i, (msg) ->
    me = /me$/.test msg.match[1]
    console.info msg.match
    url = msg.match[2]
    env = process.env
    settings.url = url
    robot.http(BASE_URL)
      .header('Content-Type', 'application/json')
      .header('Accept', 'application/json')
      .auth(env.HUBOT_BROWSER_STACK_USERNAME, env.HUBOT_BROWSER_STACK_ACCESS_KEY)
      .post(JSON.stringify settings) (err, res, body) ->
        if res.statusCode != 200
          message = "Failed to start generating screenshots: #{body}"
        else
          res = JSON.parse(body)
          message = "Started generating screenshots in #{BASE_URL}/#{res.job_id}"

        if me
          msg.reply message
        else
          msg.send message
