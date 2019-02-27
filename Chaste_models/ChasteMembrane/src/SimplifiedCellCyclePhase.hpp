
#ifndef SimplifiedCELLCYCLEPHASES_HPP_
#define SimplifiedCELLCYCLEPHASES_HPP_

/**
 * Possible phases of the cell cycle.
 *
 * When our cells 'divide' they are actually entering M phase,
 * so a cell progresses round the cell cycle in the following sequence from its birth time
 * Divide-> M -> G0/G1 -> S -> G2 -> Divide.
 *
 * G0 is a cell which stays in the G1 phase and is not going to divide. (i.e. quiescent or differentiated.)
 */
typedef enum SimplifiedCellCyclePhase_
{
    G_ZERO_PHASE,
    T_PHASE,
    P_PHASE,
    W_PHASE
} SimplifiedCellCyclePhase;

static const unsigned NUM_CELL_CYCLE_PHASES=4;

#endif /*SimplifiedCELLCYCLEPHASES_HPP_*/
