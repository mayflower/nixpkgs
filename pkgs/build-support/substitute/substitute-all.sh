if [ -f .attrs.sh ]; then
    source .attrs.sh
fi

source $stdenv/setup

eval "$preInstall"

args=

target=$out
if test -n "$dir"; then
    target=$out/$dir/$name
    mkdir -p $out/$dir
fi

substituteAll $src $target

if test -n "$isExecutable"; then
    chmod +x $target
fi

eval "$postInstall"
