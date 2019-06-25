/*

For use in the contact inhibition test run
Stops the simulation if there are too many cells
This will happen for certain parameter sets because there is nothing to stop cells continually dividing even when they are too squashed

*/

#include "OffLatticeSimulationMutationWashOut.hpp"
#include "TransitCellAnoikisResistantMutationState.hpp"
#include "AnoikisCellTagged.hpp"
#include "Debug.hpp"

bool OffLatticeSimulationMutationWashOut::StoppingEventHasOccurred()
{
	// Look through all cells, if no mutant cells are directly on the BM
	// then wash out has occurred. Alternatively, if all mutant cells are popped
	// Also keeps the cell count limit
	unsigned cell_count = mrCellPopulation.GetNumRealCells();
	if (cell_count > mCellLimit)
	{
		TRACE("Stopped because the number of cells exceeded the limit")
		return true;
	}

	if (watchForWashOut)
	{
		unsigned mutantCellCount = 0;
		unsigned monolayerMutantCellCount = 0;

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

		if (monolayerMutantCellCount == 0)
		{
			// For the sake of the output processing format. 0 means washout, 1 mean clonal conversion
			TRACE("Washout = 0")
			return true;
		}

		if (  mutantCellCount > unsigned( 0.6 * double(cell_count) ) )
		{
			TRACE("Clonal = 1")
			return true;
		}
		
	}



	return false;
	
}

void OffLatticeSimulationMutationWashOut::SetCellLimit(unsigned cell_limit)
{
	mCellLimit = cell_limit;
}

void OffLatticeSimulationMutationWashOut::WashOutSwitch()
{
	watchForWashOut = true;
}

OffLatticeSimulationMutationWashOut::OffLatticeSimulationMutationWashOut(
			AbstractCellPopulation<2>& rCellPopulation)
		: OffLatticeSimulation<2>(rCellPopulation)
{
}




// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(OffLatticeSimulationMutationWashOut)
