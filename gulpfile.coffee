gulp   = require 'gulp'
gutil  = require 'gulp-util'
coffee = require 'gulp-coffee'
mocha  = require 'gulp-mocha'
clean  = require 'gulp-clean'

gulp.task 'default', ['mocha']

gulp.task 'clean', ->
  gulp
    .src('node_modules', read: no)
    .pipe(clean())

gulp.task 'mocha', ->
  gulp
    .src('spec/*.coffee')
    .pipe(coffee(bare: yes)
    .pipe(mocha( reporter: process.env.MOCHA_REPORTER || 'nyan' ))
    .on('error', gutil.log))
