
/*
 * MODIFIED BY PHILLIP BROWN 1/11/2017
 * Added in a check for an anoikis resistant mutation, which stops a cell from dying when it
 * detaches from the non epithelial region i.e. the basement layer of cells
 * Also modified to check if cell is in contact with MembraneCellProliferativeType
 */

#include "AnoikisCellKiller.hpp"
#include "AnoikisCellTagged.hpp"
#include "AbstractCellKiller.hpp"
#include "AbstractCellProperty.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "NodeBasedCellPopulation.hpp"
#include "PanethCellMutationState.hpp"
#include "TransitCellAnoikisResistantMutationState.hpp"
#include "MembraneCellProliferativeType.hpp"

#include "Debug.hpp"

AnoikisCellKiller::AnoikisCellKiller(AbstractCellPopulation<2>* pCellPopulation)
    : AbstractCellKiller<2>(pCellPopulation),
    mCellsRemovedByAnoikis(0),
    mCutOffRadius(1.5),
    mSlowDeath(false),
    mPoppedUpLifeExpectancy(0.0),
    mResistantPoppedUpLifeExpectancy(0.0)
{
    // Sets up output file
//	OutputFileHandler output_file_handler(mOutputDirectory + "AnoikisData/", false);
//	mAnoikisOutputFile = output_file_handler.OpenOutputFile("results.anoikis");
}

AnoikisCellKiller::~AnoikisCellKiller()
{
//    mAnoikisOutputFile->close();
}

//Method to get mCutOffRadius
double AnoikisCellKiller::GetCutOffRadius()
{
	return mCutOffRadius;
}

void AnoikisCellKiller::SetPoppedUpLifeExpectancy(double poppedUpLifeExpectancy)
{
	mPoppedUpLifeExpectancy = poppedUpLifeExpectancy;
}

void AnoikisCellKiller::SetResistantPoppedUpLifeExpectancy(double resistantPoppedUpLifeExpectancy)
{
	mResistantPoppedUpLifeExpectancy = resistantPoppedUpLifeExpectancy;
}

//Method to set mCutOffRadius
void AnoikisCellKiller::SetCutOffRadius(double cutOffRadius)
{
	mCutOffRadius = cutOffRadius;
}

std::set<unsigned> AnoikisCellKiller::GetNeighbouringNodeIndices(unsigned nodeIndex)
{
	// Create a set of neighbouring node indices
	std::set<unsigned> neighbouring_node_indices;

	if (dynamic_cast<NodeBasedCellPopulation<2>*>(this->mpCellPopulation))
	{
		// Need access to the mesh but can't get to it because the cell killer only owns a
		// pointer to an AbstractCellPopulation
		NodeBasedCellPopulation<2>* p_tissue = static_cast<NodeBasedCellPopulation<2>*> (this->mpCellPopulation);

		//Update cell population
		p_tissue->Update();

		double radius = GetCutOffRadius();

		neighbouring_node_indices = p_tissue->GetNodesWithinNeighbourhoodRadius(nodeIndex, radius);
	}

    return neighbouring_node_indices;
}

/** Method to determine if an epithelial cell has lost all contacts with the gel cells below
 * TRUE if cell has popped up
 * FALSE if cell remains in the monolayer
 */
bool AnoikisCellKiller::HasCellPoppedUp(unsigned nodeIndex)
{
	bool has_cell_popped_up = false;	// Initialising
	std::set<unsigned> neighbours = GetNeighbouringNodeIndices(nodeIndex);

	if (dynamic_cast<NodeBasedCellPopulation<2>*>(this->mpCellPopulation))
	{
		NodeBasedCellPopulation<2>* p_tissue = static_cast<NodeBasedCellPopulation<2>*> (this->mpCellPopulation);

		unsigned membrane_neighbours = 0;

		// Iterate over the neighbouring cells to check the number of differentiated cell neighbours

		for(std::set<unsigned>::iterator neighbour_iter=neighbours.begin();
				neighbour_iter != neighbours.end();
				++neighbour_iter)
		{
			if (p_tissue->GetCellUsingLocationIndex(*neighbour_iter)->GetCellProliferativeType()->IsType<MembraneCellProliferativeType>() )
			{
				membrane_neighbours += 1;
			}
		}

		if(membrane_neighbours < 1)
		{
			has_cell_popped_up = true;
		}
	}

	return has_cell_popped_up;
}

void AnoikisCellKiller::PopulateAnoikisList()
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
    		
    		
    		if (p_cell->HasCellProperty<AnoikisCellTagged>() && GetNeighbouringNodeIndices(node_index).empty())
    		{
    			// If cell is isolated, kill it straight away. To ensure cell is removed correctly, mark it for death, and set the death time to now.
    			TRACE("Added an isolated cell")
    			PRINT_VARIABLE(SimulationTime::Instance()->GetTime())
    			PRINT_VARIABLE((*cell_iter)->GetCellId())
    			PRINT_VARIABLE(p_cell->GetCellId())
    			std::vector<std::pair<CellPtr, double>>::iterator it = mCellsForDelayedAnoikis.begin();
    			while(it != mCellsForDelayedAnoikis.end())
				{
					if(it->first == p_cell)
					{
						TRACE("Removed old listing of isolated cell")
						it = mCellsForDelayedAnoikis.erase(it);
						break;
					} else
					{
						++it;
					}
				}
    			std::pair<CellPtr, double> cell_data;
    			// A hack to make it die straight away
    			double long_time_ago = SimulationTime::Instance()->GetTime() - 2 * (mPoppedUpLifeExpectancy + mResistantPoppedUpLifeExpectancy + 1);
    			PRINT_VARIABLE(long_time_ago)
    			cell_data = std::make_pair(p_cell, long_time_ago); //Use both since no idea which it could be and we just want to make sure it is killed immediately
    			mCellsForDelayedAnoikis.push_back(cell_data);
    		}
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

std::vector<CellPtr> AnoikisCellKiller::GetCellsReadyToDie()
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
/** A method to return a vector that indicates which cells should be killed by anoikis
 * and which by compression-driven apoptosis
 */


/*
 * Cell Killer that kills healthy cells that pop outwards and become detached from
 * the labelled tissue cells, i.e. removal by anoikis
 *
 * Also will remove differentiated cells at the orifice if mSloughOrifice is true
 */
void AnoikisCellKiller::CheckAndLabelCellsForApoptosisOrDeath()
{

	if (dynamic_cast<NodeBasedCellPopulation<2>*>(this->mpCellPopulation))
	{
		NodeBasedCellPopulation<2>* p_tissue = static_cast<NodeBasedCellPopulation<2>*> (this->mpCellPopulation);

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
			} else {
				p_cell->Kill();
			}
			
		}
	}
}

void AnoikisCellKiller::SetSlowDeath(bool slowDeath)
{
	mSlowDeath = slowDeath;
}

void AnoikisCellKiller::OutputCellKillerParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<CutOffRadius>" << mCutOffRadius << "</CutOffRadius> \n";
    *rParamsFile << "\t\t\t<PoppedUpLifeExpectancy>" << mPoppedUpLifeExpectancy << "</PoppedUpLifeExpectancy> \n";

    // Call direct parent class
    AbstractCellKiller<2>::OutputCellKillerParameters(rParamsFile);
}




#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(AnoikisCellKiller)
