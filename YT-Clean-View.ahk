; YouTube Clean Viewer
; 1. Checks if clipboard is YT link
; 2. Opens link in DETURL's Clean Viewer webpage (using OS's default browser)
; 3. Tries to switch back to original tab
; NOTE: Recommend disable browser autoplaying media else tabbing through might start videos on other tabs

; AUTO-EXECUTE
#Requires AutoHotkey v2+ 64-bit
#SingleInstance Ignore ; only allows a single older instance of this script (to allow older instance to finish)
#NoTrayIcon
#Include "D:\Google Drive\_ADMIN\SCRIPTS\_AHK SCRIPTS\UIA-v2-1.1.3\Lib\UIA.ahk"
#Include "D:\Google Drive\_ADMIN\SCRIPTS\_AHK SCRIPTS\UIA-v2-1.1.3\Lib\UIA_Browser.ahk" ; both UIA includes needed to enable switching directly to particular browser tabs

; DEFAULTS (shouldn't need to change any of these)
winDir:=			EnvGet("windir") ; Used later to play notification sound
defaultBrowserKeyName:=	RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html\UserChoice", "ProgId") ; find which program is registered to open .html files
defaultBrowserCmd:=	RegRead("HKCR\" defaultBrowserKeyName "\shell\open\command") ; find command that opens that program
RegexMatch(defaultBrowserCmd, '\"?(.*\\(.*\.exe))\"?', &defaultBrowserExe) ; extract the program's executable + path (defaultBrowserExe[1]) and executable - path (defaultBrowserExe[2])
defaultBrowser:=	"ahk_exe " defaultBrowserExe[2]
cUIA:=				UIA_Browser(defaultBrowser)
DETURL:=			"https://deturl.com/play.php?v="
tURL:=				"Simple YouTube video player"
YTneedle:=			"youtu\.?be(?:\.com\/)?(?:e|embed|live|shorts|v|watch)?(?:\/|\?v=|\?(?:.*?)&v=)?(.*)" ; check bottom of script for YT URL list
CLEANneedle:=		"\?si=.*" ; used to remove an appended ?si=* flag

; Parse clipboard for YT link and exit if not
If !RegexMatch(A_Clipboard, YTneedle, &Link) {
	SoundPlay(winDir "\Media\Windows User Account Control.wav", 1) ; 1= wait to finish playing (else exit truncates sound)
	ExitApp
}

; Save current tab title for restoration
Try ogTab:= cUIA.GetTab().Name ; 'Name' is required for SelectTab() below

; Open link in DETURL webpage of OS's default browser
cleanLink:= RegExReplace(Link[1], CLEANneedle)
RunWait(DETURL cleanLink)
cUIA.WaitPageLoad(tURL,5,500,1,True) ; SetTitleMatchMode = begins with >> browser may sometimes append additional info after title?

; Return browser tab to original position
If IsSet(ogTab)
	Try cUIA.SelectTab(ogTab,1,True) ; SetTitleMatchMode = begins with >> browser may sometimes append additional info after title?

/* LIST OF CURRENT YT URL STYLES
	>>> all @ symbols below denote the unique portion of its address (as well as the possibility of appended flags which start with &/?/#)
	>>> any * symbols below denote unique character combinations and/or flags
	>>> the DETURL viewer seems to ignore all flags
	>>>	>>	HOWEVER, the ?si= flag breaks the url
	>>>	>>	so that flag needs to be scrubbed before attempting to open the tweaked URL
	youtu.be/@
	youtu.be/@?si=*			; when link comes from iOS YT app
	youtube.com/e/@
	youtube.com/embed/@
	youtube.com/live/@
	youtube.com/shorts/@
	youtube.com/shorts/@?si=*	; when link comes from iOS YT app
	youtube.com/v/@
	youtube.com/watch/@
	youtube.com/watch?v=@
	youtube.com/watch?*&v=@
*/
