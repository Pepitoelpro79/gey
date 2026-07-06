$port = 5555
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

$http = [System.Net.HttpListener]::new()
$http.Prefixes.Add("http://localhost:$port/")
$http.Start()

Write-Host "🏳️‍🌈 Servidor de Joselo corriendo en http://localhost:$port" -ForegroundColor Magenta
Write-Host "Presiona Ctrl+C para detenerlo" -ForegroundColor Gray

while ($http.IsListening) {
  $ctx = $http.GetContext()
  $req = $ctx.Request
  $rsp = $ctx.Response

  $path = $req.Url.AbsolutePath.TrimStart('/')
  if ($path -eq '') { $path = 'joselo.html' }

  $file = Join-Path $root $path
  if (Test-Path -LiteralPath $file -PathType Leaf) {
    $ext = [System.IO.Path]::GetExtension($file).ToLower()
    $mime = @{
      '.html' = 'text/html; charset=utf-8'
      '.css'  = 'text/css; charset=utf-8'
      '.js'   = 'application/javascript; charset=utf-8'
      '.png'  = 'image/png'
      '.jpg'  = 'image/jpeg'
      '.gif'  = 'image/gif'
      '.svg'  = 'image/svg+xml'
      '.ico'  = 'image/x-icon'
    }
    $rsp.ContentType = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' }
    $bytes = [System.IO.File]::ReadAllBytes($file)
    $rsp.ContentLength64 = $bytes.Length
    $rsp.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $rsp.StatusCode = 404
    $data = [Text.Encoding]::UTF8.GetBytes('404 Not Found')
    $rsp.ContentLength64 = $data.Length
    $rsp.OutputStream.Write($data, 0, $data.Length)
  }
  $rsp.OutputStream.Close()
}

$http.Stop()
