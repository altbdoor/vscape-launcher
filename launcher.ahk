#NoTrayIcon
#SingleInstance force
#Include stdouttovar.ahk
#Include libcrypt/build/libcrypt.ahk

InitGui()

InitGui() {
	; so everybody can update the status textbox
	global TextStatus
	
	; init the gui
	Gui, New, -Resize -MaximizeBox -MinimizeBox, VscapeLauncher
	Gui, Margin, 10, 10
	Gui, Font, s10
	Gui, Add, Link, w300 vTextStatus r2, Checking for Java...
	Gui, Add, Button, Disabled w150 h40 Default Section gPlayClick, Play
	Gui, Add, Button, Disabled w150 h40 xs150 ys0 gUpdateClick, Update
	
	; show the gui
	Gui, Show, W320 Center, /v/scape Launcher
	
	; check if we have java
	HasJava := CheckJava()
	
	; if we don't, show an error
	If (!HasJava > 0) {
		Gui, Font, cRed Bold
		GuiControl, Font, TextStatus
		GuiControl, , TextStatus, Java not found. Please <a href="https://java.com/en/download/manual.jsp">download and install Java</a> before proceeding.
		
		Return
	}
	
	; check for the presence of vidyascape.jar
	GuiControl, , TextStatus, Checking for vidyascape.jar ...
	HasJar := FileExist("vidyascape.jar")
	
	; if we don't get it now
	If (!HasJar) {
		GuiControl, , TextStatus, vidyascape.jar not found. Fetching latest version...
		GetRemote("vidyascape.jar")
	}
	
	; enable buttons, all set to play
	GuiControl, , TextStatus, vidyascape.jar ready!
	GuiControl, -Disabled, Play
	GuiControl, -Disabled, Update
	
	Return
	
	; ========================================
	
	; run vidyascape jar file
	PlayClick:
		Run, javaw -jar vidyascape.jar
		ExitApp
	
	; fetch remote jar, compare md5 and update accordingly
	UpdateClick:
		GuiControl, , TextStatus, Fetching latest version...
		GuiControl, +Disabled, Play
		GuiControl, +Disabled, Update
		
		; get the remote vidyascape jar file
		GetRemote("vidyascape_new.jar")
		
		; get the hashes and compare
		CurrentHash := LC_FileMD5("vidyascape.jar")
		RemoteHash := LC_FileMD5("vidyascape_new.jar")
		
		; if its not the same, we assume its new
		If (CurrentHash != RemoteHash) {
			GuiControl, , TextStatus, Updated to the latest version!
			
			FileDelete, vidyascape.jar
			FileMove, vidyascape_new.jar, vidyascape.jar
		}
		Else {
			GuiControl, , TextStatus, You have the latest version!
			
			FileDelete, vidyascape_new.jar
		}
		
		GuiControl, -Disabled, Play
		GuiControl, -Disabled, Update
		
		Return
}

CheckJava() {
	JavaVersion := StdOutToVar("java -version")
	;JavaVersion := StdOutToVar("ipconfig")
	JavaInstalled := RegExMatch(JavaVersion, "i)^java version")
	
	Return JavaInstalled
}

GetRemote(Filename) {
	Sleep, 100
	
	; replace the url below with the link to vidyascape jar
	UrlDownloadToFile, https://www.google.com, %Filename%
	
	Return
}
