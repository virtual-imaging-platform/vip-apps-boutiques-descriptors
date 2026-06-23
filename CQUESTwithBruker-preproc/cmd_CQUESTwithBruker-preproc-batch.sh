#!/bin/bash

# to test the command : replace (regex) ('; \n', '; ') and ('\t+', '')
# don't forget to escape every double quotes as it will be copied into a json
# bosh exec simulate (requires a correct invocation file) -> output to a file -> shellcheck -> bosh exec launch
export BASE_DIR=$PWD
unzip [MYZIP]
mkdir tmp
tar -C tmp -xf [DATA]
DATA_FOLDER=$(find \"tmp\" -maxdepth 1 -type d ! -name \"tmp\")
if [[ $(echo \"$DATA_FOLDER\" | wc -l) -gt 1 ]]; then
	echo \"Error: multiple directories found in tar\"
	exit 1
fi
DAYS_PATH=$(find \"$DATA_FOLDER\" -maxdepth 1 -type d ! -name \"$DATA_FOLDER\")
metaboliteFile=$(grep -m 1 '^met=' [PARAM_FILE] | cut -d ' ' -f1 | cut -d '=' -f2 | awk -v base=\"$BASE_DIR/\" '{print base $0}')
files=('fid' 'acqp' 'method' 'fid.refscan' 'rawdata.job0')
for DAY_PATH in $DAYS_PATH; do
	readarray -d '' STEAM_DIRS_PATH < <(find \"$DAY_PATH\" -maxdepth 1 -type d -name \"*STEAM*\" -print0)
	for STEAM_DIR_PATH in \"${STEAM_DIRS_PATH[@]}\"; do
		old_path=\"$STEAM_DIR_PATH\"
		STEAM_DIR_PATH=\"${STEAM_DIR_PATH// /}\"
		[[ \"$old_path\" != \"$STEAM_DIR_PATH\" ]] && mv \"$old_path\" \"$STEAM_DIR_PATH\"
		for file in \"${files[@]}\"; do
			if [[ ! -f \"$STEAM_DIR_PATH/Raw/$file\" ]]; then
				echo \"File not found: $file in $STEAM_DIR_PATH/Raw\"
				exit 1
			fi
		done
		python3 /bruker-spectro-processing-pipeline/vip_prepro.py --fid \"$STEAM_DIR_PATH/Raw/fid\" --acqp \"$STEAM_DIR_PATH/Raw/acqp\" --method \"$STEAM_DIR_PATH/Raw/method\" --refscan \"$STEAM_DIR_PATH/Raw/fid.refscan\" --rawjob0 \"$STEAM_DIR_PATH/Raw/rawdata.job0\" [PPM_R] [PPM_A] [NOISE_R] [DISPLAY_R] [MEAN_LW] [STDEV_LW] [STDEV_FR] [MV_AV] --metabolite \"$metaboliteFile\" --outname [OUTNAME] --outpath \"./$STEAM_DIR_PATH\"
		echo \"Preprocessing finished, listing files and launching cQuest\"
		ls \"$STEAM_DIR_PATH\"
		/cquest_exec/cquestCml -f [PARAM_FILE] \"$STEAM_DIR_PATH/[OUTNAME]RecBruker.mrui\"
		/cquest_exec/cquestCml -f [PARAM_FILE] \"$STEAM_DIR_PATH/[OUTNAME]RecPastis.mrui\"
	done
done
cd tmp && find . -type f -name '[OUTNAME]*' -print0 | tar --null --files-from - -czf [OUT_FILE]
