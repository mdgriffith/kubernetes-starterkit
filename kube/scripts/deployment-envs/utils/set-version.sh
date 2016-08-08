#!/bin/bash

# There are uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "# There are uncommitted changes.  Commit them and run deploy again."
    exit 1
fi
if git describe --abbrev=0 --tags; then
    printf "# Last version released was "
    git describe --abbrev=0 --tags
else
    echo "# There are no previous releases"
fi
echo "# What version number should be used for this release? "
read version

if [[ -z "$version" ]]; then
   echo "Version can't be left blank, exiting without deploying."
   exit 1
fi

# Tags releases in github
git tag -a $version -m "$version release"
git push --tags

echo "export STARTERKIT_CURRENT_VERSION=$version"
