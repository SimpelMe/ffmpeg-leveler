# ffmpeg-leveler

## Description
This repo tries to automate levelling and ducking with a ffmpeg command line.
With this you can possibly automate translator ducking.

## Execute
`./ducking.sh`

## Options
You have to specify the input files. The first one is the audio that should be ducked if there is level from the second audio file.

The defaults are provided in `config.defaults`, please place your specimen files in the speciment folders. If you want to use other
locations, override the values by adding the settings to the `config.user` file. This file takes precedence over `config.defaults`.

### Config key overview

* $inputPA - audio to duck
* $inputDolm - translator above ducked pa
* $inputStarttime - default 75s, because recording was starting before talk
* $inputLoglevel - default warning, use the ffmpeg options
* $para_pa_leveler - parameter dynaudnorm for pa
* $para_trans_gate - parameter compand as gate for translator
* $para_trans_limiter - parameter compand as limiter for translator
* $para_trans_leveler - parameter dynaudnorm for translator
* $para_mix_vol_pa - parameter volume of pa in the mix
* $para_mix_vol_trans - parameter volume of translator in the mix
* $para_mix_leveler - parameter dynaudnorm for the whole mix
* $para_mix_loudnorm - parameter loudnorm for the whole mix
* $para_ebur128 - parameter for the ebur128 views


## Flowchart
The flowchart.md shows the audio flow excluding the points where to listen to.

## Listening
You can toggle through different audio outputs. If you use ffplay you can switch with the `a`-key.  
1. Output - gained to -16LUFS according EBU R128
2. Mix ducked
3. Mix unducked
4. Translator levelled
5. Translator limited
6. Translator gated
7. PA levelled

## Note
If you need some audio files you can use the following ones, which are from the __Infrastructure Review__ at 35c3 in Leipzig 2009.

* PA: https://simpel.cc/temp/PA-orig.wav
* Translator: https://simpel.cc/temp/Dolm1-orig.wav
