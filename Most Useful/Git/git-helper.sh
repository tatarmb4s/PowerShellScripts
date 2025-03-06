#!/bin/bash

# Function: gtcm
# Description: Performs a Git commit with a title and optional description.
gtcm() {
    local title="$1"
    local desc="$2"

    echo "Staging all changes..."
    git add .

    if [ -n "$desc" ]; then
        echo "Committing changes with title: \"$title\" and description: \"$desc\""
        git commit -s -m "$title" -m "$desc"
    else
        echo "Committing changes with title: \"$title\""
        git commit -s -m "$title"
    fi
}

# Function: gtps
# Description: Stages changes, commits them with a title and optional description, and pushes to the remote repository.
gtps() {
    local title="$1"
    local desc="$2"

    if [ -z "$title" ]; then
        echo "Pushing changes..."
        git push
    else
        echo "Committing and pushing changes..."
        gtcm "$title" "$desc"
        echo "Pushing changes..."
        git push
    fi
}

# Function: gtpr
# Description: Performs a Git pull with rebase.
gtpr() {
    echo "Pulling changes with rebase..."
    git pull --rebase
}

# Function: gtprps
# Description: Performs a Git pull with rebase and optionally stages, commits, and pushes changes.
gtprps() {
    local title="$1"
    local desc="$2"

    if [ -z "$title" ]; then
        echo "Pulling changes with rebase..."
        git pull --rebase
    else
        gtcm "$title" "$desc"

        echo "Pulling changes with rebase..."
        git pull --rebase

        gtps
    fi
}

# Ensure the functions are available when the script is sourced.
export -f gtcm
export -f gtps
export -f gtpr
export -f gtprps

# Example usage:
# gtcm "Title" "Description"
# gtps "Title" "Description"
# gtpr
# gtprps "Title" "Description"
