

#include "SloughingCellKillerNewPhaseModel.hpp"
#include "AbstractCellKiller.hpp"
#include "AbstractCellProperty.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "NodeBasedCellPopulation.hpp"
#include "PanethCellMutationState.hpp"
//#include "TransitCellSloughingResistantMutationState.hpp"
#include "MembraneCellProliferativeType.hpp"
#include "SimplifiedPhaseBasedCellCycleModel.hpp"
#include "SimplifiedCellCyclePhases.hpp"
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
SloughingCellKillerNewPhaseModel<ELEMENT_DIM,SPACE_DIM>::SloughingCellKillerNewPhaseModel(AbstractCellPopulation<SPACE_DIM>* pCellPopulation)
    : AbstractCellKiller<SPACE_DIM>(pCellPopulation),
    mCryptTop(10.0)
{
    // Sets up output file
//	OutputFileHandler output_file_handler(mOutputDirectory + "SloughingData/", false);
//	mSloughingOutputFile = output_file_handler.OpenOutputFile("results.anoikis");
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
SloughingCellKillerNewPhaseModel<ELEMENT_DIM,SPACE_DIM>::~SloughingCellKillerNewPhaseModel()
{
//    mSloughingOutputFile->close();
}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void SloughingCellKillerNewPhaseModel<ELEMENT_DIM,SPACE_DIM>::SetCryptTop(double cryptTop)
{
	mCryptTop = cryptTop;
}

/*
 * Cell Killer that kills healthy cells that pop outwards and become detached from
 * the labelled tissue cells, i.e. removal by anoikis
 *
 * Also will remove differentiated cells at the orifice if mSloughOrifice is true
 */
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void SloughingCellKillerNewPhaseModel<ELEMENT_DIM,SPACE_DIM>::CheckAndLabelCellsForApoptosisOrDeath()
{
	if (dynamic_cast<MeshBasedCellPopulation<SPACE_DIM>*>(this->mpCellPopulation))
	{
		MeshBasedCellPopulation<SPACE_DIM>* p_tissue = static_cast<MeshBasedCellPopulation<SPACE_DIM>*> (this->mpCellPopulation);

		for (typename AbstractCellPopulation<SPACE_DIM>::Iterator cell_iter = p_tissue->Begin();
    			cell_iter != p_tissue->End();
    			++cell_iter)
    	{
    		unsigned node_index = this->mpCellPopulation->GetLocationIndexUsingCell(*cell_iter);
    		if (!cell_iter->GetCellProliferativeType()->template IsType<MembraneCellProliferativeType>())
    		{
    			Node<SPACE_DIM>* p_node = this->mpCellPopulation->GetNode(node_index);
            	double y = p_node->rGetLocation()[1];
            	if (y > mCryptTop && !cell_iter->IsDead())
            	{
                    SimplifiedPhaseBasedCellCycleModel* p_ccm = static_cast<SimplifiedPhaseBasedCellCycleModel*>(cell_iter->GetCellCycleModel());
                    SimplifiedCellCyclePhase p_phase = p_ccm->GetCurrentCellCyclePhase();
                    cell_iter->Kill();

                    if (p_phase == W_PHASE)
                    {
                        mCellKillCount += 0.5;
                    }
                    else
                    {
                        mCellKillCount += 1.0;//Increment the cell kill count by one for each cell killed
                    }
            	}
    		}
    	}
	}
	else if (dynamic_cast<NodeBasedCellPopulation<SPACE_DIM>*>(this->mpCellPopulation))
	{
		NodeBasedCellPopulation<SPACE_DIM>* p_tissue = static_cast<NodeBasedCellPopulation<SPACE_DIM>*> (this->mpCellPopulation);

		for (typename AbstractCellPopulation<SPACE_DIM>::Iterator cell_iter = p_tissue->Begin();
    			cell_iter != p_tissue->End();
    			++cell_iter)
    	{
    		unsigned node_index = this->mpCellPopulation->GetLocationIndexUsingCell(*cell_iter);
    		if (!cell_iter->GetCellProliferativeType()->template IsType<MembraneCellProliferativeType>())
    		{
    			Node<SPACE_DIM>* p_node = this->mpCellPopulation->GetNode(node_index);
            	double y = p_node->rGetLocation()[1];
            	if (y > mCryptTop && !cell_iter->IsDead())
            	{
            		SimplifiedPhaseBasedCellCycleModel* p_ccm = static_cast<SimplifiedPhaseBasedCellCycleModel*>(cell_iter->GetCellCycleModel());
                    SimplifiedCellCyclePhase p_phase = p_ccm->GetCurrentCellCyclePhase();
                    cell_iter->Kill();

                    if (p_phase == W_PHASE)
                    {
                        mCellKillCount += 0.5;
                    }
                    else
                    {
                        mCellKillCount += 1.0;//Increment the cell kill count by one for each cell killed
                    }
            	}
    		}
    	}
    }
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
unsigned SloughingCellKillerNewPhaseModel<ELEMENT_DIM,SPACE_DIM>::GetCellKillCount()
{
    return unsigned(mCellKillCount);
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void SloughingCellKillerNewPhaseModel<ELEMENT_DIM,SPACE_DIM>::OutputCellKillerParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<CellsRemovedBySloughing>" << 1 << "</CellsRemovedBySloughing> \n";

    // Call direct parent class
    AbstractCellKiller<SPACE_DIM>::OutputCellKillerParameters(rParamsFile);
}

template class SloughingCellKillerNewPhaseModel<1,1>;
template class SloughingCellKillerNewPhaseModel<1,2>;
template class SloughingCellKillerNewPhaseModel<2,2>;
template class SloughingCellKillerNewPhaseModel<1,3>;
template class SloughingCellKillerNewPhaseModel<2,3>;
template class SloughingCellKillerNewPhaseModel<3,3>;



// #include "SerializationExportWrapperForCpp.hpp"
// EXPORT_TEMPLATE_CLASS_SAME_DIMS(SloughingCellKillerNewPhaseModel)
