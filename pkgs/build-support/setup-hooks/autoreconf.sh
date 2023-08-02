preConfigurePhases="${preConfigurePhases:-} autoreconfPhase"

autoreconfPhase() {
    runHook preAutoreconf

    if [ -n "$__structuredAttrs" ]; then
        defaultFlags=(--install --force --verbose)
        autoreconf "${autoreconfFlags[@]:-"${defaultFlags[@]}"}"
    else
        autoreconf ${autoreconfFlags:---install --force --verbose}
    fi
    runHook postAutoreconf
}
