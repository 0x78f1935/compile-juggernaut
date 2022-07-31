#!/bin/bash

# Fail on errors.
set -e

# Make sure .bashrc is sourced
. /root/.bashrc

# Allow the workdir to be set using an env var.
# Useful for CI pipiles which use docker for their build steps
# and don't allow that much flexibility to mount volumes
WORKDIR=${SRCDIR:-/src}
mkdir -p $WORKDIR

cd $WORKDIR

echo "Installing build/spec requirements"
if [ -f build_requirements.txt ]; then
    pip install -r build_requirements.txt
fi # [ -f build_requirements.txt ]

echo "Installing application requirements"
if [ -f requirements.txt ]; then
    pip install -r requirements.txt
fi # [ -f requirements.txt ]

echo "$@"

if [[ "$@" == "" ]]; then
    if [ -f $SPEC_FILENAME ]; then
        pyinstaller --clean --dist ./dist/unix $SPEC_FILENAME
        chown -R --reference=. ./dist/unix
    else
        echo "Please provide a valid spec file in the root of your volume mount"
    fi # [ -f *.spec ]
else
    sh -c "$@"
fi # [[ "$@" == "" ]]

echo "Build can be found in the './dist' folder"
