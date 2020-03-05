
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

		double radius = pTissue->rGetMesh().GetMaximumInteractionDistance();

		neighbouring_node_indices = pTissue->GetNodesWithinNeighbourhoodRadius(nodeIndex, radius);

	}

    return neighbouring_node_indices;
}

bool MembraneDetachmentKiller::HasCellPoppedUp(unsigned nodeIndex)
{

	// Get the neighbours
	std::set<unsigned> neighbours = GetNeighbouringNodeIndices(nodeIndex);

	// Convert the nodeIndex to CellPtr and Node<2>*
	CellPtr pCell = this->mpCellPopulation->GetCellUsingLocationIndex(nodeIndex);
	Node<2>* pNode = this->mpCellPopulation->GetNode(nodeIndex);

	// Get the location of the cell for future checking
	c_vector<double, 2> cellLocation = pNode->rGetLocation();

	NodeBasedCellPopulation<2>* pTissue = static_cast<NodeBasedCellPopulation<2>*> (this->mpCellPopulation);


	for(std::set<unsigned>::iterator neighbourIt=neighbours.begin(); neighbourIt != neighbours.end(); ++neighbourIt)
	{
		// Convert the neighbour to CellPtr and Node<2>*
		CellPtr pNeighbourCell = pTissue->GetCellUsingLocationIndex(*neighbourIt);
		Node<2>* pNeighbourNode = this->mpCellPopulation->GetNode(*neighbourIt);
				// For each neighbour, check if it of MembraneType
		if (pNeighbourCell->GetCellProliferativeType()->IsType<MembraneType>() )
		{
						// If it is membrane type then need to make sure it is close enough
			// defined by the cutt-off radius
			c_vector<double, 2> neighbourLocation = pNeighbourNode->rGetLocation();

			c_vector<double, 2> cellToNeighbour = this->mpCellPopulation->rGetMesh().GetVectorFromAtoB(neighbourLocation, cellLocation);
			double distance = norm_2(cellToNeighbour);
			if (distance <= mCutOffRadius)
			{
				return false;
			}
		}
	}

	return true;
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
    		CellPtr pCell = (*cell_iter);
    		unsigned node_index = pTissue->GetNodeCorrespondingToCell(pCell)->GetIndex();

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
