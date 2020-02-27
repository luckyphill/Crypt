#include "StopCreepBoundaryCondition.hpp"
#include "AbstractCentreBasedCellPopulation.hpp"
#include "VertexBasedCellPopulation.hpp"
#include "StromalType.hpp"

template<class T>
StopCreepBoundaryCondition<T>::StopCreepBoundaryCondition(AbstractCellPopulation<2,2>* pCellPopulation,
													c_vector<double, 2> point,
													c_vector<double, 2> normal)
		: AbstractCellPopulationBoundaryCondition<2,2>(pCellPopulation),
		  mPointOnPlane(point),
		  mUseJiggledNodesOnPlane(false)
{
	assert(norm_2(normal) > 0.0);
	mNormalToPlane = normal/norm_2(normal);
}

template<class T>
const c_vector<double, 2>& StopCreepBoundaryCondition<T>::rGetPointOnPlane() const
{
	return mPointOnPlane;
}

template<class T>
const c_vector<double, 2>& StopCreepBoundaryCondition<T>::rGetNormalToPlane() const
{
	return mNormalToPlane;
}


template<class T>
void StopCreepBoundaryCondition<T>::SetUseJiggledNodesOnPlane(bool useJiggledNodesOnPlane)
{
	mUseJiggledNodesOnPlane = useJiggledNodesOnPlane;
}

template<class T>
bool StopCreepBoundaryCondition<T>::GetUseJiggledNodesOnPlane()
{
	return mUseJiggledNodesOnPlane;
}

template<class T>
void StopCreepBoundaryCondition<T>::ImposeBoundaryCondition(const std::map<Node<2>*, c_vector<double, 2> >& rOldLocations)
{

	if (dynamic_cast<AbstractOffLatticeCellPopulation<2,2>*>(this->mpCellPopulation)==nullptr)
	{
		EXCEPTION("StopCreepBoundaryCondition requires a subof AbstractOffLatticeCellPopulation.");
	}

	assert((dynamic_cast<AbstractCentreBasedCellPopulation<2,2>*>(this->mpCellPopulation))
			|| ((dynamic_cast<VertexBasedCellPopulation<2>*>(this->mpCellPopulation))) );

	// This is a magic number
	double max_jiggle = 1e-4;


	for (typename AbstractCellPopulation<2,2>::Iterator cellIter = this->mpCellPopulation->Begin();
         cellIter != this->mpCellPopulation->End();
         ++cellIter)
    {
		// Only apply this BC to specified cell types
		if ((*cellIter)->GetCellProliferativeType()->IsType<T>())
		{
			unsigned node_index = this->mpCellPopulation->GetLocationIndexUsingCell(*cellIter);
			Node<2>* p_node = this->mpCellPopulation->GetNode(node_index);
	
			c_vector<double, 2> node_location = p_node->rGetLocation();
	
			double signed_distance = inner_prod(node_location - mPointOnPlane, mNormalToPlane);
			if (signed_distance > 0.0)
			{
				// For the closest point on the plane we travel from node_location the signed_distance in the direction of -mNormalToPlane
				c_vector<double, 2> nearest_point;
				if (mUseJiggledNodesOnPlane)
				{
					nearest_point = node_location - (signed_distance+max_jiggle*RandomNumberGenerator::Instance()->ranf())*mNormalToPlane;
				}
				else
				{
					nearest_point = node_location - signed_distance*mNormalToPlane;
				}
				p_node->rGetModifiableLocation() = nearest_point;
			}
		}
	}
}

template<class T>
bool StopCreepBoundaryCondition<T>::VerifyBoundaryCondition()
{
	bool condition_satisfied = true;

	if (2 == 1)
	{
		EXCEPTION("StopCreepBoundaryCondition is not implemented in 1D");
	}
	else
	{
		for (typename AbstractCellPopulation<2,2>::Iterator cellIter = this->mpCellPopulation->Begin();
			 cellIter != this->mpCellPopulation->End();
			 ++cellIter)
		{
			c_vector<double, 2> cell_location = this->mpCellPopulation->GetLocationOfCellCentre(*cellIter);

			if (inner_prod(cell_location - mPointOnPlane, mNormalToPlane) > 0.0)
			{
				condition_satisfied = false;
				break;
			}
		}
	}

	return condition_satisfied;
}

template<class T>
void StopCreepBoundaryCondition<T>::OutputCellPopulationBoundaryConditionParameters(out_stream& rParamsFile)
{
	*rParamsFile << "\t\t\t<PointOnPlane>";
	for (unsigned index=0; index != 2-1U; index++) // Note: inequality avoids testing index < 0U when DIM=1
	{
		*rParamsFile << mPointOnPlane[index] << ",";
	}
	*rParamsFile << mPointOnPlane[2-1] << "</PointOnPlane>\n";

	*rParamsFile << "\t\t\t<NormalToPlane>";
	for (unsigned index=0; index != 2-1U; index++) // Note: inequality avoids testing index < 0U when DIM=1
	{
		*rParamsFile << mNormalToPlane[index] << ",";
	}
	*rParamsFile << mNormalToPlane[2-1] << "</NormalToPlane>\n";
	*rParamsFile << "\t\t\t<UseJiggledNodesOnPlane>" << mUseJiggledNodesOnPlane << "</UseJiggledNodesOnPlane>\n";

	// Call method on direct parent class
	AbstractCellPopulationBoundaryCondition::OutputCellPopulationBoundaryConditionParameters(rParamsFile);
}

// // Explicit instantiation
template class StopCreepBoundaryCondition<StromalType>;


// // Serialization for Boost >= 1.36
// #include "SerializationExportWrapperForCpp.hpp"
// EXPORT_TEMPLATE_CLASS_ALL_DIMS(StopCreepBoundaryCondition)
