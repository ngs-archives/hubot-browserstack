# Description:
#   Takes screenshot with Browser Stack
#
# Commands:
#   hubot screenshot me <url> - Searches YouTube for the query and returns the video embed link.
#

path = require 'path'

module.exports = (robot) ->

  jsonPath = if process.env.HUBOT_BROWSER_STACK_DEFAULT_BROWSERS
    path.resolve process.cwd(), process.env.HUBOT_BROWSER_STACK_DEFAULT_BROWSERS
  else
    '../data/browsers.json'
  browsers = require jsonPath

  robot.respond /(screenshot)( me)? (.*)/i, (msg) ->
    url = msg.match[3]
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
        msg.send "Started generating screenshorts in http://www.browserstack.com/screenshots/#{res.job_id}"
