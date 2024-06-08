#!/bin/sh



### Go to root
cd $(git rev-parse --show-toplevel) >/dev/null

### Alias to current module
module=$(dirname $(readlink -f $0))

### Merge all files from stub folder to root with git merge-file
echo "Merging stub files" | npx chalk-cli --stdin blue
for file in $(find $module/stub -type f); do

    ### Get middle part of the path
    folder=$(dirname ${file#$module/stub/})

    ### Create folder if not exists
    mkdir -p $folder

    ### Merge file
    echo "Merge $folder/$(basename $file)" | npx chalk-cli --stdin yellow
    git merge-file -p $file $folder/$(basename $file) ${folder#./}/$(basename $file) >$folder/$(basename $file)
done

### find all file with a trailing slash outside dist folder, make sure they are added to .gitignore and remove the trailing slash
echo "Add files to .gitignore" | npx chalk-cli --stdin blue
for file in $(find . -type f -name "*#" -not -path "./stub/*" -not -path "./node_modules/*" -not -path "./vendors/*"); do

    echo "Add $file to .gitignore" | npx chalk-cli --stdin yellow

    ### Remove trailing # and leading ./
    clean=${file%#}
    clean=${clean#./}

    ### Add to .gitignore if not already there
    grep -qxF $clean .gitignore || echo $clean >>.gitignore

    ### Rename file
    mv $file ${file%#}
done

### Ask to restart in container if this is not already the case
if [  "$CODESPACES" != "true" ] && [ "$REMOTE_CONTAINERS" != "true" ]; then
    echo "You are not in a container, please restart in a container" | npx chalk-cli --stdin yellow
    exit 0
fi

### Ask to rebuild container if devcontainer.json has changed
if [ -n "$(git diff --name-only HEAD^ HEAD .devcontainer/devcontainer.json)" ]; then
    echo "devcontainer.json has changed, please rebuild the container" | npx chalk-cli --stdin yellow
    exit 0
fi

### Call the install.sh script in all subfloder of the dist folder
for file in $(find $module/dist -type f -name "install.sh"); do

    ### Get middle part of the path
    folder=$(dirname ${file#$module/dist/})

    ### Add folder to .gitignore if not already there
    echo "Add .$folder to .gitignore" | npx chalk-cli --stdin yellow

    ### Add folder to .gitignore if not already there
    grep -qxF /.$folder .gitignore || echo /.$folder >>.gitignore

    ### Run the install.sh script
    echo "Running $file" | npx chalk-cli --stdin blue
    bash $file
done
