#include "EpithelialCellVelocityWriter.hpp"
#include "AbstractCellPopulation.hpp"
#include "TransitCellProliferativeType.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
EpithelialCellVelocityWriter<ELEMENT_DIM, SPACE_DIM>::EpithelialCellVelocityWriter()
    : AbstractCellWriter<ELEMENT_DIM, SPACE_DIM>("cell_velocity.dat")
{
    this->mVtkCellDataName = "Location indices";
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
double EpithelialCellVelocityWriter<ELEMENT_DIM, SPACE_DIM>::GetCellDataForVtkOutput(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation)
{
    // The method GetCellDataForVtkOutput() is not suitable for this class, so we simply return zero
    return 0.0;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void EpithelialCellVelocityWriter<ELEMENT_DIM, SPACE_DIM>::VisitCell(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation)
{
    if (pCell->GetCellProliferativeType()->IsType<TransitCellProliferativeType>() || pCell->GetCellProliferativeType()->IsType<DifferentiatedCellProliferativeType>())
    {
        unsigned location_index = pCellPopulation->GetLocationIndexUsingCell(pCell);

        double time_step = SimulationTime::Instance()->GetTimeStep(); ///\todo correct time step? (#2404)
        //double damping_constant = pCellPopulation->GetDampingConstant(location_index); //Not sure why this is needed, in the end it should just be a constant
        c_vector<double, SPACE_DIM> velocity = time_step * pCellPopulation->GetNode(location_index)->rGetAppliedForce();// / damping_constant;
        *this->mpOutStream << velocity[0] << ", " << velocity[1];
    }
}

// Explicit instantiation
template class EpithelialCellVelocityWriter<1,1>;
template class EpithelialCellVelocityWriter<1,2>;
template class EpithelialCellVelocityWriter<2,2>;
template class EpithelialCellVelocityWriter<1,3>;
template class EpithelialCellVelocityWriter<2,3>;
template class EpithelialCellVelocityWriter<3,3>;

#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
EXPORT_TEMPLATE_CLASS_ALL_DIMS(EpithelialCellVelocityWriter)
