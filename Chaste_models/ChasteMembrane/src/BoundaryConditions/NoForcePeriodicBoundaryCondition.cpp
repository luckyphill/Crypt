#include <cxxtest/TestSuite.h>
#include "CheckpointArchiveTypes.hpp"
#include <boost/serialization/base_object.hpp>

#include "AbstractCellPopulationBoundaryCondition.hpp"
#include "NoForcePeriodicBoundaryCondition.hpp"
#include "Debug.hpp"

// This is a periodic boundary condition that only accounts for cell position
// it does not allow forces to be transmitted between cells that are neighbours
// across the boundary

template<unsigned SPACE_DIM>
NoForcePeriodicBoundaryCondition<SPACE_DIM>::NoForcePeriodicBoundaryCondition(AbstractCellPopulation<SPACE_DIM>* pCellPopulation)
	: AbstractCellPopulationBoundaryCondition<SPACE_DIM>(pCellPopulation)
{
}

template<unsigned SPACE_DIM>
void NoForcePeriodicBoundaryCondition<SPACE_DIM>::ImposeBoundaryCondition(const std::map<Node<SPACE_DIM>*, c_vector<double, SPACE_DIM> >& rOldLocations)
{

	for (typename AbstractCellPopulation<SPACE_DIM>::Iterator cell_iter = this->mpCellPopulation->Begin();
		 cell_iter != this->mpCellPopulation->End();
		 ++cell_iter)
	{
		unsigned node_index = this->mpCellPopulation->GetLocationIndexUsingCell(*cell_iter);
		Node<SPACE_DIM>* p_node = this->mpCellPopulation->GetNode(node_index);

		for (unsigned i=0; i < SPACE_DIM; i++)
		{
			if ( i == mAxis - 1 && p_node->rGetLocation()[i] > mTopBoundary)
			{
				// This cell has moved too far, so must jump to the other boundary
				// by an equivalent amount
				double excess = p_node->rGetLocation()[i] - mTopBoundary;
				p_node->rGetModifiableLocation()[i] = mBottomBoundary + excess;
			}

			if ( i == mAxis - 1 && p_node->rGetLocation()[i] < mBottomBoundary)
			{
				// This cell has moved too far, so must jump to the other boundary
				// by an equivalent amount
				double excess = p_node->rGetLocation()[i] - mBottomBoundary;
				p_node->rGetModifiableLocation()[i] = mTopBoundary + excess;
			}

		}
	}
}

template<unsigned SPACE_DIM>
bool NoForcePeriodicBoundaryCondition<SPACE_DIM>::VerifyBoundaryCondition()
{
	bool condition_satisfied = true;
	return condition_satisfied;
}

template<unsigned SPACE_DIM>
void NoForcePeriodicBoundaryCondition<SPACE_DIM>::SetTopBoundary(double topBoundary)
{
	mTopBoundary = topBoundary;
}

template<unsigned SPACE_DIM>
void NoForcePeriodicBoundaryCondition<SPACE_DIM>::SetBottomBoundary(double BottomBoundary)
{
	mBottomBoundary = BottomBoundary;
}

template<unsigned SPACE_DIM>
void NoForcePeriodicBoundaryCondition<SPACE_DIM>::SetAxis(unsigned axis)
{
	if (axis > SPACE_DIM)
	{
		EXCEPTION("Axis must be no greater than the number of space dimensions");
	}
	mAxis = axis;
}

template<unsigned SPACE_DIM>
void NoForcePeriodicBoundaryCondition<SPACE_DIM>::OutputCellPopulationBoundaryConditionParameters(out_stream& rParamsFile)
{
	AbstractCellPopulationBoundaryCondition<SPACE_DIM>::OutputCellPopulationBoundaryConditionParameters(rParamsFile);
}

template class NoForcePeriodicBoundaryCondition<1>;
template class NoForcePeriodicBoundaryCondition<2>;
template class NoForcePeriodicBoundaryCondition<3>;

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(NoForcePeriodicBoundaryCondition)
