/*

Stops the simulation when a cell pops up

*/

#ifndef OffLatticeSimulationPoppedUpStoppingEvent_HPP_
#define OffLatticeSimulationPoppedUpStoppingEvent_HPP_
#include "SimpleAnoikisCellKiller.hpp"
#include "OffLatticeSimulation.hpp"

/**
 * Simple subclass of OffLatticeSimulation which just overloads StoppingEventHasOccurred
 * for stopping a simulation when its become polyclonal of a given degree..
 */
class OffLatticeSimulationPoppedUpStoppingEvent : public OffLatticeSimulation<2>
{
private:
	/** Define a stopping event which says stop when there are no mutant or no healthy cells. */
    bool StoppingEventHasOccurred();

    boost::shared_ptr<SimpleAnoikisCellKiller> mPopUpKiller;


public:
    OffLatticeSimulationPoppedUpStoppingEvent(AbstractCellPopulation<2>& rCellPopulation);

    void SetPopUpKiller(boost::shared_ptr<SimpleAnoikisCellKiller> popUpKiller);


};

// Serialization for Boost >= 1.26
#include "SerializationExportWrapper.hpp"
CHASTE_CLASS_EXPORT(OffLatticeSimulationPoppedUpStoppingEvent)

namespace boost
{
namespace serialization
{
/**
 * Serialize information required to construct a OffLatticeSimulationWithMyStoppingEvent.
 */
template<class Archive>
inline void save_construct_data(
    Archive & ar, const OffLatticeSimulationPoppedUpStoppingEvent * t, const unsigned int file_version)
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
	Archive & ar, OffLatticeSimulationPoppedUpStoppingEvent * t, const unsigned int file_version)
{
    // Retrieve data from archive required to construct new instance
    AbstractCellPopulation<2>* p_cell_population;
    ar >> p_cell_population;

    // Invoke inplace constructor to initialise instance
    ::new(t)OffLatticeSimulationPoppedUpStoppingEvent(*p_cell_population);
}
}
} // namespace

#endif /*OffLatticeSimulationPoppedUpStoppingEvent_HPP_*/
