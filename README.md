# state_dynamics
State dynamics of temporal networks

Usage:

(1) Download all codes in the same folder.

(2) Prepare a temporal network data as a CSV file. The format is described in the beginning of into-snapshots.py

(3) Run

python3 into-snapshots.py infilename resolution ID_offset

The infilename should not contain '.csv'.

'resolution' and 'ID_offset' are optional.

See the beginning of into-snapshots.py for more details.

This will create snapshots adj1.csv, adj2.csv, ...

(4) Set 
