#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Au3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Icon=DL.ico
#AutoIt3Wrapper_Res_Icon_Add=DL.ico
#AutoIt3Wrapper_Run_Tidy=Y

#AutoIt3Wrapper_Res_Comment=http://www.danlemire.com/DLTray
#AutoIt3Wrapper_Res_Description=DLTray Snippets
#AutoIt3Wrapper_Res_Fileversion=3.0.0.6
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=P
#AutoIt3Wrapper_Res_Field=CompanyName|danlemire.com
#AutoIt3Wrapper_Res_Field=ProductName|DLTray
#AutoIt3Wrapper_Res_Field=ProductVersion|3.0
#AutoIt3Wrapper_Res_Field=LegalCopyright|Daniel Lemire
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****
;***************************************************************************************************************
; DL Tray
; This program replicates the functionality of FrontPage 2003's snippets feature.
; Fully customizable using an ini file that includes the snippets.

; remember that the items passed to GuiCtrlSetDate must be separated by the pipe (|) instead of being an array
;$items = "html|comment|cssID|cssClass"
;$action = c("<html><body></body></html>|<!-- -->|#id{}|.class{}","|")

;***************************************************************************************************************
Dim $currentWindow
$g_szVersion = "DLtray 3.0"
;$changelog = "NEW encryption logic to protect your wildcards!" & @CRLF & "Feature complete release:" & @CRLF & "- Snippets Engine" & @CRLF & "- Window Move" & @CRLF & "- Wildcards replace in snippets" & @CRLF & "- Wildcards allow execute of any single line of autoIT script code" & @CRLF & "- Wildcards actived on dialog close" & @CRLF & "Plus, new send to clipboard only functionality just added."
$changelog = "- Snippets Style Language Chooser by hotkey!" & @CRLF
$changelog &= "- Encryption key now stored encrypted in the registry" & @CRLF

;$changelog &= @CRLF & "http://www.danlemire.com/dltray"
;If ProcessExists("dltray.exe") Then
;	MsgBox(64, "DLtray.exe", "instance already running, close before duplicating")
;	Exit ; It's already running
;EndIf

#include <GUIconstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <GuiListView.au3>
#include <Array.au3>
#include <Constants.au3>
#include <WindowsConstants.au3>
#include <String.au3> ;for encryption.
#include <Date.au3>
AutoItSetOption("GUIDataSeparatorChar", "~")
TraySetIcon("Shell32.dll", 22)
TraySetIcon("DL.ico")

Opt("GUICoordMode", 1)

;Variables to allow changes via the settings option.  Defaults are set here.
Dim $snippetsHotkey, $snippetToClipToggleHotkey, $filePath, $changeToASPHotkey, $changeToHTMLHotkey, $changeToTextHotkey, $changeToVBHotkey, $useSnippets, $useMoveWindows, $useEncryption
Dim $snippetTextToPut, $dollars, $toggleSnipToClip, $encryptionPassword, $nextLangaugeHotkey, $promptForVarRegex
Dim $toggleSnipToClip, $togglePasteToSend
Dim $regValueEncryption, $snippetsAreEncrypted, $encryptedEncryptionValue
$encryptionPassword = ""
$encryptedEncryptionValue = ""
$regValueEncryption = ""  ;; ADD your own registry value encryption to include in the complied executable. This protects the end-user's encryption key value in the registry.
$snippetsAreEncrypted = False
$snippetsHotkey = "^{ENTER}"
$snippetToClipToggleHotkey = "{pause}"
$pasteToSendToggleHotkey = "#{pause}"
$chooseLangAsSnipHotkey = "#{/}"
$promptForVarRegex = "<{\w}>"
$nextLangaugeHotkey = "#z"
$changeToVBHotkey = "#v"
$changeToHTMLHotkey = "#h"
$changeToTextHotkey = "#n"
$changeToASPHotkey = "#a"
$useSnippets = True
$useEncryption = False
$toggleSnipToClip = False
$togglePasteToSend = False
$toggleMouseJiggle = False
;Manage GUI
$manageHandle = GUICreate("Snippets Manager", 800, 400)
;GUISetIcon("Shell32.dll", 21)
GUISetIcon("dl.ico")
GUICtrlCreateLabel("Languages: ", 5, 35)
$languageList = GUICtrlCreateList("Languages", 5, 50, 150, 300)
GUICtrlCreateLabel("Tags: ", 175, 35)
$addLang = GUICtrlCreateButton("Add Language", 5, 3, 100)
$delLang = GUICtrlCreateButton("Delete Language", 105, 3, 100)



$tagList = GUICtrlCreateList("Tags", 175, 50, 150, 300)
GUICtrlCreateLabel("Tag Name: ", 345, 6)
$tagInput = GUICtrlCreateInput("", 405, 4, 150)
$addModify = GUICtrlCreateButton("Add/Modify", 560, 3, 100)
$delete = GUICtrlCreateButton("Delete", 660, 3, 100)
GUICtrlCreateLabel("Snippet Text: ", 345, 35)
$snippetText = GUICtrlCreateEdit("Snippet Goes Here", 345, 50, 450, 290)
GUICtrlSetLimit($snippetText, 9999999); = 999,999 ; 0xF423F
$OK = GUICtrlCreateButton("OK", 560, 350, 100)
$Cancel = GUICtrlCreateButton("Cancel", 660, 350, 100)

;Settings GUI
$settingsHandle = GUICreate("DLTray Settings", 800, 400)
GUISetIcon("Shell32.dll", 21)
;$SetHotkeys = GUICtrlCreateListView("Language~Hotkey", 16, 16, 386, 150)
$SetHotkeys = _GUICtrlListView_Create($settingsHandle, "Language~Hotkey", 12, 12, 296, 196, BitOR($LVS_EDITLABELS, $LVS_REPORT))
_GUICtrlListView_SetExtendedListViewStyle($SetHotkeys, $LVS_EX_GRIDLINES)

;SetHotkeys needs a few globals for listview editing
Global $hGUI, $hEdit, $hDC, $hBrush, $Item = -1, $SubItem = 0







;SnippetsTabCompletion GUI
$tabCompleteHandle = GUICreate("Tab Completion Step", 800, 400)
GUISetIcon("Shell32.dll", 21)
GUICtrlCreateLabel("Snippet Text: ", 345, 35)
$tabCompleteSnippetText = GUICtrlCreateEdit("Snippet Goes Here", 345, 50, 450, 290)
GUICtrlSetLimit($tabCompleteSnippetText, 9999999); = 999,999 ; 0xF423F
$tabCompleteOK = GUICtrlCreateButton("OK", 560, 350, 100)
$tabCompleteCancel = GUICtrlCreateButton("Cancel", 660, 350, 100)

;Use Snippets GUI
#region UseSnippets GUI
;$useHandle = GUICreate("DLsnippets", 310, 335) ; for use with go button.
$useHandle = GUICreate("DLsnippets", 310, 310)
Dim $snippetList, $items, $itemsArray, $action, $sel, $selctedText, $tempClipboard, $activeWindow, $clipboardContents
Dim $manageSnippetList, $manageItems, $manageItemsArray, $manageAction, $manageSel
Dim $wildcards, $wildcardsArray, $wildcardValues, $wildcardValuesArray
Dim $currentLoadedLang = "Normal Text"
$snippetsInitialized = False
Dim $choosingSnippet = False
Dim $selectedLang = "Normal Text"
Dim $itemString, $actionString
Dim $languages[99]
Dim $langHotkey[99]

;GUIcontrols global declaration for languages.
For $i = 0 To 99
	Assign("$lang" & $i, $i)
Next

$selectedText = ""
$snippetList = GUICtrlCreateList("list", 5, 5, 300, 300, -1)
;$useSelectedSnippetButton = GUICtrlCreateButton("GO",5,305,300,20)

#endregion UseSnippets GUI
;$disableHK = TrayCreateItem("Disable Snippets")
;$enableHK = TrayCreateItem("Enable  Snippets")
$HKonoff = TrayCreateItem("Snippets Engine")
TrayCreateItem("")
$manualSnippetsTrigger = TrayCreateItem("Select a Snippet" & @TAB & makeHotkeyReadable($snippetsHotkey))
$clipboardMode = TrayCreateItem("Keep Snippet in Clipboard" & @TAB & makeHotkeyReadable($snippetToClipToggleHotkey))
$sendpasteMode = TrayCreateItem("SendKeys instead of paste" & @TAB & makeHotkeyReadable($pasteToSendToggleHotkey))
TrayCreateItem("")
$reloadSnippets = TrayCreateItem("Reload Snippets")
$manageSnippets = TrayCreateItem("Manage Snippets")
$snippetLanguage = TrayCreateMenu("Language")
;$languageChooser = TrayCreateItem("Language Chooser")

$ENConoff = TrayCreateItem("Encryption")
TrayCreateItem("")

