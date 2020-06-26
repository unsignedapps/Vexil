#!/bin/bash

#
# These sed commands are from Norio Nomura's action-swiftlint:
#       https://github.com/norio-nomura/action-swiftlint
#

# convert the input on stdin into GitHub Actions Logging commands
# https://help.github.com/en/github/automating-your-workflow-with-github-actions/development-tools-for-github-actions#logging-commands

function stripPWD() {
    sed 
}

function convertToGitHubActionsLoggingCommands() {
    sed -E 's/^(.*):([0-9]+):([0-9]+): (warning|error|[^:]+): (.*)/::\4 file=\1,line=\2,col=\3::\5/'
}

cat - | stripPWD | convertToGitHubActionsLoggingCommands