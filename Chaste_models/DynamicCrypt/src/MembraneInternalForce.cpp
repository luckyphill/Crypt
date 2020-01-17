#include "MembraneInternalForce.hpp"
#include "AbstractCellProperty.hpp"
#include "MembraneType.hpp"
#include "Debug.hpp"

/*
 * Created by: PHILLIP BROWN, 27/10/2017
 * Initial Structure borrows heavily from "EpithelialLayerBasementMembraneForce.cpp"
 * as found in the Chaste Paper Tutorials for the CryptFissionPlos2016 project
 */

/**
 * To avoid warnings on some compilers, C++ style initialization of member
 * variables should be done in the order they are defined in the header file.
 */
MembraneInternalForce::MembraneInternalForce()
   :  AbstractForce<2>(),
   mMembraneStiffness(50)
{
}

MembraneInternalForce::~MembraneInternalForce()
{

}

void MembraneInternalForce::SetMembraneStiffness(double MembraneStiffness)
{
	mMembraneStiffness = MembraneStiffness;
}

void MembraneInternalForce::SetExternalStiffness(double ExternalStiffness)
{
	mExternalStiffness = ExternalStiffness;
}


//Method overriding the virtual method for AbstractForce. The crux of what really needs to be done.
void MembraneInternalForce::AddForceContribution(AbstractCellPopulation<2>& rCellPopulation)
{

	MeshBasedCellPopulation<2>* p_tissue = static_cast<MeshBasedCellPopulation<2>*>(&rCellPopulation);


	for (std::vector<std::vector<CellPtr>>::iterator iter = mMembraneSections.begin(); iter != mMembraneSections.end(); ++iter)
	{
		std::vector<CellPtr> membraneCells = *iter;
		// We loop through the membrane sections to set the restoring forces
		
		for (unsigned i = 0; i < membraneCells.size() - 1; i++)
		{
			CellPtr cellA = membraneCells[i];
			CellPtr cellB = membraneCells[i+1];

			Node<2>* nodeA = p_tissue->GetNode(p_tissue->GetLocationIndexUsingCell(cellA));
			Node<2>* nodeB = p_tissue->GetNode(p_tissue->GetLocationIndexUsingCell(cellB));

			double radiusA = nodeA->GetRadius();
        	double radiusB = nodeB->GetRadius();

        	double restLength = radiusA + radiusB;
						
			c_vector<double, 2> locationA = p_tissue->GetLocationOfCellCentre(cellA);
			c_vector<double, 2> locationB = p_tissue->GetLocationOfCellCentre(cellB);

			c_vector<double, 2> vectorAB = locationB - locationA;

			double lengthAB = norm_2(vectorAB);

			double dx = lengthAB - restLength;

			double forceMagnitude = mMembraneStiffness * dx;
			c_vector<double, 2> forceVector = forceMagnitude * vectorAB / lengthAB;

			nodeA->AddAppliedForceContribution(forceVector);
			nodeB->AddAppliedForceContribution(-forceVector);

			AddExternalForceContribution(nodeA, rCellPopulation);
		}
		// The last one gets missed, so do it manually
		AddExternalForceContribution(p_tissue->GetNode(p_tissue->GetLocationIndexUsingCell(membraneCells[membraneCells.size()-1])), rCellPopulation);
	}
}

void MembraneInternalForce::AddExternalForceContribution(Node<2>* pMembraneNode, AbstractCellPopulation<2>& rCellPopulation)
{
	// Get neighbours
	// Loop thoruhg
		// Check that neighbour is not another membrane node/cell
			// Apply force to non-membrane node
	MeshBasedCellPopulation<2>* p_tissue = static_cast<MeshBasedCellPopulation<2>*>(&rCellPopulation);

	std::vector<unsigned>& neighbours = pMembraneNode->rGetNeighbours();
	for (std::vector<unsigned>::iterator it = neighbours.begin(); it != neighbours.end(); it++)
    {
    	Node<2>* pNeighbour =  p_tissue->GetNode(*it);
    	CellPtr pCell = p_tissue->GetCellUsingLocationIndex(*it);
    	if (!pCell->GetCellProliferativeType()->IsType<MembraneType>())
    	{
    		double radiusA = pMembraneNode->GetRadius();
        	double radiusB = pNeighbour->GetRadius();

        	double restLength = radiusA + radiusB;
						
			c_vector<double, 2> locationA = pMembraneNode->rGetLocation();
			c_vector<double, 2> locationB = pNeighbour->rGetLocation();

			c_vector<double, 2> vectorAB = locationB - locationA;

			double lengthAB = norm_2(vectorAB);

			double dx = lengthAB - restLength;

			double forceMagnitude = mExternalStiffness * dx;
			c_vector<double, 2> forceVector = forceMagnitude * vectorAB / lengthAB;

			pMembraneNode->AddAppliedForceContribution(forceVector);
			pNeighbour->AddAppliedForceContribution(-forceVector);
    	}
    }

}


void MembraneInternalForce::SetMembraneSections(std::vector<std::vector<CellPtr>> membraneSections)
{
	mMembraneSections = membraneSections;
}

void MembraneInternalForce::OutputForceParameters(out_stream& rParamsFile)
{
	*rParamsFile <<  "\t\t\t<MembraneStiffness>"<<  mMembraneStiffness << "</MembraneStiffness> \n";

	// Call direct parent class
	AbstractForce<2>::OutputForceParameters(rParamsFile);
}


// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(MembraneInternalForce)
