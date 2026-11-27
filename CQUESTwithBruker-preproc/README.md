## batch commands
The batch commands are separated in there respective `cmd_{descriptor_name}.sh` as it can be tedious to fix the inlined bash script in the descriptor.

The main idea is to be permissive about the input directory structure using a bottom-up approach:
* first finding the spectroscopy files "acqp" (checking their content)
* **assuming** the directories containing those file are valid "raw bruker directories"
* executing preproc + cquest
* filter the outputted files from the description [OUTNAME] input and creating the tar **keeping the input structure**

> Be careful to escape everything as it will end up in a json file :)

If you want to test locally with bosh:
1. `bosh exec simulate` (requires a correct invocation file) 
2. output the generated script to a file 
3. check synthax with shellcheck
4. `bosh exec launch`

