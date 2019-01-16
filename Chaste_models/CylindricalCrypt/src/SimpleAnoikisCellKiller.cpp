
/*
 * Kills cells when they are more than a fixed distance from the membrane
 * Also incorporates delayed anoikis
 */

#include "SimpleAnoikisCellKiller.hpp"
#include "AnoikisCellTagged.hpp"
#include "AbstractCellKiller.hpp"
#include "AbstractCellProperty.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "NodeBasedCellPopulation.hpp"
// #include "PanethCellMutationState.hpp"
#include "TransitCellAnoikisResistantMutationState.hpp"

#include "Debug.hpp"

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
SimpleAnoikisCellKiller<ELEMENT_DIM,SPACE_DIM>::SimpleAnoikisCellKiller(AbstractCellPopulation<SPACE_DIM>* pCellPopulation)
    : AbstractCellKiller<SPACE_DIM>(pCellPopulation),
    mCellsRemovedByAnoikis(0),
    mSlowDeath(false),
    mPoppedUpLifeExpectancy(0.0),
    mResistantPoppedUpLifeExpectancy(0.0)
{
    // Sets up output file
//	OutputFileHandler output_file_handler(mOutputDirectory + "AnoikisData/", false);
//	mAnoikisOutputFile = output_file_handler.OpenOutputFile("results.anoikis");
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
SimpleAnoikisCellKiller<ELEMENT_DIM,SPACE_DIM>::~SimpleAnoikisCellKiller()
{
//    mAnoikisOutputFile->close();
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void SimpleAnoikisCellKiller<ELEMENT_DIM,SPACE_DIM>::SetPopUpDistance(double popUpDistance)
{
	mPopUpDistance = popUpDistance;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void SimpleAnoikisCellKiller<ELEMENT_DIM,SPACE_DIM>::SetPoppedUpLifeExpectancy(double poppedUpLifeExpectancy)
{
	mPoppedUpLifeExpectancy = poppedUpLifeExpectancy;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void SimpleAnoikisCellKiller<ELEMENT_DIM,SPACE_DIM>::SetResistantPoppedUpLifeExpectancy(double resistantPoppedUpLifeExpectancy)
{
	mResistantPoppedUpLifeExpectancy = resistantPoppedUpLifeExpectancy;
}

/** Method to determine if an epithelial cell has lost all contacts with the gel cells below
 * TRUE if cell has popped up
 * FALSE if cell remains in the monolayer
 */
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
bool SimpleAnoikisCellKiller<ELEMENT_DIM,SPACE_DIM>::HasCellPoppedUp(unsigned nodeIndex)
{
	bool has_cell_popped_up = false;	// Initialising

	NodeBasedCellPopulation<SPACE_DIM>* p_tissue = static_cast<NodeBasedCellPopulation<SPACE_DIM>*> (this->mpCellPopulation);

	c_vector<double,SPACE_DIM> cell_location = p_tissue->GetNode(nodeIndex)->rGetLocation();

	if (SPACE_DIM == 2 && cell_location[0] > mPopUpDistance)
	{
		has_cell_popped_up = true;
	}

	if (SPACE_DIM == 3 && cell_location[2] > mPopUpDistance)
	{
		has_cell_popped_up = true;
	}


	return has_cell_popped_up;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void SimpleAnoikisCellKiller<ELEMENT_DIM,SPACE_DIM>::PopulateAnoikisList()
{
	// Loop through, check if popped up and if so, store the cell pointer and the time

	if (dynamic_cast<NodeBasedCellPopulation<SPACE_DIM>*>(this->mpCellPopulation))
    {
    	NodeBasedCellPopulation<SPACE_DIM>* p_tissue = static_cast<NodeBasedCellPopulation<SPACE_DIM>*> (this->mpCellPopulation);

    	for (typename AbstractCellPopulation<SPACE_DIM>::Iterator cell_iter = p_tissue->Begin();
    			cell_iter != p_tissue->End();
    			++cell_iter)
    	{
    		unsigned node_index = p_tissue->GetNodeCorrespondingToCell(*cell_iter)->GetIndex();
    		CellPtr p_cell = p_tissue->GetCellUsingLocationIndex(node_index);
    		
    		
    // 		if (p_cell->HasCellProperty<AnoikisCellTagged>() && GetNeighbouringNodeIndices(node_index).empty())
    // 		{
    // 			// If cell is isolated, kill it straight away. To ensure cell is removed correctly, mark it for death, and set the death time to now.
    // 			TRACE("Added an isolated cell")
    // 			PRINT_VARIABLE(SimulationTime::Instance()->GetTime())
    // 			PRINT_VARIABLE((*cell_iter)->GetCellId())
    // 			PRINT_VARIABLE(p_cell->GetCellId())
    // 			std::vector<std::pair<CellPtr, double>>::iterator it = mCellsForDelayedAnoikis.begin();
    // 			while(it != mCellsForDelayedAnoikis.end())
				// {
				// 	if(it->first == p_cell)
				// 	{
				// 		TRACE("Removed old listing of isolated cell")
				// 		it = mCellsForDelayedAnoikis.erase(it);
				// 		break;
				// 	} else
				// 	{
				// 		++it;
				// 	}
				// }
    // 			std::pair<CellPtr, double> cell_data;
    // 			// A hack to make it die straight away
    // 			double long_time_ago = SimulationTime::Instance()->GetTime() - 2 * (mPoppedUpLifeExpectancy + mResistantPoppedUpLifeExpectancy + 1);
    // 			PRINT_VARIABLE(long_time_ago)
    // 			cell_data = std::make_pair(p_cell, long_time_ago); //Use both since no idea which it could be and we just want to make sure it is killed immediately
    // 			mCellsForDelayedAnoikis.push_back(cell_data);
    // 		}
    		//If it has just popped up, add to the anoikis list
    		if (!p_cell->HasCellProperty<AnoikisCellTagged>() && HasCellPoppedUp(node_index))
    		{
    			TRACE("Cell popped up")
    			PRINT_VARIABLE(p_cell->GetCellId())
    			MAKE_PTR(AnoikisCellTagged,p_tagged);
    			p_cell->AddCellProperty(p_tagged);
    			std::pair<CellPtr, double> cell_data;
    			cell_data = std::make_pair(p_cell, SimulationTime::Instance()->GetTime());
    			mCellsForDelayedAnoikis.push_back(cell_data);
    		}
    	}
    }

}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
std::vector<CellPtr> SimpleAnoikisCellKiller<ELEMENT_DIM,SPACE_DIM>::GetCellsReadyToDie()
{
	// Go through the anoikis list, if the lenght of time since it popped up is past a certain
	// threshold, then that cell is ready to be killed
	std::vector<CellPtr> cellsReadyToDie;
	std::vector<std::pair<CellPtr, double>>::iterator it = mCellsForDelayedAnoikis.begin();

	while(it != mCellsForDelayedAnoikis.end())
	{
		if (!it->first->GetMutationState()->IsType<TransitCellAnoikisResistantMutationState>() && SimulationTime::Instance()->GetTime() - it->second > mPoppedUpLifeExpectancy)
		{
			TRACE("Normal cell ready to die")
			PRINT_VARIABLE(it->second)
			cellsReadyToDie.push_back(it->first);
			it = mCellsForDelayedAnoikis.erase(it);
		} else
		{
			if (it->first->GetMutationState()->IsType<TransitCellAnoikisResistantMutationState>() && SimulationTime::Instance()->GetTime() - it->second > mResistantPoppedUpLifeExpectancy)
			{
				TRACE("Mutant cell ready to die")
				PRINT_VARIABLE(it->second)
				cellsReadyToDie.push_back(it->first);
				it = mCellsForDelayedAnoikis.erase(it);
			} else {
				++it;
			}
		}

	}
	return cellsReadyToDie;
}

/*
 * Cell Killer that kills healthy cells that pop outwards and become detached from
 * the labelled tissue cells, i.e. removal by anoikis
 *
 * Also will remove differentiated cells at the orifice if mSloughOrifice is true
 */template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void SimpleAnoikisCellKiller<ELEMENT_DIM,SPACE_DIM>::CheckAndLabelCellsForApoptosisOrDeath()
{

	if (dynamic_cast<NodeBasedCellPopulation<SPACE_DIM>*>(this->mpCellPopulation))
	{
		NodeBasedCellPopulation<SPACE_DIM>* p_tissue = static_cast<NodeBasedCellPopulation<SPACE_DIM>*> (this->mpCellPopulation);

		// Get the information at this timestep for each node index that says whether to remove by anoikis or random apoptosis
		this->PopulateAnoikisList();
		std::vector<CellPtr> cells_to_remove = this->GetCellsReadyToDie();

		//PRINT_VARIABLE(cells_to_remove.size())

		for(std::vector<CellPtr>::iterator cell_iter = cells_to_remove.begin(); cell_iter != cells_to_remove.end(); ++cell_iter)
		{
			TRACE("About to kill")
			PRINT_VARIABLE((*cell_iter)->GetCellId())
			unsigned node_index = p_tissue->GetNodeCorrespondingToCell(*cell_iter)->GetIndex();
    		CellPtr p_cell = p_tissue->GetCellUsingLocationIndex(node_index);
			if (mSlowDeath)
			{
				if (!p_cell->HasApoptosisBegun())
				{
					p_cell->StartApoptosis();
				}
			}
			else
			{
				p_cell->Kill();
				mCellKillCount += 1;//Increment the cell kill count by one for each cell killed
			}
			
		}
	}
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void SimpleAnoikisCellKiller<ELEMENT_DIM,SPACE_DIM>::SetSlowDeath(bool slowDeath)
{
	mSlowDeath = slowDeath;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
unsigned SimpleAnoikisCellKiller<ELEMENT_DIM,SPACE_DIM>::GetCellKillCount()
{
	return mCellKillCount;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void SimpleAnoikisCellKiller<ELEMENT_DIM,SPACE_DIM>::OutputCellKillerParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<PopUpDistance>" << mPopUpDistance << "</PopUpDistance> \n";
    *rParamsFile << "\t\t\t<PoppedUpLifeExpectancy>" << mPoppedUpLifeExpectancy << "</PoppedUpLifeExpectancy> \n";

    // Call direct parent class
    AbstractCellKiller<SPACE_DIM>::OutputCellKillerParameters(rParamsFile);
}


template class SimpleAnoikisCellKiller<1,1>;
template class SimpleAnoikisCellKiller<1,2>;
template class SimpleAnoikisCellKiller<2,2>;
template class SimpleAnoikisCellKiller<1,3>;
template class SimpleAnoikisCellKiller<2,3>;
template class SimpleAnoikisCellKiller<3,3>;

#include "SerializationExportWrapperForCpp.hpp"
// CHASTE_CLASS_EXPORT(SimpleAnoikisCellKiller)
