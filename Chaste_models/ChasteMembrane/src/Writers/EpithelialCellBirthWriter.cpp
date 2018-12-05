#include "EpithelialCellBirthWriter.hpp"
#include "AbstractCellPopulation.hpp"
#include "TransitCellProliferativeType.hpp"

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
EpithelialCellBirthWriter<ELEMENT_DIM, SPACE_DIM>::EpithelialCellBirthWriter()
    : AbstractCellWriter<ELEMENT_DIM, SPACE_DIM>("cell_birth.dat")
{
    this->mVtkCellDataName = "Location indices";
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
double EpithelialCellBirthWriter<ELEMENT_DIM, SPACE_DIM>::GetCellDataForVtkOutput(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation)
{
    // The method GetCellDataForVtkOutput() is not suitable for this class, so we simply return zero
    return 0.0;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void EpithelialCellBirthWriter<ELEMENT_DIM, SPACE_DIM>::VisitCell(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation)
{
    double dt = SimulationTime::Instance()->GetTimeStep();
    if (pCell->GetCellProliferativeType()->IsType<TransitCellProliferativeType>() && pCell->GetAge()<dt)
    {
        unsigned location_index = pCellPopulation->GetLocationIndexUsingCell(pCell);
        double x = pCellPopulation->GetNode(location_index)->rGetLocation()[0];
        double y = pCellPopulation->GetNode(location_index)->rGetLocation()[1];
        *this->mpOutStream << " | " << x << ", " << y;
    }
}

// Explicit instantiation
template class EpithelialCellBirthWriter<1,1>;
template class EpithelialCellBirthWriter<1,2>;
template class EpithelialCellBirthWriter<2,2>;
template class EpithelialCellBirthWriter<1,3>;
template class EpithelialCellBirthWriter<2,3>;
template class EpithelialCellBirthWriter<3,3>;

#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
EXPORT_TEMPLATE_CLASS_ALL_DIMS(EpithelialCellBirthWriter)
