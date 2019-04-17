#include "NewPhaseModelBirthWriter.hpp"
#include "AbstractCellPopulation.hpp"
#include "TransitCellProliferativeType.hpp"
#include "SimplifiedCellCyclePhases.hpp"
#include "SimplifiedPhaseBasedCellCycleModel.hpp"
#include "Debug.hpp"

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
NewPhaseModelBirthWriter<ELEMENT_DIM, SPACE_DIM>::NewPhaseModelBirthWriter()
    : AbstractCellWriter<ELEMENT_DIM, SPACE_DIM>("cell_birth_height.txt")
{
    this->mVtkCellDataName = "Location indices";
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
double NewPhaseModelBirthWriter<ELEMENT_DIM, SPACE_DIM>::GetCellDataForVtkOutput(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation)
{
    // The method GetCellDataForVtkOutput() is not suitable for this class, so we simply return zero
    return 0.0;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NewPhaseModelBirthWriter<ELEMENT_DIM, SPACE_DIM>::VisitCell(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation)
{
    assert(mSamplingMultiple != DOUBLE_UNSET);

    double dt = SimulationTime::Instance()->GetTimeStep();

    SimplifiedPhaseBasedCellCycleModel* p_ccm = static_cast<SimplifiedPhaseBasedCellCycleModel*>(pCell->GetCellCycleModel());
    SimplifiedCellCyclePhase phase = p_ccm->GetCurrentCellCyclePhase();
    double W_phase_length = p_ccm->GetWDuration();

    double y = 0.0; // The y position of the cell to be written

    // Detect if a division event has occurred in the time interval between samples
    if (pCell->GetAge() <= W_phase_length + mSamplingMultiple * dt && (phase == P_PHASE || phase == G0_PHASE))
    {
        // Find the node's twin and take the average position
        unsigned node_index = pCellPopulation->GetLocationIndexUsingCell(pCell);
        Node<SPACE_DIM>* p_node = pCellPopulation->GetNode(node_index);

        // Must find its twin
        std::vector<unsigned>& neighbours = p_node->rGetNeighbours();
        std::vector<unsigned>::iterator neighbour;

        double ageA = pCell->GetAge();
        

        double parentA = pCell->GetCellData()->GetItem("parent");
        

        for (neighbour = neighbours.begin(); neighbour != neighbours.end(); neighbour++)
        {
            CellPtr p_neighbour_cell = pCellPopulation->GetCellUsingLocationIndex(*neighbour);
            
            double ageB = p_neighbour_cell->GetAge();
            double parentB = p_neighbour_cell->GetCellData()->GetItem("parent");

            if ( ageA == ageB && parentA == parentB )
            {
                double location = pCellPopulation->GetLocationOfCellCentre(pCell)[1];
                double location_neighbour = pCellPopulation->GetLocationOfCellCentre(p_neighbour_cell)[1];

                // Take the average of the two
                y = (location + location_neighbour) / 2;

                *this->mpOutStream << ", " << y;
                mBirthCount++;

                if (y > maxDivisionCellPosition)
                {
                    maxDivisionCellPosition = y;
                }

            }
        }

        
    }
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NewPhaseModelBirthWriter<ELEMENT_DIM, SPACE_DIM>::SetSamplingMultiple(double samplingMultiple)
{
    mSamplingMultiple = samplingMultiple;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
unsigned NewPhaseModelBirthWriter<ELEMENT_DIM, SPACE_DIM>::GetBirthCount()
{
    return mBirthCount;
}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
double NewPhaseModelBirthWriter<ELEMENT_DIM, SPACE_DIM>::GetMaxDivisionCellPosition()
{
    return maxDivisionCellPosition;
}

// Explicit instantiation
template class NewPhaseModelBirthWriter<1,1>;
template class NewPhaseModelBirthWriter<1,2>;
template class NewPhaseModelBirthWriter<2,2>;
template class NewPhaseModelBirthWriter<1,3>;
template class NewPhaseModelBirthWriter<2,3>;
template class NewPhaseModelBirthWriter<3,3>;

#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
EXPORT_TEMPLATE_CLASS_ALL_DIMS(NewPhaseModelBirthWriter)
