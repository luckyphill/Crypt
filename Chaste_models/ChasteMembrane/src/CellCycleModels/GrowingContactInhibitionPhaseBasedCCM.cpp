/*

Copyright (c) 2005-2017, University of Oxford.
All rights reserved.

University of Oxford means the Chancellor, Masters and Scholars of the
University of Oxford, having an administrative office at Wellington
Square, Oxford OX1 2JD, UK.

This file is part of Chaste.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of the University of Oxford nor the names of its
   contributors may be used to endorse or promote products derived from this
   software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

#include "GrowingContactInhibitionPhaseBasedCCM.hpp"
#include "CellLabel.hpp"
#include "DifferentiatedCellProliferativeType.hpp"
#include "CellCyclePhases.hpp"
#include "SmartPointers.hpp"

#include "Debug.hpp"

GrowingContactInhibitionPhaseBasedCCM::GrowingContactInhibitionPhaseBasedCCM()
    : AbstractSimplePhaseBasedCellCycleModel(),
      mQuiescentVolumeFraction(0),
      mEquilibriumVolume(1),
      mCurrentQuiescentOnsetTime(SimulationTime::Instance()->GetTime()),
      mGrowthOnsetTime(0.0),
      mGrowthDuration(0.0),
      mDivisionOnsetTime(0.0),
      mDivisionDuration(0.0),
      mNewlyDividedRadius(0.625),     
      mPreferredRadius(0.75), // The updated radius of the cell given its process through the cycle
      mReferencePreferredRadius(0.75), // The natural radius that it sticks at during G1
      mInteractionRadius(1.125), // Distance from the cell centre, updated according to process through cycle
      mInteractionWidth(0.5),
      mUsingWnt(false),
      mG1LongDuration(0.0),
      mG1ShortDuration(0.0),
      mNicheLimitConcentration(0.0),
      mTransientLimitConcentration(0.0)
{
}

GrowingContactInhibitionPhaseBasedCCM::GrowingContactInhibitionPhaseBasedCCM(const GrowingContactInhibitionPhaseBasedCCM& rModel)
    : AbstractSimplePhaseBasedCellCycleModel(rModel),
      mQuiescentVolumeFraction(rModel.mQuiescentVolumeFraction),
      mEquilibriumVolume(rModel.mEquilibriumVolume),
      mCurrentQuiescentOnsetTime(rModel.mCurrentQuiescentOnsetTime),
      mCurrentQuiescentDuration(rModel.mCurrentQuiescentDuration),
      mGrowthOnsetTime(0.0),
      mGrowthDuration(0.0),
      mDivisionOnsetTime(0.0),
      mDivisionDuration(0.0),
      mNewlyDividedRadius(rModel.mNewlyDividedRadius),     
      mPreferredRadius(rModel.mNewlyDividedRadius), // The updated radius of the cell given its process through the cycle
      mReferencePreferredRadius(rModel.mReferencePreferredRadius), // The natural radius that it sticks at during G1
      mInteractionRadius(rModel.mNewlyDividedRadius + rModel.mInteractionWidth), // Distance from the cell centre, updated according to process through cycle
      mInteractionWidth(rModel.mInteractionWidth),
      mUsingWnt(rModel.mUsingWnt),
      mG1LongDuration(rModel.mG1LongDuration),
      mG1ShortDuration(rModel.mG1ShortDuration),
      mNicheLimitConcentration(rModel.mNicheLimitConcentration),
      mTransientLimitConcentration(rModel.mTransientLimitConcentration)
{

}

void GrowingContactInhibitionPhaseBasedCCM::UpdateCellCyclePhase()
{
    if ((mQuiescentVolumeFraction == DOUBLE_UNSET) || (mEquilibriumVolume == DOUBLE_UNSET))
    {
        EXCEPTION("The member variables mQuiescentVolumeFraction and mEquilibriumVolume have not yet been set.");
    }

    // Get cell volume
    double cell_volume = mpCell->GetCellData()->GetItem("volume");
    //PRINT_VARIABLE(cell_volume)

    // Removes the cell label
    mpCell->RemoveCellProperty<CellLabel>();

    if (mCurrentCellCyclePhase == G_ONE_PHASE)
    {
        // Update G1 duration based on cell volume
        // double dt = SimulationTime::Instance()->GetTimeStep();
        double quiescent_volume = mEquilibriumVolume * mQuiescentVolumeFraction;

        if (cell_volume < quiescent_volume)
        {
            // Update the duration of the current period of contact inhibition.
            mCurrentQuiescentDuration = SimulationTime::Instance()->GetTime() - mCurrentQuiescentOnsetTime;
            mG1Duration += mG1ShortDuration * (1 + 0.2 * RandomNumberGenerator::Instance()->ranf() - 0.4); // +/- 20% wiggle

            /*
             * This method is usually called within a CellBasedSimulation, after the CellPopulation
             * has called CellPropertyRegistry::TakeOwnership(). This means that were we to call
             * CellPropertyRegistry::Instance() here when adding the CellLabel, we would be creating
             * a new CellPropertyRegistry. In this case the CellLabel's cell count would be incorrect.
             * We must therefore access the CellLabel via the cell's CellPropertyCollection.
             */
            boost::shared_ptr<AbstractCellProperty> p_label =
            mpCell->rGetCellPropertyCollection().GetCellPropertyRegistry()->Get<CellLabel>();
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

    if (mpCell->GetCellProliferativeType()->IsType<DifferentiatedCellProliferativeType>())
    {
        mCurrentCellCyclePhase = G_ZERO_PHASE;
        //TRACE("G0_PHASE")
    }
    else if (time_since_birth < GetMDuration())
    {
        mCurrentCellCyclePhase = M_PHASE;
        // TRACE("M_PHASE")
        // PRINT_VARIABLE(SimulationTime::Instance()->GetTime())
    }
    else if (time_since_birth < GetMDuration() + mG1Duration)
    {
        mCurrentCellCyclePhase = G_ONE_PHASE;
        // TRACE("G_ONE_PHASE")
        // PRINT_VARIABLE(SimulationTime::Instance()->GetTime())
    }
    else if (time_since_birth < GetMDuration() + mG1Duration + GetSDuration())
    {
        if (mCurrentCellCyclePhase == G_ONE_PHASE)
        {
            mGrowthOnsetTime = SimulationTime::Instance()->GetTime();
            mGrowthDuration = 0.0;
        }
        mCurrentCellCyclePhase = S_PHASE;
        mGrowthDuration = SimulationTime::Instance()->GetTime() - mGrowthOnsetTime;
        // TRACE("S_PHASE")
        // PRINT_VARIABLE(SimulationTime::Instance()->GetTime())
    }
    else if (time_since_birth < GetMDuration() + mG1Duration + GetSDuration() + GetG2Duration())
    {
        mCurrentCellCyclePhase = G_TWO_PHASE;
        mGrowthDuration = SimulationTime::Instance()->GetTime() - mGrowthOnsetTime;
        // TRACE("G_TWO_PHASE")
        // PRINT_VARIABLE(SimulationTime::Instance()->GetTime())
    }

    CalculatePreferredRadius();
    
    
}


