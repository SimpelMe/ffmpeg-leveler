# ffmpeg-leveler

## Description
This repo tries to automate levelling and ducking with a ffmpeg command line.
With this you can possibly automate translator ducking.

## Execute
`source command.sh`

## Options
You have to specify the input files. The first one is the audio that should be ducked if there is level from the second audio file.

__MUST__  
inputPA.txt - audio to duck  
inputDolm.txt - translator above ducked pa

__COULD__  
inputStarttime.txt - default 75s, because recording was starting before talk  
inputLoglevel - default warning, use the ffmpeg options

## Note
If you need some audio files you can use the following ones, which are from the __Infrastructure Review__ at 35c3 in Leipzig 2009.

PA: http://simpel.cc/temp/PA-orig.wav  
Translator: http://simpel.cc/temp/Dolm1-orig.wav
