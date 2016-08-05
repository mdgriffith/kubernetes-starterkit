#!/bin/bash
# There are uncommitted changes
# if ! git diff-index --quiet HEAD --; then
#     echo "# There are uncommitted changes.  Commit them and run deploy again."
#     exit 1
# fi
{
    printf "# Last version released was "
    existing=$(git describe --abbrev=0 --tags)
    # printf "$existing"
} || {
    printf "# No versions are present yet.\n"
}
echo "# What version number should be used for this release? "
printf "# "
read version

if [[ -z "$version" ]]; then
   echo "# Version can't be left blank, exiting without deploying."
   exit 1
fi

echo "export STARTERKIT_VERSION=$version"
