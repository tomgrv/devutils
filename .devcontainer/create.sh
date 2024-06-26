#!/bin/sh

### Install GitVersion
dotnet tool install --global GitVersion.Tool --version 5.*
sudo ln -s ~/.dotnet/tools/dotnet-gitversion /usr/bin/gitversion

### Install Act
curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash -s -- -b /usr/bin

### Install GitFlow
sudo apt-get update
sudo apt-get install -y git-flow dos2unix php-zip

### Ensure correct access rights
sudo chown -Rf vscode ${containerWorkspaceFolder:-.}/* ${containerWorkspaceFolder:-.}/.*
sudo chmod -Rf 755 ${containerWorkspaceFolder:-.}/* ${containerWorkspaceFolder:-.}/.*
