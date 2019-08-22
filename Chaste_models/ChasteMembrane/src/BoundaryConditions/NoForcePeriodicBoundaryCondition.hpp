#ifndef NoForcePeriodicBoundaryCondition_HPP_
#define NoForcePeriodicBoundaryCondition_HPP_

#include <cxxtest/TestSuite.h>
#include "CheckpointArchiveTypes.hpp"
#include <boost/serialization/base_object.hpp>

#include "AbstractCellPopulationBoundaryCondition.hpp"
#include "BoundaryCellProperty.hpp"
#include "Debug.hpp"

// Forces all cells marked with the BoundaryCellProperty to keep their y position 0

template<unsigned SPACE_DIM>
class NoForcePeriodicBoundaryCondition : public AbstractCellPopulationBoundaryCondition<SPACE_DIM>
{
private:

	friend class boost::serialization::access;
	template<class Archive>
	void serialize(Archive & archive, const unsigned int version)
	{
		archive & boost::serialization::base_object<AbstractCellPopulationBoundaryCondition<SPACE_DIM> >(*this);
		archive & mTopBoundary;
		archive & mBottomBoundary;
		archive & mAxis;
	}

	double mTopBoundary;
	double mBottomBoundary;
	unsigned mAxis;

public:
	NoForcePeriodicBoundaryCondition(AbstractCellPopulation<SPACE_DIM>* pCellPopulation);

	void ImposeBoundaryCondition(const std::map<Node<SPACE_DIM>*, c_vector<double, SPACE_DIM> >& rOldLocations);

	bool VerifyBoundaryCondition();

	void SetTopBoundary(double topBoundary);
	void SetBottomBoundary(double BottomBoundary);
	void SetAxis(unsigned axis);

	void OutputCellPopulationBoundaryConditionParameters(out_stream& rParamsFile);

};

#include "SerializationExportWrapper.hpp"
// Declare identifier for the serializer
EXPORT_TEMPLATE_CLASS_SAME_DIMS(NoForcePeriodicBoundaryCondition)

namespace boost
{
	namespace serialization
	{
		/**
		 * Serialize information required to construct a PlaneBoundaryCondition.
		 */
		template<class Archive, unsigned SPACE_DIM>
		inline void save_construct_data(Archive & ar, const NoForcePeriodicBoundaryCondition<SPACE_DIM>* t, const unsigned int file_version)
		{
			// Save data required to construct instance
			const AbstractCellPopulation<SPACE_DIM>* const p_cell_population = t->GetCellPopulation();
			ar << p_cell_population;
		}

		/**
		 * De-serialize constructor parameters and initialize a PlaneBoundaryCondition.
		 */
		template<class Archive, unsigned SPACE_DIM>
		inline void load_construct_data(Archive & ar, NoForcePeriodicBoundaryCondition<SPACE_DIM>* t, const unsigned int file_version)
		{
			// Retrieve data from archive required to construct new instance
			AbstractCellPopulation<SPACE_DIM>* p_cell_population;
			ar >> p_cell_population;

			// Invoke inplace constructor to initialise instance
			::new(t)NoForcePeriodicBoundaryCondition<SPACE_DIM>(p_cell_population);
		}
	}
} // namespace ...

#endif