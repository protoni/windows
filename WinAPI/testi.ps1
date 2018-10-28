$filename = $MyInvocation.MyCommand.Name
echo "Executing ps script: $filename"


$path = "C:\PS"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
      echo "Created Folder: $path"
}

echo "Moving to working directory: $path"

Move-Item $filename -Destination $path
cd C:\PS




