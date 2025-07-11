; Script based on Off-the-Record Messaging NSI file


SetCompress off

; todo: SetBrandingImage
; HM NIS Edit Wizard helper defines
!ifndef PRODUCT_NAME
!define PRODUCT_NAME "purple-googlechat"
!endif
!ifndef PRODUCT_VERSION
!define PRODUCT_VERSION "v0.1"
!endif
!define PRODUCT_PUBLISHER "Eion Robb"
!define PRODUCT_WEB_SITE "http://eion.robbmob.com/"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!ifndef JSON_GLIB_DLL
!define JSON_GLIB_DLL "libjson-glib-1.0.dll"
!endif
!ifndef PROTOBUF_C_DLL
!define PROTOBUF_C_DLL "libprotobuf-c-1.dll"
!endif
!ifndef PIDGIN_VARIANT
!define PIDGIN_VARIANT "Pidgin"
!endif
!ifndef INSTALLER_NAME
!define INSTALLER_NAME ${PRODUCT_NAME}
!endif

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
!insertmacro MUI_PAGE_LICENSE "LICENSE"
; Directory page
;!define MUI_PAGE_CUSTOMFUNCTION_PRE dir_pre
;!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Run ${PIDGIN_VARIANT}"
!define MUI_FINISHPAGE_RUN_FUNCTION "RunPidgin"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
;!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "${INSTALLER_NAME}.exe"
InstallDir "$PROGRAMFILES\${PIDGIN_VARIANT}"

Var "PidginDir"

ShowInstDetails show
ShowUnInstDetails show

Section "MainSection" SEC01

    ;Check for pidgin installation
    Call GetPidginInstPath
    
    SetOverwrite ifnewer
	
	SetOutPath "$PidginDir"
	File "${JSON_GLIB_DLL}"
	File "${PROTOBUF_C_DLL}"
    
    SetOverwrite try
    
	SetOutPath "$PidginDir\pixmaps\pidgin"
	File "/oname=protocols\16\googlechat.png" "googlechat16.png"
	File "/oname=protocols\22\googlechat.png" "googlechat22.png"
	File "/oname=protocols\48\googlechat.png" "googlechat48.png"

    SetOverwrite try
    
	SetOutPath "$PidginDir\ca-certs"
	File "Google Internet Authority G2.pem"
	File "Google Internet Authority G3.pem"
	File "Google Trust Services - GlobalSign Root CA-R2.pem"
	File "GTS CA 1O1.pem"

    SetOverwrite try
	
	copy:
		ClearErrors
		Delete "$PidginDir\plugins\libgooglechat.dll"
		IfErrors dllbusy
		SetOutPath "$PidginDir\plugins"
	        File "libgooglechat.dll"
		Goto after_copy
	dllbusy:
		Delete "$PidginDir\plugins\libgooglechat.dllold"
		Rename  "$PidginDir\plugins\libgooglechat.dll" "$PidginDir\plugins\libgooglechat.dllold"
		MessageBox MB_OK "Old version of plugin detected.  You will need to restart ${PIDGIN_VARIANT} to complete installation"
		Goto copy
	after_copy:
	
SectionEnd

Function GetPidginInstPath
  Push $0
  ReadRegStr $0 HKLM "Software\${PIDGIN_VARIANT}" ""
	IfFileExists "$0\pidgin.exe" cont
	ReadRegStr $0 HKCU "Software\${PIDGIN_VARIANT}" ""
	IfFileExists "$0\pidgin.exe" cont
		MessageBox MB_OK|MB_ICONINFORMATION "Failed to find ${PIDGIN_VARIANT} installation."
		Abort "Failed to find ${PIDGIN_VARIANT} installation. Please install ${PIDGIN_VARIANT} first."
  cont:
	StrCpy $PidginDir $0
FunctionEnd

Function RunPidgin
	ExecShell "" "$PidginDir\pidgin.exe"
FunctionEnd

