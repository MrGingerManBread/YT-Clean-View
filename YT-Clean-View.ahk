; YouTube Clean Viewer
; 1. Checks if clipboard is YT link
; 2. Opens link in DETURL's Clean Viewer webpage (using OS's default browser)
; 3. Tries to switch back to original tab
; NOTE: Recommend disable browser autoplaying media else tabbing through might start videos on other tabs

; AUTO-EXECUTE
#Requires AutoHotkey v2+ 64-bit
#SingleInstance Ignore ; only allows a single older instance of this script (to allow older instance to finish)
#NoTrayIcon
#Include <UIA>
#Include <UIA_Browser> ; both includes need to be Descolada's v2 [https://github.com/Descolada/UIA-v2]

; DEFAULTS (shouldn't need to change any of these)
winDir:=		EnvGet("windir") ; Used later to play notification sound
defaultBrowserKeyName:=	RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html\UserChoice", "ProgId") ; find which program is registered to open .html files
defaultBrowserCmd:=	RegRead("HKCR\" defaultBrowserKeyName "\shell\open\command") ; find command to open said program
RegexMatch(defaultBrowserCmd, '\"?(.*\\(.*\.exe))\"?', &defaultBrowserExe) ; extract said program's executable + path (defaultBrowserExe[1]) and executable - path (defaultBrowserExe[2])
defaultBrowser:=	"ahk_exe " defaultBrowserExe[2]
cUIA:=			UIA_Browser(defaultBrowser)
DETURL:=		"https://deturl.com/play.php?v="
tURL:=			"Simple YouTube video player"
YTneedle:=		"(?:music\.)?youtu\.?be(?:-nocookie)?(?:\.com\/)?(?:embed|e|live|shorts|v|watch)?(?:\/|\?v=|\?.*?&v=)?([0-9A-Za-z_-]{11})" ; check bottom of script for YT URL list

; Parse clipboard for YT link and exit if not
If !RegexMatch(A_Clipboard, YTneedle, &Link) {
	SoundPlay(winDir "\Media\Windows User Account Control.wav", 1) ; 1= wait to finish playing (else exit truncates sound)
	ExitApp
}

; Save current tab title for restoration
Try ogTab:= cUIA.GetTab().Name ; 'Name' is required for SelectTab() below

; Open link in DETURL webpage of OS's default browser
RunWait(DETURL Link[1])
cUIA.WaitPageLoad(tURL,5,,1,True) ; SetTitleMatchMode = begins with >> browser may sometimes append additional info after title?

; Return browser tab to original position
If IsSet(ogTab)
	Try cUIA.SelectTab(ogTab,1,True) ; SetTitleMatchMode = begins with >> browser may sometimes append additional info after title?

/*
	LIST OF CURRENT YT URL STYLES
	>>> VIDEO_ID = strict 11-character alphanumeric string >> [0-9A-Za-z_-]{11}
	>>> flags may be appended after the ID (and start with &/?/#)
	>>> DETURL viewer seems to either outright ignore all flags or completely break because of others so best to scrub them all
	youtu.be/VIDEO_ID
	youtube.com/e/VIDEO_ID
	youtube.com/embed/VIDEO_ID
	youtube-nocookie.com/embed/VIDEO_ID
	youtube.com/live/VIDEO_ID
	youtube.com/shorts/VIDEO_ID
	youtube.com/v/VIDEO_ID
	youtube.com/watch/VIDEO_ID
	youtube.com/watch?v=VIDEO_ID
	youtube.com/watch?*&v=VIDEO_ID ; * = pre-appended flags
	music.youtube.com/watch?v=VIDEO_ID
	>>> NEEDLE: "(?:music\.)?youtu\.?be(?:-nocookie)?(?:\.com\/)?(?:embed|e|live|shorts|v|watch)?(?:\/|\?v=|\?.*?&v=)?([0-9A-Za-z_-]{11})"
*/
