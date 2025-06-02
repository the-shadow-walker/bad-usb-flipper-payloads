Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Delay 5–10 minutes
Start-Sleep -Seconds (Get-Random -Minimum 300 -Maximum 600)

$maxAttempts = 3
$attempt = 0
$responseCaptured = $false
$webhookUrl = "https://discord.com/api/webhooks/your_webhook_url"

while (-not $responseCaptured -and $attempt -lt $maxAttempts) {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Daily Feedback"
    $form.Size = New-Object System.Drawing.Size(350,220)
    $form.StartPosition = "CenterScreen"
    $form.Topmost = $true
    $form.ShowInTaskbar = $false

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "How's your day going?"
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(10,20)
    $form.Controls.Add($label)

    $textBox1 = New-Object System.Windows.Forms.TextBox
    $textBox1.Size = New-Object System.Drawing.Size(300,20)
    $textBox1.Location = New-Object System.Drawing.Point(10,50)
    $form.Controls.Add($textBox1)

    $label2 = New-Object System.Windows.Forms.Label
    $label2.Text = "Want to explain?"
    $label2.AutoSize = $true
    $label2.Location = New-Object System.Drawing.Point(10,80)
    $form.Controls.Add($label2)

    $textBox2 = New-Object System.Windows.Forms.TextBox
    $textBox2.Multiline = $true
    $textBox2.Size = New-Object System.Drawing.Size(300,40)
    $textBox2.Location = New-Object System.Drawing.Point(10,100)
    $form.Controls.Add($textBox2)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Location = New-Object System.Drawing.Point(240,150)
    $okButton.Add_Click({
        if ($textBox1.Text.Trim() -ne "" -or $textBox2.Text.Trim() -ne "") {
            $form.Tag = @{
                ShortAnswer = $textBox1.Text
                Explanation = $textBox2.Text
            }
            $responseCaptured = $true
        }
        $form.Close()
    })
    $form.Controls.Add($okButton)

    $form.ShowDialog() | Out-Null
    $attempt++
}

if ($responseCaptured) {
    $results = $form.Tag
    $payload = @{
        content = "**Day Status:** $($results.ShortAnswer)`n**Explanation:** $($results.Explanation)"
    } | ConvertTo-Json -Depth 4

    Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType 'application/json'
} else {
    Invoke-RestMethod -Uri $webhookUrl -Method Post -Body (@{
        content = "**User did not answer after $maxAttempts attempts.**"
    } | ConvertTo-Json -Depth 4) -ContentType 'application/json'
}
