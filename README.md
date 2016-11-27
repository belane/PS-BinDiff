# PowerShell Binary Diff & Patch

PS-BinDiff binary compares two files and shows similar output to "fc.exe /B" command but also generates a new patch file in powershell. Provide inputs files by command line or through interactive dialogs.
The new generated patch checks file hash and makes back up before apply modifications.



### Example 
```
> .\PS-BinDiff.ps1 -OriginalFile Program.exe -PatchedFile Program_modified.exe

Offset          Org  New
------------------------
0000001A        20   2D
0000001B        50   2A
00002033        20   6F
00002034        44   6E
00003D9B        0D   01
00003D9C        C2   D7
00003D9D        0A   2A
00003D9E        C2   1A
00003D9F        94   70
00003DA0        19   C3
00003DA1        43   AB
000043DE        AF   23
000043DF        9C   39
000043E0        5F   25
00027925        F2   BB
00027926        0C   79
------------------------
Found 16 changes

Generating patch...

Program.exe_PATCH.ps1 ready!
```

### Use
##### Change ExecutionPolicy
```
> Set-ExecutionPolicy -Force -Scope CurrentUser Unrestricted
 or 
> PowerShell.exe -ExecutionPolicy UnRestricted -File PS-BinDiff.ps1
```

##### Generate patch
```
> .\PS-BinDiff.ps1 -OriginalFile Program.exe -PatchedFile Program_modified.exe
```

##### Use your new patch
```
> .\Program.exe_PATCH.ps1
```