;$settingsItem = TrayCreateItem("Settings")
$settingsNotepad = TrayCreateItem("Edit Settings")
$aboutitem = TrayCreateItem("About")
TrayCreateItem("")
$exititem = TrayCreateItem("Exit")


Opt("TrayMenuMode", 1) ; Default tray menu items (Script Paused/Exit) will not be shown.

TraySetState()
initOptions()
While 1
	$msg = TrayGetMsg()
	Select
		Case $msg = 0
			ContinueLoop
		Case $msg = $aboutitem
			MsgBox(64, "About:", $g_szVersion & @CRLF & $changelog)
			TrayItemSetState($aboutitem, 68)
		Case $msg = $exititem
			saveSettings()
			ExitLoop
		Case $msg = $GUI_EVENT_CLOSE
			CloseOrEsc()
			;Case $msg = $enableHK
			;	enableSnippets()
			;Case $msg = $disableHK
			;	disableSnippets()
		Case $msg = $HKonoff
			$stateOfHK = TrayItemGetState($HKonoff)
			$stateOfHKtxt = ""
			If $stateOfHK = 65 Then
				$stateOfHKtxt = "Enabled"
				enableSnippets()
			ElseIf $stateOfHK = 68 Then
				$stateOfHKtxt = "Disabled"
				disableSnippets()
			EndIf
			TrayTip("Snippets Engine", $stateOfHKtxt, 10)
			;Case $msg = $enableMW
			;	enableMoveWindows()
			;Case $msg = $disableMW
			;	disableMoveWindows()
			;Case $msg = $languageChooser
			;	snippetStyleLangChooser()
			;	TrayItemSetState($languageChooser, 65)
			;	TrayItemSetState($languageChooser, 65)
			;take this out once you have it working, no plans to use GUI to set the language, it defeats the purpose of the keyboard chooser.

		Case $msg = $clipboardMode
			toggleSnipToClip()

		Case $msg = $sendpasteMode
			togglePasteToSend()

		Case $msg = $ENConoff

			$stateOfENC = TrayItemGetState($ENConoff)
			ConsoleWrite("You clicked on the Encyrption Menu Item, state dectected as " & $stateOfENC & @CRLF)
			$stateOfENCtxt = ""
			;When entering this subrouting, we are capturing the state it's coming from.
			If $stateOfENC = 65 Then

				$decrypted = encryptWildcards()
			ElseIf $stateOfENC = 68 Then
				$decrypted = decryptWildcards()
			EndIf
			ConsoleWrite("after running decrypt or encrypt, state dectected as " & $stateOfENC & @CRLF)
			;decryptWildcards can be aborted, so we've moved the state change check below.
			ConsoleWrite("Running detect of encryption menu item state." & @CRLF)

			If $decrypted Then
				$stateOfENCtxt = "Disabled"
				TrayItemSetState($ENConoff, 68) ;disabled
			Else
				$stateOfENCtxt = "Enabled"
				TrayItemSetState($ENConoff, 65) ;enabled
			EndIf

			ConsoleWrite("Snippet state dectected as " & $stateOfENCtxt & @CRLF)
			TrayTip("Wildcard Encryption", $stateOfENCtxt, 10)
		Case $msg = $reloadSnippets
			loadSnippets($currentLoadedLang)
			TrayItemSetState($reloadSnippets, 68)
			TrayTip("Snippets", "Reload Successful", 1)
		Case $msg = $manageSnippets
			disableSnippets()
			ManageSnippets()
			TrayItemSetState($manageSnippets, 68)
			;loadSnippets($currentLoadedLang)
			;Case $msg = $settingsItem
			;	chooseSettings()
		Case $msg = $settingsNotepad
			notepadSettings()
			TrayItemSetState($settingsNotepad, 68)

		Case $msg = $manualSnippetsTrigger
			getSnippets() ;reloads the snippets so now snippet is preloaded.
			snipCalled()
		Case Else
			If $msg > 0 Then
				$searchString = TrayItemGetText($msg)
				; since we added hotkeys to the tray text, now we have to take it back out before we search for that language.
				;we add a TAB between lang and hotkey, so search for the tab, go 1 letter left and only grab to that char number.
				$langToLoad = StringLeft($searchString, StringInStr($searchString, @TAB) - 1)

				TrayTip("Snippets Language", $langToLoad, 1)
				loadSnippets($langToLoad)
				;TrayItemSetState($msg,129)
			EndIf
	EndSelect
WEnd

Exit

Func getSettings()
	IniReadSectionNames("DLtray.ini")
	If @error Then
		MsgBox(64, "DLtray.ini", "The DLtray.ini configuration file wasn't found.  A new file will be created in the same directory as DLtray.exe.")
		saveSettings()
	Else
		readSettings()
	EndIf

	;TrayTip("Encryption State from VAR", "Encryption: " & $useEncryption,99)

	;If $encryptionPassword <> "" Then
	;	encryptWildcards()
	;$snippetsEncrypted = True
	;saveSettings()
	;ElseIf $encryptionPassword = "" Then
	;	decryptWildcards()
	;$snippetsEncrypted = False
	;saveSettings()
	;EndIf

EndFunc   ;==>getSettings

Func initOptions()
	;MsgBox(64,"INIT","Snip: " & $useSnippets & @CRLF & " Win: " & $useMoveWindows)

	getSettings()
	;MsgBox(64,"Loaded","Snip: " & $useSnippets & @CRLF & " Win: " & $useMoveWindows)
	changeOptionState($useSnippets, $useEncryption)


EndFunc   ;==>initOptions

Func changeOptionState($snip, $enc)
	If $snip == True Then
		;MsgBox(64, "enabling snips", $snip)
		enableSnippets()
	Else
		;MsgBox(64, "disabling snips", $snip)
		disableSnippets()
	EndIf

	If $enc == True Then
		;MsgBox(64, "enabling wins", $win)
		$encryptionPassword = establishEncryption()
		encryptWildcards()
	Else
		;MsgBox(64, "disabling wins", $win)
		decryptWildcards()
	EndIf

EndFunc   ;==>changeOptionState

Func chooseSettings()

	; SNIPPETS
	; - ini location
	$filePath = InputBox("Snippets file path", "Enter the full path for the snippets file", $filePath)
	; - additional language types

	saveSettings()
	initOptions()
EndFunc   ;==>chooseSettings

