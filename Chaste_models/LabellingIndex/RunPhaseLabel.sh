#!/bin/bash

for RUN in $(seq 1 1 100)
do
	/Users/phillipbrown/chaste_build/projects/CellBasedComparison2017/test/TestPhaseLabellingIndex -run ${RUN}

done