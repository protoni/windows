# Script for downloading/uploading apache web server files from windows powershell
# Web server and this script uses Basic Authentication
#

#------- Globals --------------------

$cred = Get-Credential
$host_user = ""
$uploadLocation = "/var/www/html/test/" 
$PSpath = "C:\PS\" 						# path where this powershell script is copied
$filename = $MyInvocation.MyCommand.Name
$mainpath = "" 							# domain file root
$uploadFolder = "upload\"
$running = $true
$pscp = "pscp.exe"
$pkey = "" 								# private key for pscp fileupload. Only use keys with password (filename. for example: key.ppk)
$host_ip = "" 

#------- /Globals -------------------

#------- Functions ---------------

function createFolder($name) {
  If(!(test-path $name))
  {
    New-Item -ItemType Directory -Force -Path $name
    echo "Created Folder: $name"
  }
}

function getLongestStringLength($array) {
  $longest = 0
  foreach($item in $array)
  {
    $tmp = $item.length
    if($tmp -gt $longest) { $longest = $tmp }
  }

  $longest += $prefix.Length
  return $longest
}

function listFolders($folder)
{
  $content=((iwr $folder -Credential $cred -usebasicparsing).Links| Where-Object {$_.href -notlike "?C=*"} | Select-Object -Skip 1 ).href
  $longest = getLongestStringLength $content
  $space = ""
  foreach($item in $content)
  {
    $charCount = $item.Length
    for($i=0;$i -le ($longest-$charCount);$i++)
    {
      $space += " "
    }

    $size = 0
    if($item -notlike '*/') { $size = (iwr $folder$item -Credential $cred -Method Head).Headers.'Content-Length' }
    else { $size = "-" }

    if($size -like "") { $size = 0 }

    #echo $item$space$size" kB"
    
    if($item -like '*/') { Write-Host $item$space$size" kB" -ForegroundColor Red }

    $space = ""
  }
}

function showFileContent($folder)
{
  $content=((iwr $folder -Credential $cred -usebasicparsing).Links| Where-Object {$_.href -notlike "?C=*"} | Select-Object -Skip 1 ).href
  $longest = getLongestStringLength $content
  $space = ""
  foreach($item in $content)
  {
    $charCount = $item.Length
    for($i=0;$i -le ($longest-$charCount);$i++)
    {
      $space += " "
    }

    $size = 0
    if($item -notlike '*/') { $size = (iwr $folder$item -Credential $cred -Method Head).Headers.'Content-Length' }
    else { $size = "-" }

    if($size -like "") { $size = 0 }

    #echo $item$space$size" kB"
    
    if($item -like '*/') { Write-Host $item$space$size" kB" -ForegroundColor Red }
    else { Write-Host $item$space$size" kB" -ForegroundColor White }

    $space = ""
  }
}


# remember to reset $firstIteration-parameter after each function call
$firstIteration = 1
function showFolder($folder, $prefix) {
  $content=((iwr $folder -Credential $cred -usebasicparsing).Links| Where-Object {$_.href -notlike "?C=*"} | Select-Object -Skip 1 ).href
  
  if($firstIteration -eq 1) { $longest = getLongestStringLength $content}
  
  
  $space = ""
  foreach($item in $content)
  { 
    $charCount = $item.Length+$prefix.Length
    #echo "asd: ($longest-$charCount)"
    for($i=0;$i -le ($longest-$charCount);$i++) {
      $space += " "
    }

    $size = 0
    if($item -notlike '*/') { $size = (iwr $folder$item -Credential $cred -Method Head).Headers.'Content-Length' }
    else { $size = "-" }

    if($size -like "") { $size = 0 }

    #echo $prefix$item$space$size" kB"
    if($item -like '*/') { Write-Host $prefix$item$space$size" kB" -ForegroundColor Red }
    else { Write-Host $prefix$item$space$size" kB" -ForegroundColor White }


    $space = ""
    if($item -like '*/')
    {
      $firstIteration = 0
      showfolder $folder$item "$prefix--"
      #echo "path: $mainpath$item"
        
    }
    
  }
}

function downloadFolder($folder, $path) {
  $content=((iwr $folder -Credential $cred -usebasicparsing).Links| Where-Object {$_.href -notlike "?C=*"} | Select-Object -Skip 1 ).href
  foreach($item in $content)
  { 
    if($item -like '*/')
    {
        createFolder $path$item

        downloadfolder $folder$item $path$item
        #echo "path: $mainpath$item"
        #echo "downloading item: $item is a folder"
        
    }
    else
    {
      echo "downloading: $item to path: $path"
      iwr $folder$item -Credential $cred -OutFile $path$item
    }
    
  }
}

function uploadFolder($folder) {
  iwr $mainpath$pscp -OutFile $PSpath$pscp -Credential $cred
  iwr $mainpath$pkey -OutFile $PSpath$pkey -Credential $cred

  #echo "pscp.exe -i .key "$folder"*" $host_user+"@"+$host_ip+":"+$uploadLocation
  .\pscp.exe -r -i .\digiOceanWin.ppk $folder"*" $host_user"@"$host_ip":"$uploadLocation

  rm $pscp
  rm $pkey
}

function searchFile($folder, $prefix, $file) {
  $matches = @()
  $content=((iwr $folder -Credential $cred -usebasicparsing).Links| Where-Object {$_.href -notlike "?C=*"} | Select-Object -Skip 1 ).href
  foreach($item in $content)
  { 
    if($item -like "*$file*")
    {
        $matches += $folder+$item
        #echo "value: $file found in path: $folder$item"
        
    }
    if($item -like '*/')
    {
        searchFile $folder$item "$prefix--" $file
        #echo "path: $mainpath$item"
        
    }
    
  }

  return $matches
  
}

