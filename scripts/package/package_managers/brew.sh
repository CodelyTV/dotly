brew::install() {
	# Some aliases
	case "$1" in
	"docpars") package="denisidoro/tools/docpars" ;;
	*) package="$1" ;;
	esac

	brew install "$package"
}