Func notepadSettings()
	SettingsGUI2()
	Run("notepad.exe " & @ScriptDir & "\" & "DLtray.ini")
	Sleep(1000)
	WinWaitClose("DLtray.ini", "[settings]")
	initOptions()
	TrayTip("Settings refreshed", "Settings have been reloaded after changes.", 100)
EndFunc   ;==>notepadSettings

Func saveSettings()
	IniWrite("DLtray.ini", "settings", "snippetsHotkey", $snippetsHotkey)
	IniWrite("DLtray.ini", "settings", "snippetToClipToggleHotkey", $snippetToClipToggleHotkey)
	IniWrite("DLtray.ini", "settings", "pasteToSendToggleHotkey", $pasteToSendToggleHotkey)
	IniWrite("DLTray.ini", "settings", "languagesAsSnippetsChoose", $chooseLangAsSnipHotkey)
	IniWrite("DLtray.ini", "settings", "filePath", $filePath)


	If $useEncryption And $encryptionPassword <> "" Then

		If $encryptedEncryptionValue == "" Then ;value in registry has been written to registery, remove it from the INI
			ConsoleWrite("Storing encryption value in INI : " & $encryptionPassword & @CRLF)
			IniWrite("DLtray.ini", "settings", "encryptionValue", $encryptionPassword)
		Else
			IniWrite("DLtray.ini", "settings", "encryptionValue", "")
		EndIf
	EndIf

	IniWrite("DLtray.ini", "settings", "snippetsEncrypted", $snippetsAreEncrypted)
	IniWrite("DLtray.ini", "settings", "useSnippets", $useSnippets)
	IniWrite("DLtray.ini", "settings", "nextLanguageHotkey", $nextLangaugeHotkey)
	IniWrite("DLtray.ini", "settings", "promptForVarRegex", $promptForVarRegex)
	$heads = IniReadSectionNames($filePath)
	For $i = 1 To $heads[0]
		IniWrite("DLtray.ini", "settings", StringReplace($heads[$i], " ", "") & "hotkey", $langHotkey[$i])
	Next
EndFunc   ;==>saveSettings

Func readSettings()
	$hotkeysAdded = ""
	$snippetsHotkey = IniRead("DLtray.ini", "settings", "snippetsHotkey", $snippetsHotkey)
	$snippetToClipToggleHotkey = IniRead("DLtray.ini", "settings", "snippetToClipToggleHotkey", $snippetToClipToggleHotkey)
	$pasteToSendToggleHotkey = IniRead("DLtray.ini", "settings", "pasteToSendToggleHotkey", $pasteToSendToggleHotkey)
	$chooseLangAsSnipHotkey = IniRead("DLTray.ini", "settings", "languagesAsSnippetsChoose", $chooseLangAsSnipHotkey)
	$filePath = IniRead("DLtray.ini", "settings", "filePath", $filePath)
	$useEncryption = IniRead("DLtray.ini", "settings", "encryptionEnabled", $useEncryption)
	$snippetsAreEncrypted = IniRead("DLtray.ini", "settings", "snippetsEncrypted", $snippetsAreEncrypted)
	$encryptionPassword = IniRead("DLtray.ini", "settings", "encryptionValue", $encryptionPassword)

	If $useEncryption Then
		$encryptionPassword = establishEncryption()

	EndIf
	ConsoleWrite("encryptionPassword=" & $encryptionPassword & @CRLF)
	$useSnippets = IniRead("DLtray.ini", "settings", "useSnippets", $useSnippets)
	$nextLangaugeHotkey = IniRead("DLtray.ini", "settings", "nextLanguageHotkey", $nextLangaugeHotkey)
	$promptForVarRegex = IniRead("DLtray.ini", "settings", "promptForVarRegex", $promptForVarRegex)
	$heads = IniReadSectionNames($filePath)
	If @error Then
		MsgBox(64, "Error", "Unable to read snippets INI file. (DLsnippets.ini by default).")
	EndIf

	For $i = 1 To $heads[0]
		$langHotkey[$i] = IniRead("DLtray.ini", "settings", StringReplace($heads[$i], " ", "") & "hotkey", $langHotkey[$i])
		$hotkeysAdded &= $langHotkey[$i] & "" & @TAB & $heads[$i] & @CRLF
	Next

	;Hotkey TrayTip reference.
	;TrayTip("Language Hotkeys", $hotkeysAdded, 1)
	;MsgBox(64, "Language Hotkeys", $hotkeysAdded)
EndFunc   ;==>readSettings

Func ManageSnippets()
	GUISwitch($manageHandle)
	GUISetState(@SW_SHOW, $manageHandle)
	loadManageLanguages()
	While 1
		$msg = GUIGetMsg()
		Select
			Case $msg = $languageList
				languageSelected()
			Case $msg = $tagList
				tagSelected()
			Case $msg = $Cancel
				ExitLoop
			Case $msg = $OK
				ExitLoop
			Case $msg = $addModify
				addModifyTag()
			Case $msg = $delete
				deleteTag()
			Case $msg = $tagInput
				GUICtrlSetData($snippetText, "")
			Case $msg = $addLang
				addLanguage()
			Case $msg = $delLang
				deleteLanguage()
			Case $msg = $GUI_EVENT_CLOSE
				ExitLoop
		EndSelect
	WEnd
	GUISetState(@SW_HIDE, $manageHandle)
	GUISwitch($useHandle)
	enableSnippets()
	TrayTip("Snippets", "Post Manage Reload Successful", 1)
EndFunc   ;==>ManageSnippets


Func SettingsGUI2()
	#comments-start
		dim $allLangHotkey
		$heads = IniReadSectionNames($filePath)
		;build the hotkey gui on the fly by throwing everything into a listbox.
		dim $settings2Handle = GUICreate("Hotkey Selection for Languages", 310, 310)
		dim $settingsHotkeyList = GUICtrlCreateList("", 5, 5, 300, 300,-1)



		GUISwitch($settings2Handle)
		For $i = 0 to $heads[0]
		$allLangHotkey &= $heads[$i] ;& " ....... " & $langHotkey[$i] & "~"
		Next
		GUICTRLsetDATA($settingsHotkeyList,$allLangHotkey)

		GUISetState(@SW_SHOW, $settings2Handle)

		While 1
		$msg = GUIGetMsg()
		Select
		;Case $msg = $languageList
		;	languageSelected()
		;Case $msg = $tagList
		;	tagSelected()
		;Case $msg = $Cancel
		;	ExitLoop
		;Case $msg = $OK
		;	ExitLoop
		;Case $msg = $addModify
		;	addModifyTag()
		;Case $msg = $delete
		;	deleteTag()
		;Case $msg = $tagInput
		;	GUICtrlSetData($snippetText, "")
		Case $msg = $GUI_EVENT_PRIMARYDOWN
		If GUICtrlRead($settingsHotKeyList) <> "" Then
		$newHotkey = InputBox("Set Hotkey","Please enter the new hotkey for " & GUICtrlRead($settingsHotKeyList))
		;setLangHotkey($lang,$newHotkey)


		EndIf


		Case $msg = $GUI_EVENT_CLOSE
		ExitLoop
		EndSelect
		WEnd
		GUISetState(@SW_HIDE, $settings2Handle)
		GUISwitch($useHandle)
		initOptions()
	#comments-end
EndFunc   ;==>SettingsGUI2
Func SettingsGUI()
	GUISwitch($settingsHandle)



	;loadManageLanguages()


	$hotkeysAdded = ""
	$heads = IniReadSectionNames($filePath)
	If @error Then
		MsgBox(64, "Error", "Unable to read snippets INI file. (DLsnippets.ini by default).")
	EndIf

	For $i = 1 To $heads[0]
		;$langHotkey[$i] = IniRead("DLtray.ini", "settings", StringReplace($heads[$i], " ", "") & "hotkey", $langHotkey[$i])
		;$hotkeysAdded &= $langHotkey[$i] & "" & @TAB & $heads[$i] & @CRLF

		_GUICtrlListView_AddItem($SetHotkeys, $heads[$i])
		_GUICtrlListView_AddSubItem($SetHotkeys, $i - 1, String($langHotkey[$i]), 1)
		ConsoleWrite("SubItem: " & $i & ", hotkey: " & $langHotkey[$i] & @CRLF)

	Next

	GUISetState(@SW_SHOW, $settingsHandle)

	GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

	;For $i = 1 to $langHotkey[0]

	;	ConsoleWrite("SubItem: " & $i & ", hotkey: " & $langHotkey[$i])
	;Next
	;_GUICtrlListView_AddSubItem($hListView, 0, "Row 1: Col 3", 2, 2)
	;_GUICtrlListView_AddItem($hListView, "Row 2: Col 1", 1)
	;_GUICtrlListView_AddSubItem($hListView, 1, "Row 2: Col 2", 1, 2)
	;_GUICtrlListView_AddItem($hListView, "Row 3: Col 1", 2)



	While 1
		$msg = GUIGetMsg()
		Select
			;Case $msg = $languageList
			;	languageSelected()
			;Case $msg = $tagList
			;	tagSelected()
			;Case $msg = $Cancel
			;	ExitLoop
			;Case $msg = $OK
			;	ExitLoop
			;Case $msg = $addModify
			;	addModifyTag()
			;Case $msg = $delete
			;	deleteTag()
			;Case $msg = $tagInput
			;	GUICtrlSetData($snippetText, "")
			Case $msg = $GUI_EVENT_CLOSE
				ExitLoop
		EndSelect
	WEnd
	GUISetState(@SW_HIDE, $settingsHandle)
	GUISwitch($useHandle)
	initOptions()
	TrayTip("Language Hotkeys", $hotkeysAdded, 1)

EndFunc   ;==>SettingsGUI

;settings gui functions need for list view editing
#region
Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
	Local $tNMHDR, $hWndFrom, $iCode
	$tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
	$hWndFrom = DllStructGetData($tNMHDR, "hWndFrom")
	$iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case $SetHotkeys
			Switch $iCode
				Case $NM_DBLCLK ; used for sub item edit
					Local $aHit = _GUICtrlListView_SubItemHitTest($SetHotkeys)
					If ($aHit[0] <> -1) And ($aHit[1] > 0) Then
						$Item = $aHit[0]
						$SubItem = $aHit[1]
						Local $iSubItemText = _GUICtrlListView_GetItemText($SetHotkeys, $Item, $SubItem)
						Local $iLen = _GUICtrlListView_GetStringWidth($SetHotkeys, $iSubItemText)
						Local $aRect = _GUICtrlListView_GetSubItemRect($SetHotkeys, $Item, $SubItem)
						If $iLen < 10 Then
							$iLen = 10
						EndIf

						$hEdit = _GUICtrlEdit_Create($settingsHandle, $iSubItemText, $aRect[0] + 6, $aRect[1], $iLen + 10, 17, BitOR($WS_CHILD, $WS_VISIBLE, $ES_AUTOHSCROLL, $ES_LEFT))
						_GUICtrlEdit_SetSel($hEdit, 0, -1)
						_WinAPI_SetFocus($hEdit)
						$hDC = _WinAPI_GetWindowDC($hEdit)
						$hBrush = _WinAPI_CreateSolidBrush(0)
						FrameRect($hDC, 0, 0, $iLen + 10, 17, $hBrush)

					EndIf
				Case $LVN_ENDLABELEDITA, $LVN_ENDLABELEDITW ; Used for 1st column edit
					Local $tInfo = DllStructCreate($tagNMLVDISPINFO, $ilParam)
					Local $tBuffer = DllStructCreate("char Text[" & DllStructGetData($tInfo, "TextMax") & "]", DllStructGetData($tInfo, "Text"))
					If StringLen(DllStructGetData($tBuffer, "Text")) Then Return True
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

Func FrameRect($hDC, $nLeft, $nTop, $nRight, $nBottom, $hBrush)
	Local $stRect = DllStructCreate("int;int;int;int")
	DllStructSetData($stRect, 1, $nLeft)
	DllStructSetData($stRect, 2, $nTop)
	DllStructSetData($stRect, 3, $nRight)
	DllStructSetData($stRect, 4, $nBottom)
	DllCall("user32.dll", "int", "FrameRect", "hwnd", $hDC, "ptr", DllStructGetPtr($stRect), "hwnd", $hBrush)
EndFunc   ;==>FrameRect

Func WM_COMMAND($hWnd, $msg, $wParam, $lParam)
	Local $iCode = BitShift($wParam, 16)
	Switch $lParam
		Case $hEdit
			Switch $iCode
				Case $EN_KILLFOCUS
					Local $iText = _GUICtrlEdit_GetText($hEdit)

					_GUICtrlListView_SetItemText($SetHotkeys, $Item, $iText, $SubItem)
					$langHotkey[$Item + 1] = $iText
					MsgBox(64, "Hotkey Changed!", "Updated " & $languages[$Item] & " to: " & $iText)
					_WinAPI_DeleteObject($hBrush)
					_WinAPI_ReleaseDC($hEdit, $hDC)
					_WinAPI_DestroyWindow($hEdit)
					$Item = -1
					$SubItem = 0
			EndSwitch
	EndSwitch
	saveSettings()
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND



#endregion



;new section
Func SnippetsTabCompletion()


	GUISwitch($manageHandle)
	GUISetState(@SW_SHOW, $manageHandle)
	;loadManageLanguages()
	While 1
		$msg = GUIGetMsg()
		Select
			Case $msg = $languageList
				languageSelected()
			Case $msg = $tagList
				tagSelected()
			Case $msg = $Cancel
				ExitLoop
			Case $msg = $OK
				ExitLoop
			Case $msg = $addModify
				addModifyTag()
			Case $msg = $delete
				deleteTag()
			Case $msg = $tagInput
				GUICtrlSetData($snippetText, "")
			Case $msg = $GUI_EVENT_CLOSE
				ExitLoop
		EndSelect
	WEnd
	GUISetState(@SW_HIDE, $manageHandle)
	GUISwitch($useHandle)
	enableSnippets()
	TrayTip("Snippets", "Post Manage Reload Successful", 1)
EndFunc   ;==>SnippetsTabCompletion

Func snipCalled()
	TrayItemSetState($manualSnippetsTrigger, 65)
	getSelection()
	$choosingSnippet = True

	resetModifierKeyState()

	HotKeySet("{ENTER}", "enterPressed")
	HotKeySet("{ESC}", "CloseOrEsc")

	resetModifierKeyState()
	GUICtrlSetState($snippetList, $GUI_FOCUS)
	GUISetState(@SW_SHOW, $useHandle)
	WinSetOnTop("DLsnippets", "", 1)
	While $choosingSnippet = True
		$msg = GUIGetMsg()
		Select
			Case $msg = $GUI_EVENT_CLOSE
				CloseOrEsc()
				;ExitLoop
				;Case $msg = $useSelectedSnippetButton
				;	enterPressed()
				;			Case $msg = $snippetList
			Case $msg = $GUI_EVENT_PRIMARYDOWN
				If GUICtrlRead($snippetList) <> "" Then
					enterPressed()
					;resetSelectedSnippetKeyword
					;move the cursor to top of list?
					;reload all the snippet values each time to reset the list cursor position?
					;destroy the GUI and rebuild?
					;GUICtrlSetState($snippetList,$GUI_INDETERMINATE)
					;GUICtrlSetState($snippetList,$GUI_FOCUS)
					getSnippets()

				EndIf
		EndSelect
	WEnd
	TrayItemSetState($manualSnippetsTrigger, 68)
EndFunc   ;==>snipCalled

Func tabCompleteCalled()
	snippetSelected()
	$tabCompletingSnippet = True
	HotKeySet("{ENTER}", "layDownSnippet")
	HotKeySet("{ESC}", "snipCalled")
	GUISetState(@SW_SHOW, $tabCompleteHandle)
	WinSetOnTop("DLsnippets", "", 1)
	While $tabCompletingSnippet = True
		$msg = GUIGetMsg()
		Select
			Case $msg = $GUI_EVENT_CLOSE
				ExitLoop
		EndSelect
	WEnd

EndFunc   ;==>tabCompleteCalled

Func enterPressed()
	$sel = GUICtrlRead($snippetList)
	$pos = _ArraySearch($itemsArray, $sel)
	Dim $snippetTextToPut, $dollars
	$activeWindow = WinGetHandle("")
	$choosingSnippet = False
	$tabCompletingSnippet = False
	HotKeySet("{ENTER}") ;unset enter keypress detection
	HotKeySet($snippetsHotkey)
	HotKeySet("{ESC}")
	CloseOrEsc()


	; The next lines controls how the snippet is placed.

	;$snippetTextToPut = StringReplace($action[$pos], "%clipboard%", $selectedText)
	$snippetTextToPut = $action[$pos]
	;$dollars = StringRegExp($snippetText, "|[^|]*|", 1)

	;Msgbox(64,"Snippet text before wildcard replace",$snippetTextToPut)
	$snippetTextToPut = replaceWildcards($snippetTextToPut)
	;Msgbox(64,"Snippet text after wildcard replace",$snippetTextToPut)

	;Msgbox(64,"Snippet text before value prompts ",$snippetTextToPut)
	$snippetTextToPut = promptForValues($snippetTextToPut)
	;Msgbox(64,"Snippet text after value prompts ",$snippetTextToPut)


	$clipboardContents = ClipGet()

	If $togglePasteToSend Then
		;convert special send keys here.
		; ! {!}
		; # {#}
		; + {+}
		; ^ {^}
		; { {{}
		; } {}}

		;regular Expression check for "specialKey" and replace it will "{specialKey}"

		Send($snippetTextToPut)
	Else
		ClipPut($snippetTextToPut)
		Send("^v")
	EndIf


	Sleep(1000)

	If $toggleSnipToClip == False Then
		replaceClipBoard()
	EndIf

	HotKeySet($snippetsHotkey, "snipCalled")
	resetModifierKeyState()
EndFunc   ;==>enterPressed


;To implement the tab completion, replace enterPressed with these two functions, calling the tabcompletion GUI just before layDownSnippet.
#region tabCompletion intra-GUI
Func snippetSelected()

	$activeWindow = WinGetHandle("")
	$choosingSnippet = False
	HotKeySet("{ENTER}") ;unset enter keypress detection
	HotKeySet($snippetsHotkey)
	HotKeySet("{ESC}")
	CloseOrEsc()
	$sel = GUICtrlRead($snippetList)
	$pos = _ArraySearch($itemsArray, $sel)

	; The next lines controls how the snippet is placed.

	$snippetTextToPut = StringReplace($action[$pos], "|", $selectedText)
	$dollars = StringRegExp($snippetTextToPut, "|[^$]*$", 1)
	$snippetTextToPut = replaceWildcards($snippetTextToPut)

	;tabCompletionGUI

	layDownSnippet()
EndFunc   ;==>snippetSelected

Func layDownSnippet()
	$snippetTextToPut = GUICtrlRead($tabCompleteSnippetText)
	$clipboardContents = ClipGet()
	ClipPut($snippetTextToPut)
	Send("^v")
	Sleep(1000)
	replaceClipBoard()
	HotKeySet($snippetsHotkey, "snipCalled")
	resetModifierKeyState()

EndFunc   ;==>layDownSnippet
#endregion tabCompletion intra-GUI

Func replaceWildcards($string)
	ConsoleWrite(@CRLF & "Wildcard string in:" & $string)
	Dim $replacedString, $wildcardExecuted
	$wildcardExecuted = False

	$replacedString = ""

	For $i = 2 To $wildcardsArray[0] - 1

		$wildcard = $wildcardsArray[$i]
		$wildcardText = $wildcardValuesArray[$i]
		;extra statement to remove CRLF conversion?
		$wildcardExec = ""

		If StringInStr($string, $wildcard) <> 0 Then
			$wildcardText = StringReplace($wildcardText, "<`>", @CRLF, 0, 2)
			$wildcardExec = Execute($wildcardText)
			ConsoleWrite(@CRLF & "WildcardExec: " & $wildcardExec)
			;MsgBox(64,"String Contents", $replacedString)

			If $wildcardExec <> "" Then
				$wildcardExecuted = True
				If $wildcardExec == 1 Then
					;MsgBox(64,"String Contents before replace", $string)
					$replacedString = StringReplace($string, $wildcard, "")
					;MsgBox(64,"String Contents after null replace", $replacedString)
				Else
					$replacedString = StringReplace($string, $wildcard, $wildcardExec)
					ConsoleWrite(@CRLF & "Wildcard: " & $wildcard & ". WildcardExecOutput: " & $wildcardExec)
				EndIf
			Else
				$replacedString = StringReplace($string, $wildcard, $wildcardText)
			EndIf

			;MsgBox(64,"String Contents", $replacedString)


			If $wildcardExecuted Or $string <> "" Then
				$string = $replacedString
			EndIf
		EndIf
	Next
	;Msgbox(64,"Running","Replace ending")
	;Msgbox(64,"Return from wildcardReplace",$string)


	Return $string

EndFunc   ;==>replaceWildcards

Func promptForValues($string);, $tokenLeft, $tokenRight)

	;for tokenized execution.. In otherwords, a variable form of wildcards.  So that not every kind of prompt has to be a wildcard.
	; -run the regular expression to find all occurences
	; replace the regular expression with a psuedo-wildcard.
	; show inputboxes
	; -replace the psuedo-wlicard with only the inputbox response

	; -similar method could bring up a text box and jump the cursor.

	;$matchesArray = StringRegExp ( $string, $promptForVarRegex,3)

	;for $i = 0 to UBound($matchesArray) - 1

	;next



	Return $string
