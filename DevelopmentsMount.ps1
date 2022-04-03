#Thus script unounts / mounts a virtual disk
Dismount-VHD -Path D:\!Hyper-V\MDP-X64\MDP-X64_Data.vhdx -PassThru | Get-Disk | Get-Partition | Get-Volume
Mount-VHD -Path D:\!Hyper-V\MDP-X64\MDP-X64_Data.vhdx -PassThru | Get-Disk | Get-Partition | Get-Volume