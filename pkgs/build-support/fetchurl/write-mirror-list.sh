if [ -e .attrs.sh ]; then source .attrs.sh; fi

source $stdenv/setup

# !!! this is kinda hacky.
set | grep -E '^[a-zA-Z]+=.*://' > $out
