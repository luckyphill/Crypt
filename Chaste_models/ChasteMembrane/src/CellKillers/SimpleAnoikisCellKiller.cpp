
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
#include "TransitCellAnoikisResistantMutationState.hpp"
#include "MembraneCellProliferativeType.hpp"

#include "Debug.hpp"

SimpleAnoikisCellKiller::SimpleAnoikisCellKiller(AbstractCellPopulation<2>* pCellPopulation)
    : AbstractCellKiller<2>(pCellPopulation),
    mSlowDeath(false),
    mPoppedUpLifeExpectancy(0.0),
    mResistantPoppedUpLifeExpectancy(0.0)
{
}

SimpleAnoikisCellKiller::~SimpleAnoikisCellKiller()
{
//    mAnoikisOutputFile->close();
}

void SimpleAnoikisCellKiller::SetPopUpDistance(double popUpDistance)
{
	mPopUpDistance = popUpDistance;
}

void SimpleAnoikisCellKiller::SetPoppedUpLifeExpectancy(double poppedUpLifeExpectancy)
{
	mPoppedUpLifeExpectancy = poppedUpLifeExpectancy;
}

void SimpleAnoikisCellKiller::SetResistantPoppedUpLifeExpectancy(double resistantPoppedUpLifeExpectancy)
{
	mResistantPoppedUpLifeExpectancy = resistantPoppedUpLifeExpectancy;
}

double SimpleAnoikisCellKiller::GetPopUpDistance()
{
	return mPopUpDistance;
}

double SimpleAnoikisCellKiller::GetPoppedUpLifeExpectancy()
{
	return mPoppedUpLifeExpectancy;
}

double SimpleAnoikisCellKiller::GetResistantPoppedUpLifeExpectancy()
{
	return mResistantPoppedUpLifeExpectancy;
}

/** Method to determine if an epithelial cell has lost all contacts with the gel cells below
 * TRUE if cell has popped up
 * FALSE if cell remains in the monolayer
 */
bool SimpleAnoikisCellKiller::HasCellPoppedUp(unsigned nodeIndex)
{
	bool has_cell_popped_up = false;	// Initialising

	NodeBasedCellPopulation<2>* p_tissue = static_cast<NodeBasedCellPopulation<2>*> (this->mpCellPopulation);

	c_vector<double,2> cell_location = p_tissue->GetNode(nodeIndex)->rGetLocation();

	if (cell_location[0] > mPopUpDistance)
	{
		has_cell_popped_up = true;
	}


	return has_cell_popped_up;
}

void SimpleAnoikisCellKiller::PopulateAnoikisList()
{
	// Loop through, check if popped up and if so, store the cell pointer and the time

	if (dynamic_cast<NodeBasedCellPopulation<2>*>(this->mpCellPopulation))
    {
    	NodeBasedCellPopulation<2>* p_tissue = static_cast<NodeBasedCellPopulation<2>*> (this->mpCellPopulation);

    	for (AbstractCellPopulation<2>::Iterator cell_iter = p_tissue->Begin();
    			cell_iter != p_tissue->End();
    			++cell_iter)
    	{
    		unsigned node_index = p_tissue->GetNodeCorrespondingToCell(*cell_iter)->GetIndex();
    		CellPtr p_cell = p_tissue->GetCellUsingLocationIndex(node_index);
    		
    		if (HasCellPoppedUp(node_index) && !IsPoppedUpCellInVector(p_cell))
    		{
    			MAKE_PTR(AnoikisCellTagged,p_tagged);
    			p_cell->AddCellProperty(p_tagged);
    			std::pair<CellPtr, double> cell_data;
    			cell_data = std::make_pair(p_cell, SimulationTime::Instance()->GetTime());
    			mCellsForDelayedAnoikis.push_back(cell_data);
    		}
    	}
    }

}

bool SimpleAnoikisCellKiller::IsPoppedUpCellInVector(CellPtr check_cell)
{

	// Checks if the popped up cell is in the list mCellsForDelayedAnoikis
	std::vector<std::pair<CellPtr, double>>::iterator it;
	for (it = mCellsForDelayedAnoikis.begin(); it != mCellsForDelayedAnoikis.end(); ++it)
	{
		if (it->first == check_cell)
		{
			return true;
		}
	}

	if (check_cell->HasCellProperty<AnoikisCellTagged>())
	{
		TRACE("Found a cell that divided after it popped up")
	}
	return false;
}


std::vector<CellPtr> SimpleAnoikisCellKiller::GetCellsReadyToDie()
{
	// Go through the anoikis list, if the lenght of time since it popped up is past a certain
	// threshold, then that cell is ready to be killed
	std::vector<CellPtr> cellsReadyToDie;
	std::vector<std::pair<CellPtr, double>>::iterator it = mCellsForDelayedAnoikis.begin();

	while(it != mCellsForDelayedAnoikis.end())
	{

		if (!it->first->GetMutationState()->IsType<TransitCellAnoikisResistantMutationState>() && SimulationTime::Instance()->GetTime() - it->second > mPoppedUpLifeExpectancy)
		{
			cellsReadyToDie.push_back(it->first);
			it = mCellsForDelayedAnoikis.erase(it);
		} else
		{
			if (it->first->GetMutationState()->IsType<TransitCellAnoikisResistantMutationState>() && SimulationTime::Instance()->GetTime() - it->second > mResistantPoppedUpLifeExpectancy)
			{
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
 */
void SimpleAnoikisCellKiller::CheckAndLabelCellsForApoptosisOrDeath()
{

	if (dynamic_cast<NodeBasedCellPopulation<2>*>(this->mpCellPopulation))
	{
		NodeBasedCellPopulation<2>* p_tissue = static_cast<NodeBasedCellPopulation<2>*> (this->mpCellPopulation);

		// Get the information at this timestep for each node index that says whether to remove by anoikis or random apoptosis
		this->PopulateAnoikisList();
		std::vector<CellPtr> cells_to_remove = this->GetCellsReadyToDie();


		for(std::vector<CellPtr>::iterator cell_iter = cells_to_remove.begin(); cell_iter != cells_to_remove.end(); ++cell_iter)
		{
			
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
				mCellKillCount++;//Increment the cell kill count by one for each cell killed
			}
			
		}
	}
}

void SimpleAnoikisCellKiller::SetSlowDeath(bool slowDeath)
{
	mSlowDeath = slowDeath;
}

unsigned SimpleAnoikisCellKiller::GetCellKillCount()
{
	return mCellKillCount;
}

void SimpleAnoikisCellKiller::ResetCellKillCount()
{
	mCellKillCount = 0;
}

void SimpleAnoikisCellKiller::OutputCellKillerParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<PopUpDistance>" << mPopUpDistance << "</PopUpDistance> \n";
    *rParamsFile << "\t\t\t<PoppedUpLifeExpectancy>" << mPoppedUpLifeExpectancy << "</PoppedUpLifeExpectancy> \n";

    // Call direct parent class
    AbstractCellKiller<2>::OutputCellKillerParameters(rParamsFile);
}




#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(SimpleAnoikisCellKiller)
