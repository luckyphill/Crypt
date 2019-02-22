import numpy as np
import matplotlib.pyplot as plt
import math
import sys

# This expects the directory location on cells_in_S_Phase.dat as the input argument
# It only wants the directory, not the name of the file
# This should either be the relative path from the current working directory, or the abolute path
# The output figure will be saved to this directory

folder = str(sys.argv[1])
if folder[-1] == "/":
	del folder[-1] #doesn't work on strings

path = folder + "/cells_in_S_Phase.dat"


with open(path, 'r') as posfile:
	data_list = posfile.readlines()

cell_positions = []
times = []
for t_step in data_list:
	cell_separated  = t_step.split(" | ")
	times.append(cell_separated[0])
	for cell in cell_separated[1:]:
		details = cell.split(", ")
		cell_positions.append([float(details[1]), float(details[2])])

y_pos = [x[1] for x in cell_positions]

bottom = min(y_pos)
top = max(y_pos)
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

plt.hist(y_pos)

fig_name = folder + "/labelling_index_S_Phase.png"
plt.savefig(fig_name)
plt.close('all')
