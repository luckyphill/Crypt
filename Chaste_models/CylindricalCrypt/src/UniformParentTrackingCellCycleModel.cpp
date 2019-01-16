/*

Uniform cell cycle model with parent tracking

*/

#include "UniformParentTrackingCellCycleModel.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

#include "Debug.hpp"

UniformParentTrackingCellCycleModel::UniformParentTrackingCellCycleModel()
    : AbstractSimpleCellCycleModel(),
      mMinCellCycleDuration(12.0), // Hours
      mMaxCellCycleDuration(14.0)  // Hours
{
}

UniformParentTrackingCellCycleModel::UniformParentTrackingCellCycleModel(const UniformParentTrackingCellCycleModel& rModel)
   : AbstractSimpleCellCycleModel(rModel),
     mMinCellCycleDuration(rModel.mMinCellCycleDuration),
     mMaxCellCycleDuration(rModel.mMaxCellCycleDuration)
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
}

AbstractCellCycleModel* UniformParentTrackingCellCycleModel::CreateCellCycleModel()
{
    return new UniformParentTrackingCellCycleModel(*this);
}

void UniformParentTrackingCellCycleModel::ResetForDivision()
{
    AbstractCellCycleModel::ResetForDivision();
    // Used for makig sure newly divided cells are handeled properly in the force calculator
    mpCell->GetCellData()->SetItem("parent", mpCell->GetCellId());
}

void UniformParentTrackingCellCycleModel::Initialise()
{
    // A brand new cell created in a Test script will need to have it's parent set
    // The parent will be set properly for cells created in the simulation
    AbstractSimpleCellCycleModel::Initialise();
    assert(mpCell != NULL);
    mpCell->GetCellData()->SetItem("parent", mpCell->GetCellId());
}

void UniformParentTrackingCellCycleModel::SetCellCycleDuration()
{
    RandomNumberGenerator* p_gen = RandomNumberGenerator::Instance();

    if (mpCell->GetCellProliferativeType()->IsType<DifferentiatedCellProliferativeType>())
    {
        mCellCycleDuration = DBL_MAX;
    }
    else
    {
        mCellCycleDuration = mMinCellCycleDuration + (mMaxCellCycleDuration - mMinCellCycleDuration) * p_gen->ranf(); // U[MinCCD,MaxCCD]
    }
}

double UniformParentTrackingCellCycleModel::GetMinCellCycleDuration()
{
    return mMinCellCycleDuration;
}

void UniformParentTrackingCellCycleModel::SetMinCellCycleDuration(double minCellCycleDuration)
{
    mMinCellCycleDuration = minCellCycleDuration;
}

double UniformParentTrackingCellCycleModel::GetMaxCellCycleDuration()
{
    return mMaxCellCycleDuration;
}

void UniformParentTrackingCellCycleModel::SetMaxCellCycleDuration(double maxCellCycleDuration)
{
    mMaxCellCycleDuration = maxCellCycleDuration;
}

double UniformParentTrackingCellCycleModel::GetAverageTransitCellCycleTime()
{
    return 0.5*(mMinCellCycleDuration + mMaxCellCycleDuration);
}

double UniformParentTrackingCellCycleModel::GetAverageStemCellCycleTime()
{
    return 0.5*(mMinCellCycleDuration + mMaxCellCycleDuration);
}

void UniformParentTrackingCellCycleModel::OutputCellCycleModelParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<MinCellCycleDuration>" << mMinCellCycleDuration << "</MinCellCycleDuration>\n";
    *rParamsFile << "\t\t\t<MaxCellCycleDuration>" << mMaxCellCycleDuration << "</MaxCellCycleDuration>\n";

    // Call method on direct parent class
    AbstractSimpleCellCycleModel::OutputCellCycleModelParameters(rParamsFile);
}

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(UniformParentTrackingCellCycleModel)
