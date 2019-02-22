import csv
import sys
# import matplotlib.pyplot as plt

folder = str(sys.argv[1])
path = "../../testoutput/TestCellDragForce/" + folder + "/results_from_time_0/cell_drag_force.dat"

force = []
position = []
with open(path, 'rb') as csvfile:
	filereader = csv.reader(csvfile, delimiter=',')
	for row in filereader:
		position.append(float(row[3]))
		force.append(float(row[5]))

# plt.scatter(force[100:500],position[100:500])
# plt.show()
# print "Maximum drag force " + str(max(force[100:500]))
# print "Minimum drag force " + str(min(force[100:500]))

# fig_name = path + ".png"
# plt.savefig(fig_name)
# plt.close('all')
file = "Drag_force_" + folder + ".txt"
max_force = max(force[100:300])
min_force = min(force[100:300])
with open(file,'a') as output_file:
	output_file.write(str(sys.argv[2]) + "," + str(min_force) + "," + str(max_force) + "\n")


