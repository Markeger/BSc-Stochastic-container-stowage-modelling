Here you find our 3 different ship sizes with the TUE capacities of 7476, 11394 and 17385.

The three ship sizes have been created from the data found in https://github.com/maritimelab/StowagePlanning_MasterPlanning_Benchmark.

Here vi have isolated all data only regarding the ships, and placed in these three files. The only jurney information in these files is the CoG limits per port for 9 ports. Below you will find a detailed description of the data, and how the ship_reader.jl reads the files:

-------
The first line of the file holds 3 values representing: the number of bays in the vessel, the number of location/blocks in the vessel and the number of adjacent bays (or bins).

The next line is a list of bay IDs (linear starting from 1) indicating all the on-deck locations. The successive line is an array with a value for each location in the vessel. For each on-deck location, the value represents the corresponding below-deck location. If the on-deck location has no below-deck counterpart, the value is 0. For each below-deck location that has a corresponding on-deck location above, the value is -1. For all other below-deck locations (with no on-deck above), the value is 0.

Next there is a line for each bay. The line is a list of the on-deck locations in that bay.

The following line has a value for each location, indicating the bay it belows to.

The next four lines hold a value for each location indicating. The first line is the TEU capcity of the location. The second is the FEU capacity of the location. The third is the number of reefer plugs in the location, and the last is the weight capacity (in tons) of each location.

The next three lines indicate the center of gravity for each location, with the first line indicating the longitudinal center of gravity, the second the vertical center of gravity, and the third the transversal center of gravity (in meters).

Following there is a line for each set of adjacent bays. Each line indicates the two adjacent bays.

The next line indicated the contant weight (lightship) at each bay (in tons).

The next three lines indicate, for each bay, the longitudinal, vertical and transversal center of gravity (in meters).

The minimum shear at each bay is given in the next line, the maximum shear in the following one, and the maximum bending in the subsequent line (in tons for shear and tons/meters for bending).

The next five lines indicate the limits of the center of gravity of the vessel at each port (except the last). The lines indicate the minimum longitutinal center of gravity, the maximum longitutudinal center of gravity, the maximum vertical center of gravity, the minimum transversal center of gravity, and the maximum transversal center of gravity, respectively (in meters).
