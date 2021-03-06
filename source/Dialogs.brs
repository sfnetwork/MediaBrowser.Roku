'**********************************************************
'**  Media Browser Roku Client - General Dialogs
'**********************************************************


'******************************************************
' Create Audio And Subtitle Dialog Boxes
'******************************************************

Function createAudioAndSubtitleDialog(audioStreams, subtitleStreams, playbackPosition, hidePlaybackDialog = false) As Object

    ' Set defaults
    audioIndex = false
    subIndex   = false
    playStart  = playbackPosition

    if audioStreams.Count() > 1
        audioIndex = createStreamSelectionDialog("Audio", audioStreams)    
        if audioIndex = -1 then return invalid ' Check for cancel
    end if

    if subtitleStreams.Count() > 0
        subIndex = createStreamSelectionDialog("Subtitle", subtitleStreams, 0, true)
        if subIndex = -1 then return invalid ' Check for Cancel
        if subIndex = 0 then subIndex = false ' Check for None
    end if

    if playbackPosition <> 0 And Not hidePlaybackDialog
        playStart = createPlaybackOptionsDialog(playbackPosition)
        if playStart = -1 then return invalid ' Check for Cancel
    end if

    return {
        audio: audioIndex
        subtitle: subIndex
        playstart: playStart
    }
End Function


'******************************************************
' Create Audio Or Subtitle Streams Dialog Box
'******************************************************

Function createStreamSelectionDialog(title, streams, startIndex = 0, showNone = false) As Integer
    port   = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port)

    dialog.SetMenuTopLeft(true)
    dialog.EnableOverlay(true)

    ' Set Title
    dialog.SetTitle("Select " + title)

    ' Setup Variables
    maxPerPage = 6 ' subtract 1 from what we want to show
    indexCount = 0
    foundMore  = false
    nextStartIndex   = startIndex
    totalStreamCount = streams.Count()-1

    if showNone then dialog.AddButton(0, "None")

    ' Setup Buttons
    for i = startIndex to totalStreamCount
        if streams[i] <> invalid
            dialog.AddButton(streams[i].Index, streams[i].Title)
            indexCount = indexCount + 1
        end if

        if indexCount > maxPerPage And i <> totalStreamCount then
            foundMore = true
            nextStartIndex = i + 1
            exit for
        end if
    end for

    if Not getGlobalVar("legacyDevice")
        dialog.AddButtonSeparator()
    end if

    if foundMore then dialog.AddButton(-2, "More " + title + " Selections")
    dialog.AddButton(-1, "Cancel")
    dialog.Show()

    while true
        msg = wait(0, dialog.GetMessagePort())

        if type(msg) = "roMessageDialogEvent"
            if msg.isScreenClosed()
                return 0
            else if msg.isButtonPressed()
                if msg.GetIndex() = -2
                    dialog.Close()
                    return createStreamSelectionDialog(title, streams, nextStartIndex)
                else
                    return msg.GetIndex()
                end if
            end if
        end if
    end while
End Function


'******************************************************
' Create Playback Options Dialog
'******************************************************

Function createPlaybackOptionsDialog(playbackPosition As Integer) As Integer
    port   = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port)

    dialog.SetMenuTopLeft(true)
    dialog.EnableOverlay(true)

    ' Set Title
    dialog.SetTitle("Select Playback")

    ' Setup Buttons
    dialog.AddButton(1, "Resume playing")
    dialog.AddButton(2, "Play from beginning")

    if Not getGlobalVar("legacyDevice")
        dialog.AddButtonSeparator()
    end if

    dialog.AddButton(-1, "Cancel")

    dialog.Show()

    while true
        msg = wait(0, dialog.GetMessagePort())

        if type(msg) = "roMessageDialogEvent"
            if msg.isScreenClosed()
                return 1
            else if msg.isButtonPressed()
                if msg.GetIndex() = -1
                    return -1
                else if msg.GetIndex() = 1
                    return playbackPosition
                else
                    return 0
                end if
            end if
        end if
    end while
End Function


'******************************************************
' Create More Video Options Dialog
'******************************************************

