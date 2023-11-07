#!/bin/sh

# PARSE ARGUMENTS
while [ $# -gt 0 ]; do
    key="$1"

    case $key in
    -f | --force)
        FORCE="true"
        shift # past argument
        shift # past value
        ;;
    *) # unknown option
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
done

#### GOTO REPOSITORY ROOT
cd "$(git rev-parse --show-toplevel)" >/dev/null

#### DETECT OS
unameOut="$(uname -s)"

#### MAP OS TO MACHINE
case "${unameOut}" in
Linux*) machine=Linux ;;
Darwin*) machine=Mac ;;
CYGWIN*) machine=Cygwin ;;
MINGW*) machine=MinGw ;;
*) machine="UNKNOWN:${unameOut}" ;;
esac

#### CONFIGURE REPO FOR MAC
if [ "$machine" == "Mac" ]; then
    echo 'Configuring git for Mac...'
fi

#### CONFIGURE REPO FOR LINUX
if [ "$machine" == "Linux" ]; then
    echo 'Configuring git for Linux...'

fi

#### CONFIGURE REPO FOR MinGw/WINDOWS
if [ "$machine" == "MinGw" ]; then
    echo 'Configuring git for MinGw...'
    git config core.filemode false
    git config credential.helper wincred
fi

echo "Configuring git globally for all platforms..."
git config core.editor "code --wait"
git config core.autocrlf input
git config alias.utils "!sh -c \"$(readlink -f $0) \" - "
git config alias.amend '!sh -c "git diff-index --cached --quiet HEAD || git commit --amend -C HEAD" - '
git config alias.undo '!sh -c "git reset --soft HEAD^ --" - '
git config alias.clean '!sh -c "git reset --hard HEAD --" - '
git config alias.renameTag '!sh -c "set -e;git tag $2 $1; git tag -d $1;git push origin :refs/tags/$1;git push --tags" - '
git config alias.initFrom '!sh -c "git clone --origin template --branch master --depth 1 -- $1 $2 && cd $2 && git branch -m master template && git checkout -b master && git checkout -b develop" - '
git config alias.histo '!sh -c "git log --oneline $(git log --merges --first-parent -1 --pretty=%h)..HEAD $*" - '
git config alias.isChanged '!sh -c "git diff --name-only HEAD@{1} HEAD | grep -q \"^$1\" && (echo true; exit 0) || (echo false; exit 1)" - '
git config alias.hibernate '!sh -c "git stash save --include-untracked  --keep-index; git clean --force -d -x -e \".env*\"; git stash apply --index; git stash drop" - '
git config alias.isRebase '!sh -c "git rev-parse --git-dir | grep -q \"rebase-merge\" || git rev-parse --git-dir | grep -q \"rebase-apply\"" - '
git config alias.isFixup '!sh -c "git log -1 --pretty=%B | grep -q \"fixup!\" && (echo true; exit 0) || (echo false; exit 1)" - '
git config alias.conflicts '!sh -c "git diff --name-only --diff-filter=U" - '
git config alias.align '!sh -c "git checkout --force $(git rev-parse --abbrev-ref HEAD)" - '
git config alias.sync '!sh -c "git fetch --progress --prune --recurse-submodules=no origin && git stash save --keep-index --include-untracked && git merge --ff-only @{u} && git stash pop --index || git stash drop" - '

echo "Adding script aliases..."
for f in $(dirname "$0")/_*.sh; do
    alias=$(basename $f .sh)
    echo "Adding alias for $(readlink -f $f)..."
    git config alias.${alias#_} "!sh -c \"$(readlink -f $f) \$*\" - "
done

echo "Configuring git for this repo..."
chmod ug+x .gitutils/*

echo "Configure json merge driver..."
npm install -g git-json-merge
git config merge.json.driver "git-json-merge %A %O %B"
git config merge.json.name "custom merge driver for json files"

echo "Defining .gitattributes..."
cat <<-EOF >.gitattributes
    * text=auto eol=lf
    *.{cmd,[cC][mM][dD]} text eol=crlf
    *.{bat,[bB][aA][tT]} text eol=crlf
    *.css linguist-vendored
    *.scss linguist-vendored
    *.js linguist-vendored
    *.json merge=json
    CHANGELOG.md export-ignore
EOF

echo "Done."
cd - >/dev/null
