path = require 'path'
Robot = require("hubot/src/robot")
TextMessage = require("hubot/src/message").TextMessage
nock = require 'nock'
process.env.HUBOT_LOG_LEVEL = 'debug'
chai = require 'chai'
chai.use require 'chai-spies'
{ expect, spy } = chai

describe 'hubot-browserstack', ->
  robot = null
  user = null
  adapter = null
  nockScope = null
  beforeEach (done)->
    process.env.HUBOT_BROWSER_STACK_ACCESS_KEY = 'fake-access-key'
    process.env.HUBOT_BROWSER_STACK_USERNAME = 'fake-user-name'
    nock.disableNetConnect()
    nockScope = nock('http://www.browserstack.com').post('/screenshots')
    robot = new Robot null, 'mock-adapter', yes, 'TestHubot'
    robot.adapter.on 'connected', ->
      robot.loadFile path.resolve('.', 'src', 'scripts'), 'browserstack.coffee'
      hubotScripts = path.resolve 'node_modules', 'hubot', 'src', 'scripts'
      robot.loadFile hubotScripts, 'help.coffee'
      user = robot.brain.userForId '1', {
        name: 'ngs'
        room: '#mocha'
      }
      adapter = robot.adapter
      waitForHelp = ->
        if robot.helpCommands().length > 0
          do done
        else
          setTimeout waitForHelp, 100
      do waitForHelp
    do robot.run

  afterEach ->
    robot.server.close()
    robot.shutdown()


  describe 'help', ->
    it 'should have 3', (done)->
      expect(robot.helpCommands()).to.have.length 3
      do done

    it 'should parse help', (done)->
      adapter.on 'send', (envelope, strings)->
        ## Prefix bug with parseHelp
        ## https://github.com/github/hubot/pull/712
        try
          expect(strings[0]).to.equal """
          TestTestHubot help - Displays all of the help commands that TestHubot knows about.
          TestTestHubot help <query> - Displays all help commands that match <query>.
          TestTestHubot screenshot me <url> - Takes screenshot with Browser Stack.
          """
          do done
        catch e
          done e
      adapter.receive new TextMessage user, 'TestHubot help'

  describe 'success', ->

    beforeEach (done)->
      nockScope.reply 200, job_id: 'abcd1234'
      do done

    it 'should reply message', (done)->
      adapter.on 'reply', (envelope, strings)->
        try
          expect(envelope.user.id).to.equal '1'
          expect(envelope.user.name).to.equal 'ngs'
          expect(envelope.user.room).to.equal '#mocha'
          expect(strings).to.have.length(1)
          expect(strings[0]).to.equal 'Started generating screenshorts in http://www.browserstack.com/screenshots/abcd1234'
          do done
        catch e
          done e
      adapter.receive new TextMessage user, 'testhubot screenshot me https://www.google.com/'

    it 'should send message', (done)->
      adapter.on 'send', (envelope, strings)->
        try
          expect(envelope.user.id).to.equal '1'
          expect(envelope.user.name).to.equal 'ngs'
          expect(envelope.user.room).to.equal '#mocha'
          expect(strings).to.have.length(1)
          expect(strings[0]).to.equal 'Started generating screenshorts in http://www.browserstack.com/screenshots/abcd1234'
          do done
        catch e
          done e
      adapter.receive new TextMessage user, 'testhubot screenshot https://www.google.com/'

  describe 'failure', ->

    beforeEach (done)->
      nockScope.reply 503, job_id: 'abcd1234'
      do done

    it 'should reply error message', (done)->
      adapter.on 'reply', (envelope, strings)->
        try
          expect(envelope.user.id).to.equal '1'
          expect(envelope.user.name).to.equal 'ngs'
          expect(envelope.user.room).to.equal '#mocha'
          expect(strings).to.have.length(1)
          expect(strings[0]).to.equal 'Failed to start generating screenshots: {"job_id":"abcd1234"}'
          do done
        catch e
          done e
      adapter.receive new TextMessage user, 'testhubot screenshot me https://www.google.com/'

    it 'should send error message', (done)->
      adapter.on 'send', (envelope, strings)->
        try
          expect(envelope.user.id).to.equal '1'
          expect(envelope.user.name).to.equal 'ngs'
          expect(envelope.user.room).to.equal '#mocha'
          expect(strings).to.have.length(1)
          expect(strings[0]).to.equal 'Failed to start generating screenshots: {"job_id":"abcd1234"}'
          do done
        catch e
          done e
      adapter.receive new TextMessage user, 'testhubot screenshot https://www.google.com/'
