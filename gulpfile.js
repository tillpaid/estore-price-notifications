const gulp = require('gulp')
const coffee = require('gulp-coffee')

const path = {
	source: 'app/source/**/*.coffee',
	public: 'app/public/'
}

gulp.task('compile-coffee', () => {
	gulp
		.src(path.source)
		.pipe(coffee({bare: true}))
		.pipe(gulp.dest(path.public))
})

gulp.task('watch', ['compile-coffee'], () => {
	gulp.watch(path.source, ['compile-coffee'])
})

gulp.task('default', ['compile-coffee'], () => {})
