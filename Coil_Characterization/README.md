The Coil Characterization app has a number of constraints, most of which are worked around in command-line. This file documents those constraints and known remaining limitations.

Constraints:
- the app can take its own previous outputs as inputs in the comparison/ dir: solved by passing the comparison dir as input.
- output files names are not fully expressible in advance: solved by using wildcards in the descriptor path templates for output files.
- output files are created in subdirectories: solved by copying output files to the current directory. This might be improved later by preserving and transferring the whole output directory tree.
- the app uses the content (first line) of the coil input to name its outputs, but bosh can only use filenames. Both basename and first line should match in practice, so we enforce this with a check at the start of command-line.

Known quirks and limitations:
- input comparison dir and output "results-dir" should be identical in most cases, but we also accept that they differ: if so, outputs will just be placed in "results-dir", and the user is responsible for managing files location for future executions as needed.
- in case of multiple parallel executions using the same coil id and sharing the same directories, the "find -newer" method might not differentiate between outputs. This should work, however, as long as the comparison/ dir is copied before execution (see script.sh), and kept independent for each job.
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
# detect new outputs and copy them to ./
OUTPUTS="$(find comparison/ -newer _start -name [OUTPUT_MAT]) $(find reportFile/ -newer _start -name [OUTPUT_PDF])"
echo "found outputs: $OUTPUTS"
cp $OUTPUTS ./
```
