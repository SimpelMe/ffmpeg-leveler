ffmpeg -thread_queue_size 8291 -filter_complex_threads 64 \
-re -i http://st02.dlf.de/dlf/02/128/mp3/stream.mp3 \
-thread_queue_size 8192 \
-re -i /LOCALFILE-GOES-HERE \
-filter_complex "[0:a:0] asetpts=N/SR/TB,\
dynaudnorm=p=0.35:r=1:f=300 , asplit=2 [pa2ebu] [pa_dyn_abhoere] ;\
[pa2ebu] ebur128=meter=9:video=1:size=640x480 [vid_pa_ebu] [pa_ebu] ;\
[1:a:0] asetpts=N/SR/TB, \
compand=attacks=0:points=-80/-115|-45.1/-80|-45/-45|20/20 , asplit=2 [trans_gate_out] [trans_gate_abhoere] ;\
[trans_gate_out] compand=attacks=0:points=-80/-80|-6/-6|20/-6 , asplit=2 [trans_lim_out] [trans_lim_abhoere] ;\
[trans_lim_out] dynaudnorm=p=0.35:r=1:f=300 , asplit=2 [trans2ebu] [trans_dyn_abhoere] ;\
[trans2ebu] ebur128=meter=9:video=1:size=640x480 [vid_trans_ebu] [trans_ebu] ;\
[pa_ebu]volume=0.1[mix_int_1];\
[trans_ebu]volume=1[mix_int_2];[mix_int_1][mix_int_2] amix=inputs=2:duration=longest, asplit=2 [mix_out][mix_abhoere] ;\
[mix_out] dynaudnorm=p=0.35:r=1:f=300, \
ebur128=meter=9:video=1:size=640x480 [vid_mix_ebu] [mix_dyn_out] ;\
\
nullsrc=size=1280x960,setpts=N/(25*TB) [vcanvas]; \
[vcanvas][vid_pa_ebu] overlay=shortest=1 [tmp1]; \
[tmp1][vid_trans_ebu] overlay=shortest=1:x=640 [tmp2]; \
[tmp2][vid_mix_ebu] overlay=shortest=1:y=480,setpts=PTS-STARTPTS [ebu_combined] " \
-map "[ebu_combined]" -c:v mpeg2video -g:0 25 -bf:0 0 -q:0 4 \
-map "[mix_dyn_out]" -map "[mix_abhoere]" -map "[trans_dyn_abhoere]" \
-map "[trans_lim_abhoere]" -map "[trans_gate_abhoere]" -map "[pa_dyn_abhoere]" \
-c:a pcm_s16le -f matroska pipe: | mpv --no-cache -
