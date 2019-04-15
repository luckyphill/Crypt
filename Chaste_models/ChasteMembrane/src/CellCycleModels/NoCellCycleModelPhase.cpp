

// Does nothing, but returns a phase if asked

#include "NoCellCycleModelPhase.hpp"
#include "SimplifiedCellCyclePhases.hpp"

NoCellCycleModelPhase::NoCellCycleModelPhase()
    : NoCellCycleModel()
{
}

SimplifiedCellCyclePhase NoCellCycleModelPhase::GetCurrentCellCyclePhase()
{
    return G0_PHASE;
}



void NoCellCycleModelPhase::OutputCellCycleModelParameters(out_stream& rParamsFile)
{
    // No new parameters to output, so just call method on direct parent class
    AbstractCellCycleModel::OutputCellCycleModelParameters(rParamsFile);
}

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(NoCellCycleModelPhase)
