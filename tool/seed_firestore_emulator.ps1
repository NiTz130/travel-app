$ErrorActionPreference = "Stop"

$projectId = "travel-app-v2-dev"
$base = "http://127.0.0.1:8080/v1/projects/$projectId/databases/(default)/documents"

function ConvertTo-FirestoreValue {
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [AllowNull()]
    $Value
  )

  if ($null -eq $Value) {
    return @{ nullValue = $null }
  }

  if ($Value -is [bool]) {
    return @{ booleanValue = $Value }
  }

  if ($Value -is [byte] -or
      $Value -is [int16] -or
      $Value -is [int] -or
      $Value -is [int64]) {
    return @{ integerValue = [string]$Value }
  }

  if ($Value -is [single] -or
      $Value -is [double] -or
      $Value -is [decimal]) {
    return @{ doubleValue = [double]$Value }
  }

  if ($Value -is [System.Collections.IDictionary]) {
    $fields = @{}
    foreach ($entry in $Value.GetEnumerator()) {
      $fields[[string]$entry.Key] = ConvertTo-FirestoreValue $entry.Value
    }
    return @{ mapValue = @{ fields = $fields } }
  }

  if ($Value -is [array]) {
    $values = @()
    foreach ($item in $Value) {
      $values += ConvertTo-FirestoreValue $item
    }
    return @{ arrayValue = @{ values = $values } }
  }

  return @{ stringValue = [string]$Value }
}

function New-FirestoreFields {
  param(
    [Parameter(Mandatory = $true)]
    [hashtable]$Fields
  )

  $typedFields = @{}
  foreach ($entry in $Fields.GetEnumerator()) {
    $typedFields[[string]$entry.Key] = ConvertTo-FirestoreValue $entry.Value
  }
  return $typedFields
}

function Set-FirestoreDocument {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [hashtable]$Fields
  )

  $body = @{
    fields = New-FirestoreFields $Fields
  }

  $json = $body | ConvertTo-Json -Depth 50
  Invoke-RestMethod `
    -Method Patch `
    -Uri "$base/$Path" `
    -ContentType "application/json" `
    -Body $json | Out-Null
}

$commonFields = @{
  rating = 4.5
  address = "Da Nang, Vietnam"
  phone = "0900000000"
  imageUrls = @("https://via.placeholder.com/800x450.png?text=Da+Nang")
  openingHours = @("Open daily")
  location = @{
    lat = 16.0544
    lng = 108.2022
  }
}

Set-FirestoreDocument "cities/da-nang" ($commonFields + @{
  placeId = "city-da-nang"
  title = "Da Nang"
  searchString = "locality"
  reviews = @()
})

Set-FirestoreDocument "attractions/dragon-bridge" ($commonFields + @{
  placeId = "attraction-dragon-bridge"
  title = "Dragon Bridge"
  searchString = "attraction"
  city = "Da Nang"
  reviews = @()
  userIds = @()
})

Set-FirestoreDocument "restaurants/sample-restaurant" ($commonFields + @{
  placeId = "restaurant-sample"
  title = "Sample Restaurant"
  searchString = "restaurant"
  city = "Da Nang"
  reviews = @()
})

Write-Output "Seeded Firestore Emulator for project $projectId."
