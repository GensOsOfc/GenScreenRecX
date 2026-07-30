<#
.SYNOPSIS
    GenScreenRecX Ultimate - Grabador de pantalla con FFmpeg
.DESCRIPTION
    Modo 1: FFmpeg + WASAPI Loopback (audio_capture.exe, sin drivers)
    Modo 2: FFmpeg + VB-Cable / Stereo Mix (cable virtual, más estable)
.NOTES
    Autor: GeniousMods
    GitHub: https://github.com/GensOsOfc
#>

#requires -Version 5.1
Add-Type -AssemblyName System.Windows.Forms

# ═══════════════════════════════════════════════════════════════
# CONFIGURACIÓN
# ═══════════════════════════════════════════════════════════════
$Brand            = "GenScreenRecX Ultimate"
$Root             = $PSScriptRoot
$Tools            = Join-Path $Root "tools"
$ffmpeg           = Join-Path $Tools "ffmpeg.exe"
$OutDir           = Join-Path $Root "records"
$LogFile          = Join-Path $Root "GenScreenRecX.log"
$AudioCaptureExe  = Join-Path $Tools "audio_capture.exe"
$AudioCaptureURL  = "https://github.com/huxinhai/audio-capture/releases/latest/download/audio_capture-windows-x64.exe"

# ═══════════════════════════════════════════════════════════════
# FUNCIONES AUXILIARES
# ═══════════════════════════════════════════════════════════════
function Write-Log([string]$Message, [string]$Level = "INFO") {
    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Add-Content -Path $LogFile -Value $line -ErrorAction SilentlyContinue
}

function Show-Error([string]$msg) {
    [System.Windows.Forms.MessageBox]::Show($msg, $Brand, "OK", "Error") | Out-Null
    Write-Log $msg "ERROR"
}

function Show-Info([string]$msg) {
    [System.Windows.Forms.MessageBox]::Show($msg, $Brand, "OK", "Information") | Out-Null
}

function Show-Header {
    Clear-Host
    Write-Host @"
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║         GenScreenRecX Ultimate  -  By: GeniousMods            ║
    ║         GitHub: https://github.com/GensOsOfc                  ║
    ║         YouTube: https://www.youtube.com/@GeniousMods         ║
    ║         2 modos FFmpeg | WASAPI o VB-Cable                    ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan
}

function Show-Menu {
    param(
        [Parameter(Mandatory)][string[]]$Options,
        [string]$Title = "Selecciona una opción"
    )
    Write-Host "`n  $Title" -ForegroundColor Yellow
    Write-Host "  $("─" * 55)" -ForegroundColor DarkGray
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host "  [$($i + 1)] $($Options[$i])" -ForegroundColor White
    }
    Write-Host "  [0] Volver / Salir" -ForegroundColor Red
    Write-Host "  $("─" * 55)" -ForegroundColor DarkGray
    do { $choice = Read-Host "`n  Tu elección" }
    while ($choice -notmatch '^\d+$' -or [int]$choice -lt 0 -or [int]$choice -gt $Options.Count)
    return [int]$choice
}

# ═══════════════════════════════════════════════════════════════
# HELPERS COMPARTIDOS
# ═══════════════════════════════════════════════════════════════
function Assert-FFmpeg {
    if (-not (Test-Path $ffmpeg)) {
        Show-Error "No encuentro ffmpeg.exe en:`n$ffmpeg`n`nDescarga desde https://ffmpeg.org y ponlo en la carpeta 'tools'."
        return $false
    }
    return $true
}

function Ensure-OutputDir {
    if (-not (Test-Path $OutDir)) {
        New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
    }
}

