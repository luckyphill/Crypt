#ifndef OFFLATTICESIMULATIONTEAROFFSTOPPINGEVENT_HPP_
#define OFFLATTICESIMULATIONTEAROFFSTOPPINGEVENT_HPP_

#include "OffLatticeSimulation.hpp"

/**
 * Simple subclass of OffLatticeSimulation which just overloads StoppingEventHasOccurred
 * for stopping a simulation when its become polyclonal of a given degree..
 */
class OffLatticeSimulationTearOffStoppingEvent : public OffLatticeSimulation<2>
{
private:
	/** Define a stopping event which says stop when there are no mutant or no healthy cells. */
		bool StoppingEventHasOccurred();
		Node<2>* mp_node;
		c_vector<double, 2> m_push_force;
		double conv_limit = 1e-4; // Should make this set manually, but can't be bothered
		double mstart = 0;

public:
		OffLatticeSimulationTearOffStoppingEvent(AbstractCellPopulation<2>& rCellPopulation);
		void SetSingleNode(Node<2>* pnode);
		void SetPushForce(c_vector<double, 2> push_force);
		void SetSimulationStartTime(double start);

};

// Serialization for Boost >= 1.26
#include "SerializationExportWrapper.hpp"
CHASTE_CLASS_EXPORT(OffLatticeSimulationTearOffStoppingEvent)

namespace boost
{
	namespace serialization
	{
		/**
		 * Serialize information required to construct a OffLatticeSimulationWithMyStoppingEvent.
		 */
		template<class Archive>
		inline void save_construct_data(
				Archive & ar, const OffLatticeSimulationTearOffStoppingEvent * t, const unsigned int file_version)
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
			Archive & ar, OffLatticeSimulationTearOffStoppingEvent * t, const unsigned int file_version)
		{
				// Retrieve data from archive required to construct new instance
				AbstractCellPopulation<2>* p_cell_population;
				ar >> p_cell_population;

				// Invoke inplace constructor to initialise instance
				::new(t)OffLatticeSimulationTearOffStoppingEvent(*p_cell_population);
		}
	}
} // namespace

#endif /*OFFLATTICESIMULATIONTEAROFFSTOPPINGEVENT_HPP_*/
