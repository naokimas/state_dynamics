#    divide a temporal network into snapshots
#   Syntax
#
#   python3 into-snapshots.py infilename resolution ID_offset
#
#       NB: The input file should be in the csv format and provided to this program without the extension.
#               The input file should have IDs of two nodes forming an event in the 1st and 2nd columns
#                and the timestamp of the event in the 3rd column.
#               Node index should start from 0 and consecutive. However, it is not a must; the only constraint is that the node index should be non-negative. The main MATLAB code treats missing node indices as isolated nodes.
#
#               resolution (optional): size of the time window with which to create a snapshot. default = 1200, assuming that the time unit is sec and a 20 min window. Then, events with timestamps 0 to 1199 go to the first snapshot, adj1.csv, those with timestamps 1200 to 2399 go to the second snapshot, adj2.csv, and so forth
#
#              ID_offset (optional): The first output file will be adj(ID_offset+1).csv.
#              For example, if ID_offset=0, which is the default, the first output file is adj1.csv
#
#               Note that in the output .csv files the node index starts from 1, not from 0,
#               because the files will be used by MATLAB, where indexing starts from 1.

import pandas as pd
import math # floor
import sys # to use input parameters
import os # to delete adj*.csv
import glob # to delete adj*.csv

# param[1] : base of the input file name
# param[2] : resolution in sec to create a snapshot (default = 1200 sec)

param = sys.argv
argc = len(param)


df  = pd.read_csv(param[1] + '.csv', header=None, delimiter='\s+', names=('v1', 'v2', 't'))
# columns 1 and 2: two nodes to form an event
# column 3: timestamp of the event

# pd.options.mode.chained_assignment = None  # default='warn'

if argc==2:
    res = 1200 # 20 min if the time unit is sec
else:
    res = int(param[2])
tmax = df['t'].max()
Nwindow = int(tmax/res + 1e-8) # number of snapshots

if argc < 4:
    offset = 0;
else:
    offset = int(param[3])
# The first output file will be adj(offset+1).csv.
# For example, if offset=0, the first output file is adj1.csv

if offset == 0: # Delete adj*.csv from the current folder
    files=glob.glob("adj*.csv")
    for file in files:
        os.remove(file)

node_ind_max = 0 # largest node index
for i in range(Nwindow): # from 0 to Nwindow-1
    df2 = df[(df.t >= i*res) & (df.t < (i+1)*res)] # select events (= rows) whose time fall in time window i
    Nrow = len(df2.index) # number of events in time window i
    for j in range(Nrow):
        if (df2.iat[j, 0] > node_ind_max):
            node_ind_max = df2.iat[j, 0]
        if (df2.iat[j, 1] > node_ind_max):
            node_ind_max = df2.iat[j, 1]
        if (df2.iat[j, 0] > df2.iat[j, 1]): # swap two nodes to make (node ID in column 1) < (node ID in column 2)
            tmp = df2.iat[j, 0]
            df2.iat[j, 0] = df2.iat[j, 1]
            df2.iat[j, 1] = tmp

# Use of the following commands is relatively beautiful but incurs at least warning message,
# which requires extra commands to be suppressed.
# The use of .loc on the left-hand side always yields the same waring message.
#
#    idx = (df2.v1 > df2.v2)
#    tmp = df2.loc[idx, 'v1']
#    df2.loc[idx, 'v1'] = df2.loc[idx, 'v2']
#    df2.loc[idx,'v2'] = tmp

    df2 = df2.sort_values(by=["v1", "v2"], ascending=True)
    df2 = df2.drop("t", axis=1) # drop timestamps
    df2['weight'] = [-1] * Nrow # edge weight. Initialized to -1 as dummy.

    j = 0
    while (j < Nrow):
        jj = j
        while (jj < Nrow - 1 and df2.iat[j, 0] == df2.iat[jj+1, 0] and df2.iat[j, 1] == df2.iat[jj+1, 1]): # detect all events on the same edge
            jj += 1
        df2.iat[j, 2] = jj - j + 1 # edge weight (= number of events on this edge)
        j = jj + 1

    df2 = df2[df2['weight'] != -1] # remove rows with 'weight' == -1

#    df2['weight'] = 1 # If one wants to make the network unweighted

# does not work
#    df2['weight'] = df2.groupby("v1")["v2"].transform(pd.Series.value_counts)
#    df2['weight'] = df2.groupby(["v1", "v2"]).transform(pd.Series.value_counts)
#    df2.drop_duplicates()

    df2['v1'] += 1 # MATLAB indexing starts from 1, not from 0
    df2['v2'] += 1
    node_ind_max += 1
    df2.to_csv('adj' + str(i+1+offset) + '.csv', sep=' ', header=None, index=False) # write files

# all snapshots done

print ("tmax = ", tmax, ", there are ", Nwindow, " snapshots, largest node index = ", node_ind_max)