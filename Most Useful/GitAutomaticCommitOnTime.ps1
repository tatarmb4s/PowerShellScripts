#author ttrmb4s
# This scripts automatically commits and pushes a repository to GitHub or other git hosting service.
$time = 10; # In seconds
$waitAfterCommit = 5; # In seconds
$folder = "E:\Temp\gittemo"; # Repo folder path
while ($true) {
    cd $folder;
    git add .;
    git commit -m "Commit at $(Get-Date)";
    Start-Sleep -s $waitAfterCommit;
    git push;
    Start-Sleep -s $time;
}