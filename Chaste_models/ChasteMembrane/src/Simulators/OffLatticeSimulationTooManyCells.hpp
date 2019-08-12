#ifndef OFFLATTICESIMULATIONTooManyCells_HPP_
#define OFFLATTICESIMULATIONTooManyCells_HPP_

#include "OffLatticeSimulation.hpp"
#include "Debug.hpp"
#include <boost/serialization/base_object.hpp>

/**
 * Simple subclass of OffLatticeSimulation which just overloads StoppingEventHasOccurred
 * for stopping a simulation when its become polyclonal of a given degree..
 */
class OffLatticeSimulationTooManyCells : public OffLatticeSimulation<2>
{
private:
	/** Define a stopping event which says stop when there are no mutant or no healthy cells. */
		bool StoppingEventHasOccurred();
		unsigned mCellLimit;

		 /** Needed for serialization. */
		friend class boost::serialization::access;

		template<class Archive>
		void serialize(Archive & archive, const unsigned int version)
		{
			archive & boost::serialization::base_object<OffLatticeSimulation<2> >(*this);
			archive & mCellLimit;
		}

public:
		OffLatticeSimulationTooManyCells(AbstractCellPopulation<2>& rCellPopulation);
		OffLatticeSimulationTooManyCells(AbstractCellPopulation<2>& rCellPopulation, unsigned cell_limit);
		void SetCellLimit(unsigned cell_limit);
		unsigned GetCellLimit();

};

// Serialization for Boost >= 1.26
#include "SerializationExportWrapper.hpp"
CHASTE_CLASS_EXPORT(OffLatticeSimulationTooManyCells)

namespace boost
{
	namespace serialization
	{
		/**
		 * Serialize information required to construct a OffLatticeSimulationWithMyStoppingEvent.
		 */
		template<class Archive>
		inline void save_construct_data(Archive & ar, const OffLatticeSimulationTooManyCells * t, const unsigned int file_version)
		{
			// Save data required to construct instance
			const AbstractCellPopulation<2>* p_cell_population = &(t->rGetCellPopulation());
			ar & p_cell_population;
		}

		/**
		 * De-serialize constructor parameters and initialise a OffLatticeSimulationWithMyStoppingEvent.
		 */
		template<class Archive>
		inline void load_construct_data(Archive & ar, OffLatticeSimulationTooManyCells * t, const unsigned int file_version)
		{
			// Retrieve data from archive required to construct new instance
			AbstractCellPopulation<2>* p_cell_population;
			ar >> p_cell_population;


			// Invoke inplace constructor to initialise instance
			::new(t)OffLatticeSimulationTooManyCells(*p_cell_population);
		}
	}
} // namespace

#endif /*OFFLATTICESIMULATIONTooManyCells_HPP_*/