EndFunc   ;==>promptForValues




Func enableSnippets()
	ConsoleWrite("enableSnippets" & @CRLF)
	;	TrayItemSetState($disableHK, 68)
	;	TrayItemSetState($enableHK, 129)
	TrayItemSetState($HKonoff, 65)
	initSnippets()
	getSnippets()
	;HotKeySet("^{ENTER}", "snipCalled")

	HotKeySet($snippetsHotkey, "snipCalled")
	HotKeySet($snippetToClipToggleHotkey, "toggleSnipToClip")
	HotKeySet($chooseLangAsSnipHotkey, "snippetStyleLangChooser")
	HotKeySet($nextLangaugeHotkey, "loadNextLang")
	HotKeySet($pasteToSendToggleHotkey, "togglePasteToSend")
	;HotKeySet($changeToVBHotkey, "loadVB")
	;HotKeySet($changeToHTMLHotkey, "loadHTML")
	;HotKeySet($changeToTextHotkey, "loadText")
	;HotKeySet($changeToASPHotkey, "loadASP")

	$heads = IniReadSectionNames($filePath)
	For $i = 1 To $heads[0]
		HotKeySet($langHotkey[$i], "loadLang")
	Next

	;loadWildcards()
	$useSnippets = True

	;MsgBox(64, "Snippets Enabled", $useSnippets)

