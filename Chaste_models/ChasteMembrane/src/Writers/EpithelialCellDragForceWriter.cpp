#include "EpithelialCellDragForceWriter.hpp"
#include "AbstractCellPopulation.hpp"
#include "TransitCellProliferativeType.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

EpithelialCellDragForceWriter::EpithelialCellDragForceWriter(c_vector<double, 2> *push_force)
    : AbstractCellWriter<2,2>("cell_drag_force.dat")
{
    this->mVtkCellDataName = "Location indices";
    m_push_force = push_force;
}

double EpithelialCellDragForceWriter::GetCellDataForVtkOutput(CellPtr pCell, AbstractCellPopulation<2,2>* pCellPopulation)
{
    // The method GetCellDataForVtkOutput() is not suitable for this class, so we simply return zero
    return 0.0;
}

void EpithelialCellDragForceWriter::VisitCell(CellPtr pCell, AbstractCellPopulation<2,2>* pCellPopulation)
{
    if (pCell->GetCellProliferativeType()->IsType<TransitCellProliferativeType>() || pCell->GetCellProliferativeType()->IsType<DifferentiatedCellProliferativeType>())
    {
        unsigned location_index = pCellPopulation->GetLocationIndexUsingCell(pCell);
        double x = pCellPopulation->GetNode(location_index)->rGetLocation()[0];
        double y = pCellPopulation->GetNode(location_index)->rGetLocation()[1];

        c_vector<double, 2> force = pCellPopulation->GetNode(location_index)->rGetAppliedForce();// / damping_constant;
        *this->mpOutStream << "," << pCell->GetCellId() << "," << x << "," << y << "," << force[0]-(*m_push_force)[0] << "," << force[1]-(*m_push_force)[1];
    }
}


#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
//EXPORT_TEMPLATE_CLASS_ALL_DIMS(EpithelialCellDragForceWriter)
