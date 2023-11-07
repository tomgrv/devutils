#!/bin/sh

#### GOTO REPOSITORY ROOT
cd "$(git rev-parse --show-toplevel)" >/dev/null

echo "Configuring husky for this repo..."
chmod ug+x .husky/*
npx husky install

echo "Done."
cd - >/dev/null
