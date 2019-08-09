#include "WntUniformCellCycleModel.hpp"
#include "AnoikisCellTagged.hpp"
#include "Debug.hpp"

WntUniformCellCycleModel::WntUniformCellCycleModel()
    : UniformCellCycleModel()
{
};

WntUniformCellCycleModel::~WntUniformCellCycleModel()
{

}

WntUniformCellCycleModel::WntUniformCellCycleModel(const WntUniformCellCycleModel& rModel)
   : UniformCellCycleModel(rModel)
{
    /*
     * Initialize only those member variables defined in this class.
     *
     * The member variable mCellCycleDuration is initialized in the
     * AbstractSimpleCellCycleModel constructor.
     *
     * The member variables mBirthTime, mReadyToDivide and mDimension
     * are initialized in the AbstractCellCycleModel constructor.
     *
     * Note that mCellCycleDuration is (re)set as soon as
     * InitialiseDaughterCell() is called on the new cell-cycle model.
     */
};

AbstractCellCycleModel* WntUniformCellCycleModel::CreateCellCycleModel()
{
    return new WntUniformCellCycleModel(*this);
};

bool WntUniformCellCycleModel::IsAbovetWntThreshold()
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

// Overloading ReadyToDivide to account for Wnt Concentration
bool WntUniformCellCycleModel::ReadyToDivide()
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
                if (GetAge() >= mNicheCellCycleTime)
                {
                    mReadyToDivide = true;
                }
            } else {
                if (GetAge() >= mTransientCellCycleTime)
                {
                    mReadyToDivide = true;
                }
            }
        }
        
    }
    return mReadyToDivide;
};

// Since we are inheriting from UniformCellCycleModel, need to overload this again.
void WntUniformCellCycleModel::ResetForDivision()
{
    assert(mReadyToDivide);
    mReadyToDivide = false;
    CellPtr this_cell = GetCell();
    if (this_cell->HasCellProperty<AnoikisCellTagged>())
    {
        TRACE("Found a dividing anoikis cell")
        this_cell->RemoveCellProperty<AnoikisCellTagged>();
    } else {
        mBirthTime = SimulationTime::Instance()->GetTime();
    }
    
}

void WntUniformCellCycleModel::OutputCellCycleModelParameters(out_stream& rParamsFile)
{

    // Call method on direct parent class
    AbstractSimpleCellCycleModel::OutputCellCycleModelParameters(rParamsFile);
};

void WntUniformCellCycleModel::SetNicheCellCycleTime(double nicheCellCycleTime)
{
    mNicheCellCycleTime = nicheCellCycleTime;

};
void WntUniformCellCycleModel::SetTransientCellCycleTime(double transientCellCycleTime)
{
    mTransientCellCycleTime = transientCellCycleTime;
};

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(WntUniformCellCycleModel)