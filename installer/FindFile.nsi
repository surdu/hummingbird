	!define FindFiles `!insertmacro CallFindFiles`
 
!macro CallFindFiles DIR FILE CBFUNC
    Push "${DIR}"
    Push "${FILE}"
    Push $0
    GetFunctionAddress $0 "${CBFUNC}"
    Exch $0
    Call FindFiles
!macroend

Function FindFiles
    Exch $R5 # callback function
    Exch 
    Exch $R4 # file name
    Exch 2
    Exch $R0 # directory
    Push $R1
    Push $R2
    Push $R3
    Push $R6
    
    Push $R0 # first dir to search
    
    StrCpy $R3 1
    
    nextDir:
      Pop $R0
      IntOp $R3 $R3 - 1
      ClearErrors
      FindFirst $R1 $R2 "$R0\*.*"
      nextFile:
        StrCmp $R2 "." gotoNextFile
        StrCmp $R2 ".." gotoNextFile
    
        StrCmp $R2 $R4 0 isDir
          Push "$R0\$R2"
          Call $R5
          Pop $R6
          GoTo done
          StrCmp $R6 "stop" 0 isDir
            loop:
              StrCmp $R3 0 done
              Pop $R0
              IntOp $R3 $R3 - 1
              Goto loop
    
        isDir:
          IfFileExists "$R0\$R2\*.*" 0 gotoNextFile
            IntOp $R3 $R3 + 1
            Push "$R0\$R2"
    
    gotoNextFile:
      FindNext $R1 $R2
      IfErrors 0 nextFile
    
    done:
      FindClose $R1
      StrCmp $R3 0 0 nextDir
    
    Pop $R6
    Pop $R3
    Pop $R2
    Pop $R1
    Pop $R0
    Pop $R5
    Pop $R4
FunctionEnd