Function createMoreVideoOptionsDialog(video As Object) As Integer
    port   = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port)

    dialog.SetMenuTopLeft(true)
    dialog.EnableOverlay(true)
    dialog.EnableBackButton(true)

    ' Set Title
    dialog.SetTitle("More Options")

    ' Setup Buttons
    if video.IsPlayed
        dialog.AddButton(2, "Mark Unplayed")
    else
        dialog.AddButton(1, "Mark Played")
    end if

    if video.IsFavorite
        dialog.AddButton(4, "Remove Favorite")
    else
        dialog.AddButton(3, "Add Favorite")
    end if

    if Not getGlobalVar("legacyDevice")
        dialog.AddButtonSeparator()
    end if

    dialog.AddButton(-1, "Cancel")

    dialog.Show()

    while true
        msg = wait(0, dialog.GetMessagePort())

        if type(msg) = "roMessageDialogEvent"
            if msg.isScreenClosed()
                return -1
            else if msg.isButtonPressed()
                return msg.GetIndex()
            end if
        end if
    end while
End Function


'******************************************************
' Create Server Update Dialog
'******************************************************

Function createServerUpdateDialog()
    port   = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port)

    dialog.EnableOverlay(true)

    ' Set Title and Text
    dialog.SetTitle("Server Restart")
    dialog.SetText("Media Browser Server needs to restart to apply updates. Restart now? Please note if restarting server, please wait a minute to relaunch channel.")

    ' Setup Buttons
    dialog.AddButton(1, "No")
    dialog.AddButton(2, "Yes")

    dialog.Show()

    while true
        msg = wait(0, dialog.GetMessagePort())

        if type(msg) = "roMessageDialogEvent"
            if msg.isScreenClosed()
                return false
            else if msg.isButtonPressed()
                if msg.GetIndex() = 2
                    ' Restart Server
                    postServerRestart()
                    return true
                else
                    return false
                end if
            end if
        end if
    end while
End Function


'******************************************************
' Create Server Selection Dialog
'******************************************************

Function createServerSelectionDialog()
    port   = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port)

    dialog.SetMenuTopLeft(true)
    dialog.EnableOverlay(true)
    dialog.EnableBackButton(true)

    ' Set Title
    dialog.SetTitle("Select Action")

    ' Setup Buttons
    dialog.AddButton(1, "Connect to Server")
    dialog.AddButton(2, "Remove Server")

    dialog.Show()

    while true
        msg = wait(0, dialog.GetMessagePort())

        if type(msg) = "roMessageDialogEvent"
            if msg.isScreenClosed()
                return 0
            else if msg.isButtonPressed()
                return msg.GetIndex()
            end if
        end if
    end while
End Function


'******************************************************
' Create Server Remove Dialog
'******************************************************

Function createServerRemoveDialog()
    port   = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port)

    dialog.SetMenuTopLeft(true)
    dialog.EnableOverlay(true)
    dialog.EnableBackButton(true)

    ' Set Title and Text
    dialog.SetTitle("Confirm Action")
    dialog.SetText("Are you sure you wish to remove this server from the list?")

    ' Setup Buttons
    dialog.AddButton(0, "No")
    dialog.AddButton(1, "Yes")

    dialog.Show()

    while true
        msg = wait(0, dialog.GetMessagePort())

        if type(msg) = "roMessageDialogEvent"
            if msg.isScreenClosed()
                return 0
            else if msg.isButtonPressed()
                return msg.GetIndex()
            end if
        end if
    end while
End Function


'******************************************************
' Create Server Add Dialog
'******************************************************

Function createServerAddDialog()
    port   = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port)

    dialog.SetMenuTopLeft(true)
    dialog.EnableOverlay(true)
    dialog.EnableBackButton(true)

    ' Set Title
    dialog.SetTitle("Select Action")

    ' Setup Buttons
    dialog.AddButton(1, "Scan Network")
    dialog.AddButton(2, "Manually Add Server")

    dialog.Show()

    while true
        msg = wait(0, dialog.GetMessagePort())

        if type(msg) = "roMessageDialogEvent"
            if msg.isScreenClosed()
                return 0
            else if msg.isButtonPressed()
                return msg.GetIndex()
            end if
        end if
    end while
End Function


'******************************************************
' Create Loading Error Dialog
'******************************************************

Function createLoadingErrorDialog()

    createDialog("Error Loading", "There was an error while loading. Please Try again.", "Back")

End Function


'******************************************************
' Create Folder Rip Warning Dialog
'******************************************************

Function createFolderRipWarningDialog()
    createDialog("Warning", "Folder rips and ISO playback is experimental. It may not work at all with some titles.", "Continue")
End Function


'******************************************************
' Create Waiting Dialog
'******************************************************

