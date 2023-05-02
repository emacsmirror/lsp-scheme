#!/usr/bin/bash

ARGS=$@

BASE_DIR=$(readlink -f $(dirname $0))
CUR_DIR=`pwd`

deps=("codeberg.org/rgherdt/srfi" \
          "github.com/ashinn/irregex" \
          "github.com/rgherdt/chibi-scheme" \
          "codeberg.org/rgherdt/scheme-json-rpc/json-rpc" \
          "codeberg.org/rgherdt/scheme-lsp-server/lsp-server")

for dep in ${deps[@]}; do
    gsi -uninstall $dep > /dev/null 2>&1
    gsi -install $dep
done

gsc codeberg.org/rgherdt/scheme-json-rpc/json-rpc

userlib_path=`gsi -e '(display (path-expand "~~userlib"))'`
scheme_lsp_dir=${userlib_path}codeberg.org/rgherdt/scheme-lsp-server/@
compile_script=${scheme_lsp_dir}/gambit/compile.sh

if ! [ -f $compile_script ]; then
    echo "Library not installed. Aborting."
    exit 1
fi

echo "Compiling library."

cd $scheme_lsp_dir/gambit
rm -f $BASE_DIR/gambit-lsp-server

sh ./compile.sh
cp $scheme_lsp_dir/gambit/gambit-lsp-server $BASE_DIR
cd $CUR_DIR
