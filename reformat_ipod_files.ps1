# Install-Module -Name AudioWorks.Commands 
# pip install eyeD3
## install irfanview via exe

Get-ChildItem * -include '*.mp3','*.flac', '*.aac', '*.wav', '*.ogg' -recurse |
Foreach-Object {
  cd ($_.directoryname -replace '[[\]]', '`$&')
  
  if (!(Test-Path ./Cover.jpg)) {
    echo ('>> grabbing cover for ' + $_.directoryname)
    ffmpeg -i $_.fullname -an -y -hide_banner -loglevel error -frames:v 1 -c:v copy Cover.jpg
  }
  
  if ((Test-Path ./Cover.png)) {
    echo ('>> converting cover.png to jpg')
    Start-Process -FilePath "C:\Program Files\IrfanView\i_view64.exe" -ArgumentList "Cover.png /convert=Cover.jpg" -Wait -NoNewWindow -PassThru 
    remove-Item Cover.png
  }
  
  if ((Test-Path ./Cover.jpg)) {
    $cover = get-item '.\cover.jpg'
    $coverObject = [System.Drawing.Image]::FromFile($cover.FullName);
    $coverWidth = $coverObject.Width
    $coverHeight = $coverObject.Height

    $coverObject.Dispose()

    if ($coverWidth -gt 200 -Or $coverHeight -gt 200){
      echo ('>> resizing cover.jpg to 200x200')
      Start-Process -FilePath "C:\Program Files\IrfanView\i_view64.exe" -ArgumentList "Cover.jpg /resize=(200,200) /resample /convert=Cover_resized.jpg" -Wait -NoNewWindow -PassThru 
      remove-Item Cover.jpg 
      mv Cover_resized.jpg Cover.jpg
    }

    eyeD3 -Q --remove-all-images $_.fullname
  }

  if ($_.extension -eq '.flac' -or $_.extension -eq '.wav') {
    echo ('>> downmixing ' + $_.basename + ' to mp3')
    Get-AudioFile $_.fullname | Export-AudioFile LameMP3 -b 320 . && remove-Item $_.fullname
  }
}