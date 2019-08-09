/*

For use in the contact inhibition test run
Stops the simulation if there are too many cells
This will happen for certain parameter sets because there is nothing to stop cells continually dividing even when they are too squashed

*/

#include "OffLatticeSimulationTooManyCells.hpp"
#include "Debug.hpp"

bool OffLatticeSimulationTooManyCells::StoppingEventHasOccurred()
{
	unsigned cell_count = mrCellPopulation.GetNumRealCells();
	if (cell_count > mCellLimit)
	{
		TRACE("Stopped because the number of cells exceeded the limit")
		return true;
	}
	return false;
}

void OffLatticeSimulationTooManyCells::SetCellLimit(unsigned cell_limit)
{
	mCellLimit = cell_limit;
}
unsigned OffLatticeSimulationTooManyCells::GetCellLimit()
{
	return mCellLimit;
}

OffLatticeSimulationTooManyCells::OffLatticeSimulationTooManyCells(AbstractCellPopulation<2>& rCellPopulation)
	: OffLatticeSimulation<2>(rCellPopulation)
{
	mCellLimit = 1000;
}

OffLatticeSimulationTooManyCells::OffLatticeSimulationTooManyCells(AbstractCellPopulation<2>& rCellPopulation, unsigned cell_limit)
	: OffLatticeSimulation<2>(rCellPopulation),
	mCellLimit(cell_limit)
{
}



// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(OffLatticeSimulationTooManyCells)