EndFunc   ;==>enableSnippets

Func disableSnippets()
	;	TrayItemSetState($enableHK, 68)
	;	TrayItemSetState($disableHK, 129)
	TrayItemSetState($HKonoff, 68)
	;HotKeySet($snippetsHotkey)
	;HotKeySet($changeToVBHotkey)
	;HotKeySet($changeToHTMLHotkey)
	;HotKeySet($changeToTextHotkey)
	;HotKeySet($changeToASPHotkey)

	$useSnippets = False
	;MsgBox(64, "Snippets Disabled", $useSnippets)

	$heads = IniReadSectionNames($filePath)
	For $i = 1 To $heads[0]
		HotKeySet($langHotkey[$i])
	Next
EndFunc   ;==>disableSnippets

Func toggleSnipToClip()

	If Not $toggleSnipToClip Then
		$toggleSnipToClip = True
		TrayTip("Clipboard Mode", "Enabled", 99)
		;"Snippets clipboard mode enabled"
		;TrayTip("Snippets clipboard mode enabled",$stateOfHKtxt,10)
	Else
		$toggleSnipToClip = False
		replaceClipBoard() ;once we disable sending the snippet directly to the clipboard, put back the clipboard contents.
		TrayTip("Clipboard Mode", "Disabled", 99)
	EndIf



EndFunc   ;==>toggleSnipToClip

Func togglePasteToSend()

	If Not $togglePasteToSend Then
		$togglePasteToSend = True
		TrayTip("SendKeys Mode", "Enabled", 99)
	Else
		$togglePasteToSend = False
		TrayTip("SendKeys Mode", "Disabled", 99)
	EndIf

EndFunc   ;==>togglePasteToSend

Func CloseOrEsc()
	$choosingSnippet = False
	HotKeySet("{ENTER}") ;unset enter keypress detection
	HotKeySet("{ESC}")
	GUISetState(@SW_HIDE, $useHandle)
EndFunc   ;==>CloseOrEsc

Func getSelection()
	$tempClipboard = ClipGet()
	ClipPut("|")
	Send("^c")

	Dim $higlightedText = ClipGet()

	;TrayTip("Selection Grab data", $higlightedText,1)

	If $higlightedText <> "|" Then ;something was picked up while doing a send to clipboard, so, something must've been highlighted.
		$selectedText = $higlightedText
	Else
		; take what's in the clipboard since nothing was picked up from higlighting.
		$selectedText = $tempClipboard
	EndIf
	ClipPut($tempClipboard)
EndFunc   ;==>getSelection

Func replaceClipBoard()
	ClipPut($clipboardContents)
EndFunc   ;==>replaceClipBoard

Func getSnippets()
	loadSnippets($currentLoadedLang)
EndFunc   ;==>getSnippets

Func loadLang()
	;MsgBox(64,"Loading Language","detected: " & @HotKeyPressed)

	;find that key in the $langHotkey[] array
	;Assign("changeToLang" & $i,$langHotkey[$i],2)
	$searchString = @HotKeyPressed
	$langToLoad = _ArraySearch($langHotkey, $searchString)
	If $langToLoad <> -1 Then
		TrayTip("Snippets Language", $searchString, 1)
		TraySetToolTip("DLtray.exe :: " & $languages[$langToLoad - 1] & " active.")
		loadSnippets($languages[$langToLoad - 1])
	EndIf
	;loadSnippets("Normal Text")
	TrayTip("Snippets Language", $languages[$langToLoad - 1], 1)
EndFunc   ;==>loadLang

Func loadNextLang()
	;get the currently loaded language
	;find the index of that $language, add one and load that language.
	$searchString = $currentLoadedLang
	$heads = IniReadSectionNames($filePath)
	;MsgBox(64,"Loading Language","detected: " & @HotKeyPressed)

	;find that key in the $langHotkey[] array
	;Assign("changeToLang" & $i,$langHotkey[$i],2)
	$langToLoad = _ArraySearch($heads, $searchString)
	If $langToLoad <> -1 Then

		;if we max out the array, the next language is the first in the stack, to reset the index.
		If $langToLoad = $heads[0] Then
			$langToLoad = 0
		EndIf
		TrayTip("Snippets Language", $searchString, 1)
		TraySetToolTip("DLtray.exe :: " & $languages[$langToLoad] & " active.")
		loadSnippets($languages[$langToLoad])
	EndIf
	;loadSnippets("Normal Text")
	TrayTip("Snippets Language", $languages[$langToLoad], 1)
EndFunc   ;==>loadNextLang




Func loadSnippets($section)
	ConsoleWrite("loading snippet " & $section & "!" & @CRLF)
	$currentLoadedLang = $section
	GUICtrlSetData($snippetList, "")
	$items = ""
	$itemsArray = ""
	$itemString = ""
	$actionString = ""
	$var = ""
	;$var = IniReadSection($filePath, $section)
	$var = _IniReadSectionEx($filePath, $section)
	$numSnip = $var[0][0]
	For $i = 1 To $numSnip
		$itemString &= $var[$i][0] & "~"
		$actionString &= $var[$i][1] & "<~>"
	Next
	$items = $itemString
	$itemsArray = StringSplit($itemString, "~", 1)

	;transform any \n into a carriage return and line feed.
	$actionString = StringReplace($actionString, "<`>", @CRLF, 0, 1)
	$action = StringSplit($actionString, "<~>", 1)

	GUICtrlSetData($snippetList, $items)

	$heads = IniReadSectionNames($filePath)
	For $i = 1 To $heads[0]
		If $currentLoadedLang = $heads[$i] Then
			;TrayItemSetState("$lang" & $i-1,65)
			$returnCode = TrayItemSetState(Eval("$lang" & $i - 1), 129)
		Else
			TrayItemSetState(Eval("$lang" & $i - 1), 68)
		EndIf
	Next
	TraySetToolTip("DLtray: " & $section & " active.")
EndFunc   ;==>loadSnippets

