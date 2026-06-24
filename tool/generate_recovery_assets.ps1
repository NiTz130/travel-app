Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = (Resolve-Path (Join-Path $scriptDir "..")).Path
$assetDir = Join-Path $projectRoot "assets/images"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

New-Item -ItemType Directory -Force -Path $assetDir | Out-Null

$imageSpecs = @(
    @{ Name = "app bac.jpg"; Label = "TRAVEL"; Kind = "Background"; Width = 900; Height = 1400; Primary = @(68, 171, 196); Secondary = @(25, 93, 118) },
    @{ Name = "Rectangle 1.png"; Label = "WELCOME"; Kind = "Panel"; Width = 520; Height = 280; Primary = @(37, 131, 175); Secondary = @(36, 178, 137) },
    @{ Name = "Rectangle 1 loging.png"; Label = "SIGN IN"; Kind = "Panel"; Width = 520; Height = 280; Primary = @(26, 110, 151); Secondary = @(58, 176, 138) },
    @{ Name = "home.png"; Label = "HM"; Kind = "Icon"; Primary = @(91, 129, 179) },
    @{ Name = "homeClick.png"; Label = "HM"; Kind = "Icon"; Primary = @(28, 85, 150) },
    @{ Name = "search.png"; Label = "SE"; Kind = "Icon"; Primary = @(91, 129, 179) },
    @{ Name = "searchClick.png"; Label = "SE"; Kind = "Icon"; Primary = @(28, 85, 150) },
    @{ Name = "map.png"; Label = "MP"; Kind = "Icon"; Primary = @(91, 129, 179) },
    @{ Name = "mapClick.png"; Label = "MP"; Kind = "Icon"; Primary = @(28, 85, 150) },
    @{ Name = "like.png"; Label = "LK"; Kind = "Icon"; Primary = @(91, 129, 179) },
    @{ Name = "likeClick.png"; Label = "LK"; Kind = "Icon"; Primary = @(28, 85, 150) },
    @{ Name = "user.png"; Label = "US"; Kind = "Icon"; Primary = @(91, 129, 179) },
    @{ Name = "userClick.png"; Label = "US"; Kind = "Icon"; Primary = @(28, 85, 150) },
    @{ Name = "hotel.png"; Label = "HT"; Kind = "Icon"; Primary = @(48, 132, 219) },
    @{ Name = "burger.png"; Label = "CA"; Kind = "Icon"; Primary = @(220, 128, 75) },
    @{ Name = "forest.png"; Label = "PA"; Kind = "Icon"; Primary = @(48, 149, 97) },
    @{ Name = "flash.png"; Label = "AT"; Kind = "Icon"; Primary = @(232, 171, 55) },
    @{ Name = "gas-pump.png"; Label = "GS"; Kind = "Icon"; Primary = @(104, 112, 120) },
    @{ Name = "heart.png"; Label = "HV"; Kind = "Icon"; Primary = @(224, 92, 116) },
    @{ Name = "heartBlack.png"; Label = "HF"; Kind = "Icon"; Primary = @(34, 34, 34) },
    @{ Name = "star.png"; Label = "ST"; Kind = "Icon"; Primary = @(230, 174, 57) },
    @{ Name = "location.png"; Label = "LO"; Kind = "Icon"; Primary = @(50, 132, 183) },
    @{ Name = "correct.png"; Label = "OK"; Kind = "Icon"; Primary = @(55, 159, 103) },
    @{ Name = "dry-clean.png"; Label = "CL"; Kind = "Icon"; Primary = @(139, 144, 152) },
    @{ Name = "travel.png"; Label = "TR"; Kind = "Icon"; Primary = @(44, 154, 151) },
    @{ Name = "destination.png"; Label = "DS"; Kind = "Icon"; Primary = @(35, 143, 166) },
    @{ Name = "add.png"; Label = "AD"; Kind = "Icon"; Primary = @(45, 145, 89) },
    @{ Name = "add-black.png"; Label = "AD"; Kind = "Icon"; Primary = @(38, 38, 38) },
    @{ Name = "chat-arrow.png"; Label = "CH"; Kind = "Icon"; Primary = @(52, 141, 205) },
    @{ Name = "chat-arrow-before.png"; Label = "CH"; Kind = "Icon"; Primary = @(155, 161, 168) },
    @{ Name = "facebook-logo.png"; Label = "FB"; Kind = "Icon"; Primary = @(79, 117, 164) },
    @{ Name = "google-logo.png"; Label = "GO"; Kind = "Icon"; Primary = @(196, 102, 73) },
    @{ Name = "sunny.png"; Label = "SU"; Kind = "Icon"; Primary = @(235, 176, 61) },
    @{ Name = "cloudy.png"; Label = "CL"; Kind = "Icon"; Primary = @(119, 158, 179) },
    @{ Name = "mostly-cloudy.png"; Label = "MC"; Kind = "Icon"; Primary = @(98, 137, 166) },
    @{ Name = "cloudsAndSun.png"; Label = "CS"; Kind = "Icon"; Primary = @(95, 168, 205) },
    @{ Name = "Partly-sunny.png"; Label = "PS"; Kind = "Icon"; Primary = @(231, 176, 77) },
    @{ Name = "Mostly-Sunny-Day.png"; Label = "MS"; Kind = "Icon"; Primary = @(235, 162, 54) },
    @{ Name = "PartlyCloudyNightV2.png"; Label = "PN"; Kind = "Icon"; Primary = @(58, 77, 130) },
    @{ Name = "MostlyClearNight.png"; Label = "MN"; Kind = "Icon"; Primary = @(36, 52, 109) },
    @{ Name = "MostlyCloudyNightV2.png"; Label = "CN"; Kind = "Icon"; Primary = @(68, 76, 116) },
    @{ Name = "N210LightRainShowersV2.png"; Label = "RN"; Kind = "Icon"; Primary = @(72, 111, 168) },
    @{ Name = "Light-rain.png"; Label = "LR"; Kind = "Icon"; Primary = @(75, 130, 190) },
    @{ Name = "time-left.png"; Label = "TM"; Kind = "Icon"; Primary = @(128, 132, 138) }
)

