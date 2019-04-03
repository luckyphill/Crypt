

// Can only be used with the new pahse model

#include "CryptStateTrackingModifier.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "SimplifiedPhaseBasedCellCycleModel.hpp"
#include "SimplifiedCellCyclePhases.hpp"
#include "Debug.hpp"

template<unsigned DIM>
CryptStateTrackingModifier<DIM>::CryptStateTrackingModifier()
    : AbstractCellBasedSimulationModifier<DIM>()
{
}

template<unsigned DIM>
CryptStateTrackingModifier<DIM>::~CryptStateTrackingModifier()
{
}

template<unsigned DIM>
void CryptStateTrackingModifier<DIM>::UpdateAtEndOfTimeStep(AbstractCellPopulation<DIM,DIM>& rCellPopulation)
{
    rCellPopulation.Update();

    UpdateRunningAverage(rCellPopulation);

    UpdateBirthStats(rCellPopulation);
  

    
}

template<unsigned DIM>
void CryptStateTrackingModifier<DIM>::UpdateBirthStats(AbstractCellPopulation<DIM,DIM>& rCellPopulation)
{
    std::list<CellPtr> cells = rCellPopulation.rGetCells();

    cells.sort([&rCellPopulation](const CellPtr pCellA, const CellPtr pCellB)
        {
            c_vector<double, 2> locationA = rCellPopulation.GetLocationOfCellCentre(pCellA);
            c_vector<double, 2> locationB = rCellPopulation.GetLocationOfCellCentre(pCellB);

            return locationA[1] < locationB[1];
        });


    unsigned position_count = 1;
    double dt = SimulationTime::Instance()->GetTimeStep();
    // PRINT_VARIABLE(SimulationTime::Instance()->GetTime())
    // PRINT_VARIABLE(dt)

    for (std::list<CellPtr>::iterator it = cells.begin(); it != cells.end(); ++it)
    {
        

        SimplifiedPhaseBasedCellCycleModel* p_ccm = static_cast<SimplifiedPhaseBasedCellCycleModel*>((*it)->GetCellCycleModel());
        SimplifiedCellCyclePhase phase = p_ccm->GetCurrentCellCyclePhase();

        double W_phase_length = p_ccm->GetWDuration();
        // PRINT_VARIABLE(rCellPopulation.GetLocationOfCellCentre((*it))[1])
        // PRINT_VARIABLE((*it)->GetAge())
        // PRINT_VARIABLE(phase)

        // Detect if a division event has occurred in the time interval between samples
        if ((*it)->GetAge() <= (W_phase_length + dt) && (phase == P_PHASE || phase == G0_PHASE))
        {
            // This means the cell has just divided
            mBirthCount++;
            if (position_count > mMaxBirthPosition)
            {
                mMaxBirthPosition = position_count;
            }

            // Hopefully this means it jumps past the next cell because the next cell will be the sibling cell
            // and we don't want to double count
            // ++it;
        }

        position_count++;
    }  
}

template<unsigned DIM>
void CryptStateTrackingModifier<DIM>::UpdateRunningAverage(AbstractCellPopulation<DIM,DIM>& rCellPopulation)
{

    // This counts all the cells in the crypt
    // Since there will be two W phase nodes per cell, we have to differentiate by phase
    // to get the correct count

    unsigned wCount = 0;
    unsigned pCount = 0;
    unsigned g0Count = 0;

    std::list<CellPtr> cells = rCellPopulation.rGetCells();
    for (std::list<CellPtr>::iterator it = cells.begin(); it != cells.end(); ++it)
    {
        SimplifiedPhaseBasedCellCycleModel* p_ccm = static_cast<SimplifiedPhaseBasedCellCycleModel*>((*it)->GetCellCycleModel());

        if (p_ccm->GetCurrentCellCyclePhase() == W_PHASE)
        {
            wCount++;
        }

        if (p_ccm->GetCurrentCellCyclePhase() == P_PHASE)
        {
            pCount++;
        }

        if (p_ccm->GetCurrentCellCyclePhase() == G0_PHASE)
        {
            g0Count++;
        }
    }

    mCurrentTotal = pCount + g0Count + (double)wCount/2;
    mObservationCount++;

    mRunningAverage = (mRunningAverage*(mObservationCount-1) + mCurrentTotal)/mObservationCount;
}

template<unsigned DIM>
void CryptStateTrackingModifier<DIM>::SetupSolve(AbstractCellPopulation<DIM,DIM>& rCellPopulation, std::string outputDirectory)
{

    // Nothing to do
}

template<unsigned DIM>
double CryptStateTrackingModifier<DIM>::GetAverageCount()
{
    return mRunningAverage;
}

template<unsigned DIM>
unsigned CryptStateTrackingModifier<DIM>::GetBirthCount()
{
    return mBirthCount;
}


template<unsigned DIM>
unsigned CryptStateTrackingModifier<DIM>::GetMaxBirthPosition()
{
    return mMaxBirthPosition;
}


template<unsigned DIM>
void CryptStateTrackingModifier<DIM>::OutputSimulationModifierParameters(out_stream& rParamsFile)
{
    // No parameters to output, so just call method on direct parent class
    AbstractCellBasedSimulationModifier<DIM>::OutputSimulationModifierParameters(rParamsFile);
}

// Explicit instantiation
template class CryptStateTrackingModifier<1>;
template class CryptStateTrackingModifier<2>;
template class CryptStateTrackingModifier<3>;

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(CryptStateTrackingModifier)

