#ifndef CRYPTBOUNDARYCONDITION_HPP_
#define CRYPTBOUNDARYCONDITION_HPP_

#include <cxxtest/TestSuite.h>
#include "CheckpointArchiveTypes.hpp"
#include <boost/serialization/base_object.hpp>

#include "AbstractCellPopulationBoundaryCondition.hpp"
#include "BoundaryCellProperty.hpp"
#include "Debug.hpp"

// Forces all cells marked with the BoundaryCellProperty to keep their y position 0

class CryptBoundaryCondition : public AbstractCellPopulationBoundaryCondition<2>
{
private:

	friend class boost::serialization::access;
	template<class Archive>
	void serialize(Archive & archive, const unsigned int version)
	{
		archive & boost::serialization::base_object<AbstractCellPopulationBoundaryCondition<2> >(*this);
	}

public:
	CryptBoundaryCondition(AbstractCellPopulation<2>* pCellPopulation);

	void ImposeBoundaryCondition(const std::map<Node<2>*, c_vector<double, 2> >& rOldLocations);

	bool VerifyBoundaryCondition();

	void OutputCellPopulationBoundaryConditionParameters(out_stream& rParamsFile);

};

#include "SerializationExportWrapper.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(CryptBoundaryCondition)

namespace boost
{
	namespace serialization
	{
		/**
		 * Serialize information required to construct a PlaneBoundaryCondition.
		 */
		template<class Archive>
		inline void save_construct_data(Archive & ar, const CryptBoundaryCondition* t, const unsigned int file_version)
		{
			// Save data required to construct instance
			const AbstractCellPopulation<2>* const p_cell_population = t->GetCellPopulation();
			ar << p_cell_population;
		}

		/**
		 * De-serialize constructor parameters and initialize a PlaneBoundaryCondition.
		 */
		template<class Archive>
		inline void load_construct_data(Archive & ar, CryptBoundaryCondition* t, const unsigned int file_version)
		{
			// Retrieve data from archive required to construct new instance
			AbstractCellPopulation<2>* p_cell_population;
			ar >> p_cell_population;

			// Invoke inplace constructor to initialise instance
			::new(t)CryptBoundaryCondition(p_cell_population);
		}
	}
} // namespace ...

#endif