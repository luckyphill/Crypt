#include "IsNan.hpp"
#include "AbstractCellProperty.hpp"

#include "TransitCellProliferativeType.hpp"
#include "StemCellProliferativeType.hpp"
#include "NodeBasedCellPopulation.hpp"

#include "Debug.hpp"
#include "EpithelialType.hpp"
#include "StemType.hpp"
#include "EpithelialInternalForce.hpp"


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
EpithelialInternalForce<ELEMENT_DIM,SPACE_DIM>::EpithelialInternalForce()
   : AbstractTwoBodyInteractionForce<ELEMENT_DIM,SPACE_DIM>(),
	mSpringStiffness(15.0),
	mRestLength(1.0),
	mCutOffLength(1.1),
	mAttractionParameter(5.0)

{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
EpithelialInternalForce<ELEMENT_DIM,SPACE_DIM>::~EpithelialInternalForce()
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
c_vector<double, SPACE_DIM> EpithelialInternalForce<ELEMENT_DIM,SPACE_DIM>::CalculateForceBetweenNodes(unsigned nodeAGlobalIndex,
																					unsigned nodeBGlobalIndex,
																					AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation)
{

	MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>* p_tissue = static_cast<MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>*>(&rCellPopulation);
	// We should only ever calculate the force between two distinct nodes
	assert(nodeAGlobalIndex != nodeBGlobalIndex);

	CellPtr pCellA = rCellPopulation.GetCellUsingLocationIndex(nodeAGlobalIndex);
	CellPtr pCellB = rCellPopulation.GetCellUsingLocationIndex(nodeBGlobalIndex);

	c_vector<double, SPACE_DIM> zero_vector;
	for (unsigned i=0; i < SPACE_DIM; i++)
	{
		zero_vector[i] = 0;
	}

	bool isEpithelialA = pCellA->GetCellProliferativeType()->IsType<EpithelialType>() || pCellA->GetCellProliferativeType()->IsType<StemType>();
	bool isEpithelialB = pCellB->GetCellProliferativeType()->IsType<EpithelialType>() || pCellB->GetCellProliferativeType()->IsType<StemType>();

	if (!isEpithelialA || !isEpithelialB)
	{
		return zero_vector;
	}
	else
	{
		Node<SPACE_DIM>* nodeA = rCellPopulation.GetNode(nodeAGlobalIndex);
		Node<SPACE_DIM>* nodeB = rCellPopulation.GetNode(nodeBGlobalIndex);

		// Get the node locations
		c_vector<double, SPACE_DIM> locationA = nodeA->rGetLocation();
		c_vector<double, SPACE_DIM> locationB = nodeB->rGetLocation();

		double radiusA = nodeA->GetRadius();
		double radiusB = nodeB->GetRadius();

		double restLength = radiusA + radiusB;


		// Get the unit vector parallel to the line joining the two nodes
		c_vector<double, SPACE_DIM> unitForceDirection;

		unitForceDirection = rCellPopulation.rGetMesh().GetVectorFromAtoB(locationA, locationB);

		// Calculate the distance between the two nodes
		double lengthAB = norm_2(unitForceDirection);
		assert(lengthAB > 0);
		assert(!std::isnan(lengthAB));

		

		unitForceDirection /= lengthAB;

		if (lengthAB > mCutOffLength)
		{
			return zero_vector;
		}


		// Checks if both cells have the same parent
		// *****************************************************************************************
		// Implements cell sibling tracking
		double ageA = pCellA->GetAge();
		double ageB = pCellB->GetAge();

		double parentA = pCellA->GetCellData()->GetItem("parent");
		double parentB = pCellB->GetCellData()->GetItem("parent");

		double minLength = (p_tissue->GetMeinekeDivisionSeparation() + 1.0)/0.7; // Using same reasoning as in BasicNonLinearSpringForceMultiNodeFix


		if (ageA < mMeinekeSpringGrowthDuration && ageA == ageB && parentA == parentB)
		{
			// Make the spring length grow.
			double lambda = mMeinekeDivisionRestingSpringLength;
			restLength = minLength + (lambda - minLength) * ageA/mMeinekeSpringGrowthDuration;
			// restLength = lambda + (restLength - lambda) * ageA/mMeinekeSpringGrowthDuration;
		}
		// *****************************************************************************************

		double dx = lengthAB - restLength;

		if (dx <= 0) //dx is negative
		{
			// log(x+1) is undefined for x<=-1
			assert(dx > -restLength);
			c_vector<double, 2> temp = mSpringStiffness * unitForceDirection * restLength * log(1.0 + dx/restLength);
			return temp;
		}
		else
		{
			double alpha = mAttractionParameter;
			c_vector<double, 2> temp = mSpringStiffness * unitForceDirection * dx * exp(-alpha * dx/restLength);
			return temp;
		}
	}

}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void EpithelialInternalForce<ELEMENT_DIM,SPACE_DIM>::SetAttractionParameter(double attractionParameter)
{
	mAttractionParameter = attractionParameter;
}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void EpithelialInternalForce<ELEMENT_DIM,SPACE_DIM>::SetSpringStiffness(double SpringStiffness)
{
	assert(SpringStiffness > 0.0);
	mSpringStiffness = SpringStiffness;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void EpithelialInternalForce<ELEMENT_DIM,SPACE_DIM>::SetRestLength(double RestLength)
{
	assert(RestLength > 0.0);
	mRestLength = RestLength;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void EpithelialInternalForce<ELEMENT_DIM,SPACE_DIM>::SetCutOffLength(double CutOffLength)
{
	assert(CutOffLength > 0.0);
	mCutOffLength = CutOffLength;
}


// For growing spring length
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void EpithelialInternalForce<ELEMENT_DIM,SPACE_DIM>::SetMeinekeSpringStiffness(double springStiffness)
{
	assert(springStiffness > 0.0);
	mMeinekeSpringStiffness = springStiffness;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void EpithelialInternalForce<ELEMENT_DIM,SPACE_DIM>::SetMeinekeDivisionRestingSpringLength(double divisionRestingSpringLength)
{
	assert(divisionRestingSpringLength <= 1.0);
	assert(divisionRestingSpringLength >= 0.0);

	mMeinekeDivisionRestingSpringLength = divisionRestingSpringLength;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void EpithelialInternalForce<ELEMENT_DIM,SPACE_DIM>::SetMeinekeSpringGrowthDuration(double springGrowthDuration)
{
	assert(springGrowthDuration >= 0.0);

	mMeinekeSpringGrowthDuration = springGrowthDuration;
}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void EpithelialInternalForce<ELEMENT_DIM,SPACE_DIM>::OutputForceParameters(out_stream& rParamsFile)
{
	*rParamsFile << "\t\t\t<SpringStiffness>" << mSpringStiffness << "</SpringStiffness>\n";

	// Call method on direct parent class
	AbstractTwoBodyInteractionForce<ELEMENT_DIM,SPACE_DIM>::OutputForceParameters(rParamsFile);
	// Call method on direct parent class
}

/////////////////////////////////////////////////////////////////////////////
// Explicit instantiation
/////////////////////////////////////////////////////////////////////////////

template class EpithelialInternalForce<1,1>;
template class EpithelialInternalForce<1,2>;
template class EpithelialInternalForce<2,2>;
template class EpithelialInternalForce<1,3>;
template class EpithelialInternalForce<2,3>;
template class EpithelialInternalForce<3,3>;

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(EpithelialInternalForce)