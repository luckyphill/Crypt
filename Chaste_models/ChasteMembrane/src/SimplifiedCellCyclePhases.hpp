
#ifndef SimplifiedCELLCYCLEPHASES_HPP_
#define SimplifiedCELLCYCLEPHASES_HPP_

/**
 * Possible phases of the cell cycle.
 *
 * G0 Phase - a state where the cell is differentiated and no longer divides
 * P Phase - the phase immediately after cell division, cells can pause due to contact inhibition, cell do not grow
 * W Phase - after P, the cell is growing and cannot be paused. Cells are represented by two nodes
 */
typedef enum SimplifiedCellCyclePhase_
{
	G0_PHASE,
	P_PHASE,
	W_PHASE
} SimplifiedCellCyclePhase;

static const unsigned NUM_SIMPLIFIED_CELL_CYCLE_PHASES=3;

#endif /*SimplifiedCELLCYCLEPHASES_HPP_*/
