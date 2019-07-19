/*

This implements a stopping event for crypts with mutant cells
There are three stopping criteria:

ALWAYS: Stop when mutation has cleared from the crypt - the simulation is no longer interesting
			-Stop as soon as monolayer is clear of mutant - used for determining proportions
			-Stop when mutant has cleared crypt - used for observing serration pattern
		Stop when cell count breaks a certain threshold - by default set relatively high

WHEN REQUIRED: Stop when clonal conversion occurs - used for proportion testing

*/

#include "OffLatticeSimulationWithMutation.hpp"
#include "TransitCellAnoikisResistantMutationState.hpp"
#include "AnoikisCellTagged.hpp"
#include "Debug.hpp"

bool OffLatticeSimulationWithMutation::StoppingEventHasOccurred()
{



	// If cell limit is exceeded stop straight away
	unsigned cell_count = mrCellPopulation.GetNumRealCells();
	if (cell_count > mCellLimit)
	{
		TRACE("Exceeded cell limit")
		return true;
	}

	// Don't search for clonality or mutation clearing until the transient has cleared
	// and the mutation has been added.
	if (watchForWashOut)
	{
		unsigned mutantCellCount = 0;
		unsigned monolayerMutantCellCount = 0;

		// Count the mutant and monolayer mutant cells
		std::list<CellPtr> cells = mrCellPopulation.rGetCells();
		for (std::list<CellPtr>::iterator it = cells.begin(); it != cells.end(); ++it)
	    {

			if ( (*it)->GetMutationState()->IsType<TransitCellAnoikisResistantMutationState>() )
			{
				mutantCellCount++;
				if ( !(*it)->HasCellProperty<AnoikisCellTagged>() )
				{
					monolayerMutantCellCount++;
				}
			}
		}

		// The monolayer has no mutant cells in it
		if (monolayerMutantCellCount == 0 && !monolayerEmpty)
		{
			// Notify that the mutation has completely popped out of the monolayer
			TRACE("Monolayer clear")
			monolayerEmpty = true;
			if (stopOnEmptyMonolayer)
			{
				return true;
			}
		}

		// The whole crypt has no mutant cells
		if (mutantCellCount == 0)
		{
			TRACE("Crypt clear")
			return true;
		}

		// The entire crypt is made up of mutant cells
		if ( mutantCellCount > unsigned( 0.8 * double(cell_count) ) )
		{
			TRACE("Clonal conversion")
			if (stopOnClonalConversion )
			{
				return true;
			}
		}
		
	}



	return false;
	
}

void OffLatticeSimulationWithMutation::SetCellLimit(unsigned cell_limit)
{
	mCellLimit = cell_limit;
}

void OffLatticeSimulationWithMutation::WashOutSwitch()
{
	watchForWashOut = true;
}

void OffLatticeSimulationWithMutation::StopOnEmptyMonolayer()
{
	stopOnEmptyMonolayer = true;
}
    
void OffLatticeSimulationWithMutation::StopOnClonalConversion()
{
	stopOnClonalConversion = true;
}

OffLatticeSimulationWithMutation::OffLatticeSimulationWithMutation(
			AbstractCellPopulation<2>& rCellPopulation)
		: OffLatticeSimulation<2>(rCellPopulation)
{
}




// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(OffLatticeSimulationWithMutation)
