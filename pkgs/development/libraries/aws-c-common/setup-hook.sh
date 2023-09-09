addAwsCCommonModuleDir() {
    if [ -n "$__structuredAttrs" ]; then
        cmakeFlags=("-DCMAKE_MODULE_PATH=@out@/lib/cmake" "${cmakeFlags[@]}")
    else
        cmakeFlags="-DCMAKE_MODULE_PATH=@out@/lib/cmake ${cmakeFlags:-}"
    fi
}

postHooks+=(addAwsCCommonModuleDir)
