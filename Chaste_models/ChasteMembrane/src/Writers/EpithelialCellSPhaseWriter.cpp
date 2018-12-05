#include "EpithelialCellSPhaseWriter.hpp"
#include "AbstractCellPopulation.hpp"
#include "TransitCellProliferativeType.hpp"
#include "CellCyclePhases.hpp"

#include "GrowingContactInhibitionPhaseBasedCCM.hpp"

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
EpithelialCellSPhaseWriter<ELEMENT_DIM, SPACE_DIM>::EpithelialCellSPhaseWriter()
    : AbstractCellWriter<ELEMENT_DIM, SPACE_DIM>("cells_in_S_Phase.dat")
{
    this->mVtkCellDataName = "Location indices";
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
double EpithelialCellSPhaseWriter<ELEMENT_DIM, SPACE_DIM>::GetCellDataForVtkOutput(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation)
{
    // The method GetCellDataForVtkOutput() is not suitable for this class, so we simply return zero
    return 0.0;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void EpithelialCellSPhaseWriter<ELEMENT_DIM, SPACE_DIM>::VisitCell(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation)
{
    GrowingContactInhibitionPhaseBasedCCM* pCCM = static_cast<GrowingContactInhibitionPhaseBasedCCM*>(pCell->GetCellCycleModel());
    
    if (pCCM->GetCellPhase() == S_PHASE)
    {
        unsigned location_index = pCellPopulation->GetLocationIndexUsingCell(pCell);
        double x = pCellPopulation->GetNode(location_index)->rGetLocation()[0];
        double y = pCellPopulation->GetNode(location_index)->rGetLocation()[1];
        *this->mpOutStream << " | " << pCell->GetCellId() << ", " << x << ", " << y;
    }
}

// Explicit instantiation
template class EpithelialCellSPhaseWriter<1,1>;
template class EpithelialCellSPhaseWriter<1,2>;
template class EpithelialCellSPhaseWriter<2,2>;
template class EpithelialCellSPhaseWriter<1,3>;
template class EpithelialCellSPhaseWriter<2,3>;
template class EpithelialCellSPhaseWriter<3,3>;

#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
EXPORT_TEMPLATE_CLASS_ALL_DIMS(EpithelialCellSPhaseWriter)
