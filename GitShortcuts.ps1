# Define the gcm function
function gtcm {
    param (
        [string]$Title,
        [string]$Desc
    )

    # Stage all changes
    Write-Host "Staging all changes..."
    git add .

    # Create the commit message
    $commitMessage = "-m `"$Title`""
    if ($Desc) {
        $commitMessage += " -m `"$Desc`""
    }

    # Run the commit command
    Write-Host "Committing changes with message: $commitMessage"
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
        Write-Host "Pushing changes..."
        git push
    } else {
        # Stage and commit with the provided title and optional description
        Write-Host "Committing and pushing changes..."
        gtcm -Title $Title -Desc $Desc
        Write-Host "Pushing changes..."
        git push
    }
}

# Define the gps function
function gtprb {
    Write-Host "Pulling changes with rebase..."
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
        Write-Host "Pulling changes with rebase..."
        git pull --rebase
    } else {
        # Stage and commit with the provided title and optional description
        Write-Host "Pulling changes with rebase..."
        git pull --rebase
        Write-Host "Committing and pushing changes after rebase..."
        gtps -Title $Title -Desc $Desc
    }
}
