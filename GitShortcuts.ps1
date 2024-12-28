# Define the gcm function
function gtcm {
    param (
        [string]$Title,
        [string]$Desc
    )

    # Stage all changes
    git add .

    # Create the commit message
    $commitMessage = "-m `"$Title`""
    if ($Desc) {
        $commitMessage += " -m `"$Desc`""
    }

    # Run the commit command
    Invoke-Expression "git commit -s $commitMessage"
}

# Define the gps function
function gtps {
    param (
        [string]$Title,
        [string]$Desc
    )

    if (-not $Title) {
        # If no parameters are provided, push directly
        git push
    } else {
        # Stage and commit with the provided title and optional description
        gtcm -Title $Title -Desc $Desc
        git push
    }
}

# Define the gps function
function gtprb {
    git pull --rebase
}

# Define the gps function
function gtprbp {
    param (
        [string]$Title,
        [string]$Desc
    )

    if (-not $Title) {
        # If no parameters are provided, push directly
        git pull --rebase
    } else {
        # Stage and commit with the provided title and optional description
        gtps -Title $Title -Desc $Desc
    }
}