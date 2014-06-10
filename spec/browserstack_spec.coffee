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
    robot = new Robot null, 'mock-adapter', no
    robot.adapter.on 'connected', ->
      require('../src/scripts/browserstack') robot
      user = robot.brain.userForId '1', {
        name: 'ngs'
        room: '#mocha'
      }
      adapter = robot.adapter
      do done
    do robot.run

  afterEach -> robot.shutdown()

  describe 'success', ->

    beforeEach (done)->
      nockScope.reply 200, '{"job_id":"abcd1234"}'
      do done

    it 'should reply message', (done)->
      adapter.on 'reply', (envelope, strings)->
        expect(envelope.user.id).to.equal '1'
        expect(envelope.user.name).to.equal 'ngs'
        expect(envelope.user.room).to.equal '#mocha'
        expect(strings).to.have.length(1)
        expect(strings[0]).to.equal 'Started generating screenshorts in http://www.browserstack.com/screenshots/abcd1234'
        do done
      adapter.receive new TextMessage user, 'hubot screenshot me https://www.google.com/'

    it 'should send message', (done)->
      adapter.on 'send', (envelope, strings)->
        expect(envelope.user.id).to.equal '1'
        expect(envelope.user.name).to.equal 'ngs'
        expect(envelope.user.room).to.equal '#mocha'
        expect(strings).to.have.length(1)
        expect(strings[0]).to.equal 'Started generating screenshorts in http://www.browserstack.com/screenshots/abcd1234'
        do done
      adapter.receive new TextMessage user, 'hubot screenshot https://www.google.com/'

  describe 'failure', ->

    beforeEach (done)->
      nockScope.reply 503, '{"job_id":"abcd1234"}'
      do done

    it 'should reply error message', (done)->
      adapter.on 'reply', (envelope, strings)->
        expect(envelope.user.id).to.equal '1'
        expect(envelope.user.name).to.equal 'ngs'
        expect(envelope.user.room).to.equal '#mocha'
        expect(strings).to.have.length(1)
        expect(strings[0]).to.equal 'Failed to start generating screenshots: {"job_id":"abcd1234"}'
        do done
      adapter.receive new TextMessage user, 'hubot screenshot me https://www.google.com/'

    it 'should send error message', (done)->
      adapter.on 'send', (envelope, strings)->
        expect(envelope.user.id).to.equal '1'
        expect(envelope.user.name).to.equal 'ngs'
        expect(envelope.user.room).to.equal '#mocha'
        expect(strings).to.have.length(1)
        expect(strings[0]).to.equal 'Failed to start generating screenshots: {"job_id":"abcd1234"}'
        do done
      adapter.receive new TextMessage user, 'hubot screenshot https://www.google.com/'