Function createWaitingDialog(title As dynamic, message As dynamic) As Object
    if not isstr(title) title = ""
    if not isstr(message) message = ""

    port = CreateObject("roMessagePort")
    dialog = invalid

    ' If no message text, only Create Single Line dialog
    if message = ""
        dialog = CreateObject("roOneLineDialog")
    else
        dialog = CreateObject("roMessageDialog")
        dialog.SetText(message)
    end if

    dialog.SetMessagePort(port)

    dialog.SetTitle(title)
    dialog.ShowBusyAnimation()
    dialog.Show()

    return dialog
End Function





Function createContextMenuDialog() As Integer
    port   = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port)

    dialog.SetMenuTopLeft(true)
    dialog.EnableOverlay(true)

    ' Set Title
    dialog.SetTitle("Options")

    ' Setup Buttons
    dialog.AddButton(1, "Filter by: None")
    dialog.AddButton(2, "Sort by: Name")
    dialog.AddButton(3, "Direction: Ascending")
    dialog.AddButton(4, "View Menu")

    dialog.AddButtonSeparator()

    dialog.AddButton(5, "Search")
    dialog.AddButton(6, "Home")

    dialog.AddButtonSeparator()

    dialog.AddButton(7, "Close")

    dialog.Show()

    while true
        msg = wait(0, dialog.GetMessagePort())

        if type(msg) = "roMessageDialogEvent"
            if msg.isScreenClosed()
                return 1
            else if msg.isButtonPressed()
                if msg.GetIndex() = 1
                    dialog.Close()
                    returned = createContextOptionsDialog("Filter Options")
                    createContextMenuDialog() ' Re-create self
                else if msg.GetIndex() = 2
                    dialog.Close()
                    returned = createContextOptionsDialog("Sort Options")
                    createContextMenuDialog() ' Re-create self

                end if
                
                return 1
            end if
        end if
    end while
End Function


Function createContextOptionsDialog(title As String) As Integer
    port   = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port)

    dialog.SetMenuTopLeft(true)
    dialog.EnableOverlay(true)

    ' Set Title
    dialog.SetTitle(title)

    ' Setup Buttons
    dialog.AddButton(0, "None")
    dialog.AddButton(1, "Un-Watched")

    dialog.Show()

    while true
        msg = wait(0, dialog.GetMessagePort())

        if type(msg) = "roMessageDialogEvent"
            if msg.isScreenClosed()
                return 1
            else if msg.isButtonPressed()
                return msg.GetIndex()
            end if
        end if
    end while
End Function


'******************************************************
' Create Dialog Box
'******************************************************

Function createDialog(title As Dynamic, text As Dynamic, buttonText As String)
    if Not isstr(title) title = ""
    if Not isstr(text) text = ""

    port   = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port)

    dialog.EnableBackButton(true)

    dialog.SetTitle(title)
    dialog.SetText(text)
    dialog.AddButton(1, buttonText)
    dialog.Show()

    while true
        dlgMsg = wait(0, dialog.GetMessagePort())

        if type(dlgMsg) = "roMessageDialogEvent"
            if dlgMsg.isButtonPressed()
                exit while
            else if dlgMsg.isScreenClosed()
                exit while
            end if
        end if
    end while
End Function


'******************************************************
' Create Keyboard Screen
'******************************************************

Function createKeyboardScreen(title = "", prompt = "", defaultText = "", secure = false)
    result = ""

    port = CreateObject("roMessagePort")
    screen = CreateObject("roKeyboardScreen")
    screen.SetMessagePort(port)

    ' Set Title
    if title <> ""
        screen.SetTitle(title)
    end if

    ' Set Display Text
    if prompt <> ""
        screen.SetDisplayText(prompt)
    end if

    ' Set Default Text
    if defaultText <> ""
        screen.SetText(defaultText)
    end if

    ' Add Buttons
    screen.AddButton(1, "Okay")
    screen.AddButton(2, "Cancel")

    ' If secure is true, the typed text will be obscured on the screen
    ' this is useful when the user is entering a password
    screen.SetSecureText(secure)

    ' Show keyboard screen
    screen.Show()

    while true
        msg = wait(0, port)

        if type(msg) = "roKeyboardScreenEvent" then
            if msg.isScreenClosed() then
                exit while
            else if msg.isButtonPressed()
                if msg.GetIndex() = 1
                    ' the user pressed the Okay button
                    ' close the screen and return the text they entered
                    result = screen.GetText()
                    exit while
                else if msg.GetIndex() = 2
                    ' the user pressed the Cancel button
                    ' close the screen and return an empty string
                    result = ""
                    exit while
                end if
            end if
        end if
    end while

    screen.Close()
    return result
End Function
