/*

For use in the contact inhibition test run
Stops the simulation if there are too many cells
This will happen for certain parameter sets because there is nothing to stop cells continually dividing even when they are too squashed

*/

#include "OffLatticeSimulationPoppedUpStoppingEvent.hpp"
#include "AnoikisCellTagged.hpp"
#include "Debug.hpp"

bool OffLatticeSimulationPoppedUpStoppingEvent::StoppingEventHasOccurred()
{

  std::list<CellPtr> pos_cells =  mrCellPopulation.rGetCells();

  for (std::list<CellPtr>::iterator cell_iter = pos_cells.begin(); cell_iter != pos_cells.end(); ++cell_iter)
  {
    
    if ((*cell_iter)->HasCellProperty<AnoikisCellTagged>())
    {
      TRACE("FAILED")
      return true;
    }
  }
  return false;
}

OffLatticeSimulationPoppedUpStoppingEvent::OffLatticeSimulationPoppedUpStoppingEvent(
        AbstractCellPopulation<2>& rCellPopulation)
    : OffLatticeSimulation<2>(rCellPopulation)
{
}




// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(OffLatticeSimulationPoppedUpStoppingEvent)
