#!/bin/sh

# Source files with all default settings
. "$PWD/config.defaults"
# source optional users custom config
[ -f "$PWD/config.user" ] && . "$PWD/config.user"

echo using the following values:
echo "inputPA=$inputPA"
echo "inputDolm=$inputDolm"
echo "inputStarttime=$inputStarttime"
echo "logLevel=$loglevel"
echo "para_pa_leveler=$para_pa_leveler"
echo "para_trans_gate=$para_trans_gate"
echo "para_trans_limiter=$para_trans_limiter"
echo "para_trans_leveler=$para_trans_leveler"
echo "para_mix_vol_pa=$para_mix_vol_pa"
echo "para_mix_vol_trans=$para_mix_vol_trans"
echo "para_mix_leveler=$para_mix_leveler"
echo "para_mix_loudnorm=$para_mix_loudnorm"
echo "para_ebur128=$para_ebur128"
echo

ffmpeg -hide_banner $loglevel \
    -thread_queue_size 8291 -filter_complex_threads 64 \
    $inputStarttime -i "$inputPA" \
    -thread_queue_size 8192 \
    $inputStarttime -i "$inputDolm" \
    \
    -filter_complex "\
    [0:a:0] asetpts=N/SR/TB,\
    dynaudnorm=$para_pa_leveler , asplit=2 [pa2ebu] [pa_dyn_monitor] ;\
    [pa2ebu] ebur128=$para_ebur128 [vid_pa_ebu] [pa_ebu] ;\
    \
    [1:a:0] asetpts=N/SR/TB, \
    compand=$para_trans_gate , asplit=2 [trans_gate_out] [trans_gate_monitor] ;\
    [trans_gate_out] compand=$para_trans_limiter , asplit=2 [trans_lim_out] [trans_lim_monitor] ;\
    [trans_lim_out] dynaudnorm=$para_trans_leveler , asplit=2 [trans2ebu] [trans_dyn_monitor] ;\
    [trans2ebu] ebur128=$para_ebur128 [vid_trans_ebu] [trans_ebu] ;\
    \
    [pa_ebu]volume=$para_mix_vol_pa[mix_int_1];\
    [trans_ebu]volume=$para_mix_vol_trans[mix_int_2];\
    [mix_int_1][mix_int_2] amix=inputs=2:duration=longest, asplit=2 [mix_out][mix_monitor] ;\
    [mix_out]dynaudnorm=$para_mix_leveler, asplit=2 [dyn_out][mix_dyn_monitor] ;\
    [dyn_out]loudnorm=$para_mix_loudnorm, \
    ebur128=$para_ebur128 [vid_mix_ebu] [mix_last_out_monitor] ;\
    \
    nullsrc=size=1280x960,fps=25,setpts=N/(25*TB) [vcanvas]; \
    testsrc=size=640x480[clock];\
    [vcanvas][vid_pa_ebu] overlay=shortest=1 [tmp1]; \
    [tmp1][vid_trans_ebu] overlay=shortest=1:x=640 [tmp2]; \
    [tmp2][vid_mix_ebu] overlay=shortest=1:y=480 [tmp3];
    [tmp3][clock] overlay=shortest=1:x=640:y=480,setpts=PTS-STARTPTS [ebu_combined] " \
    \
    -map "[ebu_combined]" -c:v mpeg2video -g:0 10 -bf:0 0 -q:0 4 \
    -map "[mix_last_out_monitor]" -map "[mix_dyn_monitor]" -map "[mix_monitor]" -map "[trans_dyn_monitor]" \
    -map "[trans_lim_monitor]" -map "[trans_gate_monitor]" -map "[pa_dyn_monitor]" \
    -metadata:s:a:0 title="Output - gained to -16LUFS" \
    -metadata:s:a:1 title="Mix ducked" \
    -metadata:s:a:2 title="Mix unducked" \
    -metadata:s:a:3 title="Translator levelled" \
    -metadata:s:a:4 title="Translator limited" \
    -metadata:s:a:5 title="Translator gated" \
    -metadata:s:a:6 title="PA levelled" \
    -c:a pcm_s16le -f matroska pipe: | ffplay -hide_banner -
