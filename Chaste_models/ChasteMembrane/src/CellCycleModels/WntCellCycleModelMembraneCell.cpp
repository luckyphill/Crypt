

#include "WntCellCycleModelMembraneCell.hpp"
#include "AnoikisCellTagged.hpp"
#include "Debug.hpp"

WntCellCycleModelMembraneCell::WntCellCycleModelMembraneCell()
{
};

WntCellCycleModelMembraneCell::~WntCellCycleModelMembraneCell()
{

}

WntCellCycleModelMembraneCell::WntCellCycleModelMembraneCell(const WntCellCycleModelMembraneCell& rModel)
   : AbstractCellCycleModel(),
    mNicheCellCycleTime(rModel.mNicheCellCycleTime),
   mTransientCellCycleTime(rModel.mTransientCellCycleTime),
   mStoredNicheCellCycleTime(rModel.mStoredNicheCellCycleTime),
   mStoredTransientCellCycleTime(rModel.mStoredTransientCellCycleTime)
{
};

AbstractCellCycleModel* WntCellCycleModelMembraneCell::CreateCellCycleModel()
{
    return new WntCellCycleModelMembraneCell(*this);
};


bool WntCellCycleModelMembraneCell::IsAbovetWntThreshold()
{
    assert(mpCell != nullptr);
    //double level = 0;
    bool AboveThreshold = false;

    if (WntConcentration<2>::Instance()->GetWntLevel(mpCell) > 0.25)
    {
       AboveThreshold = true;
    }

    return AboveThreshold;
};

bool WntCellCycleModelMembraneCell::IsCompressed()
{
    // If checking for compression, look at the immediate neighbours and if they are too close together, then prevent division at this moment
    // Find neigbours
    // Find closest
    // If both closest are compressing the cell too much then yes, cell is compressed
    // Else it is not compressed
    double cell_volume = mpCell->GetCellData()->GetItem("volume");

    double pause_time = 12.0;
    if(cell_volume < 0.62)
    {
        // Extend the cell cycle time by 1 hour
        mNicheCellCycleTime += pause_time;
        mTransientCellCycleTime += pause_time;
        // TRACE("Cell is compressed")
        // PRINT_VARIABLE(mpCell->GetCellId())
        return true;
    }
    return false;
}

// Overloading ReadyToDivide to account for Wnt Concentration
bool WntCellCycleModelMembraneCell::ReadyToDivide()
{
    assert(mpCell != nullptr);
    // Assume that the crypt can be broken into three sections:
    // The niche, where division happens slowly
    // The transient amplifying region where division is rapid
    // The top region where cells have terminally differentiated and stop dividing
    // The point where these regimes change can be controlled by changing the threshold
    if (!mReadyToDivide)
    {
        double wntLevel = WntConcentration<2>::Instance()->GetWntLevel(mpCell);
        
        if (wntLevel > mTransientRegimeThreshold){
            // Niche division rate
            if (wntLevel > mNicheDivisionRegimeThreshold){
            // Niche division rate
                if (GetAge() >= mNicheCellCycleTime && !IsCompressed())
                {
                    mReadyToDivide = true;
                }
            } else {
                if (GetAge() >= mTransientCellCycleTime && !IsCompressed())
                {
                    mReadyToDivide = true;
                }
            }
        }
        
    }
    return mReadyToDivide;
};

// Since we are inheriting from UniformCellCycleModel, need to overload this again.
void WntCellCycleModelMembraneCell::ResetForDivision()
{
    assert(mReadyToDivide);
    mReadyToDivide = false;
    mBirthTime = SimulationTime::Instance()->GetTime();
    
}

void WntCellCycleModelMembraneCell::InitialiseDaughterCell()
{
    CellPtr this_cell = GetCell();
    if (this_cell->HasCellProperty<AnoikisCellTagged>())
    {
        TRACE("Removed tag from popped-up daughter")
        this_cell->RemoveCellProperty<AnoikisCellTagged>(); //need to do this to ensure the daughter cells are added to the delayed anoikis list
    }
    SetCellCycleTimesForDaughter();
}

void WntCellCycleModelMembraneCell::OutputCellCycleModelParameters(out_stream& rParamsFile)
{

    // Call method on direct parent class
    AbstractCellCycleModel::OutputCellCycleModelParameters(rParamsFile);
};

void WntCellCycleModelMembraneCell::SetNicheCellCycleTime(double nicheCellCycleTime)
{
    mNicheCellCycleTime = nicheCellCycleTime;
    mStoredNicheCellCycleTime = nicheCellCycleTime;

};
void WntCellCycleModelMembraneCell::SetTransientCellCycleTime(double transientCellCycleTime)
{   
    mTransientCellCycleTime = transientCellCycleTime;
    mStoredTransientCellCycleTime = transientCellCycleTime;
};

double WntCellCycleModelMembraneCell::GetAverageTransitCellCycleTime()
{
    return mTransientCellCycleTime;
};

double WntCellCycleModelMembraneCell::GetAverageStemCellCycleTime()
{
    return mNicheCellCycleTime;
};

void WntCellCycleModelMembraneCell::SetCellCycleTimesForDaughter()
{
    //Adds an element of randomness to the cell cycle lengths for daughter cells to avoid synchronising behaviour
    //Can't allow CCT to be less than 2, ideally at least 5  to avoid ridiculously small CCTs
    RandomNumberGenerator* p_gen = RandomNumberGenerator::Instance();

    //wiggle is at most 10% of the CCT, can be +ve or -ve
    double wiggle_trans = 0.2 * mStoredTransientCellCycleTime * (p_gen->ranf() - 0.5); 
    double wiggle_niche = 0.2 * mStoredNicheCellCycleTime * (p_gen->ranf() - 0.5);
    //PRINT_VARIABLE(wiggle_trans)

    mTransientCellCycleTime = mStoredTransientCellCycleTime + wiggle_trans;
    mNicheCellCycleTime = mStoredNicheCellCycleTime + wiggle_niche; //Since Niche CCT is twice that of the Transient
    //PRINT_VARIABLE(mTransientCellCycleTime)
    //PRINT_VARIABLE(mNicheCellCycleTime)
};

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(WntCellCycleModelMembraneCell)