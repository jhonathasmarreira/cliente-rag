# Libera ClipCursor enquanto BrasaRO estiver aberto (mouse livre em janela).
$ErrorActionPreference = 'SilentlyContinue'
Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class FreeMouseNative {
  [DllImport("user32.dll")] public static extern bool ClipCursor(IntPtr lpRect);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
  [DllImport("user32.dll")] public static extern bool ReleaseCapture();
}
"@
while (Get-Process BrasaRO -ErrorAction SilentlyContinue) {
  [void][FreeMouseNative]::ClipCursor([IntPtr]::Zero)
  $fg = [FreeMouseNative]::GetForegroundWindow()
  if ($fg -ne [IntPtr]::Zero) {
    [uint32]$pid = 0
    [void][FreeMouseNative]::GetWindowThreadProcessId($fg, [ref]$pid)
    $p = Get-Process -Id $pid -ErrorAction SilentlyContinue
    if ($p -and $p.ProcessName -eq 'BrasaRO') {
      [void][FreeMouseNative]::ReleaseCapture()
      [void][FreeMouseNative]::ClipCursor([IntPtr]::Zero)
    }
  }
  Start-Sleep -Milliseconds 100
}
