/*
 * LAST MODIFIED: 1/3/2018
 * Sloughing cell killer removes epithelial cells that have reached the top of the crypt
 */

#include "SimpleSloughingCellKiller.hpp"
#include "AbstractCellKiller.hpp"
#include "AbstractCellProperty.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "NodeBasedCellPopulation.hpp"
#include "MembraneType.hpp"

template<unsigned SPACE_DIM>
SimpleSloughingCellKiller<SPACE_DIM>::SimpleSloughingCellKiller(AbstractCellPopulation<SPACE_DIM>* pCellPopulation)
    : AbstractCellKiller<SPACE_DIM>(pCellPopulation),
    mCryptTop(10.0)
{
    // Sets up output file
//	OutputFileHandler output_file_handler(mOutputDirectory + "SloughingData/", false);
//	mSloughingOutputFile = output_file_handler.OpenOutputFile("results.anoikis");
}

template<unsigned SPACE_DIM>
SimpleSloughingCellKiller<SPACE_DIM>::~SimpleSloughingCellKiller()
{
//    mSloughingOutputFile->close();
}


template<unsigned SPACE_DIM>
void SimpleSloughingCellKiller<SPACE_DIM>::SetCryptTop(double cryptTop)
{
	mCryptTop = cryptTop;
}

/*
 * Cell Killer that kills healthy cells that pop outwards and become detached from
 * the labelled tissue cells, i.e. removal by anoikis
 *
 * Also will remove differentiated cells at the orifice if mSloughOrifice is true
 */
template<unsigned SPACE_DIM>
void SimpleSloughingCellKiller<SPACE_DIM>::CheckAndLabelCellsForApoptosisOrDeath()
{
	if (dynamic_cast<NodeBasedCellPopulation<SPACE_DIM>*>(this->mpCellPopulation))
	{
		NodeBasedCellPopulation<SPACE_DIM>* p_tissue = static_cast<NodeBasedCellPopulation<SPACE_DIM>*> (this->mpCellPopulation);

		for (typename AbstractCellPopulation<SPACE_DIM>::Iterator cell_iter = p_tissue->Begin();
    			cell_iter != p_tissue->End();
    			++cell_iter)
    	{
    		unsigned node_index = this->mpCellPopulation->GetLocationIndexUsingCell(*cell_iter);
    		if (!cell_iter->GetCellProliferativeType()->template IsType<MembraneType>())
    		{
    			Node<SPACE_DIM>* p_node = this->mpCellPopulation->GetNode(node_index);
                double x = p_node->rGetLocation()[0];
            	double y = p_node->rGetLocation()[1];
            	if (y > mCryptTop && !cell_iter->IsDead())
            	{
            		cell_iter->Kill();
                    mCellKillCount += 1;//Increment the cell kill count by one for each cell killed
            	}
                // Should replace 1.1 with a variable extracted from the anoikis cell killer class, but I've nevver changed it
                if (y > mCryptTop - 1.0 && x > 1.1 && !cell_iter->IsDead()) 
                {
                    cell_iter->Kill();
                    mCellKillCount += 1;//Increment the cell kill count by one for each cell killed
                }
    		}
    	}
    }
}

template<unsigned SPACE_DIM>
unsigned SimpleSloughingCellKiller<SPACE_DIM>::GetCellKillCount()
{
    return mCellKillCount;
}

template<unsigned SPACE_DIM>
void SimpleSloughingCellKiller<SPACE_DIM>::OutputCellKillerParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<CellsRemovedBySloughing>" << 1 << "</CellsRemovedBySloughing> \n";

    // Call direct parent class
    AbstractCellKiller<SPACE_DIM>::OutputCellKillerParameters(rParamsFile);
}

template class SimpleSloughingCellKiller<1>;
template class SimpleSloughingCellKiller<2>;
template class SimpleSloughingCellKiller<3>;



#include "SerializationExportWrapperForCpp.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(SimpleSloughingCellKiller)
