#!/bin/sh

#### GOTO REPOSITORY ROOT
cd "$(git rev-parse --show-toplevel)" >/dev/null

echo "Merge package.json..."
git merge-file package.json .template/package.json .template/package.json

echo "Defining .gitignore..."
echo "*" >.vscode/.gitignore

echo "Done."
cd - >/dev/null
