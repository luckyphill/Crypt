

#include "SimplifiedPhaseBasedCellCycleModel.hpp"
#include "StemCellProliferativeType.hpp"
#include "TransitCellProliferativeType.hpp"
#include "DifferentiatedCellProliferativeType.hpp"
#include "AnoikisCellTagged.hpp"
#include "WntConcentration.hpp"

SimplifiedPhaseBasedCellCycleModel::SimplifiedPhaseBasedCellCycleModel()
{
}

SimplifiedPhaseBasedCellCycleModel::~SimplifiedPhaseBasedCellCycleModel()
{
}

SimplifiedPhaseBasedCellCycleModel::SimplifiedPhaseBasedCellCycleModel(const SimplifiedPhaseBasedCellCycleModel& rModel)
    : AbstractCellCycleModel(rModel),
    mBasePDuration(rModel.mBasePDuration),
    mPDuration(rModel.mPDuration),
    mMinimumPDuration(rModel.mMinimumPDuration),
    mWDuration(rModel.mWDuration)
{
    /*
     * The member variables mCurrentCellCyclePhase, mG1Duration,
     * mMinimumGapDuration, mStemCellG1Duration, mTransitCellG1Duration,
     * mSDuration, mG2Duration and mMDuration are initialized in the
     * AbstractPhaseBasedCellCycleModel constructor.
     *
     * The member variables mBirthTime, mReadyToDivide and mDimension
     * are initialized in the AbstractCellCycleModel constructor.
     *
     * Note that mG1Duration is (re)set as soon as InitialiseDaughterCell()
     * is called on the new cell-cycle model.
     */
}

void SimplifiedPhaseBasedCellCycleModel::Initialise()
{
    // A brand new cell created in a Test script will need to have it's parent set
    // The parent will be set properly for cells created in the simulation
    AbstractSimplePhaseBasedCellCycleModel::Initialise();
    assert(mpCell != NULL);
    mpCell->GetCellData()->SetItem("parent", mpCell->GetCellId());
}

void SimplifiedPhaseBasedCellCycleModel::InitialiseDaughterCell()
{
    // Set everything identically. This should be done by reset for division
    // In fact, this will be handled by the instantiation
}

void SimplifiedPhaseBasedCellCycleModel::SetPDuration()
{
    assert(mpCell != nullptr);
    
    if (mpCell->GetCellProliferativeType()->IsType<DifferentiatedCellProliferativeType>())
    {
        mPDuration = DBL_MAX;
    }
    else
    {
        mPDuration = p_gen->NormalRandomDeviate(GetBasePDuration(), 2.0);
        if (mPDuration < 1)
        {
            // Must have at least some time in P phase because crucial things happen there
            mPDuration = 1;
        }
    }
}

void SimplifiedPhaseBasedCellCycleModel::SetBasePDuration(double basePDuration)
{
    assert(mBasePDuration > 1);
    mBasePDuration = basePDuration;
}

void SimplifiedPhaseBasedCellCycleModel::GetBasePDuration(double basePDuration)
{
    return mBasePDuration;
}


void SimplifiedPhaseBasedCellCycleModel::UpdateCellCyclePhase()
{

    if ((mQuiescentVolumeFraction == DOUBLE_UNSET) || (mEquilibriumVolume == DOUBLE_UNSET))
    {
        EXCEPTION("The member variables mQuiescentVolumeFraction and mEquilibriumVolume have not yet been set.");
    }

    double wnt_level= GetWntLevel();
    MAKE_PTR(DifferentiatedCellProliferativeType, p_diff_type);
    MAKE_PTR(TransitCellProliferativeType, p_trans_type);
    MAKE_PTR(CellLabel, p_label);

    // If the Wnt level is too low and we are in the pausable phase, set to differentiated type
    if (wnt_level < GetWntThreshold() && mCurrentCellCyclePhase == P_PHASE)
    {
        mpCell->SetCellProliferativeType(p_diff_type);
        mCurrentCellCyclePhase = G_ZERO_PHASE;
        mpCell->RemoveCellProperty<CellLabel>();
    }

    
    // Removes the cell label that tells the visualiser the cell is contact inhibited
    mpCell->RemoveCellProperty<CellLabel>();

    if (mCurrentCellCyclePhase == P_PHASE)
    {
        // If we're in the pausable phase, check to see if the cell is too squashed
        double cell_volume = mpCell->GetCellData()->GetItem("volume");
        double quiescent_volume = mEquilibriumVolume * mQuiescentVolumeFraction;

        if (cell_volume < quiescent_volume)
        {
            // The cell is too squashed to continue in the cell cycle, so pause
            // In practice, the pause is done by increasing the length of time needed
            // to be spent in P phase by the simulation time step
            mCurrentQuiescentDuration = SimulationTime::Instance()->GetTime() - mCurrentQuiescentOnsetTime;
            mPDuration += SimulationTime::Instance()->GetTimeStep();

            // Put the label back so the visualiser knows the cell is compressed
            mpCell->AddCellProperty(p_label);
        }
        else
        {
            // Reset the cell's quiescent duration and update the time at which the onset of quiescent occurs
            mCurrentQuiescentDuration = 0.0;
            mCurrentQuiescentOnsetTime = SimulationTime::Instance()->GetTime();
        }
    }

    double time_since_birth = GetAge();
    assert(time_since_birth >= 0);

    // T Phase is the temporaray phase cells start in to make sure:
    // 1. We can give cells a wide range of starting times to avoid synchronisation, while;
    // 2. Stopping cells from expecting to have a pair cell, if they would be starting in W phase
    if (mCurrentCellCyclePhase == T_PHASE)
    {
        if (time_since_birth > GetWDuration())
        {
            mCurrentCellCyclePhase = P_PHASE;
        }
    }
    else
    {
        if (time_since_birth < GetWDuration())
        {
            mCurrentCellCyclePhase = W_PHASE;
        }
        else if (time_since_birth > GetWDuration() && mCurrentCellCyclePhase == W_PHASE )
        {
            mCurrentCellCyclePhase = P_PHASE;
            SetPDuration();
            // Do the stuff to give random cell cycle time
            // This is where true division happens
        }
    }
}


void SimplifiedPhaseBasedCellCycleModel::ResetForDivision()
{
    AbstractCellCycleModel::ResetForDivision();
    // Used for making growing cell pairs are handled properly in the force calculator
    mpCell->GetCellData()->SetItem("parent", mpCell->GetCellId());
}


void SimplifiedPhaseBasedCellCycleModel::SetWntThreshold(double wntThreshold)
{
    mWntThreshold = wntThreshold;
}

double SimplifiedPhaseBasedCellCycleModel::GetWntThreshold()
{
    return mWntThreshold;
}


void SimplifiedPhaseBasedCellCycleModel::OutputCellCycleModelParameters(out_stream& rParamsFile)
{
    // Need to output phase parameters etc.
    AbstractCellCycleModel::OutputCellCycleModelParameters(rParamsFile);
}
