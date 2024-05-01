#!/bin/sh

# Retrieve the latest version of the devutils archive in the temporary directory
curl --location --remote-header-name https://github.com/tomgrv/devutils/archive/main.zip -o /tmp/devutils-main.zip

# Unzip the archive in temporary directory
unzip -Cqo /tmp/devutils-main.zip -d /tmp -x devutils-main/install.sh

# Configure git
git config --global --add safe.directory $PWD

# Stash current modifications
git stash save --include-untracked --keep-index --quiet

# Merge the content of the archive with the current directory
find /tmp/devutils-main/ -type f | while read file; do

    merge="diff --new-file --strip-trailing-cr $file ${file##/tmp/devutils-main/}"

    if ! $merge -q; then
        echo "Merge $file -> ${file##/tmp/devutils-main/}"
        $merge | patch --set-time --remove-empty-files --forward ${file##/tmp/devutils-main/}
    fi
done

# Remove the archive
rm -rf /tmp/devutils-main /tmp/devutils-main.zip

# Call install script for each subdirectory starting with a dot
find . -maxdepth 1 -type d -name '.*' -exec sh -c '{}/.install.sh' \;

# Commit untracked & modified files
git add --all && git commit -m "Chore: Update devutils"

# Pop stashed modifications
git stash pop --quiet

# Init npm if package.json exists
if [ -f package.json ]; then

    if [ $(npm config get workspaces) != "null" ]; then
        npm install --if-present --ws --include-workspace-root
    else
        npm install
    fi

    npm run init
fi
