

#ifndef OFFLATTICESIMULATIONMutationWashOut_HPP_
#define OFFLATTICESIMULATIONMutationWashOut_HPP_

#include "OffLatticeSimulation.hpp"

/**
 * Simple subclass of OffLatticeSimulation which just overloads StoppingEventHasOccurred
 * for stopping a simulation when its become polyclonal of a given degree..
 */
class OffLatticeSimulationMutationWashOut : public OffLatticeSimulation<2>
{
private:
	/** Define a stopping event which says stop when there are no mutant or no healthy cells. */
	bool StoppingEventHasOccurred();
	unsigned mCellLimit = 10000;
	bool watchForWashOut = false;

public:
	OffLatticeSimulationMutationWashOut(AbstractCellPopulation<2>& rCellPopulation);
	void SetCellLimit(unsigned cell_limit);
	void WashOutSwitch();

};

// Serialization for Boost >= 1.26
#include "SerializationExportWrapper.hpp"
CHASTE_CLASS_EXPORT(OffLatticeSimulationMutationWashOut)

namespace boost
{
	namespace serialization
	{
		/**
		 * Serialize information required to construct a OffLatticeSimulationWithMyStoppingEvent.
		 */
		template<class Archive>
		inline void save_construct_data(
			Archive & ar, const OffLatticeSimulationMutationWashOut * t, const unsigned int file_version)
		{
			// Save data required to construct instance
			const AbstractCellPopulation<2>* p_cell_population = &(t->rGetCellPopulation());
			ar & p_cell_population;
		}

		/**
		 * De-serialize constructor parameters and initialise a OffLatticeSimulationWithMyStoppingEvent.
		 */
		template<class Archive>
		inline void load_construct_data(
			Archive & ar, OffLatticeSimulationMutationWashOut * t, const unsigned int file_version)
		{
			// Retrieve data from archive required to construct new instance
			AbstractCellPopulation<2>* p_cell_population;
			ar >> p_cell_population;

			// Invoke inplace constructor to initialise instance
			::new(t)OffLatticeSimulationMutationWashOut(*p_cell_population);
		}
	}
} // namespace

#endif /*OFFLATTICESIMULATIONMutationWashOut_HPP_*/
