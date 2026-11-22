param(
    [int]$Port = 8080,
    [string]$Root = "build\web"
)

$resolvedRoot = Resolve-Path (Join-Path $PSScriptRoot $Root)
Write-Output "Starting Banchong Cafe Web Server at http://0.0.0.0:$Port/"
Write-Output "Serving directory: $resolvedRoot"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://*:$Port/")

try {
    $listener.Start()
} catch {
    # If wildcard requires admin, fall back to localhost + IP
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:$Port/")
    $listener.Prefixes.Add("http://192.168.1.132:$Port/")
    $listener.Start()
}

Write-Output "Server running successfully!"
Write-Output "Access on computer: http://localhost:$Port"
Write-Output "Access on mobile:   http://192.168.1.132:$Port"

$mimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".htm"  = "text/html; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".mjs"  = "application/javascript; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".wasm" = "application/wasm"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".ttf"  = "font/ttf"
    ".otf"  = "font/otf"
    ".woff" = "font/woff"
    ".woff2"= "font/woff2"
}

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $path = $request.Url.LocalPath.TrimStart('/')
        if ([string]::IsNullOrWhiteSpace($path)) {
            $path = "index.html"
        }

        $filePath = Join-Path $resolvedRoot $path

        # If file not found, serve index.html for SPA routing
        if (-not (Test-Path $filePath -PathType Leaf)) {
            $filePath = Join-Path $resolvedRoot "index.html"
        }

        if (Test-Path $filePath -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            $contentType = if ($mimeTypes.ContainsKey($ext)) { $mimeTypes[$ext] } else { "application/octet-stream" }
            $response.ContentType = $contentType
            $response.Headers.Add("Access-Control-Allow-Origin", "*")

            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
        }
        $response.Close()
    } catch {
        # ignore client disconnects
    }
}
