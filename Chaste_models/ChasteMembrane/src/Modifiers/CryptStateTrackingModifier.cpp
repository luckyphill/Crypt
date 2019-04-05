

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
  
  // Does nothing right now, testing end of solve

    
}

template<unsigned DIM>
void CryptStateTrackingModifier<DIM>::UpdateAtEndOfSolve(AbstractCellPopulation<DIM,DIM>& rCellPopulation)
{
    // Nothing

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


    double position_count = 0;
    double dt = SimulationTime::Instance()->GetTimeStep();

    for (std::list<CellPtr>::iterator it = cells.begin(); it != cells.end(); ++it)
    {
        

        SimplifiedPhaseBasedCellCycleModel* p_ccm = static_cast<SimplifiedPhaseBasedCellCycleModel*>((*it)->GetCellCycleModel());
        SimplifiedCellCyclePhase phase = p_ccm->GetCurrentCellCyclePhase();

        double W_phase_length = p_ccm->GetWDuration();

        if (phase == W_PHASE)
        {
            position_count += 0.5;
        }
        else
        {
            position_count += 1.0;
        }

        if (      !p_ccm->IsAgeGreaterThan(W_phase_length + dt)     &&     phase != W_PHASE    )
        {
            // Presuming one node out of a multi node cell can never die
            // mBirthCount will always be twice the actual birth count
            // There is one very unlikely case where this will end up with an odd
            // number, and that is if a dividing cell has one node killed when
            // by sloughing off the top. This will need to be repaired in
            // the sloughing cell killer
            mBirthCount += 1;

            // Since the cell has actually divided as this point, the two nodes
            // we visit will both be in P or G0 phase
            // We will hence enter the above if statement twice per division event
            // Since both cells are counted as full cells, we enter the if statement
            // with position_count = n and n+1. We only want n counted in max position
            // because that is the position the parent cell had immediately before division
            // n+1 will always be the bigger number, so just subtract 1 for the max
            // division check
            if (unsigned(position_count - 1) > mMaxBirthPosition)
            {
                mMaxBirthPosition = unsigned(position_count - 1);
            }
        }
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
    return mBirthCount/2;
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

