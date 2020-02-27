#include <cxxtest/TestSuite.h>
#include "CheckpointArchiveTypes.hpp"
#include <boost/serialization/base_object.hpp>

#include "AbstractCellPopulationBoundaryCondition.hpp"
#include "BoundaryCellProperty.hpp"
#include "FixedPlaneBoundaryCondition.hpp"
#include "Debug.hpp"


FixedPlaneBoundaryCondition::FixedPlaneBoundaryCondition(AbstractCellPopulation<2>* pCellPopulation, unsigned axis)
	: AbstractCellPopulationBoundaryCondition<2>(pCellPopulation),
	mAxis(axis)
{
}

void FixedPlaneBoundaryCondition::ImposeBoundaryCondition(const std::map<Node<2>*, c_vector<double, 2> >& rOldLocations)
{
	for (AbstractCellPopulation<2>::Iterator cell_iter = this->mpCellPopulation->Begin();
		 cell_iter != this->mpCellPopulation->End();
		 ++cell_iter)
	{
		unsigned node_index = this->mpCellPopulation->GetLocationIndexUsingCell(*cell_iter);
		Node<2>* p_node = this->mpCellPopulation->GetNode(node_index);
		//double y_coordinate = p_node->rGetLocation()[1];
		//double x_coordinate = p_node->rGetLocation()[0];

		if (cell_iter->HasCellProperty<BoundaryCellProperty>())
		{
			// PRINT_VARIABLE(rOldLocations[p_node])
			typename std::map<Node<2>*, c_vector<double, 2> >::const_iterator it = rOldLocations.find(p_node);
			c_vector<double, 2> previous_location = it->second;
			p_node->rGetModifiableLocation()[mAxis] = previous_location[mAxis];
		}
	}
}

unsigned FixedPlaneBoundaryCondition::GetAxis() const
{
	return mAxis;
}

bool FixedPlaneBoundaryCondition::VerifyBoundaryCondition()
{
	bool condition_satisfied = true;

	return condition_satisfied;
}

void FixedPlaneBoundaryCondition::OutputCellPopulationBoundaryConditionParameters(out_stream& rParamsFile)
{
	AbstractCellPopulationBoundaryCondition<2>::OutputCellPopulationBoundaryConditionParameters(rParamsFile);
}

#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(FixedPlaneBoundaryCondition)
