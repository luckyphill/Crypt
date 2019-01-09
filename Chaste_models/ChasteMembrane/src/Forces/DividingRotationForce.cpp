#include "DividingRotationForce.hpp"
#include "AbstractCellProperty.hpp"
#include "SimpleWntContactInhibitionCellCycleModel.hpp"
#include "CellCyclePhases.hpp"
#include "Debug.hpp"

// Assumes the use of parent cell labelling from "SimpleWntContactInhibitionCellCycleModel.hpp"

//************************************************************************************************
// Uses cell_data method of tracing cell parents, in order to deal with newly divided cells
//************************************************************************************************

DividingRotationForce::DividingRotationForce()
   :  AbstractForce<2>(),
   mTorsionalStiffness(10.0)
{
}

DividingRotationForce::~DividingRotationForce()
{

}

void DividingRotationForce::SetTorsionalStiffness(double torsionalStiffness)
{
	mTorsionalStiffness = torsionalStiffness;
}

void DividingRotationForce::AddForceContribution(AbstractCellPopulation<2>& rCellPopulation)
{
	// loop through cell population
	// find all pairs of cells that are dividing
	// for each dividing pair, add in a returning force proportional to the rotation angle from the membrane axis

	std::vector<std::pair<Node<2>*, Node<2>*>> node_pairs = DividingRotationForce::GetNodePairs(rCellPopulation);

	for (std::vector<std::pair<Node<2>*, Node<2>*>>::iterator it = node_pairs.begin(); it != node_pairs.end(); ++it)
    {
    	Node<2>* nodeA = it->first;
    	Node<2>* nodeB = it->second;


    	c_vector<double, 2> locationA = nodeA->rGetLocation();
    	c_vector<double, 2> locationB = nodeB->rGetLocation();

    	// Get the unit vector parallel to the line joining the two nodes

	    c_vector<double, 2> divisionVector = rCellPopulation.rGetMesh().GetVectorFromAtoB(locationA, locationB);

	    double lengthDivisionVector = norm_2(divisionVector);

	    // Normalise the vector
	    divisionVector /= lengthDivisionVector;

	    // Get the angle between the membrane axis and the division vector
	    // Only need the dot product because the two vectors have been normalised to length 1
	    double dotProduct = divisionVector[0] * mMembraneAxis[0] + divisionVector[1] * mMembraneAxis[1];

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

		Node<2>* nodeToApplyForce = ((locationA[0] > locationB[0]) ? nodeA : nodeB);

		double forceMagnitude = mTorsionalStiffness * angle;

		c_vector<double, 2> forceDirection;
		forceDirection[0] = -1;
		forceDirection[1] = 0;
		
		c_vector<double, 2> forceVector = forceMagnitude * forceDirection;

		nodeToApplyForce->AddAppliedForceContribution(forceVector);

    }



}

std::vector<std::pair<Node<2>*, Node<2>*>> DividingRotationForce::GetNodePairs(AbstractCellPopulation<2>& rCellPopulation)
{

	// The mitotic pairs
	std::vector<std::pair<Node<2>*, Node<2>*>> nodePairs;
	std::list<CellPtr> mphase_cells;

	
	MeshBasedCellPopulation<2,2>* p_tissue = static_cast<MeshBasedCellPopulation<2,2>*>(&rCellPopulation);
    std::list<CellPtr> cells =  p_tissue->rGetCells();

    for (std::list<CellPtr>::iterator cell_iter = cells.begin(); cell_iter != cells.end(); ++cell_iter)
    {
    	// If cell is in M-phase, add it to the list
        Node<2>* p_node =  p_tissue->GetNodeCorrespondingToCell(*cell_iter);
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
    			// PRINT_2_VARIABLES(idA,idB)
    			std::pair<Node<2>*, Node<2>*> dividing_cell;
    			// make cells into nodes
    			Node<2>* nodeA = p_tissue->GetNode(p_tissue->GetLocationIndexUsingCell((*cell_iter)));
    			Node<2>* nodeB = p_tissue->GetNode(p_tissue->GetLocationIndexUsingCell((*cell_iter_2)));
    			//
    			dividing_cell = std::make_pair(nodeA, nodeB);
    			nodePairs.push_back(dividing_cell);
    			// delete from list
    			cell_iter = mphase_cells.erase(cell_iter);
    			mphase_cells.erase(cell_iter_2);

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


void DividingRotationForce::OutputForceParameters(out_stream& rParamsFile)
{
	*rParamsFile <<  "\t\t\t<torsionalStiffness>"<<  mTorsionalStiffness << "</torsionalStiffness> \n";

	// Call direct parent class
	AbstractForce<2>::OutputForceParameters(rParamsFile);
}

void DividingRotationForce::SetMembraneAxis(c_vector<double, 2> membraneAxis)
{
    double magnitude = sqrt(membraneAxis(0) * membraneAxis(0) + membraneAxis(1) * membraneAxis(1));
    mMembraneAxis = membraneAxis/magnitude;
    // need to normalise so it is a unit vector

}