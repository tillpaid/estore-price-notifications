const gulp = require('gulp')
const coffee = require('gulp-coffee')

const path = {
	source: 'app/source/**/*.coffee',
	public: 'app/public/'
}

function compileCoffee() {
	return gulp
		.src(path.source)
		.pipe(coffee({bare: true}))
		.pipe(gulp.dest(path.public))
}

function watcher() {
	gulp.watch(path.source, build)
}

var build = gulp.series(compileCoffee)
var watch = gulp.series(build, watcher)

exports.build = build
exports.watch = watch

exports.default = build
