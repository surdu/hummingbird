	!define GetSectionNames `!insertmacro GetSectionNamesCall`
 
	!macro GetSectionNamesCall _FILE _FUNC
		Push $0
		Push `${_FILE}`
		GetFunctionAddress $0 `${_FUNC}`
		Push `$0`
		Call GetSectionNames
		Pop $0
	!macroend

Function GetSectionNames 
	Exch $R1
	Exch
	Exch $0
	Exch
	Push $2
	Push $3
	Push $4
	Push $5
	Push $8
	Push $1
 
	System::Alloc 1024
	Pop $2
        StrCpy $3 $2
 
        System::Call "kernel32::GetPrivateProfileSectionNamesA(i, i, t) i(r3, 1024, r0) .r4"
       
	enumok:
        System::Call 'kernel32::lstrlenA(t) i(i r3) .r5'
	StrCmp $5 '0' enumex
 
	System::Call '*$3(&t1024 .r1)'
 
	Push $0
	Push $R1
	Push $2
	Push $3
	Push $4
	Push $5
	Push $8
	Call $R1
	Pop $1
	Pop $8
	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $R1
	Pop $0
        StrCmp $1 'StopGetSectionNames' enumex
 
	IntOp $3 $3 + $5
	IntOp $3 $3 + 1
	goto enumok
 
	enumex:
	System::Free $2
 
	Pop $1
	Pop $8
	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $R1
	Pop $0
FunctionEnd
