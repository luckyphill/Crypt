#include "WntUniformContactInhibition.hpp"
#include "DifferentiatedCellProliferativeType.hpp"
#include "CellLabel.hpp"
#include "Debug.hpp"

WntUniformContactInhibition::WntUniformContactInhibition()
    : AbstractSimpleCellCycleModel(),
      mMinCellCycleDuration(12.0), // Hours
      mMaxCellCycleDuration(14.0)  // Hours
{
}

WntUniformContactInhibition::WntUniformContactInhibition(const WntUniformContactInhibition& rModel)
   : AbstractSimpleCellCycleModel(rModel),
     mMinCellCycleDuration(rModel.mMinCellCycleDuration),
     mMaxCellCycleDuration(rModel.mMaxCellCycleDuration),
     mQuiescentVolumeFraction(rModel.mQuiescentVolumeFraction),
     mEquilibriumVolume(rModel.mEquilibriumVolume),
     mProliferativeRegion(rModel.mProliferativeRegion)
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

AbstractCellCycleModel* WntUniformContactInhibition::CreateCellCycleModel()
{
    return new WntUniformContactInhibition(*this);
}


bool WntUniformContactInhibition::ReadyToDivide()
{
    assert(mpCell != nullptr);


    if (!mReadyToDivide)
    {
        double cell_volume = mpCell->GetCellData()->GetItem("volume");

        //PRINT_VARIABLE(cell_volume)

        // For some reason I am unable to set the cell radius that the method GetItem("volume") returns
        // It always sets the radius as 0.5
        // Currently I have no work around, so we have to use 0.5

        // Cells don't carry their location, so have to introduce division cut off with a Wnt gradient

        double quiescent_volume = mEquilibriumVolume * mQuiescentVolumeFraction;
        // PRINT_VARIABLE(cell_volume)
        // PRINT_VARIABLE(GetAge())
        // 
        // PRINT_VARIABLE(mProliferativeRegion)
        if (GetAge() >= mCellCycleDuration && cell_volume > quiescent_volume && WntConcentration<2>::Instance()->GetWntLevel(mpCell) >= mProliferativeRegion)
        {
            // TRACE("Division happening here right now at this place")
            // PRINT_VARIABLE(WntConcentration<2>::Instance()->GetWntLevel(mpCell))          
            
            mReadyToDivide = true;
        }
    }
    return mReadyToDivide;
};

void WntUniformContactInhibition::SetQuiescentVolumeFraction(double quiescentVolumeFraction)
{
    mQuiescentVolumeFraction = quiescentVolumeFraction;
};

void WntUniformContactInhibition::SetEquilibriumVolume(double equilibriumVolume)
{
    mEquilibriumVolume = equilibriumVolume;
};

void WntUniformContactInhibition::SetProliferativeRegion(double proliferativeRegion)
{
    mProliferativeRegion = proliferativeRegion;
};


void WntUniformContactInhibition::SetCellCycleDuration()
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

double WntUniformContactInhibition::GetMinCellCycleDuration()
{
    return mMinCellCycleDuration;
}

void WntUniformContactInhibition::SetMinCellCycleDuration(double minCellCycleDuration)
{
    mMinCellCycleDuration = minCellCycleDuration;
}

double WntUniformContactInhibition::GetMaxCellCycleDuration()
{
    return mMaxCellCycleDuration;
}

void WntUniformContactInhibition::SetMaxCellCycleDuration(double maxCellCycleDuration)
{
    mMaxCellCycleDuration = maxCellCycleDuration;
}

double WntUniformContactInhibition::GetAverageTransitCellCycleTime()
{
    return 0.5*(mMinCellCycleDuration + mMaxCellCycleDuration);
}

double WntUniformContactInhibition::GetAverageStemCellCycleTime()
{
    return 0.5*(mMinCellCycleDuration + mMaxCellCycleDuration);
}

void WntUniformContactInhibition::OutputCellCycleModelParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<MinCellCycleDuration>" << mMinCellCycleDuration << "</MinCellCycleDuration>\n";
    *rParamsFile << "\t\t\t<MaxCellCycleDuration>" << mMaxCellCycleDuration << "</MaxCellCycleDuration>\n";

    // Call method on direct parent class
    AbstractSimpleCellCycleModel::OutputCellCycleModelParameters(rParamsFile);
}

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(WntUniformContactInhibition)