void GrowingContactInhibitionPhaseBasedCCM::CalculatePreferredRadius()
{
    if (mCurrentCellCyclePhase == M_PHASE)
    {
        // Linear growth
        mPreferredRadius =  mNewlyDividedRadius + (mReferencePreferredRadius - mNewlyDividedRadius)*  (mpCell->GetAge()/mMDuration);
        //TRACE("New growth")
    }
    else if (mCurrentCellCyclePhase == S_PHASE || mCurrentCellCyclePhase == G_TWO_PHASE)
    {
        // Want 1.5 * area at the end of G2 phase, assuming area grows at a constant rate, so non-linear growth of the radius
        mPreferredRadius =  mReferencePreferredRadius * sqrt( mGrowthDuration / (2*(mSDuration + mG2Duration)) + 1);
        //TRACE("Fattening")
    }
    else
    {
        // Defaults to Reference for G1 and G0
        mPreferredRadius = mReferencePreferredRadius;
        //TRACE("Default")
    }

    mInteractionRadius = mPreferredRadius + mInteractionWidth;
    //PRINT_VARIABLE(mPreferredRadius)
}


void GrowingContactInhibitionPhaseBasedCCM::SetG1Duration()
{
  mG1Duration = mTransitCellG1Duration * (1 + 0.2 * RandomNumberGenerator::Instance()->ranf() -0.4); // %20 wiggle
}

