:: run with powershell
;@echo off
;Findstr -rbv ; %0 | powershell -c - 
;goto:sCode
:: end

Add-Type -AssemblyName System.Speech
$SpeechSynth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$SpeechSynth.Speak("Trolololololllololollololooootrololololooooo")