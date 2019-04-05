

#include "SimplifiedPhaseBasedCellCycleModel.hpp"
#include "StemCellProliferativeType.hpp"
#include "TransitCellProliferativeType.hpp"
#include "DifferentiatedCellProliferativeType.hpp"
#include "CellLabel.hpp"
#include "AnoikisCellTagged.hpp"
#include "WntConcentration.hpp"
#include "RandomNumberGenerator.hpp"
#include "Debug.hpp"

SimplifiedPhaseBasedCellCycleModel::SimplifiedPhaseBasedCellCycleModel()
: AbstractCellCycleModel(),
    mBasePDuration(5),
    mMinimumPDuration(1),
    mWDuration(10),
    mWntThreshold(0.75)
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
    mWDuration(rModel.mWDuration),
    mQuiescentVolumeFraction(rModel.mQuiescentVolumeFraction),
    mEquilibriumVolume(rModel.mEquilibriumVolume),
    mWntThreshold(rModel.mWntThreshold)
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
    AbstractCellCycleModel::Initialise();
    assert(mpCell != NULL);
    try
    {
        unsigned parent = mpCell->GetCellData()->GetItem("parent");
    } 
    catch (...)
    {
        mpCell->GetCellData()->SetItem("parent", mpCell->GetCellId());
    }
    SetPDuration();
    mCurrentCellCyclePhase = W_PHASE;
}

void SimplifiedPhaseBasedCellCycleModel::InitialiseDaughterCell()
{
    SetPDuration();
    mCurrentCellCyclePhase = W_PHASE;
}

void SimplifiedPhaseBasedCellCycleModel::SetPDuration()
{
    assert(mpCell != nullptr);
    
    RandomNumberGenerator* p_gen = RandomNumberGenerator::Instance();
    if (mpCell->GetCellProliferativeType()->IsType<DifferentiatedCellProliferativeType>())
    {
        mPDuration = DBL_MAX;
    }
    else
    {
        mPDuration = p_gen->NormalRandomDeviate(GetBasePDuration(), 1.0);
        if (mPDuration < mMinimumPDuration)
        {
            // Must have at least some time in P phase because crucial things happen there
            mPDuration = mMinimumPDuration;
        }
    }
}

double SimplifiedPhaseBasedCellCycleModel::GetPDuration()
{
    return mPDuration;
}

void SimplifiedPhaseBasedCellCycleModel::SetBasePDuration(double basePDuration)
{
    assert(mBasePDuration > mMinimumPDuration);
    mBasePDuration = basePDuration;
}

double SimplifiedPhaseBasedCellCycleModel::GetBasePDuration()
{
    return mBasePDuration;
}

void SimplifiedPhaseBasedCellCycleModel::SetWDuration(double wDuration)
{
    assert(wDuration > mMinimumPDuration);
    mWDuration = wDuration;
}

double SimplifiedPhaseBasedCellCycleModel::GetWDuration()
{
    return mWDuration;
}

void SimplifiedPhaseBasedCellCycleModel::SetMinimumPDuration(double minimumPDuration)
{
    assert(minimumPDuration > 0);
    mMinimumPDuration = minimumPDuration;
}

double SimplifiedPhaseBasedCellCycleModel::GetMinimumPDuration()
{
    return mMinimumPDuration;
}


void SimplifiedPhaseBasedCellCycleModel::UpdateCellCyclePhase()
{

    if ((mQuiescentVolumeFraction == DOUBLE_UNSET) || (mEquilibriumVolume == DOUBLE_UNSET))
    {
        EXCEPTION("The member variables mQuiescentVolumeFraction and mEquilibriumVolume have not yet been set.");
    }

    double wnt_level= GetWntLevel();
    
    // No idea why this needs to be done this way
    boost::shared_ptr<AbstractCellProperty> p_transit_type =
            mpCell->rGetCellPropertyCollection().GetCellPropertyRegistry()->Get<TransitCellProliferativeType>();
    
    boost::shared_ptr<AbstractCellProperty> p_diff_type =
            mpCell->rGetCellPropertyCollection().GetCellPropertyRegistry()->Get<DifferentiatedCellProliferativeType>();
    
    boost::shared_ptr<AbstractCellProperty> p_label =
            mpCell->rGetCellPropertyCollection().GetCellPropertyRegistry()->Get<CellLabel>();

    // If the Wnt level is too low and we are in the pausable phase, set to differentiated type
    if (wnt_level < GetWntThreshold() && mCurrentCellCyclePhase == P_PHASE)
    {
        mpCell->SetCellProliferativeType(p_diff_type);
        mCurrentCellCyclePhase = G0_PHASE;
        mpCell->RemoveCellProperty<CellLabel>();
    }

    
    // Removes the cell label that tells the visualiser the cell is contact inhibited
    mpCell->RemoveCellProperty<CellLabel>();

    if (mCurrentCellCyclePhase == P_PHASE)
    {
        // If we're in the pausable phase, check to see if the cell is too squashed
        double cell_volume = mpCell->GetCellData()->GetItem("volume");
        double quiescent_volume = mEquilibriumVolume * mQuiescentVolumeFraction;
        if (!mpCell->HasCellProperty<AnoikisCellTagged>())
        {
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
        } else 
        {
            if (!mPopUpDivision)
            {
                // If the cell is tagged for anoikis, and we are not allowing cells to divide after popping up, then make the
                // cell differentiated
                mCurrentCellCyclePhase = G0_PHASE;
                mpCell->SetCellProliferativeType(p_diff_type);
            }            
        }
        
    }

    // All cells will start in W_Phase

    if (  IsAgeLessThan( GetWDuration() )  )
    {
        mCurrentCellCyclePhase = W_PHASE;
    }
    else 
    {
        if (mCurrentCellCyclePhase == W_PHASE)
        {
            mCurrentCellCyclePhase = P_PHASE;
            mpCell->GetCellData()->SetItem("parent", mpCell->GetCellId());
            // Reset the parent tracker since we only care about this in W phase
        }
    }
}

