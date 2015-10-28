# TODO: implement this http://stackoverflow.com/questions/22886682/how-can-gulp-be-restarted-on-gulpfile-change

fs     = require 'fs'
http   = require 'http'
path   = require 'path'
crypto = require 'crypto'

es            = require 'event-stream'
gulp          = require 'gulp'
gzip          = require 'gulp-gzip'
gutil         = require 'gulp-util'
shell         = require 'gulp-shell'
gitRev        = require 'git-rev'
rimraf        = require 'rimraf'
coffee        = require 'gulp-coffee'
concat        = require 'gulp-concat'
rename        = require 'gulp-rename'
stylus        = require 'gulp-stylus'
uglify        = require 'gulp-uglify'
replace       = require 'gulp-replace'
embedlr       = require 'gulp-embedlr'
lrServer      = require('tiny-lr')()
ecstatic      = require 'ecstatic'
minifyCSS     = require 'gulp-minify-css'
cloudfront    = require 'gulp-cloudfront'
livereload    = require 'gulp-livereload'
coffeelint    = require 'gulp-coffeelint'
ngAnnotate    = require 'gulp-ng-annotate'
handlebars    = require 'gulp-compile-handlebars'
autoprefiexer = require 'gulp-autoprefixer'

_    = require 'lodash'
cson = require 'cson'
argv = require('yargs').argv
ASSET_REGEX = /ASSET{(.+)}/g
DEST = './www'

configName = argv.config or 'local'
defaultConfig = cson.parseFile "configs/default.cson"
buildConfig = cson.parseFile "configs/#{configName}.cson"
config = _.merge defaultConfig, buildConfig
publicConfig = _.pick config, config.publicConfigKeys

writeToFile = (filePath, data) -> fs.writeFile filePath, data, (err) -> throw err if err

calculateMD5 = (fsPath) ->
    unless fs.existsSync fsPath
        gutil.log gutil.colors.cyan("#{fsPath} doesn't exist, making random hash")
        return Math.random().toString(36).substr(2, 6)

    md5 = crypto.createHash 'md5'
    contents = fs.readFileSync fsPath
    md5.update(contents).digest('hex')

getFiles = (dir, files_) ->
    files_ = files_ or []
    files = fs.readdirSync(dir)

    for i of files
        name = dir + '/' + files[i]
        if fs.statSync(name).isDirectory()
            getFiles name, files_
        else
            files_.push name

    files_

# console.log getFiles './www'

getTemplateHashes = ->
    hashes = {}
    files = getFiles "#{DEST}/templates"

    for file in files
        relPath = file.replace "#{DEST}/", ''
        hashes[relPath] = calculateMD5(file)[...6]

    hashes

gulp.task '__templatehashes', ->
    console.log getTemplateHashes()

assetCacheBustFunc = (whole, relPath) ->
    fsPath = path.join DEST, relPath
    hash = calculateMD5 fsPath
    return "#{relPath}?rel=#{hash[...6]}"

gulp.task 'clean', (cb) ->
    rimraf DEST, cb

gulp.task 'copy', ->
    tasks = [
        # ['./sourcePath',                        './destPath']
        ['./src/templates/**/*',                  "#{DEST}/templates"]
        ['./src/assets/**/*',                     DEST]
        ['./src/lib/onsen/css/font_awesome/**/*', "#{DEST}/font_awesome"]
        ['./src/lib/onsen/css/ionicons/**/*',     "#{DEST}/ionicons"]
    ]

    streams = tasks.map (task) -> gulp.src(task[0]).pipe gulp.dest task[1]
    es.merge streams...

gulp.task 'icons', ->
    sources = config.iosIcons.sizes.map (icon) ->
        config.iosIcons.base + '/' + icon.name

    gulp.src sources
        .pipe gulp.dest "#{DEST}/icons"

gulp.task 'index.html', ['copy', 'appScripts', 'styles'], ->
    hashes = getTemplateHashes()
    templateHashValue = JSON.stringify(hashes)

    stream = gulp.src './src/index.html'
        .pipe replace '<%% config %%>', JSON.stringify publicConfig
        .pipe replace '<%% templateHashes %%>', templateHashValue
        .pipe replace ASSET_REGEX, assetCacheBustFunc

    if config.build.useLiveReload
        stream = stream.pipe embedlr()

    stream.pipe gulp.dest DEST

gulp.task 'config', ->
    gulp.src './configs/config.xml.hbs'
        .pipe handlebars config
        .pipe rename 'config.xml'
        .pipe gulp.dest './'

    fs.mkdirSync(DEST)  unless fs.existsSync DEST
    writeToFile "#{DEST}/config.json", JSON.stringify publicConfig
    return

gulp.task 'appScripts', ['copy'], ->
    src = [
        './src/app/index.coffee'
        './src/app/**/*'
    ]

    stream = gulp.src src
        .pipe coffeelint()
        .pipe coffeelint.reporter()
        .pipe coffee()
        .pipe concat 'app.bundle.js'
        .pipe replace ASSET_REGEX, assetCacheBustFunc

    if config.build.minifyAssets
        stream = stream
            .pipe ngAnnotate()
            .pipe uglify()

    stream
        .pipe gulp.dest DEST
        .pipe livereload lrServer

gulp.task 'depScripts', ->
    gulp.src config.build.jsDependencies
        .pipe concat 'dependencies.bundle.js'
        .pipe uglify()
        .pipe gulp.dest DEST
        .pipe livereload lrServer

gulp.task 'styles', ['copy'], ->
    stylusOptions =
        'include css': true
        'linenos': true

    stream = gulp.src ['./src/styles/_main.styl']
        .pipe stylus stylusOptions
        .pipe autoprefiexer()
        .pipe replace ASSET_REGEX, assetCacheBustFunc
        .pipe rename 'styles.bundle.css'

    if config.build.minifyAssets
        stream = stream.pipe minifyCSS {
            advanced: false
            processImport: false
            aggressiveMerging: false
            shorthandCompacting: false
        }

    stream
        .pipe gulp.dest DEST
        .pipe livereload lrServer

gulp.task 'serve', ->
    http.createServer(ecstatic({root: DEST})).listen config.build.serverPort
    lrServer.listen config.build.liveReloadPort

    console.log 'Running dev server on port ' + config.build.serverPort

gulp.task 'cacheBust', ->
    src = [
        "#{DEST}/**/*.html",
        "#{DEST}/**/*.css",
        "#{DEST}/**/*.js"
    ]
    gulp.src src
        .pipe replace ASSET_REGEX, assetCacheBustFunc
        .pipe gulp.dest DEST

gulp.task 'watch', ->
    gulp.watch ['./src/styles/**/*'], ['styles']
    gulp.watch ['./src/lib/**/*'], ['depScripts']
    gulp.watch ['./src/templates/**/*', './src/index.html'], ['copy']
    gulp.watch ['./src/app/index.coffee', './src/app/**/*'], ['appScripts']

gulp.task 'build', ['clean'], ->
    gulp.start ['styles', 'appScripts', 'depScripts', 'copy', 'icons', 'index.html', 'config']

gulp.task 'default', ['clean'], -> gulp.start ['build', 'serve', 'watch']