The Coil Characterization app has a number of constraints, most of which are worked around in command-line. This file documents those constraints and known remaining limitations.

Constraints:
- the app can take its own previous outputs as inputs in the comparison/ dir: solved by passing the comparison dir as input.
- output files names are not fully expressible in advance: solved by using wildcards in the descriptor path templates for output files.
- output files are created in subdirectories: solved by specifying relative subdirectory in path templates. This needs the execution environment to correctly handle such outputs.
- the app uses the content (first line) of the coil input to name its outputs, but bosh can only use filenames. Both basename and first line should match in practice, so we enforce this with a check at the start of command-line.

Known quirks and limitations:
- input comparison dir should be the "comparison" directory under "results-dir" in most cases (as indicated by default values), but we also accept that they differ: if so, outputs will just be placed in "results-dir", and the user is responsible for managing files location for future executions as needed.
- when using wildcards in path-template, bosh only takes one arbitrary file matching the pattern (python glob semantics). So this can only be used to get a single output file per template, when the output name can't be known in advance. We handle this by removing all files older than the execution under comparison/ at the end of the execution. This also assumes that the app creates a single new mat file and a single new pdf file.
- in case of multiple parallel executions using the same coil id and sharing the same directories, the `touch _start` + `find -newer` method might not differentiate between outputs. As for the previous point, things work as long as the comparison/ dir is copied before execution and kept independent for each job.
- if a mat file for a given coil input already exists in comparison dir, only the `reportFile/*pdf` output is produced. This is still considered a successful execution, with a single output file.
- the container image is currently not compatible with singularity, only with docker.

For reference, a more readable and commented version of command-line:
```
# check that the Coil input is consistent: app uses first line to name the
# outputs, but bosh descriptor uses the file name, so bosh must match
if ! test "$(basename [COIL] .txt)" = "$(head -1 [COIL])"; then
  echo "Invalid coil input: name mismatch"
  exit 1
fi
# create a 'comparison' dir if needed (name hardcoded in the app)
if test "$(basename [COMPARISON])" != comparison; then
  ln -sfT [COMPARISON] comparison
fi
# pre-execution debug trace
echo "before exec:" && ls -l comparison/
# marker file to detect new outputs
touch _start
# run the app
caract_inside.sh [COIL] [FANTOM] [DATA]
# post-execution debug trace
echo "after exec:" && ls -l comparison/ reportFile/
# remove any mat file in comparison/ that is older than the execution,
# so that remaining files can be correctly detected by bosh
find comparison/ -not -newer _start -name "$(basename [OUTPUT_MAT])" -delete
echo "after cleanup:" && ls -l comparison/ reportFile/
```
