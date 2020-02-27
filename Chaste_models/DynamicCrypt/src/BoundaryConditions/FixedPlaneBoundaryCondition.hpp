#ifndef FixedPlaneBOUNDARYCONDITION_HPP_
#define FixedPlaneBOUNDARYCONDITION_HPP_

#include <cxxtest/TestSuite.h>
#include "CheckpointArchiveTypes.hpp"
#include <boost/serialization/base_object.hpp>

#include "AbstractCellPopulationBoundaryCondition.hpp"
#include "BoundaryCellProperty.hpp"
#include "Debug.hpp"

// Forces all cells marked with the BoundaryCellProperty to keep their y position 0

class FixedPlaneBoundaryCondition : public AbstractCellPopulationBoundaryCondition<2>
{
private:

	// The axis that is fixed for a cell with the BoundaryCellProperty
	unsigned mAxis;

	friend class boost::serialization::access;
	template<class Archive>
	void serialize(Archive & archive, const unsigned int version)
	{
		archive & boost::serialization::base_object<AbstractCellPopulationBoundaryCondition<2> >(*this);
		archive & mAxis;
	}

public:
	FixedPlaneBoundaryCondition(AbstractCellPopulation<2>* pCellPopulation, unsigned axis);

	void ImposeBoundaryCondition(const std::map<Node<2>*, c_vector<double, 2> >& rOldLocations);
	unsigned GetAxis() const;

	bool VerifyBoundaryCondition();

	void OutputCellPopulationBoundaryConditionParameters(out_stream& rParamsFile);

};

#include "SerializationExportWrapper.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(FixedPlaneBoundaryCondition)

namespace boost
{
	namespace serialization
	{
		/**
		 * Serialize information required to construct a PlaneBoundaryCondition.
		 */
		template<class Archive>
		inline void save_construct_data(Archive & ar, const FixedPlaneBoundaryCondition* t, const unsigned int file_version)
		{
			// Save data required to construct instance
			const AbstractCellPopulation<2>* const p_cell_population = t->GetCellPopulation();
			const unsigned axis = t->GetAxis();
			ar << p_cell_population;
			ar << axis;
		}

		/**
		 * De-serialize constructor parameters and initialize a PlaneBoundaryCondition.
		 */
		template<class Archive>
		inline void load_construct_data(Archive & ar, FixedPlaneBoundaryCondition* t, const unsigned int file_version)
		{
			// Retrieve data from archive required to construct new instance
			AbstractCellPopulation<2>* p_cell_population;
			unsigned axis;
			ar >> p_cell_population;
			ar >> axis;

			// Invoke inplace constructor to initialise instance
			::new(t)FixedPlaneBoundaryCondition(p_cell_population, axis);
		}
	}
} // namespace ...

#endif