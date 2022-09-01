# PowerShell Binary Diff & Patch

Compares two binary files and generates a patch file in PowerShell. 

The generated patch checks the file hash and makes a backup before applying modifications.

## Usage

#### Change ExecutionPolicy

```
PS> Set-ExecutionPolicy -Force -Scope CurrentUser Unrestricted
 or 
PS> PowerShell.exe -ExecutionPolicy UnRestricted -File PS-BinDiff.ps1
```

#### Generate patch

```
PS> .\PS-BinDiff.ps1 -OriginalFile program.exe -PatchedFile program_modified.exe
```

#### Apply your new patch

```
PS> .\program.exe_PATCH.ps1
```

## Output

```
PS> .\PS-BinDiff.ps1 -OriginalFile program.exe -PatchedFile program_modified.exe

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

program.exe_PATCH.ps1 ready!
```

```
PS> .\program.exe_PATCH.ps1

Patching...
0000001A  2D
0000001B  2A
00002033  6F
00002034  6E
00003D9B  01
00003D9C  D7
00003D9D  2A
00003D9E  1A
00003D9F  70
00003DA0  C3
00003DA1  AB
000043DE  23
000043DF  39
000043E0  25
00027925  BB
00027926  79

Writing...

Done!
```
