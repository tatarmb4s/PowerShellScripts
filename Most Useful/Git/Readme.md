# PowerShell Git Shortcuts

This script provides a collection of PowerShell functions to streamline Git operations. Below are the commands and their meanings based on the naming scheme:

- **`gtcm`**: Git Commit with a title and optional description.
- **`gtps`**: Git Push. Stages changes, optionally commits with a title and description, and pushes them to the remote repository.
- **`gtpr`**: Git Pull Rebase. Rebases local changes on top of the latest remote changes.
- **`gtprps`**: Git Pull Rebase, Commit, and Push. Rebases local changes, then optionally commits and pushes changes with a title and description.

Each function includes help documentation accessible via `Get-Help`.

---

## To import and use the PowerShell script, follow these steps:

### 1. **Save the Script to a `.ps1` File**
Save the script content to a `.ps1` file. For example, save it as `GitShortcuts.ps1`.

### 2. **Import the Script in Your PowerShell Session**
To use the functions in your current session, you can import the script with the `.` dot-sourcing method:

```powershell
. /path/to/GitShortcuts.ps1
```

Replace `/path/to/GitShortcuts.ps1` with the full path to the script file.

### 3. **Make the Script Available Globally (Recommended and Optional)**
If you want the commands to be available in every PowerShell session:

1. **Add the Script to Your PowerShell Profile**:
   - Open your PowerShell profile for editing:
     ```powershell
     notepad $PROFILE
     ```
   - Add the dot-sourcing line to the profile file:
     ```powershell
     . /path/to/GitShortcuts.ps1
     ```
   - Save and close the file.

2. **Reload Your Profile**:
   ```powershell
   . $PROFILE
   ```

Now the `gtcm`, `gtps`, `gtpr`, `gtprps` commands will be available every time you open PowerShell. If you forget what they do, use the `Get-Help <cmdName>` command to access their descriptions and examples.