#include "SimpleWntContactInhibitionCellCycleModel.hpp"
#include "CellLabel.hpp"
#include "RandomNumberGenerator.hpp"
#include "TransitCellProliferativeType.hpp"
#include "DifferentiatedCellProliferativeType.hpp"
#include "WntConcentration.hpp"

SimpleWntContactInhibitionCellCycleModel::SimpleWntContactInhibitionCellCycleModel()
    : ContactInhibitionCellCycleModel(),
      mWntThreshold(0.5)
{
}

SimpleWntContactInhibitionCellCycleModel::SimpleWntContactInhibitionCellCycleModel(const SimpleWntContactInhibitionCellCycleModel& rModel)
   : ContactInhibitionCellCycleModel(rModel),
     mWntThreshold(rModel.mWntThreshold)
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

void SimpleWntContactInhibitionCellCycleModel::UpdateCellCyclePhase()
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

    ContactInhibitionCellCycleModel::UpdateCellCyclePhase();
}

void SimpleWntContactInhibitionCellCycleModel::SetG1Duration()
{
    assert(mpCell != NULL);

    RandomNumberGenerator* p_gen = RandomNumberGenerator::Instance();

    if (mpCell->GetCellProliferativeType()->IsType<TransitCellProliferativeType>())
    {
        mG1Duration = p_gen->NormalRandomDeviate(GetTransitCellG1Duration(), 1.0);
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

double SimpleWntContactInhibitionCellCycleModel::GetWntLevel()
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

AbstractCellCycleModel* SimpleWntContactInhibitionCellCycleModel::CreateCellCycleModel()
{
    // Create a new cell-cycle model
    return new SimpleWntContactInhibitionCellCycleModel(*this);
}

void SimpleWntContactInhibitionCellCycleModel::SetWntThreshold(double wntThreshold)
{
    mWntThreshold = wntThreshold;
}

double SimpleWntContactInhibitionCellCycleModel::GetWntThreshold()
{
    return mWntThreshold;
}

void SimpleWntContactInhibitionCellCycleModel::OutputCellCycleModelParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<WntThreshold>" << mWntThreshold << "</WntThreshold>\n";

    // Call method on direct parent class
    ContactInhibitionCellCycleModel::OutputCellCycleModelParameters(rParamsFile);
}

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(SimpleWntContactInhibitionCellCycleModel)
