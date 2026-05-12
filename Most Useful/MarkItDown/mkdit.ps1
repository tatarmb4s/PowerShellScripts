function mid {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$InputFile,

        [string]$PathFilename
    )

    # Ensure the input file exists
    if (-not (Test-Path $InputFile)) {
        Write-Error "❌ Input file not found: $InputFile"
        return
    }

    try {
        # Resolve full input path
        $resolvedInputPath = (Resolve-Path -Path $InputFile).Path

        # Determine output path
        if ($PathFilename) {
            $outputPath = $PathFilename
        } else {
            $outputPath = [System.IO.Path]::ChangeExtension($resolvedInputPath, ".md")
        }

        # Execute via cmd to preserve Unicode
        $cmdCommand = "markitdown.exe `"$resolvedInputPath`" > `"$outputPath`""
        cmd /c $cmdCommand

        if (Test-Path $outputPath) {
            Write-Host "✅ Markdown file created:" -NoNewline
            Write-Host " $outputPath" -ForegroundColor Cyan
        } else {
            Write-Warning "⚠️ Command ran, but output file not found. Check markitdown.exe execution."
        }

    } catch {
        Write-Error "❌ Failed to run mkdit: $_"
    }
}
