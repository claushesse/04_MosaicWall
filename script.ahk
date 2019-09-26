;----------------------------------------------------------------------------------
; AutoHotKey is free and can be downloaded from:
; http://www.autohotkey.com
;
; Written by
; Claus Hesse - https://claushesse.github.io/colisiones/
;----------------------------------------------------------------------------------

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

; Name of the subfolder in which to save the used photos
UsedDir = usadas

; Name of the subfolder in which to save the final edited files
FinalDir = final

; Name of the subfolder where are the overlays 
OvlDir = overlays

; Name of the subfolder in which to save the used overlays
UsedOvl = overlays_usados

; set this to 1 to enable debug messages or 0 to disable them
showDebugMessages := 0

;src dir

;*******************************************
;** No need to change anything below here **
;*******************************************
FilterScript = %A_ScriptDir%\script.txt

if showDebugMessages
{
	; display a debug window at the top of the screen
	Gui +LastFound +AlwaysOnTop +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
	Gui, Color, cBlack
	Gui, Font, s12 
	Gui, Add, Text, vStatusText cLime, AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	Gui, Add, Text, vStatusText2 cLime, AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	Gui, Show,x100 y0 NoActivate,%A_ScriptName%  ; NoActivate avoids deactivating the currently active window.
	GuiControl,,StatusText,Please wait...
	GuiControl,,StatusText2,
}

SrcDir = %A_ScriptDir% 
PhotosSrcDir := SrcDir . "\fotos"
UsedPhotosDir := SrcDir . "\" . UsedDir
OverlaysDir := SrcDir . "\" . OvlDir
UserOverlaysDir := SrcDir . "\" . UsedOvl
DestDir := SrcDir . "\" . FinalDir

Loop
{
    IfExist,%PhotosSrcDir% 
    	{
         Loop, Files, %PhotosSrcDir%\*.* 
            {
                DebugMessage(1, "Scanning " PhotosSrcDir)

        	  ifExist, %PhotosSrcDir%\*.jpg
                {
                Loop %OvlDir%\*.png
                    {
                    overlays = %A_LoopFileName%|%overlays%
                    imageNb := A_Index
                    ;MsgBox, %imageNb%
                    }

                    overlays := SubStr(overlays, 1)
                    ;MsgBox Field1: %overlays%
                    SrcFile = %A_LoopFileName%
                    SrcFilePath = %A_LoopFileFullPath%

                    PhotoUsed := UsedPhotosDir . "\" . RegExReplace(SrcFile, "...$", "jpg") 
                    PhotoForOvl := PhotosSrcDir . "\" . RegExReplace(SrcFile, "...$", "jpg")
                    ;MsgBox Field2: %PhotoUsed% , %PhotoForOvl%
            
                    ifNotExist %PhotoUsed%
                    {   
                    OverlaysArray := StrSplit(overlays, "|")
                    Random, rnd, 1, %imageNb%
                    ;MsgBox, rnd %rnd%
                    OverlaySelected := OverlaysArray[rnd]
                    ;MsgBox, %OverlaySelected% 

                    Overlay := OverlaysDir . "\" . RegExReplace(OverlaySelected, "...$", "png")
                    Final := DestDir . "\" . RegExReplace(OverlaySelected, "...$", "jpg")
                    ;MsgBox Field3: Final = %Final% , Overlay = %Overlay%
                    ifNotExist %Final%
                        {
                        DebugMessage(1, "Converting " PhotoForOvl )
                        FileCreateDir, %UsedPhotosDir%
                        runwait, ffmpeg -i %PhotoForOvl% -i "%Overlay%" -filter_complex_script "%FilterScript%" -map [ovl] "%Final%" ,, hide
                        Sleep, 2000
                        FileMove, %PhotoForOvl%, %UsedPhotosDir%
                        ;MsgBox, %Overlay%
                        FileMove, %Overlay%, %UserOverlaysDir%
                        overlays := ""
                        Sleep, 2000
                        } 
                    }
                    
                }
                else
                {
                    DebugMessage(1, "Esperando las fotos")
                }
            }
        } 
; only run every second to avoid hogging the processor
Sleep 3000
}

; Display a debug message if showDebugMessages = 1
; num specifies the line on which to display the message (1 or 2)
; msg is the message to display
DebugMessage(num, msg)
{
	global cStatusText, cStatusText2
	global showDebugMessages

	if msg
	{
		msg := A_Hour ":" A_Min ":" A_Sec ": " msg
	}
	if showDebugMessages
	{
		if num=1
		{
			GuiControl,,StatusText,%msg%
		}
		else
		{
			GuiControl,,StatusText2,%msg%
		}
	}
}
