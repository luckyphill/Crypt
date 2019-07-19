

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
#include "AnoikisCellTagged.hpp"


SloughingCellKillerNewPhaseModel::SloughingCellKillerNewPhaseModel(AbstractCellPopulation<2>* pCellPopulation)
    : AbstractCellKiller<2>(pCellPopulation),
    mCryptTop(10.0)
{
    // Sets up output file
//	OutputFileHandler output_file_handler(mOutputDirectory + "SloughingData/", false);
//	mSloughingOutputFile = output_file_handler.OpenOutputFile("results.anoikis");
}

SloughingCellKillerNewPhaseModel::~SloughingCellKillerNewPhaseModel()
{
//    mSloughingOutputFile->close();
}


void SloughingCellKillerNewPhaseModel::SetCryptTop(double cryptTop)
{
	mCryptTop = cryptTop;
}

/*
 * Cell Killer that kills healthy cells that pop outwards and become detached from
 * the labelled tissue cells, i.e. removal by anoikis
 *
 * Also will remove differentiated cells at the orifice if mSloughOrifice is true
 */
void SloughingCellKillerNewPhaseModel::CheckAndLabelCellsForApoptosisOrDeath()
{
    if (dynamic_cast<NodeBasedCellPopulation<2>*>(this->mpCellPopulation))
	{
		NodeBasedCellPopulation<2>* p_tissue = static_cast<NodeBasedCellPopulation<2>*> (this->mpCellPopulation);

		for (typename AbstractCellPopulation<2>::Iterator cell_iter = p_tissue->Begin();
    			cell_iter != p_tissue->End();
    			++cell_iter)
    	{
    		unsigned node_index = this->mpCellPopulation->GetLocationIndexUsingCell(*cell_iter);
    		if (!cell_iter->GetCellProliferativeType()->template IsType<MembraneCellProliferativeType>())
    		{
    			Node<2>* p_node = this->mpCellPopulation->GetNode(node_index);
                double x = p_node->rGetLocation()[0];
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
                // An attempt to stop a row of cells hanging around at the top of the crypt
                // x-0.6 depends on the free height of the monolayer cells. Any change to that will break this

                // This draws a line at an angle of 60 degrees down from the top cell on the monolayer
                // any cell above the line is considered to be sloughed off
                // This solves the issue with cells lingering at the top of the crypt when they should
                // have been killed. It introduces a "model limitation", though, since the cells
                // at the top of the crypt can be killed even at fairly low heights if the popped up layer is
                // particularly tall. The interesting part of the mutation lumps should be the middle to lower parts
                // since the top is not exactly physically accurate to begin with.
                if (y > mCryptTop - (x - 0.6) / sqrt(3) && (*cell_iter)->template HasCellProperty<AnoikisCellTagged>() && !cell_iter->IsDead()) 
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

unsigned SloughingCellKillerNewPhaseModel::GetCellKillCount()
{
    return unsigned(mCellKillCount);
}

void SloughingCellKillerNewPhaseModel::OutputCellKillerParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<CellsRemovedBySloughing>" << 1 << "</CellsRemovedBySloughing> \n";

    // Call direct parent class
    AbstractCellKiller<2>::OutputCellKillerParameters(rParamsFile);
}



// #include "SerializationExportWrapperForCpp.hpp"
// EXPORT_TEMPLATE_CLASS_SAME_DIMS(SloughingCellKillerNewPhaseModel)
