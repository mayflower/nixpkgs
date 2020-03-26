# This setup hook strips libraries and executables in the fixup phase.

fixupOutputHooks+=(_checkHardening)

_checkHardening() {
    if [ -z "$dontCheckHardening" ]; then
        zvelf $prefix
    fi
}
