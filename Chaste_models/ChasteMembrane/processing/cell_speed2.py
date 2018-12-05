import numpy as np
import matplotlib.pyplot as plt
import math
import sys

# This expects the directory location on cell_velocity.dat as the input argument
# It only wants the directory, not the name of the file
# This should either be the relative path from the current working directory, or the abolute path
# The output figure will be saved to this directory

folder = str(sys.argv[1])
if folder[-1] == "/":
	del folder[-1]

path = folder + "/cell_velocity.dat"

with open(path, 'r') as posfile:
	data_list = posfile.readlines()

# creates a dictionary recording the positions that a cell takes
cell_positions = {}
cell_ids = []
times = []
for t_step in data_list:
	cell_separated  = t_step.split(" | ")
	times.append(cell_separated[0])
	for cell in cell_separated[1:]:
		details = cell.split(", ")
		cell_name = details[0]
		if cell_name not in cell_positions:
			cell_positions[cell_name] = []
		cell_positions[cell_name].append(np.array([float(details[1]), float(details[2]), float(details[3]), float(details[4])]))
		if cell_name not in cell_ids:
			cell_ids.append(cell_name)


# 
dt = float(times[1]) - float(times[0])
y_speed = {}
all_speed = []
all_position = []
for cell in cell_ids:
	positions = cell_positions[cell]
	for i in xrange(1,len(cell_positions[cell])):
		b = positions[i]
		if cell not in y_speed:
			y_speed[cell] = []
		y_speed[cell].append(b[3])
		all_position.append(b[1])
		all_speed.append(b[3])

bottom = min(all_position)
top = max(all_position)
height = top - bottom
n_bins = int(height) + 1
size = height/n_bins
bins = []

b_l = bottom
b_r = b_l + size

while b_l < top:
	bins.append([b_l, b_r])
	b_l = b_l + size
	b_r = b_r + size
	if b_r > top:
		b_r = top

if bins[-1][1] - bins[-1][0] < size/2:
	bins[-2][1] = top
	del bins[-1]

speeds_in_bins = [ [] for _ in range(len(bins))]

for i,speed in enumerate(all_speed):
	for j,bint in enumerate(bins):
		if all_position[i] <= bint[1] and all_position[i] > bint[0]:
			speeds_in_bins[j].append(speed)
			#print str(i) + " put " + str(speed) + " in " + str(bint)
			break


speed_avg = [ np.average(speeds) for speeds in speeds_in_bins]
#speed_90 = [ np.percentile(speeds, 75) for speeds in speeds_in_bins]
#speed_10 = [ np.percentile(speeds, 25) for speeds in speeds_in_bins]
bin_positions = [x[1] for x in bins]
plt.plot(bin_positions, speed_avg,'b')#,  bin_positions,speed_90, 'g--', bin_positions, speed_10, 'g--')

fig_name = folder + "/cell_speed.png"
plt.savefig(fig_name)
plt.close('all')

