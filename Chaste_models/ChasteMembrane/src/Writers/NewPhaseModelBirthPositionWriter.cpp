#include "NewPhaseModelBirthPositionWriter.hpp"
#include "AbstractCellPopulation.hpp"
#include "TransitCellProliferativeType.hpp"
#include "SimplifiedCellCyclePhases.hpp"
#include "SimplifiedPhaseBasedCellCycleModel.hpp"
#include "Debug.hpp"

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
NewPhaseModelBirthPositionWriter<ELEMENT_DIM, SPACE_DIM>::NewPhaseModelBirthPositionWriter()
    : AbstractCellWriter<ELEMENT_DIM, SPACE_DIM>("cell_birth_position.txt")
{
    this->mVtkCellDataName = "Location indices";
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
double NewPhaseModelBirthPositionWriter<ELEMENT_DIM, SPACE_DIM>::GetCellDataForVtkOutput(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation)
{
    // The method GetCellDataForVtkOutput() is not suitable for this class, so we simply return zero
    return 0.0;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NewPhaseModelBirthPositionWriter<ELEMENT_DIM, SPACE_DIM>::VisitCell(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation)
{
    assert(mSamplingMultiple != DOUBLE_UNSET);

    double dt = SimulationTime::Instance()->GetTimeStep();

    SimplifiedPhaseBasedCellCycleModel* p_ccm = static_cast<SimplifiedPhaseBasedCellCycleModel*>(pCell->GetCellCycleModel());
    SimplifiedCellCyclePhase phase = p_ccm->GetCurrentCellCyclePhase();
    c_vector<double, 2> location = pCellPopulation->GetLocationOfCellCentre(pCell);
    double W_phase_length = p_ccm->GetWDuration();

    double y = 0; // The y position of the cell to be written.
    // The algorithm to follow only counts cells below, meaning the actual position number
    // is one more than y, so start y at 1 to account for this 

    std::list<CellPtr> cells = pCellPopulation->rGetCells();

    // Detect if a division event has occurred in the time interval between samples
    if (pCell->GetAge() <= W_phase_length + mSamplingMultiple * dt && (phase == P_PHASE || phase == G0_PHASE))
    // if ( !p_ccm->IsAgeGreaterThan(W_phase_length + mSamplingMultiple * dt) && (phase == P_PHASE || phase == G0_PHASE))   
    {
        // Put the cells in order of height
        // Count through until we hit this cell
        // As counting is occurring, add 1 for Pphase cells and 1/2 for Wphase cells
        // If we end up with a count ending in 0.5, then we are sitting at the bottom
        // node of a cell pair. This will happen 50% of the time, so at this point,
        // take the integer part.

        std::list<CellPtr>::iterator it;
        for (it = cells.begin(); it!=cells.end(); ++it)
        {
            SimplifiedPhaseBasedCellCycleModel* p_ccm_it = static_cast<SimplifiedPhaseBasedCellCycleModel*>((*it)->GetCellCycleModel());
            SimplifiedCellCyclePhase phase_it = p_ccm_it->GetCurrentCellCyclePhase();
            c_vector<double, 2> location_it = pCellPopulation->GetLocationOfCellCentre(*it);
            if (location_it[1] < location[1])
            {
                if (phase_it == W_PHASE)
                {
                    y+= 0.5;
                }
                else
                {
                    y+= 1.0;
                }
            }
        }
        unsigned yu = unsigned(y);

        *this->mpOutStream << ", " << yu;

        // We need to subtract 1 because this algorithm works only after a cell division has occurre
        // therefore, there will always be two cell positions to account for the two daughter cells
        // Assuming this is a column, the top cell will always be one cell position higher than the
        // parent cell, hence the maxDivisionCellPosition would wrongly be set as one higher than it
        // otherwise should be. 
        if (yu - 1 > maxDivisionCellPosition)
        {
            maxDivisionCellPosition = yu - 1;
        }

        mBirthCount++;

    }
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NewPhaseModelBirthPositionWriter<ELEMENT_DIM, SPACE_DIM>::SetSamplingMultiple(double samplingMultiple)
{
    mSamplingMultiple = samplingMultiple;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
unsigned NewPhaseModelBirthPositionWriter<ELEMENT_DIM, SPACE_DIM>::GetBirthCount()
{
    return mBirthCount/2;
}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
unsigned NewPhaseModelBirthPositionWriter<ELEMENT_DIM, SPACE_DIM>::GetMaxDivisionCellPosition()
{
    return maxDivisionCellPosition;
}

// Explicit instantiation
template class NewPhaseModelBirthPositionWriter<1,1>;
template class NewPhaseModelBirthPositionWriter<1,2>;
template class NewPhaseModelBirthPositionWriter<2,2>;
template class NewPhaseModelBirthPositionWriter<1,3>;
template class NewPhaseModelBirthPositionWriter<2,3>;
template class NewPhaseModelBirthPositionWriter<3,3>;

#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
EXPORT_TEMPLATE_CLASS_ALL_DIMS(NewPhaseModelBirthPositionWriter)
