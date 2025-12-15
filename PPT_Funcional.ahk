; ============================================
; CONTROL PPT - VERSIÓN FUNCIONAL
; ============================================
#NoEnv
#SingleInstance Force
SetBatchLines, -1

; CONFIGURAR PUERTO AQUÍ
PuertoCOM := "COM12"  ; <--- ¡CAMBIAR ESTO!

; Variable para el puerto
PortHandle := 0

; Crear ventana simple
Gui, Add, Text, x10 y10 w200, Controlador PowerPoint
Gui, Add, Text, x10 y35, Puerto COM:
Gui, Add, Edit, x80 y33 w60 vEditCOM, %PuertoCOM%
Gui, Add, Button, x150 y32 w80 gBtnConectar, Conectar
Gui, Add, Text, x10 y65 w200 vTextoEstado, [Esperando conexión]
Gui, Add, Text, x10 y90, Mensajes:
Gui, Add, Edit, x10 y110 w280 h100 vEditLog ReadOnly,
Gui, Show, w300 h220, ESP32 PPT

; Intentar conectar automáticamente
SetTimer, ConectarAuto, 1000
return

; ============================================
; CONEXIÓN AUTOMÁTICA
; ============================================
ConectarAuto:
    SetTimer, ConectarAuto, Off  ; Solo una vez
    
    ; Cerrar si ya estaba abierto
    if (PortHandle) {
        DllCall("CloseHandle", "UInt", PortHandle)
        PortHandle := 0
    }
    
    GuiControlGet, PuertoCOM,, EditCOM
    
    ; Intentar abrir puerto
    PortHandle := DllCall("CreateFile", "Str", "\\.\" . PuertoCOM, "UInt", 0xC0000000, "UInt", 3, "UInt", 0, "UInt", 3, "UInt", 0, "UInt", 0)
    
    if (PortHandle = -1 or PortHandle = 0) {
        Log("Error: No se pudo abrir " . PuertoCOM)
        GuiControl,, TextoEstado, [ERROR - Verifica COM]
        return
    }
    
    ; Configurar puerto
    DCB := "baud=115200 parity=N data=8 stop=1"
    VarSetCapacity(DCBStruct, 28, 0)
    NumPut(28, DCBStruct, 0, "UInt")
    DllCall("BuildCommDCB", "Str", DCB, "UInt", &DCBStruct)
    DllCall("SetCommState", "UInt", PortHandle, "UInt", &DCBStruct)
    
    ; Configurar timeouts
    VarSetCapacity(Timeouts, 20, 0)
    NumPut(0, Timeouts, 0, "UInt")   ; ReadIntervalTimeout
    NumPut(1, Timeouts, 4, "UInt")   ; ReadTotalTimeoutMultiplier
    NumPut(1, Timeouts, 8, "UInt")   ; ReadTotalTimeoutConstant
    NumPut(1, Timeouts, 12, "UInt")  ; WriteTotalTimeoutMultiplier
    NumPut(1, Timeouts, 16, "UInt")  ; WriteTotalTimeoutConstant
    DllCall("SetCommTimeouts", "UInt", PortHandle, "UInt", &Timeouts)
    
    Log("Conectado a " . PuertoCOM)
    GuiControl,, TextoEstado, [CONECTADO - Listo!]
    
    ; Iniciar lectura
    SetTimer, LeerSerial, 10
return

; ============================================
; LEER DATOS DEL PUERTO
; ============================================
LeerSerial:
    if (!PortHandle)
        return
    
    ; Leer bytes disponibles
    VarSetCapacity(ReadBuffer, 1)
    BytesRead := 0
    
    ; Leer un byte
    Success := DllCall("ReadFile", "UInt", PortHandle, "UInt", &ReadBuffer, "UInt", 1, "UInt*", BytesRead, "UInt", 0)
    
    if (Success and BytesRead = 1) {
        Byte := NumGet(ReadBuffer, 0, "UChar")
        Cmd := Chr(Byte)
        
        ; Mostrar en log
        Tiempo := A_Hour . ":" . A_Min . ":" . A_Sec
        Log(Tiempo . " - Cmd: " . Cmd)
        
        ; Ejecutar comando
        if (Cmd = "N") {
            Send, {Right}
            ;ToolTip, → SIGUIENTE, 10, 10
            ;Sleep, 300
            ;ToolTip
        }
        else if (Cmd = "P") {
            Send, {Left}
            ;ToolTip, ← ANTERIOR, 10, 10
            ;Sleep, 300
            ;ToolTip
        }
        else if (Cmd = "S") {
            Send, {F5}
        }
        else if (Cmd = "E") {
            Send, {Esc}
        }
        else if (Cmd = "B") {
            Send, {.}
        }
        else if (Cmd = "W") {
            Send, {,}
        }
    }
return

; ============================================
; BOTÓN CONECTAR MANUAL
; ============================================
BtnConectar:
    ; Cerrar conexión actual
    if (PortHandle) {
        DllCall("CloseHandle", "UInt", PortHandle)
        PortHandle := 0
        SetTimer, LeerSerial, Off
    }
    
    ; Reconectar
    SetTimer, ConectarAuto, 100
return

; ============================================
; FUNCIÓN LOG
; ============================================
Log(Mensaje) {
    GuiControlGet, TextoActual,, EditLog
    NuevoTexto := Mensaje . "`n" . TextoActual
    
    ; Limitar a 10 líneas
    Loop, Parse, NuevoTexto, `n
    {
        if (A_Index <= 10)
            TextoFinal .= A_LoopField . "`n"
    }
    
    GuiControl,, EditLog, %TextoFinal%
}

; ============================================
; TECLAS DE PRUEBA (opcional)
; ============================================
F1::Send, {Right}  ; Siguiente
F2::Send, {Left}   ; Anterior
^F1::Send, {F5}    ; Iniciar (Ctrl+F1)
^F2::Send, {Esc}   ; Terminar (Ctrl+F2)

; ============================================
; CERRAR
; ============================================
GuiClose:
    if (PortHandle) {
        DllCall("CloseHandle", "UInt", PortHandle)
    }
    ExitApp