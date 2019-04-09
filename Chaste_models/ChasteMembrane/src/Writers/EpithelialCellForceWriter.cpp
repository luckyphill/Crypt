#include "EpithelialCellForceWriter.hpp"
#include "AbstractCellPopulation.hpp"
#include "TransitCellProliferativeType.hpp"
#include "DifferentiatedCellProliferativeType.hpp"
#include "SimplifiedPhaseBasedCellCycleModel.hpp"
#include "SimplifiedCellCyclePhases.hpp"

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
EpithelialCellForceWriter<ELEMENT_DIM, SPACE_DIM>::EpithelialCellForceWriter()
    : AbstractCellWriter<ELEMENT_DIM, SPACE_DIM>("cell_force.txt")
{
    this->mVtkCellDataName = "Location indices";
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
double EpithelialCellForceWriter<ELEMENT_DIM, SPACE_DIM>::GetCellDataForVtkOutput(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation)
{
    // The method GetCellDataForVtkOutput() is not suitable for this class, so we simply return zero
    return 0.0;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void EpithelialCellForceWriter<ELEMENT_DIM, SPACE_DIM>::VisitCell(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation)
{
    if (pCell->GetCellProliferativeType()->IsType<TransitCellProliferativeType>() || pCell->GetCellProliferativeType()->IsType<DifferentiatedCellProliferativeType>())
    {
        unsigned location_index = pCellPopulation->GetLocationIndexUsingCell(pCell);
        SimplifiedPhaseBasedCellCycleModel* pccm = static_cast<SimplifiedPhaseBasedCellCycleModel*>(pCell->GetCellCycleModel());

        SimplifiedCellCyclePhase phase = pccm->GetCurrentCellCyclePhase();

        c_vector<double, SPACE_DIM> force = pCellPopulation->GetNode(location_index)->rGetAppliedForce();// / damping_constant;
        c_vector<double, SPACE_DIM> position = pCellPopulation->GetNode(location_index)->rGetLocation();
        *this->mpOutStream << "," << pCell->GetCellId() << "," << std::setprecision(15) << position[0] << "," << position[1] << "," << force[0] << "," << force[1] << "," << pCell->GetAge() << ", " << pCell->GetCellData()->GetItem("parent") << ", " << phase;
    }
}

// Explicit instantiation
template class EpithelialCellForceWriter<1,1>;
template class EpithelialCellForceWriter<1,2>;
template class EpithelialCellForceWriter<2,2>;
template class EpithelialCellForceWriter<1,3>;
template class EpithelialCellForceWriter<2,3>;
template class EpithelialCellForceWriter<3,3>;

#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
EXPORT_TEMPLATE_CLASS_ALL_DIMS(EpithelialCellForceWriter)
