Name "Hummingbird"
Caption "Hummingbird v1.0 BETA1"
Icon "icon.ico"
OutFile "setup.exe"

BGGradient FFFF00 FF0000 FF0000
XPStyle on

ShowInstDetails show

!include FindFile.nsi
!include GetParentDir.nsi
!include GetSections.nsi
!include GetValues.nsi

!include "FileFunc.nsh"
!insertmacro GetDrives

InstallDir ""

Page directory
Page instfiles

DirText "Choose the 3ds max directory if the installer did not found if or found it incorectly." "3ds max directory"
Var menuFile
Var iniSearchFlag
Var renderIniMenu
Var menuItemCount

Function SetInstallPath
    Exch $0
    Push $0
    Call GetParent
    Pop $R0
    StrCpy $INSTDIR $R0
FunctionEnd

Function Find3dsOnHdd
    !insertmacro CallFindFiles C: 3dsmax.exe SetInstallPath
FunctionEnd

Function FindRenderMenu
    StrCmp $9 'MenuName="&Rendering"' ok next
    ok:
        StrCpy $iniSearchFlag 0
    next:
FunctionEnd

Function ParseIniSection
    StrCpy $renderIniMenu $1
    ${GetSection} $menuFile $1 "FindRenderMenu"
    StrCmp $iniSearchFlag 0 0 next
    StrCpy $0 StopGetSectionNames
    next:
    Push $0
FunctionEnd

Function .onInit
    System::Call 'kernel32::CreateMutexA(i 0, i 0, t "myMutex") i .r1 ?e'
    Pop $R0
    
    StrCmp $R0 0 +3
    MessageBox MB_OK|MB_ICONEXCLAMATION "The installer is already running."
    Abort
    
	InitPluginsDir
	File /oname=$PLUGINSDIR\splash.bmp "splash.bmp"

    advsplash::show 3000 600 400 -1 $PLUGINSDIR\splash
    MessageBox MB_OK "The installer will now search for 3ds max on your machine. This may take some time."
    ${GetDrives} "HDD" "Find3dsOnHdd"
FunctionEnd

Section "Main"

    SetOutPath $INSTDIR
    File ..\source\cvds_logo.bmp
    SetOutPath $INSTDIR\UI\Macroscripts    
    File ..\source\CVDS-Hummingbird.mcr
    SetOutPath $INSTDIR\Scenes\Hummingbird    
    File ..\source\test.max
    File ..\source\TestCurve.hbc
    SetOutPath $INSTDIR\Animations\Hummingbird    
    File ..\source\test.avi
        
    ReadINIStr $menuFile $INSTDIR\3dsmax.ini CustomMenus FileName
    
    StrCpy $iniSearchFlag 1
    
    ${GetSectionNames} $menuFile "ParseIniSection"  
    ReadINIStr $menuItemCount $menuFile $renderIniMenu ItemCount
    
    IntOp $R0 $menuItemCount + 2
    IntOp $R1 $menuItemCount + 1 
    
    WriteINIStr $menuFile $renderIniMenu ItemCount $R0
    WriteINIStr $menuFile $renderIniMenu Item_$menuItemCount_Mode 1
    WriteINIStr $menuFile $renderIniMenu Item_$R1_Mode 2
    WriteINIStr $menuFile $renderIniMenu Item_$R1_Action 647394|Hummingbird`CVDS
    
SectionEnd
