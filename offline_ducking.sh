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
echo "para_pa_pregain=$para_pa_pregain"
echo "para_pa_leveler=$para_pa_leveler"
echo "para_trans_gate=$para_trans_gate"
echo "para_trans_limiter=$para_trans_limiter"
echo "para_trans_leveler=$para_trans_leveler"
echo "para_mix_vol_pa=$para_mix_vol_pa"
echo "para_mix_vol_trans=$para_mix_vol_trans"
echo "para_mix_leveler=$para_mix_leveler"
echo "para_mix_loudnorm=$para_mix_loudnorm"
echo "para_output=$para_output"
echo

ffmpeg -hide_banner $loglevel \
    -thread_queue_size 8291 -filter_complex_threads 64 \
    $inputStarttime -i "$inputPA" \
    -thread_queue_size 8192 \
    $inputStarttime -i "$inputDolm" \
    \
    -filter_complex "\
    [0:0] asetpts=N/SR/TB,\
    volume=$para_pa_pregain [pa_pregain] ;\
    [pa_pregain] dynaudnorm=$para_pa_leveler [pa_out] ;\
    \
    [1:0] asetpts=N/SR/TB, \
    compand=$para_trans_gate [trans_gate_out] ;\
    [trans_gate_out] compand=$para_trans_limiter [trans_lim_out] ;\
    [trans_lim_out] dynaudnorm=$para_trans_leveler [trans_out] ;\
    \
    [pa_out]volume=$para_mix_vol_pa[mix_int_1];\
    [trans_out]volume=$para_mix_vol_trans[mix_int_2];\
    [mix_int_1][mix_int_2] amix=inputs=2:duration=longest [mix_out] ;\
    [mix_out]dynaudnorm=$para_mix_leveler [dyn_out] ;\
    [dyn_out]loudnorm=$para_mix_loudnorm "\
    -c:a pcm_s16le -ar 48000 -f wav $para_output