CellCyclePhase GrowingContactInhibitionPhaseBasedCCM::GetCellPhase()
{
  return mCurrentCellCyclePhase;
}


AbstractCellCycleModel* GrowingContactInhibitionPhaseBasedCCM::CreateCellCycleModel()
{
    return new GrowingContactInhibitionPhaseBasedCCM(*this);
}

void GrowingContactInhibitionPhaseBasedCCM::SetQuiescentVolumeFraction(double quiescentVolumeFraction)
{
    mQuiescentVolumeFraction = quiescentVolumeFraction;
}

double GrowingContactInhibitionPhaseBasedCCM::GetQuiescentVolumeFraction() const
{
    return mQuiescentVolumeFraction;
}

void GrowingContactInhibitionPhaseBasedCCM::SetEquilibriumVolume(double equilibriumVolume)
{
    mEquilibriumVolume = equilibriumVolume;
}

double GrowingContactInhibitionPhaseBasedCCM::GetEquilibriumVolume() const
{
    return mEquilibriumVolume;
}

double GrowingContactInhibitionPhaseBasedCCM::GetCurrentQuiescentDuration() const
{
    return mCurrentQuiescentDuration;
}

double GrowingContactInhibitionPhaseBasedCCM::GetCurrentQuiescentOnsetTime() const
{
    return mCurrentQuiescentOnsetTime;
}

// Growth duration details
// i.e. how much time in the S and G2 phases
double GrowingContactInhibitionPhaseBasedCCM::GetGrowthDuration() const
{
    return mGrowthDuration;
}

double GrowingContactInhibitionPhaseBasedCCM::GetGrowthOnsetTime() const
{
    return mGrowthOnsetTime;
}

double GrowingContactInhibitionPhaseBasedCCM::GetDivisionDuration() const
{
    return mMDuration;
}


double GrowingContactInhibitionPhaseBasedCCM::GetPreferredRadius() const
{
    return mPreferredRadius;
}


double GrowingContactInhibitionPhaseBasedCCM::GetInteractionRadius() const
{
    return mInteractionRadius;
}

void GrowingContactInhibitionPhaseBasedCCM::SetNewlyDividedRadius(double newlyDividedRadius)
{
    mNewlyDividedRadius = newlyDividedRadius;
}

void GrowingContactInhibitionPhaseBasedCCM::SetPreferredRadius(double preferedRadius)
{
    mPreferredRadius = preferedRadius;
    mReferencePreferredRadius = preferedRadius;
}

void GrowingContactInhibitionPhaseBasedCCM::SetInteractionRadius(double interactionRadius)
{
    mInteractionRadius = interactionRadius;
    assert(mPreferredRadius != DOUBLE_UNSET);
    mInteractionWidth = interactionRadius - mPreferredRadius;
}


void GrowingContactInhibitionPhaseBasedCCM::SetG1LongDuration(double g1LongDuration)
{
    mG1LongDuration = g1LongDuration;
}

void GrowingContactInhibitionPhaseBasedCCM::SetG1ShortDuration(double g1ShortDuration)
{
    mG1ShortDuration = g1ShortDuration;
}

void GrowingContactInhibitionPhaseBasedCCM::SetNicheLimitConcentration(double nicheLimitConcentration)
{
    mNicheLimitConcentration = nicheLimitConcentration;
}

void GrowingContactInhibitionPhaseBasedCCM::SetTransientLimitConcentration(double transientLimitConcentration)
{
    mTransientLimitConcentration = transientLimitConcentration;
}

void GrowingContactInhibitionPhaseBasedCCM::SetUsingWnt(bool usingWnt)
{
    mUsingWnt = usingWnt;
}


void GrowingContactInhibitionPhaseBasedCCM::OutputCellCycleModelParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<QuiescentVolumeFraction>" << mQuiescentVolumeFraction << "</QuiescentVolumeFraction>\n";
    *rParamsFile << "\t\t\t<EquilibriumVolume>" << mEquilibriumVolume << "</EquilibriumVolume>\n";

    // Call method on direct parent class
    AbstractSimplePhaseBasedCellCycleModel::OutputCellCycleModelParameters(rParamsFile);
}

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(GrowingContactInhibitionPhaseBasedCCM)
