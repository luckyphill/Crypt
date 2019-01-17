#include "DividingRotationForce.hpp"
#include "AbstractCellProperty.hpp"
#include "SimpleWntContactInhibitionCellCycleModel.hpp"
#include "CellCyclePhases.hpp"
#include "Debug.hpp"

// Assumes the use of parent cell labelling from "SimpleWntContactInhibitionCellCycleModel.hpp"

//************************************************************************************************
// Uses cell_data method of tracing cell parents, in order to deal with newly divided cells
//************************************************
// ************************************************
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
DividingRotationForce<ELEMENT_DIM,SPACE_DIM>::DividingRotationForce()
   :  AbstractForce<SPACE_DIM>(),
   mTorsionalStiffness(10.0)
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
DividingRotationForce<ELEMENT_DIM,SPACE_DIM>::~DividingRotationForce()
{

}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void DividingRotationForce<ELEMENT_DIM,SPACE_DIM>::SetTorsionalStiffness(double torsionalStiffness)
{
	mTorsionalStiffness = torsionalStiffness;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void DividingRotationForce<ELEMENT_DIM,SPACE_DIM>::AddForceContribution(AbstractCellPopulation<SPACE_DIM>& rCellPopulation)
{
	// loop through cell population
	// find all pairs of cells that are dividing
	// for each dividing pair, add in a returning 
    // force proportional to the rotation angle from the membrane axis
	std::vector<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>*>> node_pairs = DividingRotationForce<ELEMENT_DIM,SPACE_DIM>::GetNodePairs(rCellPopulation);

	for (typename std::vector<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>*>>::iterator it = node_pairs.begin(); it != node_pairs.end(); ++it)
    {

    	Node<SPACE_DIM>* nodeA = it->first;
    	Node<SPACE_DIM>* nodeB = it->second;


    	c_vector<double, SPACE_DIM> locationA = nodeA->rGetLocation();
    	c_vector<double, SPACE_DIM> locationB = nodeB->rGetLocation();

    	// Get the unit vector parallel to the line joining the two nodes

	    c_vector<double, SPACE_DIM> divisionVector = rCellPopulation.rGetMesh().GetVectorFromAtoB(locationA, locationB);

	    double lengthDivisionVector = norm_2(divisionVector);

	    // Normalise the vector
	    divisionVector /= lengthDivisionVector;

	    // Get the angle between the membrane axis and the division vector
	    // Only need the dot product because the two vectors have been normalised to length 1
	    double dotProduct = 0;
        for (unsigned i = 0; i < SPACE_DIM; i++)
        {
            dotProduct += divisionVector[i] * mMembraneAxis[i];
        }

		double angle = acos(dotProduct);
		// Occasionally the argument steps out of the bounds for acos, for instance -1.0000000000000002
		// This is enough to make the acos function return nans
		// This line of code is not ideal, but catches the error for the time being
		if (isnan(angle) && dotProduct > -1.00000000000005) 
		{
			angle = acos(-1);
		}

		// Need to decide which cell the apply the force to
		// Generally, only one of the two cells gets pushed out of the column
		// This might change after adding the force in, so will have to observe behaviour

		// Choose the cell that is furthest in the +ve x direction from the membrane
        Node<SPACE_DIM>* nodeToApplyForce = ((locationA[0] > locationB[0]) ? nodeA : nodeB);
        c_vector<double, SPACE_DIM> forceDirection;
        forceDirection[0] = -1;
        forceDirection[1] = 0;
        if (SPACE_DIM == 3)
        {
            nodeToApplyForce = ((locationA[2] > locationB[2]) ? nodeA : nodeB);
            forceDirection[0] = 0;
            forceDirection[2] = -1;
        }
		
		double forceMagnitude = mTorsionalStiffness * angle;
		
		c_vector<double, SPACE_DIM> forceVector = forceMagnitude * forceDirection;

		nodeToApplyForce->AddAppliedForceContribution(forceVector);

    }



}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
std::vector<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>*>> DividingRotationForce<ELEMENT_DIM,SPACE_DIM>::GetNodePairs(AbstractCellPopulation<SPACE_DIM>& rCellPopulation)
{

	// The mitotic pairs
	std::vector<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>*>> nodePairs;
	std::list<CellPtr> mphase_cells;

	
	MeshBasedCellPopulation<SPACE_DIM>* p_tissue = static_cast<MeshBasedCellPopulation<SPACE_DIM>*>(&rCellPopulation);
    std::list<CellPtr> cells =  p_tissue->rGetCells();

    for (std::list<CellPtr>::iterator cell_iter = cells.begin(); cell_iter != cells.end(); ++cell_iter)
    {
    	// If cell is in M-phase, add it to the list
        AbstractCellCycleModel* temp_ccm = (*cell_iter)->GetCellCycleModel();
        SimpleWntContactInhibitionCellCycleModel* ccm = static_cast<SimpleWntContactInhibitionCellCycleModel*>(temp_ccm);

        CellCyclePhase phase = ccm->GetCurrentCellCyclePhase();

        if (phase == M_PHASE)
        {
        	mphase_cells.push_back(*cell_iter);
        }

	}

	// Match pairs of cells that represent a cell growing before division

	std::list<CellPtr>::iterator cell_iter = mphase_cells.begin();
	while ( cell_iter != mphase_cells.end())
    {
    	std::list<CellPtr>::iterator cell_iter_2 = mphase_cells.begin();
    	bool pair_found = false;
    	while ( cell_iter_2 != mphase_cells.end())
    	{
    		double parentA = (*cell_iter)->GetCellData()->GetItem("parent");
			double parentB = (*cell_iter_2)->GetCellData()->GetItem("parent");
			
			unsigned idA = (*cell_iter)->GetCellId();
			unsigned idB = (*cell_iter_2)->GetCellId();
			
			// If cells have the same parent, and we haven't found the same cell, then they are a dividing pair
    		if (parentA == parentB && idA != idB)
    		{
    			pair_found = true;
    			std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>*> dividing_cell;
    			// make cells into nodes
    			Node<SPACE_DIM>* nodeA = p_tissue->GetNode(p_tissue->GetLocationIndexUsingCell((*cell_iter)));
    			Node<SPACE_DIM>* nodeB = p_tissue->GetNode(p_tissue->GetLocationIndexUsingCell((*cell_iter_2)));
    			// Add the pair to the list
    			dividing_cell = std::make_pair(nodeA, nodeB);
    			nodePairs.push_back(dividing_cell);
    			// delete from list
    			mphase_cells.erase(cell_iter_2);
                cell_iter = mphase_cells.erase(cell_iter);

    			break;
    			
    		} else {
    			++cell_iter_2;
    		}
    	}
    	if (!pair_found)
    	{
    		++cell_iter;
    	}
    }
	return nodePairs;
}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void DividingRotationForce<ELEMENT_DIM,SPACE_DIM>::OutputForceParameters(out_stream& rParamsFile)
{
	*rParamsFile <<  "\t\t\t<torsionalStiffness>"<<  mTorsionalStiffness << "</torsionalStiffness> \n";

	// Call direct parent class
	AbstractForce<SPACE_DIM>::OutputForceParameters(rParamsFile);
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void DividingRotationForce<ELEMENT_DIM,SPACE_DIM>::SetMembraneAxis(c_vector<double, SPACE_DIM> membraneAxis)
{
    double magnitude = norm_2(membraneAxis);
    mMembraneAxis = membraneAxis/magnitude;
    // need to normalise so it is a unit vector

}

template class DividingRotationForce<1,1>;
template class DividingRotationForce<1,2>;
template class DividingRotationForce<2,2>;
template class DividingRotationForce<1,3>;
template class DividingRotationForce<2,3>;
template class DividingRotationForce<3,3>;