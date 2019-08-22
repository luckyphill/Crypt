/*
 * MADE TO HELP THE CONTACT INHIBITION 1D TEST WORK PROPERLY IN THE EXTREME CASES
 */

#include "TopAndBottomSloughing.hpp"
#include "AbstractCellKiller.hpp"
#include "AbstractCellProperty.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "NodeBasedCellPopulation.hpp"
#include "PanethCellMutationState.hpp"
//#include "TransitCellSloughingResistantMutationState.hpp"
#include "MembraneCellProliferativeType.hpp"

TopAndBottomSloughing::TopAndBottomSloughing(AbstractCellPopulation<2>* pCellPopulation)
    : AbstractCellKiller<2>(pCellPopulation),
    mCryptTop(10.0)
{
    // Sets up output file
//	OutputFileHandler output_file_handler(mOutputDirectory + "SloughingData/", false);
//	mSloughingOutputFile = output_file_handler.OpenOutputFile("results.anoikis");
}

TopAndBottomSloughing::~TopAndBottomSloughing()
{
//    mSloughingOutputFile->close();
}



void TopAndBottomSloughing::SetCryptTop(double cryptTop)
{
	mCryptTop = cryptTop;
}

/*
 * Cell Killer that kills healthy cells that pop outwards and become detached from
 * the labelled tissue cells, i.e. removal by anoikis
 *
 * Also will remove differentiated cells at the orifice if mSloughOrifice is true
 */
void TopAndBottomSloughing::CheckAndLabelCellsForApoptosisOrDeath()
{
	if (dynamic_cast<MeshBasedCellPopulation<2>*>(this->mpCellPopulation))
	{
		MeshBasedCellPopulation<2>* p_tissue = static_cast<MeshBasedCellPopulation<2>*> (this->mpCellPopulation);

		for (AbstractCellPopulation<2>::Iterator cell_iter = p_tissue->Begin();
    			cell_iter != p_tissue->End();
    			++cell_iter)
    	{
    		unsigned node_index = this->mpCellPopulation->GetLocationIndexUsingCell(*cell_iter);
    		if (!cell_iter->GetCellProliferativeType()->IsType<MembraneCellProliferativeType>())
    		{
    			Node<2>* p_node = this->mpCellPopulation->GetNode(node_index);
            	double y = p_node->rGetLocation()[1];
            	if ((y > mCryptTop || y < 0) && !cell_iter->IsDead())
            	{
            		cell_iter->Kill();
            	}
    		}
    	}
	}
	else if (dynamic_cast<NodeBasedCellPopulation<2>*>(this->mpCellPopulation))
	{
		NodeBasedCellPopulation<2>* p_tissue = static_cast<NodeBasedCellPopulation<2>*> (this->mpCellPopulation);

		for (AbstractCellPopulation<2>::Iterator cell_iter = p_tissue->Begin();
    			cell_iter != p_tissue->End();
    			++cell_iter)
    	{
    		unsigned node_index = this->mpCellPopulation->GetLocationIndexUsingCell(*cell_iter);
    		if (!cell_iter->GetCellProliferativeType()->IsType<MembraneCellProliferativeType>())
    		{
    			Node<2>* p_node = this->mpCellPopulation->GetNode(node_index);
            	double y = p_node->rGetLocation()[1];
            	if ((y > mCryptTop || y < 0) && !cell_iter->IsDead())
            	{
            		cell_iter->Kill();
            	}
    		}
    	}
    }
}


void TopAndBottomSloughing::OutputCellKillerParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<CellsRemovedBySloughing>" << 1 << "</CellsRemovedBySloughing> \n";

    // Call direct parent class
    AbstractCellKiller<2>::OutputCellKillerParameters(rParamsFile);
}




#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(TopAndBottomSloughing)
