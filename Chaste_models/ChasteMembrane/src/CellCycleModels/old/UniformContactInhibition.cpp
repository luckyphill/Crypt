#include "UniformContactInhibition.hpp"
#include "DifferentiatedCellProliferativeType.hpp"
#include "CellLabel.hpp"
#include "Debug.hpp"

UniformContactInhibition::UniformContactInhibition()
    : AbstractSimpleCellCycleModel(),
      mMinCellCycleDuration(12.0), // Hours
      mMaxCellCycleDuration(14.0)  // Hours
{
}

UniformContactInhibition::UniformContactInhibition(const UniformContactInhibition& rModel)
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

AbstractCellCycleModel* UniformContactInhibition::CreateCellCycleModel()
{
    return new UniformContactInhibition(*this);
}


bool UniformContactInhibition::ReadyToDivide()
{
    assert(mpCell != nullptr);


    if (!mReadyToDivide)
    {
        double cell_volume = mpCell->GetCellData()->GetItem("volume");

        //PRINT_VARIABLE(cell_volume)

        // For some reason I am unable to set the cell radius that the method GetItem("volume") returns
        // It always sets the radius as 0.5
        // Currently I have no work around, so we have to use 0.5

        double quiescent_volume = mEquilibriumVolume * mQuiescentVolumeFraction;
        
        if (GetAge() >= mCellCycleDuration && cell_volume > quiescent_volume)
        {
            mReadyToDivide = true;
        }
    }
    return mReadyToDivide;
};

void UniformContactInhibition::SetQuiescentVolumeFraction(double quiescentVolumeFraction)
{
    mQuiescentVolumeFraction = quiescentVolumeFraction;
};

void UniformContactInhibition::SetEquilibriumVolume(double equilibriumVolume)
{
    mEquilibriumVolume = equilibriumVolume;
};

void UniformContactInhibition::SetProliferativeRegion(double proliferativeRegion)
{
    mProliferativeRegion = proliferativeRegion;
};


void UniformContactInhibition::SetCellCycleDuration()
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

double UniformContactInhibition::GetMinCellCycleDuration()
{
    return mMinCellCycleDuration;
}

void UniformContactInhibition::SetMinCellCycleDuration(double minCellCycleDuration)
{
    mMinCellCycleDuration = minCellCycleDuration;
}

double UniformContactInhibition::GetMaxCellCycleDuration()
{
    return mMaxCellCycleDuration;
}

void UniformContactInhibition::SetMaxCellCycleDuration(double maxCellCycleDuration)
{
    mMaxCellCycleDuration = maxCellCycleDuration;
}

double UniformContactInhibition::GetAverageTransitCellCycleTime()
{
    return 0.5*(mMinCellCycleDuration + mMaxCellCycleDuration);
}

double UniformContactInhibition::GetAverageStemCellCycleTime()
{
    return 0.5*(mMinCellCycleDuration + mMaxCellCycleDuration);
}

void UniformContactInhibition::OutputCellCycleModelParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<MinCellCycleDuration>" << mMinCellCycleDuration << "</MinCellCycleDuration>\n";
    *rParamsFile << "\t\t\t<MaxCellCycleDuration>" << mMaxCellCycleDuration << "</MaxCellCycleDuration>\n";

    // Call method on direct parent class
    AbstractSimpleCellCycleModel::OutputCellCycleModelParameters(rParamsFile);
}

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(UniformContactInhibition)
