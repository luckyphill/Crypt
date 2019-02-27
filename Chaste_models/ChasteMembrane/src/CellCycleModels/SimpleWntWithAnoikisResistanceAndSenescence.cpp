#include "SimpleWntWithAnoikisResistanceAndSenescence.hpp"
#include "CellLabel.hpp"
#include "RandomNumberGenerator.hpp"
#include "TransitCellProliferativeType.hpp"
#include "DifferentiatedCellProliferativeType.hpp"
#include "TransitCellAnoikisResistantMutationState.hpp"
#include "AnoikisCellTagged.hpp"
#include "WntConcentration.hpp"
#include "Debug.hpp"

SimpleWntWithAnoikisResistanceAndSenescence::SimpleWntWithAnoikisResistanceAndSenescence()
    : ContactInhibitionCellCycleModel(),
      mWntThreshold(0.5),
      mPopUpDivision(false)
{
}

SimpleWntWithAnoikisResistanceAndSenescence::SimpleWntWithAnoikisResistanceAndSenescence(const SimpleWntWithAnoikisResistanceAndSenescence& rModel)
   : ContactInhibitionCellCycleModel(rModel),
     mWntThreshold(rModel.mWntThreshold),
     mPopUpDivision(rModel.mPopUpDivision),
     mPoppedUpG1Duration(rModel.mPoppedUpG1Duration)
{
    /*
     * Set each member variable of the new cell-cycle model that inherits
     * its value from the parent.
     *
     * Note 1: some of the new cell-cycle model's member variables will already
     * have been correctly initialized in its constructor or parent classes.
     *
     * Note 2: one or more of the new cell-cycle model's member variables
     * may be set/overwritten as soon as InitialiseDaughterCell() is called on
     * the new cell-cycle model.
     *
     * Note 3: Only set the variables defined in this class. Variables defined
     * in parent classes will be defined there.
     *
     */
}

void SimpleWntWithAnoikisResistanceAndSenescence::Initialise()
{
    // A brand new cell created in a Test script will need to have it's parent set
    // The parent will be set properly for cells created in the simulation
    AbstractSimplePhaseBasedCellCycleModel::Initialise();
    assert(mpCell != NULL);
    mpCell->GetCellData()->SetItem("parent", mpCell->GetCellId());
}

void SimpleWntWithAnoikisResistanceAndSenescence::SetPopUpDivision(bool popUpDivision)
{
    mPopUpDivision = popUpDivision;
}

void SimpleWntWithAnoikisResistanceAndSenescence::SetPoppedUpG1Duration(double poppedUpG1Duration)
{
    mPoppedUpG1Duration = poppedUpG1Duration;
    mPopUpDivision = true;
    TRACE("Division while popped up can occur")
    PRINT_VARIABLE(mPoppedUpG1Duration)
}

void SimpleWntWithAnoikisResistanceAndSenescence::UpdateCellCyclePhase()
{
    double wnt_level= GetWntLevel();

    // Set the cell type to TransitCellProliferativeType if the Wnt stimulus exceeds wnt_division_threshold if not set it to Differentiated Type
    if (wnt_level >= GetWntThreshold())
    {
        boost::shared_ptr<AbstractCellProperty> p_transit_type =
            mpCell->rGetCellPropertyCollection().GetCellPropertyRegistry()->Get<TransitCellProliferativeType>();
        mpCell->SetCellProliferativeType(p_transit_type);
    }
    else
    {
        // The cell is set to have DifferentiatedCellProliferativeType and so in G0 phase
        boost::shared_ptr<AbstractCellProperty> p_diff_type =
            mpCell->rGetCellPropertyCollection().GetCellPropertyRegistry()->Get<DifferentiatedCellProliferativeType>();
        mpCell->SetCellProliferativeType(p_diff_type);
    }

    // If we do not allow pop-up division and the cell has AnoikisCellTagged
    if (!mPopUpDivision && mpCell->HasCellProperty<AnoikisCellTagged>())
    {
        // AND if it is Resistant to anoikis and it is not already dividing
        if (mpCell->GetMutationState()->IsType<TransitCellAnoikisResistantMutationState>() && mCurrentCellCyclePhase != M_PHASE)
        {
            // Then set it to differentiated cell type to stop further division
            // It may not be necessary to check. if it's in M phase, but better to do so
            // in case future iterations of cell division are checking for proliferative state
            // to control the spring length
            boost::shared_ptr<AbstractCellProperty> p_diff_type =
                mpCell->rGetCellPropertyCollection().GetCellPropertyRegistry()->Get<DifferentiatedCellProliferativeType>();
            mpCell->SetCellProliferativeType(p_diff_type);
        }
    } 
    else if (mpCell->HasCellProperty<AnoikisCellTagged>())
    {
        SetG1Duration();
    }

    ContactInhibitionCellCycleModel::UpdateCellCyclePhase();
}

void SimpleWntWithAnoikisResistanceAndSenescence::SetG1Duration()
{
    assert(mpCell != NULL);

    RandomNumberGenerator* p_gen = RandomNumberGenerator::Instance();
    if (mPopUpDivision && mpCell->HasCellProperty<AnoikisCellTagged>())
    {
        mG1Duration = p_gen->NormalRandomDeviate(mPoppedUpG1Duration, 2.0);
    }
    else if (mpCell->GetCellProliferativeType()->IsType<TransitCellProliferativeType>())
    {
        mG1Duration = p_gen->NormalRandomDeviate(GetTransitCellG1Duration(), 2.0);
    }
    else if (mpCell->GetCellProliferativeType()->IsType<DifferentiatedCellProliferativeType>())
    {
        mG1Duration = DBL_MAX;
    }
    else
    {
        NEVER_REACHED;
    }

    // Check that the normal random deviate has not returned a small or negative G1 duration
    if (mG1Duration < mMinimumGapDuration)
    {
        mG1Duration = mMinimumGapDuration;
    }
}

double SimpleWntWithAnoikisResistanceAndSenescence::GetWntLevel()
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

AbstractCellCycleModel* SimpleWntWithAnoikisResistanceAndSenescence::CreateCellCycleModel()
{
    // Create a new cell-cycle model
    return new SimpleWntWithAnoikisResistanceAndSenescence(*this);
}


void SimpleWntWithAnoikisResistanceAndSenescence::ResetForDivision()
{
    AbstractPhaseBasedCellCycleModel::ResetForDivision();
    // Used for making sure newly divided cells are handeled properly in the force calculator
    mpCell->GetCellData()->SetItem("parent", mpCell->GetCellId());
}


void SimpleWntWithAnoikisResistanceAndSenescence::SetWntThreshold(double wntThreshold)
{
    mWntThreshold = wntThreshold;
}

double SimpleWntWithAnoikisResistanceAndSenescence::GetWntThreshold()
{
    return mWntThreshold;
}

void SimpleWntWithAnoikisResistanceAndSenescence::OutputCellCycleModelParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<WntThreshold>" << mWntThreshold << "</WntThreshold>\n";

    // Call method on direct parent class
    ContactInhibitionCellCycleModel::OutputCellCycleModelParameters(rParamsFile);
}

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(SimpleWntWithAnoikisResistanceAndSenescence)
