# Install-Module -Name AudioWorks.Commands 

Get-ChildItem * -include '*.mp3','*.flac', '*.aac', '*.wav', '*.ogg' -recurse |
Foreach-Object {
  cd ($_.directoryname -replace '[[\]]', '`$&')
  if (!(Test-Path ./cover.jpg)) {
    echo ('Grabbing cover for ' + $_.directoryname)
    ffmpeg -i $_.fullname -an -y -hide_banner -loglevel error -frames:v 1 -c:v copy cover.jpg
    if ((Test-Path ./cover.jpg)) {
      Start-Process -FilePath "C:\Program Files\IrfanView\i_view64.exe" -ArgumentList "cover.jpg /resize=(200,200) /resample /convert=cover.jpg" -Wait -NoNewWindow -PassThru
    }
  }
  if ($_.extension -eq '.flac' -or $_.extension -eq '.wav') {
    echo ('downmixing ' + $_.basename + ' to mp3')
    Get-AudioFile $_.fullname | Export-AudioFile LameMP3 -b 320 . && remove-Item $_.fullname
  }
}
