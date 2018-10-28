Add-Type -TypeDefinition  @'
using System;
using System.Runtime.InteropServices;
using System.ComponentModel;
 
namespace CDROM
{
    public class Commands
    {
        [DllImport("winmm.dll")]
        static extern Int32 mciSendString(string command, string buffer, int bufferSize, IntPtr hwndCallback);
 
        public static void Eject()
        {
             string rt = "";
             mciSendString("set CDAudio door open", rt, 127, IntPtr.Zero);
        }
 
        public static void Close()
        {
             string rt = "";
             mciSendString("set CDAudio door closed", rt, 127, IntPtr.Zero);
        }
    }
}
'@

$num = 10;
echo "Opening CD tray $num times";
Write-Progress -Activity 'Opening CD tray' -Status "$num times of $num left" -PercentComplete 0

for($i=1; $i -le $num+1; $i++) {
    [CDROM.Commands]::Eject()
    [CDROM.Commands]::Close()
    
    $percentComplete = ($i / $num) * 100
    $currNum = $num - $i
    Write-Progress -Activity 'Opening CD tray' -Status "$currNum times of $num left" -PercentComplete $percentComplete

}