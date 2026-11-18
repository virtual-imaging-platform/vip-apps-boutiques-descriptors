# to put it in the descriptor, make sure double quotes & backslash are escaped
# you can run bosh exec simulate [descriptor.json] --invocation [invocation_file.json] and ShellCheck the result to be sure
## This script basically find raw bruker spectroscopy files in a file tree and execute preprocessing + lcmodel over the dir
## It assumes the vip_prepro.py script will error out if necessary files (method,fid,fid.refscan) are not found
unzip -j [ZIP_BASIS] -d basis &&
mkdir -p ROOT_DATA_DIR &&
case [DATA_FILE] in *.tar) tar -C ROOT_DATA_DIR -xf [DATA_FILE] ;; *.tar.gz | *.tgz) tar -C ROOT_DATA_DIR -xzf [DATA_FILE] ;; *.zip) unzip [DATA_FILE] -d ROOT_DATA_DIR ;; *) exit 1 ;; esac &&
find ROOT_DATA_DIR -type f -name 'acqp' -exec grep -zrlP '##\\$ACQ_dim_desc=\\( 1 \\)\\nSpectroscopic' {} + | while IFS= read -r f; do
d=$(dirname \"$f\") &&
python3 /bruker-spectro-processing-pipeline/vip_prepro.py --fid \"$d\"/fid --acqp \"$d\"/acqp --method \"$d\"/method --refscan \"$d\"/fid.refscan --rawjob0 \"$d\"/rawdata.job0 [PPM_R] [PPM_A] [NOISE_R] [DISPLAY_R] [MEAN_LW] [STDEV_LW] [STDEV_FR] [MV_AV] --outname [OUTNAME] --outpath \"$d\" &&
bash /run_lcmodel.sh [CTRL_FILE] \"$d\"/[OUTNAME]RecPastis.RAW basis \"$d\"/[OUTNAME]_pastis_lcmodel &&
bash /run_lcmodel.sh [CTRL_FILE] \"$d\"/[OUTNAME]RecBruker.RAW basis \"$d\"/[OUTNAME]_bruker_lcmodel
; done &&
find ROOT_DATA_DIR -type f -name \"[OUTNAME]*\" -print0 | tar --null --files-from=- --transform=\"s#^ROOT_DATA_DIR/##\" -czf [OUT_FILE] &&
rm -rf basis &&
rm -rf ROOT_DATA_DIR
