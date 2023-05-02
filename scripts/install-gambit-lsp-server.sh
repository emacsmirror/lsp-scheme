#!/bin/sh

set -e

BASE_DIR=$(readlink -f $(dirname $0))
CUR_DIR=`pwd`

gsi -uninstall "codeberg.org/rgherdt/srfi"
gsi -uninstall "github.com/ashinn/irregex"
gsi -uninstall "github.com/rgherdt/chibi-scheme"
gsi -uninstall "codeberg.org/rgherdt/scheme-json-rpc/json-rpc"
gsi -uninstall "codeberg.org/rgherdt/scheme-lsp-server/lsp-server"
gsi -install "codeberg.org/rgherdt/srfi"
gsi -install "github.com/ashinn/irregex"
gsi -install "github.com/rgherdt/chibi-scheme"
gsi -install "codeberg.org/rgherdt/scheme-json-rpc/json-rpc"
gsi -install "codeberg.org/rgherdt/scheme-lsp-server/lsp-server"

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
cd $CUR_DIR