function New-SolidBrush {
    param([int[]]$Rgb)
    return [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, $Rgb[0], $Rgb[1], $Rgb[2]))
}

function New-Pen {
    param(
        [int[]]$Rgb,
        [float]$Width = 4
    )
    return [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(255, $Rgb[0], $Rgb[1], $Rgb[2]), $Width)
}

function Save-Bitmap {
    param(
        $Bitmap,
        [string]$Path,
        $Format
    )
    $Bitmap.Save($Path, $Format)
}

function New-IconAsset {
    param(
        [string]$Name,
        [string]$Label,
        [int[]]$Primary,
        [int[]]$Secondary = @(255, 255, 255),
        [int]$Size = 96
    )

    $path = Join-Path $assetDir $Name
    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $bg = $null
    $accent = $null
    $pen = $null
    $font = $null
    $format = $null

    try {
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
        $graphics.Clear([System.Drawing.Color]::Transparent)

        $bg = New-SolidBrush $Primary
        $accent = New-SolidBrush $Secondary
        $graphics.FillEllipse($bg, 8, 8, ($Size - 16), ($Size - 16))
        $graphics.FillEllipse($accent, 26, 18, 14, 14)
        $graphics.FillRectangle($accent, 54, 66, 18, 6)

        $pen = New-Pen $Secondary 5
        $graphics.DrawEllipse($pen, 19, 19, ($Size - 38), ($Size - 38))

        $font = [System.Drawing.Font]::new("Arial", 25, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
        $format = [System.Drawing.StringFormat]::new()
        $format.Alignment = [System.Drawing.StringAlignment]::Center
        $format.LineAlignment = [System.Drawing.StringAlignment]::Center
        $graphics.DrawString($Label, $font, $accent, [System.Drawing.RectangleF]::new(0, 2, $Size, $Size), $format)

        Save-Bitmap $bitmap $path ([System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        if ($format) { $format.Dispose() }
        if ($font) { $font.Dispose() }
        if ($pen) { $pen.Dispose() }
        if ($accent) { $accent.Dispose() }
        if ($bg) { $bg.Dispose() }
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

function New-PanelAsset {
    param(
        [string]$Name,
        [string]$Label,
        [int]$Width,
        [int]$Height,
        [int[]]$Primary,
        [int[]]$Secondary
    )

    $path = Join-Path $assetDir $Name
    $bitmap = [System.Drawing.Bitmap]::new($Width, $Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $rect = [System.Drawing.Rectangle]::new(0, 0, $Width, $Height)
    $brush = $null
    $accent = $null
    $font = $null
    $format = $null
    $pen = $null

    try {
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
        $brush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
            $rect,
            [System.Drawing.Color]::FromArgb(255, $Primary[0], $Primary[1], $Primary[2]),
            [System.Drawing.Color]::FromArgb(255, $Secondary[0], $Secondary[1], $Secondary[2]),
            35
        )
        $graphics.FillRectangle($brush, $rect)

        $accent = New-SolidBrush @(255, 255, 255)
        $graphics.FillEllipse($accent, ($Width - 150), 22, 96, 96)

        $pen = New-Pen @(255, 255, 255) 6
        $graphics.DrawRectangle($pen, 20, 20, ($Width - 40), ($Height - 40))

        $font = [System.Drawing.Font]::new("Arial", 36, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
        $format = [System.Drawing.StringFormat]::new()
        $format.Alignment = [System.Drawing.StringAlignment]::Center
        $format.LineAlignment = [System.Drawing.StringAlignment]::Center
        $graphics.DrawString($Label, $font, [System.Drawing.Brushes]::White, [System.Drawing.RectangleF]::new(0, 0, $Width, $Height), $format)

        Save-Bitmap $bitmap $path ([System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        if ($format) { $format.Dispose() }
        if ($font) { $font.Dispose() }
        if ($pen) { $pen.Dispose() }
        if ($accent) { $accent.Dispose() }
        if ($brush) { $brush.Dispose() }
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

function New-BackgroundAsset {
    param([string]$Name)

    $width = 900
    $height = 1400
    $path = Join-Path $assetDir $Name
    $bitmap = [System.Drawing.Bitmap]::new($width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $rect = [System.Drawing.Rectangle]::new(0, 0, $width, $height)
    $sky = $null
    $hillA = $null
    $hillB = $null
    $sun = $null
    $font = $null
    $format = $null

    try {
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
        $sky = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
            $rect,
            [System.Drawing.Color]::FromArgb(255, 68, 171, 196),
            [System.Drawing.Color]::FromArgb(255, 25, 93, 118),
            90
        )
        $graphics.FillRectangle($sky, $rect)

        $sun = New-SolidBrush @(255, 210, 105)
        $graphics.FillEllipse($sun, 620, 120, 150, 150)

        $hillA = New-SolidBrush @(42, 129, 103)
        $hillB = New-SolidBrush @(31, 101, 94)
        $graphics.FillPolygon($hillA, @(
            [System.Drawing.Point]::new(0, 930),
            [System.Drawing.Point]::new(240, 640),
            [System.Drawing.Point]::new(520, 960),
            [System.Drawing.Point]::new(900, 690),
            [System.Drawing.Point]::new(900, 1400),
            [System.Drawing.Point]::new(0, 1400)
        ))
        $graphics.FillPolygon($hillB, @(
            [System.Drawing.Point]::new(0, 1080),
            [System.Drawing.Point]::new(360, 760),
            [System.Drawing.Point]::new(710, 1110),
            [System.Drawing.Point]::new(900, 920),
            [System.Drawing.Point]::new(900, 1400),
            [System.Drawing.Point]::new(0, 1400)
        ))

        $font = [System.Drawing.Font]::new("Arial", 54, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
        $format = [System.Drawing.StringFormat]::new()
        $format.Alignment = [System.Drawing.StringAlignment]::Center
        $format.LineAlignment = [System.Drawing.StringAlignment]::Center
        $graphics.DrawString("TRAVEL", $font, [System.Drawing.Brushes]::White, [System.Drawing.RectangleF]::new(0, 420, $width, 140), $format)

        Save-Bitmap $bitmap $path ([System.Drawing.Imaging.ImageFormat]::Jpeg)
    }
    finally {
        if ($format) { $format.Dispose() }
        if ($font) { $font.Dispose() }
        if ($sun) { $sun.Dispose() }
        if ($hillB) { $hillB.Dispose() }
        if ($hillA) { $hillA.Dispose() }
        if ($sky) { $sky.Dispose() }
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

function Write-LottieAsset {
    $lottie = @'
{
  "v": "5.7.4",
  "fr": 30,
  "ip": 0,
  "op": 60,
  "w": 240,
  "h": 240,
  "nm": "Recovery checklist",
  "ddd": 0,
  "assets": [],
  "layers": [
    {
      "ddd": 0,
      "ind": 1,
      "ty": 4,
      "nm": "Project generated placeholder",
      "sr": 1,
      "ks": {
        "o": { "a": 0, "k": 100 },
        "r": { "a": 0, "k": 0 },
        "p": { "a": 0, "k": [120, 120, 0] },
        "a": { "a": 0, "k": [0, 0, 0] },
        "s": { "a": 0, "k": [100, 100, 100] }
      },
      "ao": 0,
      "shapes": [
        {
          "ty": "gr",
          "it": [
            { "ty": "rc", "d": 1, "s": { "a": 0, "k": [120, 120] }, "p": { "a": 0, "k": [0, 0] }, "r": { "a": 0, "k": 16 } },
            { "ty": "fl", "c": { "a": 0, "k": [0.18, 0.58, 0.52, 1] }, "o": { "a": 0, "k": 100 } },
            { "ty": "tr", "p": { "a": 0, "k": [0, 0] }, "a": { "a": 0, "k": [0, 0] }, "s": { "a": 0, "k": [100, 100] }, "r": { "a": 0, "k": 0 }, "o": { "a": 0, "k": 100 } }
          ]
        }
      ],
      "ip": 0,
      "op": 60,
      "st": 0,
      "bm": 0
    }
  ]
}
'@
    [System.IO.File]::WriteAllText((Join-Path $assetDir "143784-checklist.json"), $lottie, $utf8NoBom)
}

function Invoke-SystemDrawingGenerator {
    Add-Type -AssemblyName System.Drawing

    foreach ($spec in $imageSpecs) {
        switch ($spec.Kind) {
            "Background" {
                New-BackgroundAsset -Name $spec.Name
            }
            "Panel" {
                New-PanelAsset -Name $spec.Name -Label $spec.Label -Width $spec.Width -Height $spec.Height -Primary $spec.Primary -Secondary $spec.Secondary
            }
            "Icon" {
                New-IconAsset -Name $spec.Name -Label $spec.Label -Primary $spec.Primary
            }
        }
    }
}

function Invoke-FallbackGenerator {
    $onePixelPng = [Convert]::FromBase64String(
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII="
    )
    $onePixelJpeg = [Convert]::FromBase64String(
        "/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAMCAgMCAgMDAwMEAwMEBQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBYQERMUFRUVDA8XGBYUGBIUFRT/2wBDAQMEBAUEBQkFBQkUDQsNFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBT/wAARCAABAAEDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD9U6KKKAP/2Q=="
    )

    foreach ($spec in $imageSpecs) {
        $bytes = if ($spec.Name.EndsWith(".jpg", [System.StringComparison]::OrdinalIgnoreCase)) {
            $onePixelJpeg
        }
        else {
            $onePixelPng
        }
        [System.IO.File]::WriteAllBytes((Join-Path $assetDir $spec.Name), $bytes)
    }
}

try {
    Invoke-SystemDrawingGenerator
    Write-Output "Generated recovery image assets with System.Drawing in $assetDir"
}
catch {
    Write-Warning "System.Drawing asset rendering failed: $($_.Exception.Message)"
    Write-Warning "Writing deterministic fallback image assets."
    Invoke-FallbackGenerator
}

Write-LottieAsset
Write-Output "Generated recovery assets in $assetDir"
