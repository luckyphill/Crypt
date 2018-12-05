/*

Written by Phill

*/
#include "WntConcentrationXSection.hpp"

/** Pointer to the single instance */
template<unsigned DIM>
WntConcentrationXSection<DIM>* WntConcentrationXSection<DIM>::mpInstance = nullptr;

template<unsigned DIM>
WntConcentrationXSection<DIM>* WntConcentrationXSection<DIM>::Instance()
{
    if (mpInstance == nullptr)
    {
        mpInstance = new WntConcentrationXSection;
    }
    return mpInstance;
}

template<unsigned DIM>
WntConcentrationXSection<DIM>::WntConcentrationXSection()
    : mCryptLength(DOUBLE_UNSET),
      mCryptStart(DOUBLE_UNSET),
      mWntThreshold(DOUBLE_UNSET),
      mLengthSet(false),
      mStartSet(false),
      mThresholdSet(false),
      mWntType(NONE),
      mpCellPopulation(nullptr),
      mTypeSet(false),
      mConstantWntValueForTesting(0),
      mUseConstantWntValueForTesting(false),
      mWntConcentrationXSectionParameter(DOUBLE_UNSET)
{
    // Make sure there's only one instance - enforces correct serialization
    assert(mpInstance == nullptr);
}

template<unsigned DIM>
WntConcentrationXSection<DIM>::~WntConcentrationXSection()
{
}

template<unsigned DIM>
void WntConcentrationXSection<DIM>::Destroy()
{
    if (mpInstance)
    {
        delete mpInstance;
        mpInstance = nullptr;
    }
}

template<unsigned DIM>
double WntConcentrationXSection<DIM>::GetWntLevel(CellPtr pCell)
{
    if (mUseConstantWntValueForTesting)  // to test a cell and cell-cycle models without a cell population
    {
        return mConstantWntValueForTesting;
    }

    assert(mpCellPopulation!=nullptr);
    assert(mTypeSet);
    assert(mLengthSet);

    double height;
    height = mpCellPopulation->GetLocationOfCellCentre(pCell)[DIM-1];

    return GetWntLevel(height);
}

template<unsigned DIM>
void WntConcentrationXSection<DIM>::SetCellPopulation(AbstractCellPopulation<DIM>& rCellPopulation)
{
    mpCellPopulation = &rCellPopulation;
}

template<unsigned DIM>
AbstractCellPopulation<DIM>& WntConcentrationXSection<DIM>::rGetCellPopulation()
{
    return *mpCellPopulation;
}

template<unsigned DIM>
double WntConcentrationXSection<DIM>::GetCryptLength()
{
    return mCryptLength;
}

template<unsigned DIM>
void WntConcentrationXSection<DIM>::SetCryptLength(double cryptLength)
{
    assert(cryptLength > 0.0);
    if (mLengthSet==true)
    {
        EXCEPTION("Destroy has not been called");
    }

    mCryptLength = cryptLength;
    mLengthSet = true;
}


template<unsigned DIM>
double WntConcentrationXSection<DIM>::GetCryptStart()
{
    return mCryptStart;
}

template<unsigned DIM>
void WntConcentrationXSection<DIM>::SetCryptStart(double cryptStart)
{
    assert(cryptStart >= 0.0);
    if (mStartSet==true)
    {
        EXCEPTION("Destroy has not been called");
    }

    mCryptStart = cryptStart;
    mStartSet = true;
}


template<unsigned DIM>
double WntConcentrationXSection<DIM>::GetWntThreshold()
{
    return mWntThreshold;
}

template<unsigned DIM>
void WntConcentrationXSection<DIM>::SetWntThreshold(double wntThreshold)
{
    assert(wntThreshold > 0.0);
    if (mThresholdSet==true)
    {
        EXCEPTION("Destroy has not been called");
    }

    mWntThreshold = wntThreshold;
    mThresholdSet = true;
}



template<unsigned DIM>
WntConcentrationXSectionType WntConcentrationXSection<DIM>::GetType()
{
    return mWntType;
}

template<unsigned DIM>
void WntConcentrationXSection<DIM>::SetType(WntConcentrationXSectionType type)
{
    if (mTypeSet==true)
    {
        EXCEPTION("Destroy has not been called");
    }
    mWntType = type;
    mTypeSet = true;
}

template<unsigned DIM>
double WntConcentrationXSection<DIM>::GetWntLevel(double height)
{
    if (mWntType == NONE)
    {
        return 0.0;
    }

    // Need to call SetCryptLength first
    assert(mLengthSet);

    double wnt_level = -1.0; // Test this is changed before leaving method.

    // The first type of Wnt concentration to try
    if (mWntType==LINEAR)
    {
        wnt_level = 1 - (height - GetCryptStart())/mWntConcentrationXSectionParameter;
    }

    if (mWntType==EXPONENTIAL)
    {
        if (height < GetCryptLength() + GetCryptStart())
        {
            wnt_level = exp(-(height - GetCryptStart())/(GetCryptLength()*mWntConcentrationXSectionParameter));
        }
        else
        {
            wnt_level = 0.0;
        }
    }

    assert(wnt_level >= 0.0);

    return wnt_level;
}

template<unsigned DIM>
bool WntConcentrationXSection<DIM>::IsWntSetUp()
{
    bool result = false;
    if (mTypeSet && mLengthSet && mStartSet && mThresholdSet && mpCellPopulation!=nullptr && mWntType!=NONE)
    {
        result = true;
    }
    return result;
}

template<unsigned DIM>
void WntConcentrationXSection<DIM>::SetConstantWntValueForTesting(double value)
{
    if (value < 0)
    {
        EXCEPTION("WntConcentrationXSection<DIM>::SetConstantWntValueForTesting - Wnt value for testing should be non-negative.\n");
    }
    mConstantWntValueForTesting = value;
    mUseConstantWntValueForTesting = true;
    if (!mTypeSet)
    {
        mWntType = NONE;
    }
}

template<unsigned DIM>
double WntConcentrationXSection<DIM>::GetWntConcentrationXSectionParameter()
{
    return mWntConcentrationXSectionParameter;
}

template<unsigned DIM>
void WntConcentrationXSection<DIM>::SetWntConcentrationXSectionParameter(double wntConcentrationXSectionParameter)
{
    assert(wntConcentrationXSectionParameter > 0.0);
    mWntConcentrationXSectionParameter = wntConcentrationXSectionParameter;
}


// Explicit instantiation
template class WntConcentrationXSection<1>;
template class WntConcentrationXSection<2>;
template class WntConcentrationXSection<3>;