# Devuelve @{ System = @(...); Mics = @(...) }
function Get-AudioDevices {
    $result = @{ System = @(); Mics = @() }
    try {
        # FFmpeg escribe la lista en stderr. Convertimos cada entrada a texto
        # para evitar que PowerShell recorte o trate las líneas como ErrorRecord.
        $lines = & $ffmpeg -hide_banner -list_devices true -f dshow -i dummy 2>&1 |
            ForEach-Object { $_.ToString() }

        foreach ($line in $lines) {
            if ($line -match '\"([^\"]+)\"\s+\(audio\)') {
                $name = $matches[1].Trim()
                if ([string]::IsNullOrWhiteSpace($name)) { continue }

                $lower = $name.ToLowerInvariant()
                if ($lower -match 'cable output|stereo mix|what u hear|loopback') {
                    if ($result.System -notcontains $name) { $result.System += $name }
                }
                elseif ($lower -match 'microphone|micrófono|microfono|mic array|microphone array') {
                    if ($result.Mics -notcontains $name) { $result.Mics += $name }
                }
                else {
                    # Todo dispositivo de audio que no parece loopback se ofrece como micrófono.
                    if ($result.Mics -notcontains $name) { $result.Mics += $name }
                }
            }
        }
    } catch {
        Write-Log "Error detectando dispositivos de audio: $($_.Exception.Message)" "ERROR"
    }
    return $result
}

function Select-MicDevice([string[]]$Mics) {
    if ($Mics.Count -eq 0) { return $null }
    $opts  = @("No, solo audio del sistema") + $Mics
    $sel   = Show-Menu -Options $opts -Title "¿Incluir micrófono?"
    if ($sel -le 1) { return $null }
    return $Mics[$sel - 2]
}

function Select-Quality {
    $opts = @(
        "Rápido    (CRF 28, preset superfast)",
        "Equilibrado (CRF 23, preset veryfast) [recomendado]",
        "Calidad   (CRF 18, preset medium)"
    )
    $sel = Show-Menu -Options $opts -Title "Calidad de video"
    $quality = switch ($sel) {
        1 { @{ CRF = 28; Preset = "superfast" } }
        3 { @{ CRF = 18; Preset = "medium"    } }
        default { @{ CRF = 23; Preset = "veryfast" } }
    }
    return $quality
}

function Show-RecordingResult([string]$OutFile) {
    if (Test-Path $OutFile) {
        $size = [math]::Round((Get-Item $OutFile).Length / 1MB, 2)
        Show-Info "Grabación FINALIZADA ✅`n`nArchivo: $OutFile`nTamaño: $size MB"
        Write-Log "Finalizado: $OutFile ($size MB)"
    }
}

# ═══════════════════════════════════════════════════════════════
# MODO 1: FFMPEG + WASAPI LOOPBACK (audio_capture.exe)
# ═══════════════════════════════════════════════════════════════
function Assert-AudioCapture {
    if (Test-Path $AudioCaptureExe) { return $true }

    Write-Host "`n  ⚠️  No encuentro audio_capture.exe" -ForegroundColor Yellow
    Write-Host "  Herramienta open source (~200 KB) para capturar audio del sistema vía WASAPI." -ForegroundColor Gray
    $sel = Show-Menu -Options @("Descargar automáticamente desde GitHub") -Title "¿Descargar ahora?"
    if ($sel -ne 1) { return $false }

    try {
        if (-not (Test-Path $Tools)) { New-Item -ItemType Directory -Path $Tools -Force | Out-Null }
        Write-Host "  Descargando audio_capture.exe..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $AudioCaptureURL -OutFile $AudioCaptureExe -UseBasicParsing
        Write-Host "  ✅ Listo: $AudioCaptureExe" -ForegroundColor Green
        Write-Log "audio_capture.exe descargado correctamente"
        return $true
    } catch {
        Show-Error "Error descargando audio_capture.exe:`n$($_.Exception.Message)`n`nDescarga manual desde:`nhttps://github.com/huxinhai/audio-capture/releases"
        return $false
    }
}

function Build-WasapiFFmpegArgs([string]$OutFile, [hashtable]$Quality, [string]$MicName) {
    $args = [System.Collections.Generic.List[string]]@(
        "-hide_banner", "-y",
        "-f", "gdigrab", "-framerate", "30", "-draw_mouse", "1", "-i", "desktop"
    )

    # Micrófono (entrada 1)
    if ($MicName) {
        $args.AddRange([string[]]@(
            "-f", "dshow", "-rtbufsize", "100M", "-thread_queue_size", "4096",
            "-i", "audio=$MicName"
        ))
    }

    # Audio del sistema via pipe (siempre la última entrada de audio)
    $args.AddRange([string[]]@(
        "-f", "s16le", "-ar", "48000", "-ac", "2",
        "-thread_queue_size", "4096", "-i", "pipe:0"
    ))

    # Mapeos
    $args.AddRange([string[]]@("-map", "0:v"))
    if ($MicName) {
        $args.AddRange([string[]]@("-map", "1:a", "-map", "2:a"))
    } else {
        $args.AddRange([string[]]@("-map", "1:a"))
    }

    # Codecs y salida
    $args.AddRange([string[]]@(
        "-c:v", "libx264", "-preset", $Quality.Preset, "-crf", "$($Quality.CRF)", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k",
        $OutFile
    ))

    return $args
}

