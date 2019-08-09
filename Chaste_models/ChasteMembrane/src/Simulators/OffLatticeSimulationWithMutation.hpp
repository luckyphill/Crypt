/*

This implements a stopping event for crypts with mutant cells
There are three stopping criteria:

ALWAYS: Stop when mutation has cleared from the crypt - the simulation is no longer interesting
			-Stop as soon as monolayer is clear of mutant - used for determining proportions
			-Stop when mutant has cleared crypt - used for observing serration pattern
		Stop when cell count breaks a certain threshold - by default set relatively high

WHEN REQUIRED: Stop when clonal conversion occurs - used for proportion testing

*/

#ifndef OFFLATTICESIMULATIONWithMutation_HPP_
#define OFFLATTICESIMULATIONWithMutation_HPP_

#include "OffLatticeSimulation.hpp"
#include <boost/serialization/base_object.hpp>

/**
 * Simple subclass of OffLatticeSimulation which just overloads StoppingEventHasOccurred
 * for stopping a simulation when its become polyclonal of a given degree..
 */
class OffLatticeSimulationWithMutation : public OffLatticeSimulation<2>
{
private:
	/** Define a stopping event which says stop when there are no mutant or no healthy cells. */
	bool StoppingEventHasOccurred();
	
	unsigned mCellLimit = 1000;

	bool stopOnEmptyMonolayer = false;
	bool monolayerEmpty = false; // A flag to make sure notified only once of empty monolayer
	bool monolayerFull = false; // A flag to make sure notified only once of clonal conversion

	bool stopOnClonalConversion = false;

	// A switch needed to stop the simulation terminating during transient burn-in phase
	bool watchForWashOut = false;

	/** Needed for serialization. */
	friend class boost::serialization::access;

	template<class Archive>
	void serialize(Archive & archive, const unsigned int version)
	{
		archive & boost::serialization::base_object<OffLatticeSimulation<2> >(*this);
		archive & mCellLimit;

		archive & stopOnEmptyMonolayer;
		archive & monolayerEmpty;
		archive & monolayerFull;
		archive & stopOnClonalConversion;
		archive & watchForWashOut;

	}
   

public:
	OffLatticeSimulationWithMutation(AbstractCellPopulation<2>& rCellPopulation);
	
	void SetCellLimit(unsigned cell_limit);
	
	void StopOnEmptyMonolayer();
	
	void StopOnClonalConversion();

	void WashOutSwitch();

};

// Serialization for Boost >= 1.26
#include "SerializationExportWrapper.hpp"
CHASTE_CLASS_EXPORT(OffLatticeSimulationWithMutation)

namespace boost
{
	namespace serialization
	{
		/**
		 * Serialize information required to construct a OffLatticeSimulationWithMyStoppingEvent.
		 */
		template<class Archive>
		inline void save_construct_data(
			Archive & ar, const OffLatticeSimulationWithMutation * t, const unsigned int file_version)
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
			Archive & ar, OffLatticeSimulationWithMutation * t, const unsigned int file_version)
		{
			// Retrieve data from archive required to construct new instance
			AbstractCellPopulation<2>* p_cell_population;
			ar >> p_cell_population;

			// Invoke inplace constructor to initialise instance
			::new(t)OffLatticeSimulationWithMutation(*p_cell_population);
		}
	}
} // namespace

#endif /*OFFLATTICESIMULATIONWithMutation_HPP_*/