Func loadWildcards()
	ConsoleWrite("loadWildcards" & @CRLF)
	;$currentLoadedLang = $section
	$wilds = ""
	$wildcards = ""
	$wildcardValues = ""
	$wildcardsArray = ""
	$wildcardValuesArray = ""
	;$var = IniReadSection($filePath, $section)

	$wilds = _IniReadSectionEx($filePath, "wildcards")
	$numSnip = $wilds[0][0]
	For $i = 1 To $numSnip
		$wildcards &= $wilds[$i][0] & "|"
		$wildcardValues &= $wilds[$i][1] & "|"
	Next
	$wildcardsArray = StringSplit($wildcards, "|")

	;transform any \n into a carriage return and line feed.
	;$actionString = StringReplace($actionString, "`", @CRLF, 0, 1)
	$wildcardValuesArray = StringSplit($wildcardValues, "|")

	;GUICtrlSetData($snippetList, $items)
EndFunc   ;==>loadWildcards

Func initSnippets()
	ConsoleWrite("initSnippets" & @CRLF)
	If $snippetsInitialized = False Then
		$snippetsInitialized = True
		Dim $langHotKeyText = ""
		$heads = ""
		$heads = IniReadSectionNames($filePath)
		loadWildcards()
		If @error Then
			MsgBox(4096, "", "Error occurred, file " & $filePath & " not found.")
		Else
			For $i = 1 To $heads[0]
				; StringRegExp returns 0 if nothing found, otherwise returns position num.
				;$result =StringRegExp( $heads[$i], '[0-9]+')

				;If $result = 0 Then
				$languages[$i - 1] = $heads[$i]
				;EndIf
			Next

			;For $i = 1 To $heads[0]
			;	;read the first element to get the laguage name.
			;	$names = IniReadSection($filePath, $heads[$i])
			;	;add the section name to the array
			;	$langName = StringReplace($names[1][0], "!-", "")
			;	$langName = StringReplace($langName, "-!", "")
			;	$languages[$heads[$i]] = $langName
			;Next
		EndIf
		Dim $evals = ""
		For $i = 0 To $heads[0]
			;Eval( "$lang" & $i & "= TrayCreateItem(""" & $languages[$i] & """,$snippetLanguage)")


			;show the hotkey used for the language in parenthesis next to the language.
			; replace # with WIN, ! with Ctrl and ^ with Alt.

			$langHotKeyText = $langHotkey[$i + 1]

			$langHotKeyText = makeHotkeyReadable($langHotKeyText)

			If $i + 1 <= $heads[0] Then
				Assign("$lang" & $i, TrayCreateItem($languages[$i] & @TAB & "" & $langHotKeyText & "", $snippetLanguage))
			EndIf
			;assign("$lang" & $i,TrayCreateItem(" & $languages[$i] & ",$snippetLanguage)"
			$evals &= "$lang" & $i & "= TrayCreateItem(""" & $languages[$i] & """,$snippetLanguage)" & @CRLF
			;$Smalltalk = TrayCreateItem("Smalltalk",$snippetLanguage)

			If Not $i == 0 Then
				;Add an optional hotkey for each language
				Assign("changeToLang" & $i, $langHotkey[$i], 2)

			EndIf

		Next
	Else
		;this will be executed if snippets have been initialized, but if wildcards were changed, we have to run this again.
		loadWildcards()
	EndIf

EndFunc   ;==>initSnippets

Func leaveManage()
	GUISetState(@SW_HIDE, $manageHandle)
	GUISwitch($useHandle)
	enableSnippets()
	;TrayTip("Snippets","Post Manage Reload Successful",1)
EndFunc   ;==>leaveManage

Func tagInputAction()
	GUICtrlSetData($snippetText, "")
EndFunc   ;==>tagInputAction

Func loadManageSnippets($section)
	Opt("GUICoordMode", 1)
	Opt("GUIOnEventMode", 0)
	GUICtrlSetData($tagList, "")

	$manageItems = ""
	$manageItemsArray = ""
	$manageItemString = ""
	$manageActionString = ""
	$var = ""

	;$var = IniReadSection($filePath, $section)
	$var = _IniReadSectionEx($filePath, $section)

	If $section <> "" Then
		If IsArray($var) Then
			$numSnip = $var[0][0]
			For $i = 1 To $numSnip
				;remove the section name string from the list.
				If $var[$i][0] <> "!-" & $section & "-!" Then
					$manageItemString &= $var[$i][0] & "~"
					$manageActionString &= $var[$i][1] & "<~>"
				EndIf
			Next
			$manageItems = $manageItemString
			$manageItemsArray = StringSplit($manageItemString, "~", 1)

			;transform any CRLF into a \n.
			$manageActionString = StringReplace($manageActionString, "<`>", @CRLF, 0, 1)
			$manageAction = StringSplit($manageActionString, "<~>", 1)
		Else
			;we're dealing with arrays, so make sure there is always at least one item for every section.
			Dim $tagName, $tagText, $tagLang
			$tagName = $section
			$tagText = " "
			IniWrite($filePath, $section, "!-" & $section & "-!", " ")
			;languageSelected()
			;tagSelected()
		EndIf
	EndIf

	GUICtrlSetData($tagList, $manageItems)
EndFunc   ;==>loadManageSnippets

Func loadManageLanguages()
	$heads = IniReadSectionNames($filePath)
	Dim $langsList = ""

	For $i = 1 To $heads[0]

		;	;read the first element to get the laguage name.
		;	$names = IniReadSection($filePath, $heads[$i])
		;	;add the section name to the array
		;	$langName = StringReplace($names[1][0], "!-", "")
		;	$langName = StringReplace($langName, "-!", "")
		;	$languages[$heads[$i]] = $langName
		;	$langsList &= "~" & $langName

		$langsList &= "~" & $heads[$i]
	Next
	GUICtrlSetData($languageList, $langsList)
EndFunc   ;==>loadManageLanguages

Func tagSelected()
	GUICtrlSetData($snippetText, "")
	Dim $tagText, $dollars
	$manageSel = GUICtrlRead($tagList)
	$managePos = _ArraySearch($manageItemsArray, $manageSel)
	$tagText = $manageAction[$managePos]
	GUICtrlSetData($snippetText, $tagText)
	GUICtrlSetData($tagInput, $manageSel)
EndFunc   ;==>tagSelected

Func languageSelected()
	$searchString = GUICtrlRead($languageList)
	$langToLoad = $searchString
	;If $langToLoad <> -1 Then
	loadManageSnippets($langToLoad)
	GUICtrlSetData($tagInput, "")
	GUICtrlSetData($snippetText, "")
	;EndIf
EndFunc   ;==>languageSelected

Func addModifyTag()
	Dim $tagName, $tagText, $tagLang
	$tagName = GUICtrlRead($tagInput)
	$tagText = GUICtrlRead($snippetText)
	If $tagText = "" Then
		Dim $takeClipboardInstead
		$takeClipboardInstead = MsgBox(4, "Snippet Save", "Snippet " & $tagName & " saved was blank.  Would you like to use the clipboard as your snippet text?")
		If $takeClipboardInstead == 6 Then ; 6 is yes, 7 is no.
			$tagText = ClipGet()
		Else
			$tagText = GUICtrlRead($snippetText)
		EndIf
		;TrayTip("Warning", "Snippet text saved was blank." & $tagName, 99)
	EndIf


	$searchString = GUICtrlRead($languageList)
	$tagLang = $searchString

	If $tagLang <> "" Then
		$tagText = StringReplace($tagText, @CRLF, "<`>", 0, 1)

		; do wildcard encryption magic here for new items.

		If $tagLang = "wildcards" And $useEncryption Then
			IniWrite($filePath, $tagLang, $tagName, encryptString($tagText, $encryptionPassword))
			TrayTip("Encryption enabled", "Encrypting new snippet: " & $tagName, 99)
		Else
			IniWrite($filePath, $tagLang, $tagName, $tagText)
			TrayTip("Encryption disabled", "Not encrypting new snippet: " & $tagName, 99)
		EndIf
		TrayTip("Snippet Saved!", "Snippet " & $tagName & " saved.", 99)
		;MsgBox(64, "Snippet Save", "Snippet " & $tagName & " saved.")
		languageSelected()
		tagSelected()
	Else
		MsgBox(64, "Error", "Language context lost, please reselect the language and snippet.  Snippet code placed in clipboard.")
		;abort closing the gui.
		;InputBox("Language","Please type in the language you intended this snippet for",$searchString)
		ClipPut($tagText)
	EndIf
EndFunc   ;==>addModifyTag

Func deleteTag()
	Dim $tagName, $tagText, $tagLang
	$tagName = GUICtrlRead($tagInput)
	$searchString = GUICtrlRead($languageList)
	$tagLang = $searchString
	;If $tagLang = -1 Then
	;	MsgBox(64, "Error", "I can't find that language in the ini file.")
	;EndIf
	IniDelete($filePath, $tagLang, $tagName)
	MsgBox(64, "Snippet Delete", "Snippet " & $tagName & " deleted.")
	languageSelected()
	GUICtrlSetData($tagInput, "")
	GUICtrlSetData($snippetText, "")
EndFunc   ;==>deleteTag

Func _IniReadSectionEx($hFile, $vSection, $decrypt = True)
	Local $iSize = FileGetSize($hFile) / 1024
	If $iSize <= 31 Then
		Local $aSecRead = IniReadSection($hFile, $vSection)
		If @error Then Return SetError(@error, 0, '')
		Return $aSecRead
	EndIf
	Local $sFRead = @CRLF & FileRead($hFile) & @CRLF & '['
	;$vSection = StringStripWS($vSection, 7)
	Local $aData = StringRegExp($sFRead, '(?s)(?i)\n\s*\[\s*' & $vSection & '\s*\]\s*\r\n(.*?)\r\n\[', 3)
	If IsArray($aData) = 0 Then Return SetError(1, 0, 0)
	Local $aKey = StringRegExp(@LF & $aData[0], '\n\s*(.*?)\s*=', 3)
	Local $aValue = StringRegExp(@LF & $aData[0], '\n\s*.*?\s*=(.*?)\r', 3)

	Local $a = 0
	Local $aKeyList = ""
	Local $aValueList = ""
	;MsgBox(64,"aKey Upper Bound",UBound($aKey))
	;For $a = 0 To UBound($aKey)-1
	$aKeyList = $aKey[$a]
	$aValueList = $aValue[$a]

	;Next
	Local $nUbound = UBound($aKey)
	Local $aSection[$nUbound + 1][$nUbound + 1]

	;msgbox(64,"Array Load",$nUbound & ":" & $aKey[$nUbound-2]  & "===" & $aValue[$nUbound-2])

	$aSection[0][0] = $nUbound
	For $iCC = 0 To $nUbound - 1
		Select
			Case StringLeft($aKey[$iCC], 1) <> ";"
				$aSection[$iCC + 1][0] = $aKey[$iCC]

				;the following code is critical to decrypting the contents of the wildcards, which are kept encrypted.
				If $vSection = "wildcards" And $decrypt And $useEncryption Then
					ConsoleWrite("decrypting value: " & $aKey[$iCC] & "=" & $aValue[$iCC] & @CRLF)
					decryptString($aValue[$iCC], $encryptionPassword)
					$aSection[$iCC + 1][1] = decryptString($aValue[$iCC], $encryptionPassword)
				Else ;value does not need decryption
					$aSection[$iCC + 1][1] = $aValue[$iCC]
				EndIf
				;because of this code, encryption is an all or nothing endeavor for a given language.


		EndSelect
	Next
	Return $aSection
EndFunc   ;==>_IniReadSectionEx


;add encryption to the snippets file.
;consider only encrypting one portion.
;encryption key would be stored in config file, separate from snippets.ini
;decryption would happen on application load.


Func encryptString($stringToEncrypt, $encryptionPassword)
	Dim $encryptedString
	$encryptedString = _StringEncrypt(1, $stringToEncrypt, $encryptionPassword, 1)
	Return $encryptedString
EndFunc   ;==>encryptString

Func decryptString($stringToDecrypt, $encryptionPassword)
	Dim $decryptedString
	$decryptedString = _StringEncrypt(0, $stringToDecrypt, $encryptionPassword, 1)
	Return $decryptedString
EndFunc   ;==>decryptString

Func encryptWildcards()
	ConsoleWrite("encryptWildards" & @CRLF)
	If $useEncryption == True Then
		TrayItemSetState($ENConoff, 65)
	Else
		;MsgBox(64,"Encrypting Wildcards!","Wildcard snippets are being encrypted now.",99)
		TrayItemSetState($ENConoff, 65)
		$useEncryption = True
		establishEncryption()
		Return True
	EndIf
	ConsoleWrite("End encryptWildards" & @CRLF)
EndFunc   ;==>encryptWildcards

Func decryptWildcards()
	;dim $currentEncryptionState, $headerValue
	;$headerValue = _IniReadSectionEx($filePath, "wildcards", false)
	ConsoleWrite("decryptWildards" & @CRLF)
	If $useEncryption == True Then
		ConsoleWrite("$useEncryption == True" & @CRLF)

		$lastPassword = InputBox("Wildcard Storage Decryption", "Please enter the encryption key to remove encryption from snippets file.")
		If $lastPassword == $encryptionPassword Then
			ConsoleWrite("Calling Remove Encyrption" & @CRLF)
			removeEncryption()
			$useEncryption = False
			Return True ;snippets have been decrypted.
		Else
			MsgBox(64, "Decrypt aborted", "You did not provide the correct decryption value. Encryption is still in use.")
			ConsoleWrite($encryptionPassword & @CRLF & $lastPassword & @CRLF)
			Return False ;snippets have not been decrypted.
			;TrayItemSetState($ENConoff, 65) ;disabled
		EndIf
	Else
		ConsoleWrite("$useEncryption == False" & @CRLF)
		Return False
	EndIf
	ConsoleWrite("End decryptWildards" & @CRLF)
EndFunc   ;==>decryptWildcards

Func establishEncryption()
	Dim $encryptionValue
	$encryptionPassword = IniRead("DLtray.ini", "settings", "encryptionValue", $encryptionPassword)
	$encryptedEncryptionValue = RegRead("HKCU\Software\DLTray", "ENC")

	If $encryptedEncryptionValue <> "" Then
		ConsoleWrite("Encryption key provided by registry value." & @CRLF)
		ConsoleWrite(decryptString(RegRead("HKCU\Software\DLTray", "ENC"), $regValueEncryption) & @CRLF)
	Else
		ConsoleWrite("Warning: I don't see any encryption keys in registry!" & @CRLF)
		If $encryptionPassword == "" Or $encryptionPassword == False Then
			ConsoleWrite("I don't see any encryption keys in ini!" & @CRLF)
			$encryptionValue = InputBox("Encryption key needed", "Settings indicate your snippets are encrypted." & @CRLF & "Please enter your existing encryption value to use the existing encrypted wildcards.")
			$encryptedEncryptionValue = encryptString($encryptionValue, $regValueEncryption)
		Else
			$encryptedEncryptionValue = encryptString($encryptionPassword, $regValueEncryption)
		EndIf

		If $encryptionPassword <> "" Or $encryptionValue <> "" Then
			RegWrite("HKCU\Software\DLTray", "ENC", "REG_SZ", $encryptedEncryptionValue)

			ConsoleWrite("Clearing the encryption value from the INI." & @CRLF)
			MsgBox(64, "NOTICE", "Version 3 of DLTray moves the encryption key to the registry. Your encryption key is stored in the user registery and may need to be re-entered when running under a different context.")
			IniWrite("DLtray.ini", "settings", "encryptionValue", "")

			If $snippetsAreEncrypted == False Then
				sequentialEncryptWilcardSnippets()
			EndIf
			$useEncryption = True
			saveSettings()
		Else
			ConsoleWrite("I don't see any encryption keys in registry or ini!")
			MsgBox(64, "No Encryption Value provided", "No encryption value was provided.  Aborting encryption setting and reverting to plain text storage for wildcards.")
			$useEncryption = False
			$snippetsAreEncrypted = False
			saveSettings()
		EndIf
	EndIf

	Return decryptString(RegRead("HKCU\Software\DLTray", "ENC"), $regValueEncryption)
EndFunc   ;==>establishEncryption


Func removeEncryption()
	$encyrptionPassword = ""
	RegDelete("HKCU\Software\DLTray", "ENC")
	sequentialDecryptWilcardSnippets()
	$useEncryption = False
	saveSettings()
	Return ""
EndFunc   ;==>removeEncryption

Func sequentialEncryptWilcardSnippets()

	;save off the current INI before proceeding.
	FileCopy($filePath, $filePath & ".plain.bak")
	ConsoleWrite("Beginning encryption of wildcards" & @CRLF)
	$sectionHeader = "wildcards"
	$snipsToCrypt = _IniReadSectionEx($filePath, $sectionHeader, False)
	$numSnip = $snipsToCrypt[0][0]

	; 1 is the first item: !-wildcards-!, this stay unecrypted to keep track of whether or not the values are encrypted. Thus we start at 2.
	For $i = 1 To $numSnip
		;$snipsToCrypt[$i][0] = keywords
		;$snipsToCrypt[$i][1] = snippetText

		If $snipsToCrypt[$i][1] <> "" Then
			;ConsoleWrite("IniWrite(" & $filePath & ", " & $sectionHeader & ", " & $snipsToCrypt[$i][0] & ", encryptString(" & $snipsToCrypt[$i][1] & "," & $encryptionPassword & "))" & @CRLF)
			IniWrite($filePath, $sectionHeader, $snipsToCrypt[$i][0], encryptString($snipsToCrypt[$i][1], $encryptionPassword))
		EndIf
	Next
	$snippetsAreEncrypted = True
	saveSettings()
	ConsoleWrite("Sequential Encryption completed.  Reloading wildcards" & @CRLF)
EndFunc   ;==>sequentialEncryptWilcardSnippets

Func sequentialDecryptWilcardSnippets()

	;save off the current INI before proceeding.

	FileCopy($filePath, $filePath & ".enc.bak")

	$sectionHeader = "wildcards"
	$snipsToCrypt = _IniReadSectionEx($filePath, $sectionHeader, True)
	$numSnip = $snipsToCrypt[0][0]

	;set the header value to reflect that these snippets are no longer.
	;IniWrite($filePath, $sectionHeader, $snipsToCrypt[1][1], "")

	; 1 is the first item: !-wildcards-!, this stay unecrypted to keep track of whether or not the values are encrypted. Thus we start at 2.
	For $i = 1 To $numSnip
		;$snipsToCrypt[$i][0] = keywords
		;$snipsToCrypt[$i][1] = snippetText
		If $snipsToCrypt[$i][1] <> "" Then
			;ConsoleWrite("IniWrite(" & $filePath & ", " & $sectionHeader & ", " & $snipsToCrypt[$i][0] & "," & $snipsToCrypt[$i][1] & ")" & @CRLF)
			IniWrite($filePath, $sectionHeader, $snipsToCrypt[$i][0], $snipsToCrypt[$i][1])
		EndIf
	Next
	$snippetsAreEncrypted = False
	saveSettings()
EndFunc   ;==>sequentialDecryptWilcardSnippets

Func resetModifierKeyState()
	; I seem to be having trouble lately with the CTRL+ENTER hotkey sequence leaving the CTRL key engaged.  We'll try a modifier key up sequence to attempt to prevent this.

	;Send("{ALTUP}{SHIFTUP}{CTRLUP}{LWINUP}{RWINUP}")
	;Send("{LCTRL}{LSHIFT}{LALT}")

	;TrayTip("Modifier Key State","Sending key state reset.",99)


	;The following command should 'unstick' any keys that are stuck down (i.e. ctrl,alt,shift)
	ControlSend("Snippets Manager", "Snippets Engine", "", "^!+", 0)
EndFunc   ;==>resetModifierKeyState


;take send() wildcards out of wildcards and implment a section just for sending keys.
; it would probably take the form of a checkbox that lets you chose to have the snippet done/dropped in as a sendkeys instead of paste.
; the other way would be a sendkeys snippet type, where the contents of the snippet is output via send.
; this would allow implementing other snippets under a send context.

Func makeHotkeyReadable($hotkeySequence)
	$hotkeySequence = StringReplace($hotkeySequence, "#", "Win+")
	$hotkeySequence = StringReplace($hotkeySequence, "!", "Alt+")
	$hotkeySequence = StringReplace($hotkeySequence, "^", "Ctrl+")
	Return $hotkeySequence
EndFunc   ;==>makeHotkeyReadable


Func setLangHotkey($lang, $newHotkey)
	;lookup the language
	;findthe index for that languages hotkey
	;replace the hotkey that's there with the new one.
	;update the variables.
	;update the ini file.
EndFunc   ;==>setLangHotkey


Func exportSnippetsToXML()
	Dim $heads
	$heads = IniReadSectionNames($filePath)
	For $i = 1 To $heads[0]
		;write language
		$var = IniReadSection($filePath, $heads[$i])
		$numSnip = $var[0][0]
		For $i = 1 To $numSnip
			;write $var[$i][0] inside <h1>

			$itemString &= $var[$i][0] & "~"

			;write $var[$i][1] inside <p>
			$actionString &= $var[$i][1] & "~"
			$actionString = StringReplace($actionString, "\n", @CRLF, 0, 1)
		Next
	Next
EndFunc   ;==>exportSnippetsToXML

Func addLanguage()
	;show text input box for new language
	Dim $heads
	$heads = IniReadSectionNames($filePath)
	$newLanguage = InputBox("Add Snippet Language", "Enter the snippet langauge", "NewSnippetLanguage")

	;search the current snippets to prevent duplicates. If duplication found, re-prompt.
	For $i = 1 To $heads[0]
		If StringCompare($newLanguage, $heads[$i], 2) == 0 Then
			MsgBox(64, "Snippet Language already exists", "Please enter a unique snippet language.")
			$newLanguage = InputBox("Add Snippet Language", "Enter the snippet langauge", "NewSnippetLanguage")
		EndIf

	Next

	;add a section to the snippets INI file
	;add a new snippet to the section so that we have our marker !-snippetLang-!=
	IniWrite($filePath, $newLanguage, "!-" & $newLanguage & "-!=", "" & @CRLF)

	;reload snippets to include the new langauge
	loadSnippets($currentLoadedLang)
	loadManageLanguages()
EndFunc   ;==>addLanguage

Func deleteLanguage()
	$langForDelete = InputBox("Delete Snippet Language", "Enter the snippet langauge to delete, exactly as it appears below", "NewSnippetLanguage")
	Dim $heads, $foundLang, $goodLang
	$goodLang = False
	$heads = IniReadSectionNames($filePath)

	;search the current snippets to find a match. If match found, proceed to delete it, otherwise tell the no luck.
	For $i = 1 To $heads[0]
		$foundLang = StringCompare($langForDelete, $heads[$i], 2)
		If $foundLang == 0 Then
			$goodLang = True
			$confirmDelete = InputBox("Delete Snippet Language", "Type YES below to delete " & $langForDelete & @CRLF & " and all it's child snippets.", "")
			If StringCompare("YES", $confirmDelete, 2) == 0 Then

				;lookup the langauage selected.
				$var = IniReadSection($filePath, $langForDelete)
				$numSnip = $var[0][0]
				;remove the section
				IniDelete($filePath, $langForDelete)
				ConsoleWrite("Deleted Snippet Language: " & $langForDelete & "." & @CRLF)

				;reload snippets to include the new langauge
				loadSnippets($currentLoadedLang)
				loadManageLanguages()
			EndIf
		EndIf
	Next
	If Not $goodLang Then
		MsgBox(64, "Snippet Language not found", "Please enter a valid snippet language to delete.")
	EndIf
EndFunc   ;==>deleteLanguage

Func snippetStyleLangChooser()
	;use the $heads array to populate the language chooser instead of snippets.
	Dim $heads, $headsString, $headsAll
	$headsString = ""
	$headsAll = ""
	$searchString = $currentLoadedLang
	$heads = IniReadSectionNames($filePath)
	;MsgBox(64,"Loading Language","detected: " & @HotKeyPressed)
	GUICtrlSetData($snippetList, "")

	$numSnip = $heads[0]
	For $i = 1 To $numSnip
		$headsString &= $heads[$i] & "~"
	Next
	$headsAll = $headsString
	GUICtrlSetData($snippetList, $headsAll)
	$choosingSnippet = True

	resetModifierKeyState()

	HotKeySet("{ENTER}", "langChooserHotkeyPressed")
	HotKeySet("{ESC}", "langChooserEscape")

	resetModifierKeyState()
	;GUISetState(@SW_HIDE, $useHandle) ;ADDED
	GUICtrlSetState($snippetList, $GUI_FOCUS)

	GUISetState(@SW_SHOW, $useHandle)
	WinSetOnTop("DLsnippets", "", 1)
	While $choosingSnippet = True
		$msg = GUIGetMsg()
		Select
			Case $msg = $GUI_EVENT_CLOSE
				langChooserEscape()

			Case $msg = $GUI_EVENT_PRIMARYDOWN
				If GUICtrlRead($snippetList) <> "" Then

					langChooserHotkeyPressed()
				EndIf
		EndSelect
	WEnd

EndFunc   ;==>snippetStyleLangChooser

Func langChooserHotkeyPressed()
	$choosingSnippet = False
	$sel = GUICtrlRead($snippetList)
	;find that key in the $langHotkey[] array
	;Assign("changeToLang" & $i,$langHotkey[$i],2)
	HotKeySet("{ENTER}") ;unset enter keypress detection
	HotKeySet("{ESC}")
	;GUISetState(@SW_HIDE, $useHandle)
	;enableSnippets()

	$heads = IniReadSectionNames($filePath)
	$langToLoad = _ArraySearch($heads, $sel)
	$langToLoad -= 1
	If $langToLoad <> -1 Then
		TrayTip("Snippets Language", $sel, 1)
		TraySetToolTip("DLtray.exe :: " & $languages[$langToLoad] & " active.")
		loadSnippets($languages[$langToLoad])
	EndIf
	snipCalled()
	;loadSnippets("Normal Text")
	TrayTip("Snippets Language", $languages[$langToLoad], 1)



EndFunc   ;==>langChooserHotkeyPressed

Func langChooserEscape()
	$choosingSnippet = False
	HotKeySet("{ENTER}") ;unset enter keypress detection
	HotKeySet("{ESC}")
	GUISetState(@SW_HIDE, $useHandle)

EndFunc   ;==>langChooserEscape



; add a function that will add the clipboard as an additional language.  If clipboard mode is not enabled, use the clipboard_Copies.au3 code to save clipboard to it's own ini file.
; the, add the clipboard as a language, and while switched to that language load the clipboard ini into snippets.
