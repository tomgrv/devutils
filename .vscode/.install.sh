#!/bin/sh

#### GOTO REPOSITORY ROOT
cd "$(git rev-parse --show-toplevel)" >/dev/null

echo "Configuring vscode for this repo..."
chmod ug+x .vscode/*.sh

echo "Defining .gitignore..."
echo "*" >.vscode/.gitignore

echo "Done."
cd - >/dev/null
