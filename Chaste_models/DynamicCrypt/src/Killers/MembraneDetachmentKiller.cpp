
/*
 * MODIFIED BY PHILLIP BROWN 1/11/2017
 * Added in a check for an anoikis resistant mutation, which stops a cell from dying when it
 * detaches from the non epithelial region i.e. the basement layer of cells
 * Also modified to check if cell is in contact with MembraneCellProliferativeType
 */

#include "MembraneDetachmentKiller.hpp"
#include "AbstractCellKiller.hpp"
#include "AbstractCellProperty.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "NodeBasedCellPopulation.hpp"
#include "MembraneType.hpp"
#include "EpithelialType.hpp"

#include "Debug.hpp"

MembraneDetachmentKiller::MembraneDetachmentKiller(AbstractCellPopulation<2>* pCellPopulation)
    : AbstractCellKiller<2>(pCellPopulation),
    mCutOffRadius(1.5)
{
}

MembraneDetachmentKiller::~MembraneDetachmentKiller()
{
}

double MembraneDetachmentKiller::GetCutOffRadius()
{
	return mCutOffRadius;
}

void MembraneDetachmentKiller::SetCutOffRadius(double cutOffRadius)
{
	mCutOffRadius = cutOffRadius;
}

std::set<unsigned> MembraneDetachmentKiller::GetNeighbouringNodeIndices(unsigned nodeIndex)
{
	// Create a set of neighbouring node indices
	std::set<unsigned> neighbouring_node_indices;

	if (dynamic_cast<NodeBasedCellPopulation<2>*>(this->mpCellPopulation))
	{
		// Need access to the mesh but can't get to it because the cell killer only owns a
		// pointer to an AbstractCellPopulation
		NodeBasedCellPopulation<2>* pTissue = static_cast<NodeBasedCellPopulation<2>*> (this->mpCellPopulation);

		//Update cell population
		pTissue->Update();

		NodesOnlyMesh<2>& rMesh = pTissue->rGetMesh();

		double radius = GetCutOffRadius();

		neighbouring_node_indices = pTissue->GetNodesWithinNeighbourhoodRadius(nodeIndex, radius);

	}

    return neighbouring_node_indices;
}

bool MembraneDetachmentKiller::HasCellPoppedUp(unsigned nodeIndex)
{
	bool has_cell_popped_up = false;	// Initialising
	std::set<unsigned> neighbours = GetNeighbouringNodeIndices(nodeIndex);

	if (dynamic_cast<NodeBasedCellPopulation<2>*>(this->mpCellPopulation))
	{
		NodeBasedCellPopulation<2>* pTissue = static_cast<NodeBasedCellPopulation<2>*> (this->mpCellPopulation);

		unsigned membrane_neighbours = 0;

		// Iterate over the neighbouring cells to check the number of differentiated cell neighbours

		for(std::set<unsigned>::iterator neighbour_iter=neighbours.begin();
				neighbour_iter != neighbours.end();
				++neighbour_iter)
		{
			if (pTissue->GetCellUsingLocationIndex(*neighbour_iter)->GetCellProliferativeType()->IsType<MembraneType>() )
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


void MembraneDetachmentKiller::CheckAndLabelCellsForApoptosisOrDeath()
{

	if (dynamic_cast<NodeBasedCellPopulation<2>*>(this->mpCellPopulation))
	{
		NodeBasedCellPopulation<2>* pTissue = static_cast<NodeBasedCellPopulation<2>*> (this->mpCellPopulation);

    	for (AbstractCellPopulation<2>::Iterator cell_iter = pTissue->Begin();
    			cell_iter != pTissue->End();
    			++cell_iter)
    	{
    		unsigned node_index = pTissue->GetNodeCorrespondingToCell(*cell_iter)->GetIndex();

    		CellPtr pCell = pTissue->GetCellUsingLocationIndex(node_index);
    		if (pCell->GetCellProliferativeType()->IsType<EpithelialType>())
    		{
				if(HasCellPoppedUp(node_index))
				{
					if (mSlowDeath)
					{
						if (!pCell->HasApoptosisBegun())
						{
							pCell->StartApoptosis();
						}
					} else {
						pCell->Kill();
					}
					
				}
			}
		}
	}
}

void MembraneDetachmentKiller::SetSlowDeath(bool slowDeath)
{
	mSlowDeath = slowDeath;
}

void MembraneDetachmentKiller::OutputCellKillerParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<CutOffRadius>" << mCutOffRadius << "</CutOffRadius> \n";

    // Call direct parent class
    AbstractCellKiller<2>::OutputCellKillerParameters(rParamsFile);
}




#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(MembraneDetachmentKiller)
