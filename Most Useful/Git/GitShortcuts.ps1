function gtcm {
    [CmdletBinding()]
    param (
        [string]$Title,
        [string]$Desc
    )

    <#
    .SYNOPSIS
    Performs a Git commit with a title and optional description.

    .PARAMETER Title
    The title of the commit.

    .PARAMETER Desc
    An optional description for the commit.

    .EXAMPLE
    gtcm -Title "Initial Commit" -Desc "Added all project files."

    .NOTES
    Naming Scheme:
    gt = Git, cm = Commit
    #>

    Write-Host "Staging all changes..."
    git add .

    $commitMessage = "-m `"$Title`""
    if ($Desc) {
        $commitMessage += " -m `"$Desc`""
    }

    Write-Host "Committing changes with message: $commitMessage"
    Invoke-Expression "git commit -s $commitMessage"
}

function gtps {
    [CmdletBinding()]
    param (
        [string]$Title,
        [string]$Desc
    )

    <#
    .SYNOPSIS
    Stages changes, commits them with a title and optional description, and pushes them to the remote repository.

    .PARAMETER Title
    The title of the commit.

    .PARAMETER Desc
    An optional description for the commit.

    .EXAMPLE
    gtps -Title "Bug Fix" -Desc "Resolved issue with login functionality."

    .EXAMPLE
    gtps
    # Pushes changes without committing.

    .NOTES
    Naming Scheme:
    gt = Git, ps = Push
    #>

    if (-not $Title) {
        Write-Host "Pushing changes..."
        git push
    } else {
        Write-Host "Committing and pushing changes..."
        gtcm -Title $Title -Desc $Desc
        Write-Host "Pushing changes..."
        git push
    }
}

function gtpr {
    [CmdletBinding()]
    param ()

    <#
    .SYNOPSIS
    Performs a Git pull with rebase, ensuring that local changes are rebased on top of the latest remote changes.

    .EXAMPLE
    gtprb

    .NOTES
    Naming Scheme:
    gt = Git, pr = Pull Rebase
    #>

    Write-Host "Pulling changes with rebase..."
    git pull --rebase
}

function gtprps {
    [CmdletBinding()]
    param (
        [string]$Title,
        [string]$Desc
    )

    <#
    .SYNOPSIS
    Performs a Git pull with rebase and optionally stages, commits, and pushes changes.

    .PARAMETER Title
    The title of the commit.

    .PARAMETER Desc
    An optional description for the commit.

    .EXAMPLE
    gtprbp -Title "Feature Update" -Desc "Added new authentication module."

    .EXAMPLE
    gtprbp
    # Performs a pull with rebase without committing or pushing changes.

    .NOTES
    Naming Scheme:
    gt = Git, pr = Pull Rebase, ps = Push (optional commit like in the gtps)
    #>

    if (-not $Title) {
        Write-Host "Pulling changes with rebase..."
        git pull --rebase
    } else {
        Write-Host "Pulling changes with rebase..."
        git pull --rebase
        Write-Host "Committing and pushing changes after rebase..."
        gtps -Title $Title -Desc $Desc
    }
}
