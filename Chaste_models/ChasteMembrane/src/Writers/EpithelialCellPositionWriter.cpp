#include "EpithelialCellPositionWriter.hpp"
#include "AbstractCellPopulation.hpp"
#include "TransitCellProliferativeType.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
EpithelialCellPositionWriter<ELEMENT_DIM, SPACE_DIM>::EpithelialCellPositionWriter()
    : AbstractCellWriter<ELEMENT_DIM, SPACE_DIM>("cell_positions.dat")
{
    this->mVtkCellDataName = "Location indices";
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
double EpithelialCellPositionWriter<ELEMENT_DIM, SPACE_DIM>::GetCellDataForVtkOutput(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation)
{
    // The method GetCellDataForVtkOutput() is not suitable for this class, so we simply return zero
    return 0.0;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void EpithelialCellPositionWriter<ELEMENT_DIM, SPACE_DIM>::VisitCell(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation)
{
    if (pCell->GetCellProliferativeType()->IsType<TransitCellProliferativeType>() || pCell->GetCellProliferativeType()->IsType<DifferentiatedCellProliferativeType>())
    {
        unsigned location_index = pCellPopulation->GetLocationIndexUsingCell(pCell);
        double x = pCellPopulation->GetNode(location_index)->rGetLocation()[0];
        double y = pCellPopulation->GetNode(location_index)->rGetLocation()[1];
        *this->mpOutStream << ", " << pCell->GetCellId() << ", " << x << ", " << y;
    }
}

// Explicit instantiation
template class EpithelialCellPositionWriter<1,1>;
template class EpithelialCellPositionWriter<1,2>;
template class EpithelialCellPositionWriter<2,2>;
template class EpithelialCellPositionWriter<1,3>;
template class EpithelialCellPositionWriter<2,3>;
template class EpithelialCellPositionWriter<3,3>;

#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
EXPORT_TEMPLATE_CLASS_ALL_DIMS(EpithelialCellPositionWriter)
