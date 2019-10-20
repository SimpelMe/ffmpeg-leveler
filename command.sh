#!/bin/sh

# Source files with all default settings
. "$PWD/config.defaults"
# source optional users custom config
[ -f "$PWD/config.users" ] && . "$PWD/config.users"

echo using the following values:
echo "inputPA=$inputPA"
echo "inputDolm=$inputDolm"
echo "inputStarttime=$inputStarttime"
echo "inputLogLevel=$inputLoglevel"

ffmpeg -hide_banner $inputLoglevel \
-thread_queue_size 8291 -filter_complex_threads 64 \
$inputStarttime -i "$inputPA" \
-thread_queue_size 8192 \
$inputStarttime -i "$inputDolm" \
-filter_complex "[0:a:0] asetpts=N/SR/TB,\
dynaudnorm=p=0.35:r=1:f=300 , asplit=2 [pa2ebu] [pa_dyn_abhoere] ;\
[pa2ebu] ebur128=meter=18:video=1:size=640x480:scale=relative:gauge=s:target=-16 [vid_pa_ebu] [pa_ebu] ;\
[1:a:0] asetpts=N/SR/TB, \
compand=attacks=0:points=-80/-115|-55.1/-80|-55/-55|20/20 , asplit=2 [trans_gate_out] [trans_gate_abhoere] ;\
[trans_gate_out] compand=attacks=0:points=-80/-80|-12/-12|20/-12 , asplit=2 [trans_lim_out] [trans_lim_abhoere] ;\
[trans_lim_out] dynaudnorm=p=0.35:r=1:f=300 , asplit=2 [trans2ebu] [trans_dyn_abhoere] ;\
[trans2ebu] ebur128=meter=18:video=1:size=640x480:scale=relative:gauge=s:target=-16 [vid_trans_ebu] [trans_ebu] ;\
[pa_ebu]volume=0.1[mix_int_1];\
[trans_ebu]volume=1[mix_int_2];[mix_int_1][mix_int_2] amix=inputs=2:duration=longest, asplit=2 [mix_out][mix_abhoere] ;\
[mix_out]dynaudnorm=p=0.35:r=1:f=300, asplit=2 [dyn_out][mix_dyn_out] ;\
[dyn_out]loudnorm=i=-16.0:lra=12.0:tp=-3.0, \
ebur128=meter=18:video=1:size=640x480:scale=relative:gauge=s:target=-16 [vid_mix_ebu] [mix_loud_out] ;\
\
nullsrc=size=1280x960,fps=25,setpts=N/(25*TB) [vcanvas]; \
testsrc=size=640x480[clock];\
[vcanvas][vid_pa_ebu] overlay=shortest=1 [tmp1]; \
[tmp1][vid_trans_ebu] overlay=shortest=1:x=640 [tmp2]; \
[tmp2][vid_mix_ebu] overlay=shortest=1:y=480 [tmp3];
[tmp3][clock] overlay=shortest=1:x=640:y=480,setpts=PTS-STARTPTS [ebu_combined] " \
-map "[ebu_combined]" -c:v mpeg2video -g:0 10 -bf:0 0 -q:0 4 \
-map "[mix_loud_out]" -map "[mix_dyn_out]" -map "[mix_abhoere]" -map "[trans_dyn_abhoere]" \
-map "[trans_lim_abhoere]" -map "[trans_gate_abhoere]" -map "[pa_dyn_abhoere]" \
-metadata:s:a:0 title="Output - gained to -16LUFS" \
-metadata:s:a:1 title="Mix ducked" \
-metadata:s:a:2 title="Mix unducked" \
-metadata:s:a:3 title="Translator levelled" \
-metadata:s:a:4 title="Translator limited" \
-metadata:s:a:5 title="Translator gated" \
-metadata:s:a:6 title="PA levelled" \
-c:a pcm_s16le -f matroska pipe: | ffplay -