function ConvertTo-CommandLineArgument([string]$Value) {
    if ($null -eq $Value) { return '""' }
    if ($Value -notmatch '[\s"]') { return $Value }

    # Escapado compatible con CommandLineToArgvW para argumentos con espacios.
    $escaped = $Value -replace '(\\*)"', '$1$1\"'
    $escaped = $escaped -replace '(\\+)$', '$1$1'
    return '"' + $escaped + '"'
}

function Start-PipedRecording([string]$OutFile, [string[]]$FFmpegArgs) {
    # Inicia audio_capture.exe
    $audioPsi = New-Object System.Diagnostics.ProcessStartInfo
    $audioPsi.FileName             = $AudioCaptureExe
    $audioPsi.Arguments            = "--sample-rate 48000 --channels 2 --bit-depth 16"
    $audioPsi.RedirectStandardOutput = $true
    $audioPsi.RedirectStandardError  = $true
    $audioPsi.UseShellExecute      = $false
    $audioPsi.CreateNoWindow       = $true
    $audioProc = [System.Diagnostics.Process]::Start($audioPsi)

    # Inicia ffmpeg con stdin
    $ffmpegPsi = New-Object System.Diagnostics.ProcessStartInfo
    $ffmpegPsi.FileName            = $ffmpeg
    $ffmpegPsi.Arguments           = (($FFmpegArgs | ForEach-Object { ConvertTo-CommandLineArgument $_ }) -join " ")
    $ffmpegPsi.RedirectStandardInput = $true
    $ffmpegPsi.UseShellExecute     = $false
    $ffmpegPsi.CreateNoWindow      = $false   # Visible para ver progreso

    try {
        $ffmpegProc = [System.Diagnostics.Process]::Start($ffmpegPsi)
        $buf = New-Object byte[] 8192

        while (-not $audioProc.HasExited -and -not $ffmpegProc.HasExited) {
            $read = $audioProc.StandardOutput.BaseStream.Read($buf, 0, $buf.Length)
            if ($read -gt 0) {
                $ffmpegProc.StandardInput.BaseStream.Write($buf, 0, $read)
            } else {
                Start-Sleep -Milliseconds 10
            }
        }
        $ffmpegProc.WaitForExit()
    } finally {
        if (-not $audioProc.HasExited)  { $audioProc.Kill()  }
        if ($ffmpegProc -and -not $ffmpegProc.HasExited) { $ffmpegProc.Kill() }
    }
}

function Start-FFmpegWasapiRecording {
    if (-not (Assert-FFmpeg))       { return }
    if (-not (Assert-AudioCapture)) { return }
    Ensure-OutputDir

    Show-Header
    Write-Host "`n  ⚡ MODO FFMPEG + WASAPI LOOPBACK" -ForegroundColor Green
    Write-Host "  Captura audio del sistema sin instalar drivers extra." -ForegroundColor Gray

    $devices = Get-AudioDevices
    if ($devices.Mics.Count -eq 0) {
        Write-Host "  ⚠️ No se detectaron micrófonos DirectShow." -ForegroundColor Yellow
        Write-Log "No se detectaron micrófonos DirectShow" "WARN"
    } else {
        Write-Host "  🎙 Micrófonos detectados: $($devices.Mics -join ', ')" -ForegroundColor Green
    }
    $micName = Select-MicDevice -Mics $devices.Mics
    $quality  = Select-Quality

    $ts      = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $outFile = Join-Path $OutDir "record_wasapi_$ts.mkv"
    $audioDesc = if ($micName) { "Sistema + Micrófono ($micName)" } else { "Solo sistema (WASAPI)" }

    Show-Info "GRABACIÓN INICIADA`nModo: FFmpeg + WASAPI`nAudio: $audioDesc`nArchivo: $outFile`n`nPara detener: Cierra la ventana de FFmpeg."
    Write-Log "Inicio WASAPI: $outFile | CRF $($quality.CRF) | Audio: $audioDesc"

    $ffmpegArgs = Build-WasapiFFmpegArgs -OutFile $outFile -Quality $quality -MicName $micName
    Start-PipedRecording -OutFile $outFile -FFmpegArgs $ffmpegArgs

    Show-RecordingResult -OutFile $outFile
}

