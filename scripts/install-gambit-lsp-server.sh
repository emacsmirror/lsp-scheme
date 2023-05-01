#!/usr/bin/bash

ARGS=$@

BASE_DIR=$(dirname $0)

force_flag=0
compile_flag=0

if [ "$#" -eq 1 ]; then
    if test "$1" = "compile"; then
        echo "COMPILE"
        compile_flag=1
    fi
fi

deps=("codeberg.org/rgherdt/srfi" \
          "github.com/ashinn/irregex" \
          "github.com/rgherdt/chibi-scheme" \
          "codeberg.org/rgherdt/scheme-json-rpc/json-rpc" \
          "codeberg.org/rgherdt/scheme-lsp-server/lsp-server")

for dep in ${deps[@]}; do
    gsi -uninstall $dep > /dev/null 2>&1
    gsi -install $dep
done

if [ $compile_flag -eq 1 ]; then
    gsc codeberg.org/rgherdt/scheme-lsp-server/lsp-server/private/gambit \
        codeberg.org/rgherdt/scheme-lsp-server/lsp-server/private/util \
        codeberg.org/rgherdt/scheme-lsp-server/lsp-server/private/parse \
        codeberg.org/rgherdt/scheme-lsp-server/lsp-server/private/adapter \
        codeberg.org/rgherdt/scheme-lsp-server/lsp-server/private/trie \
        codeberg.org/rgherdt/scheme-lsp-server/lsp-server
fi

gsc -exe -nopreload ${BASE_DIR}/gambit-lsp-server.scm