bool SimplifiedPhaseBasedCellCycleModel::IsAgeLessThan(double comparison)
{

    double eps = SimulationTime::Instance()->GetTimeStep() / 10;
    double age = GetAge();

    return ( age < comparison && abs(comparison - GetAge()) > eps );

}

bool SimplifiedPhaseBasedCellCycleModel::IsAgeGreaterThan(double comparison)
{

    double eps = SimulationTime::Instance()->GetTimeStep() / 10;
    double age = GetAge();

    return ( age > comparison && abs(comparison - GetAge()) > eps );

}


double SimplifiedPhaseBasedCellCycleModel::GetWntLevel()
{
    assert(mpCell != NULL);
    double level = 0;

    switch (mDimension)
    {
        case 1:
        {
            const unsigned DIM = 1;
            level = WntConcentration<DIM>::Instance()->GetWntLevel(mpCell);
            break;
        }
        case 2:
        {
            const unsigned DIM = 2;
            level = WntConcentration<DIM>::Instance()->GetWntLevel(mpCell);
            break;
        }
        case 3:
        {
            const unsigned DIM = 3;
            level = WntConcentration<DIM>::Instance()->GetWntLevel(mpCell);
            break;
        }
        default:
            NEVER_REACHED;
    }
    return level;
}


void SimplifiedPhaseBasedCellCycleModel::ResetForDivision()
{
    AbstractCellCycleModel::ResetForDivision();
    // Used for making growing cell pairs are handled properly in the force calculator
    mpCell->GetCellData()->SetItem("parent", mpCell->GetCellId()); // Now done in the W to P transition, but can't hurt to leave it here
    mCurrentCellCyclePhase = W_PHASE;
}

bool SimplifiedPhaseBasedCellCycleModel::ReadyToDivide()
{
    assert(mpCell != nullptr);

    if (!mReadyToDivide)
    {
        UpdateCellCyclePhase();
        if ( mCurrentCellCyclePhase == P_PHASE && GetAge() >= GetPDuration() + GetWDuration())
        {
            mReadyToDivide = true;
            // Set cell property 'parent_cell' to be this cell
            // This should be copied over to both new cells
            mpCell->GetCellData()->SetItem("parent_cell", mpCell->GetCellId());
        }
    }
    return mReadyToDivide;
}

AbstractCellCycleModel* SimplifiedPhaseBasedCellCycleModel::CreateCellCycleModel()
{
    return new SimplifiedPhaseBasedCellCycleModel(*this);
}


void SimplifiedPhaseBasedCellCycleModel::SetWntThreshold(double wntThreshold)
{
    mWntThreshold = wntThreshold;
}

double SimplifiedPhaseBasedCellCycleModel::GetWntThreshold()
{
    return mWntThreshold;
}

SimplifiedCellCyclePhase SimplifiedPhaseBasedCellCycleModel::GetCurrentCellCyclePhase()
{
    return mCurrentCellCyclePhase;
}


void SimplifiedPhaseBasedCellCycleModel::SetQuiescentVolumeFraction(double quiescentVolumeFraction)
{
    mQuiescentVolumeFraction = quiescentVolumeFraction;
}

double SimplifiedPhaseBasedCellCycleModel::GetQuiescentVolumeFraction() const
{
    return mQuiescentVolumeFraction;
}

void SimplifiedPhaseBasedCellCycleModel::SetEquilibriumVolume(double equilibriumVolume)
{
    mEquilibriumVolume = equilibriumVolume;
}

double SimplifiedPhaseBasedCellCycleModel::GetEquilibriumVolume() const
{
    return mEquilibriumVolume;
}

double SimplifiedPhaseBasedCellCycleModel::GetCurrentQuiescentDuration() const
{
    return mCurrentQuiescentDuration;
}

double SimplifiedPhaseBasedCellCycleModel::GetCurrentQuiescentOnsetTime() const
{
    return mCurrentQuiescentOnsetTime;
}

double SimplifiedPhaseBasedCellCycleModel::GetAverageTransitCellCycleTime()
{
    return 0;
}

double SimplifiedPhaseBasedCellCycleModel::GetAverageStemCellCycleTime()
{
    return 0;
}

void SimplifiedPhaseBasedCellCycleModel::SetPopUpDivision(bool popUpDivision)
{
    mPopUpDivision = popUpDivision;
}


void SimplifiedPhaseBasedCellCycleModel::OutputCellCycleModelParameters(out_stream& rParamsFile)
{
    // Need to output phase parameters etc.
    AbstractCellCycleModel::OutputCellCycleModelParameters(rParamsFile);
}