# ═══════════════════════════════════════════════════════════════
# MODO 2: FFMPEG + VB-CABLE / STEREO MIX
# ═══════════════════════════════════════════════════════════════
function Start-FFmpegVBCableRecording {
    if (-not (Assert-FFmpeg)) { return }
    Ensure-OutputDir

    Show-Header
    Write-Host "`n  🔌 MODO FFMPEG + VB-CABLE / STEREO MIX" -ForegroundColor Green
    Write-Host "  Requiere VB-Cable o Stereo Mix habilitado. Muy estable para uso frecuente." -ForegroundColor Gray

    $devices = Get-AudioDevices

    if ($devices.System.Count -eq 0) {
        Show-Error "No detecté ningún dispositivo de loopback.`n`nOpciones:`n• Instala VB-Cable: https://vb-audio.com/Cable/`n• Habilita 'Stereo Mix' en el Panel de Sonido de Windows`n`nO usa el Modo WASAPI (sin dependencias)."
        return
    }

    $sysName = if ($devices.System.Count -eq 1) {
        $devices.System[0]
    } else {
        $sel = Show-Menu -Options $devices.System -Title "Selecciona dispositivo de audio del sistema"
        if ($sel -eq 0) { return }
        $devices.System[$sel - 1]
    }

    $micName = Select-MicDevice -Mics $devices.Mics
    $quality  = Select-Quality

    $ts      = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $outFile = Join-Path $OutDir "record_vbcable_$ts.mkv"
    $audioDesc = if ($micName) { "$sysName + Micrófono ($micName)" } else { $sysName }

    # Construir argumentos
    $ffmpegArgs = [System.Collections.Generic.List[string]]@(
        "-hide_banner", "-y",
        "-f", "gdigrab", "-framerate", "30", "-draw_mouse", "1", "-i", "desktop",
        "-f", "dshow", "-rtbufsize", "100M", "-thread_queue_size", "4096", "-i", "audio=$sysName"
    )

    if ($micName) {
        $ffmpegArgs.AddRange([string[]]@(
            "-f", "dshow", "-rtbufsize", "100M", "-thread_queue_size", "4096", "-i", "audio=$micName",
            "-map", "0:v", "-map", "1:a", "-map", "2:a"
        ))
    } else {
        $ffmpegArgs.AddRange([string[]]@("-map", "0:v", "-map", "1:a"))
    }

    $ffmpegArgs.AddRange([string[]]@(
        "-c:v", "libx264", "-preset", $quality.Preset, "-crf", "$($quality.CRF)", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k",
        $outFile
    ))

    Show-Info "GRABACIÓN INICIADA`nModo: FFmpeg + VB-Cable`nAudio: $audioDesc`nArchivo: $outFile`n`nPara detener: Presiona [Q] en la consola de FFmpeg."
    Write-Log "Inicio VB-Cable: $outFile | CRF $($quality.CRF) | Audio: $audioDesc"

    & $ffmpeg @ffmpegArgs

    Show-RecordingResult -OutFile $outFile
}

# ═══════════════════════════════════════════════════════════════
# MENÚ PRINCIPAL
# ═══════════════════════════════════════════════════════════════
do {
    Show-Header
    $choice = Show-Menu -Options @(
        "⚡ FFmpeg + WASAPI Loopback  — Sin drivers extra (descarga ~200 KB)",
        "🔌 FFmpeg + VB-Cable         — Requiere VB-Cable o Stereo Mix habilitado"
    ) -Title "¿Cómo quieres grabar?"

    switch ($choice) {
        1 { Start-FFmpegWasapiRecording }
        2 { Start-FFmpegVBCableRecording }
        0 { Write-Host "`n  Saliendo...`n" -ForegroundColor Red; exit }
    }

    if ($choice -ne 0) {
        $again = Show-Menu -Options @("Volver al menú principal") -Title "¿Qué deseas hacer?"
        if ($again -eq 0) { Write-Host "`n  Saliendo...`n" -ForegroundColor Red; exit }
    }
} while ($true)