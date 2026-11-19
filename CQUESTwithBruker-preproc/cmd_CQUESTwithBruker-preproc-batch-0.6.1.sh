unzip -j [ZIP_BASIS] -d basis 
&& met=$(find basis -name Cr* -print -quit); : \"${met:?Creatine metabolite not found}\" 
&& mkdir -p ROOT_DATA_DIR 
&& case [DATA_FILE] in *.tar) tar -C ROOT_DATA_DIR -xf [DATA_FILE] ;; *.tar.gz | *.tgz) tar -C ROOT_DATA_DIR -xzf [DATA_FILE] ;; *.zip) unzip [DATA_FILE] -d ROOT_DATA_DIR ;; *) exit 1 ;; esac 
&& find ROOT_DATA_DIR -type f -name 'acqp' -exec grep -zrlP '##\\$ACQ_dim_desc=\\( 1 \\)\\nSpectroscopic' {} + | while IFS= read -r f; do d=$(dirname \"$f\") 
&& python3 /bruker-spectro-processing-pipeline/vip_prepro.py --fid \"$d\"/fid --acqp \"$d\"/acqp --method \"$d\"/method --refscan \"$d\"/fid.refscan --rawjob0 \"$d\"/rawdata.job0 --metabolite \"$met\" [PPM_R] [PPM_A] [NOISE_R] [DISPLAY_R] [MEAN_LW] [STDEV_LW] [STDEV_FR] [MV_AV] --outname [OUTNAME] --outpath \"$d/\" 
&& bash /run_cquest.sh [PARAM_FILE] \"$d/[OUTNAME]RecPastis.mrui\" basis \"$d/[OUTNAME]RecBruker.mrui\" 
&& python3 /plot_cquest_result.py -i ROOT_DATA_DIR -m basis ; done 
&& find ROOT_DATA_DIR -type f -name \"[OUTNAME]*\" -print0 | tar --null --files-from=- --transform=\"s#^ROOT_DATA_DIR/##\" -czf [OUT_FILE] 
&& rm -rf basis 
&& rm -rf ROOT_DATA_DIR