function showSpecificFolder($folder, $search) {

  $content = searchFile $folder "" $search
  #$content=((iwr $folder -Credential $cred -usebasicparsing).Links| Where-Object {$_.href -notlike "?C=*"} | Select-Object -Skip 1 ).href
  foreach($item in $content)
  { 
    if($item -like '*/')
    {
      Write-Host $item -ForegroundColor Red
      showFolder $item ""
      $firstIteration = 0
    }
  }
}

function getFile($folder, $prefix, $file) {
  $matches = @()
  $content=((iwr $folder -Credential $cred -usebasicparsing).Links| Where-Object {$_.href -notlike "?C=*"} | Select-Object -Skip 1 ).href
  foreach($item in $content)
  { 
    if($item -like "*$file*")
    {
        $matches += $folder+$item
        #return $folder+$file
    }
    if($item -like '*/')
    {
        getFile $folder$item "$prefix--" $file
        #echo "path: $mainpath$item"
        
    }
    
  }

  return $matches
}

function getFolderFromPath($path) {
  $splitArray = $path.split('/',[System.StringSplitOptions]::RemoveEmptyEntries)
  $last = $splitArray | Select-Object -Last 1
      
  return $last += "\"
}

function getFileFromPath($path) {
  $splitArray = $path.split('/',[System.StringSplitOptions]::RemoveEmptyEntries)
  $last = $splitArray | Select-Object -Last 1
      
  return $last
}



#----------- / Functions ----------------

#----------- Init -----------------------

echo "Executing ps script: $filename"
createFolder $PSpath
createFolder $PSpath$uploadFolder
echo "Moving to working directory: $PSpath"
Move-Item $filename -Destination $PSpath
cd C:\PS

#----------- / Init ---------------------

while($running)
{
  echo ""
  echo ""
  echo "Run options:"
  echo ""
  echo "List all files: under root   L"
  echo "List all folders under root: F"
  echo "List all files recursively:  LR"
  echo "Show specific folder:        SF"
  echo "Search file:                 S"
  echo "List all commands:           C"
  echo "Download file or folder:     D"
  echo "Open working directory:      W"
  echo "Upload file or folder:       U"
  #echo "Test:                       T"
  echo ""
  echo ""

  $input = Read-Host -Prompt '>'

  if($input -eq "L" -or $input -eq "l")
  {
    echo "Listing all files from host root folder."
    echo " "
    showFileContent $mainpath
    
  }

  if($input -eq "F" -or $input -eq "f")
  {
    echo "Listing all folders from host root folder."
    echo " "
    listFolders $mainpath
  }

  if($input -eq "SF" -or $input -eq "sf")
  {
    echo "Give folder name to show it."
    $folder = Read-Host -Prompt 'filename: '
    showSpecificFolder $mainpath $folder"/"
  }

  if($input -eq "C" -or $input -eq "c")
  {
    echo "Listing all powershell commands from host."
    iwr $mainpath commands.txt -Credential $cred | Select-Object -Expand Content
  }

  if($input -eq "LR" -or $input -eq "lr")
  {
    #$ret = @()
    echo "Showing folder $mainpath content: "
    echo " "
    showFolder $mainpath ""
    $firstIteration = 0
  }

  if($input -eq "S" -or $input -eq "s")
  {
    echo "Search a file from host."
    $file = Read-Host -Prompt 'filename: '
    $fileLoc = @()
    $fileLoc += searchFile $mainpath "" $file
    #echo "filesFound: $filesFound"
    if($fileLoc.Length -gt 0)
    {
      foreach($fname in $fileLoc) { echo "found file: $fname" }
    }
    else{ echo "No files found!" }

  }

  if($input -eq "D" -or $input -eq "d")
  {
    echo "Downloading a file from the host."
    $file = Read-Host -Prompt 'filename: '
    
    $fileLoc = @()
    $fileLoc += getFile $mainpath "" $file
    if($fileLoc.Length -gt 1)
    {
        echo "found multiple files with the same name. Pick one"
        $i = 0
        foreach($option in $fileLoc)
        {
            echo "$i : $option"
            $i+=1
        }
        $answer = Read-Host -Prompt 'Select file number: '
        $downloadFile = $fileLoc[$answer]
    }
    else { $downloadFile = $fileLoc }
    


    if($downloadFile -like '*/')
    {
      echo "is a folder"

      $folder = getFolderFromPath $downloadFile
      createFolder $PSpath$folder
      showFolder $downloadFile ""
      downloadFolder $downloadFile $PSpath$folder
    }
    else
    {
      $downloadFile = $downloadFile[0]
      $fileEnd = getFileFromPath $downloadFile
      echo "Downloading file: $downloadFile to path: $PSpath$fileEnd"
      iwr $downloadFile -OutFile $PSpath$fileEnd -Credential $cred
    }
    #iwr $downloadFile -OutFile $file -Credential $cred
  }

  if($input -eq "W" -or $input -eq "w")
  {
    explorer $PSpath
  }

  if($input -eq "U" -or $input -eq "u")
  {
    Get-ChildItem -Path C:\PS\upload
    

    echo "Following files will be uploaded to the host. Continue? (yes/no)"
    
    $answer = Read-Host -Prompt '>'
    if($answer -eq "yes" -or $answer -eq "YES" -or $answer -eq "Yes") {
      uploadFolder $PSpath$uploadFolder
    }

    
  }
}
