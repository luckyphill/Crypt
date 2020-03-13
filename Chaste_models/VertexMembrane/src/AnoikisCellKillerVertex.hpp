
#ifndef AnoikisCELLKILLERVertex_HPP_
#define AnoikisCELLKILLERVertex_HPP_

#include "AbstractCellKiller.hpp"

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>
#include <boost/serialization/vector.hpp>

/**
 * A cell killer that kills any cell:
 *   1. that has the CellLabel property;
 *   2. is not the only cell to have the CellLabel property;
 *   3. shares no edges with any other cell with the CellLabel property.
 *
 * Works for a VertexBasedCellPopulation only.
 */
template<unsigned DIM>
class AnoikisCellKillerVertex : public AbstractCellKiller<DIM>
{
    friend class TestCellKillers;
private:

    /** Needed for serialization. */
    friend class boost::serialization::access;
    /**
     * Archive the object.
     *
     * @param archive the archive
     * @param version the current version of this class
     */
    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
        archive & boost::serialization::base_object<AbstractCellKiller<DIM> >(*this);
    }

public:

    /**
     * Default constructor.
     *
     * @param pCellPopulation pointer to a cell population
     */
    AnoikisCellKillerVertex(AbstractCellPopulation<DIM>* pCellPopulation);

    /**
     * Kills any isolated cells with the CellLabel property (unless there is only one such cell in the population).
     */
    void CheckAndLabelCellsForApoptosisOrDeath();

    /**
     * Overridden OutputCellKillerParameters() method.
     *
     * @param rParamsFile the file stream to which the parameters are output
     */
    void OutputCellKillerParameters(out_stream& rParamsFile);
};

#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(AnoikisCellKillerVertex)

namespace boost
{
namespace serialization
{
/**
 * Serialize information required to construct a AnoikisCellKillerVertex.
 */
template<class Archive, unsigned DIM>
inline void save_construct_data(
    Archive & ar, const AnoikisCellKillerVertex<DIM> * t, const unsigned int file_version)
{
    // Save data required to construct instance
    const AbstractCellPopulation<DIM>* const p_cell_population = t->GetCellPopulation();
    ar << p_cell_population;
}

/**
 * De-serialize constructor parameters and initialise a AnoikisCellKillerVertex.
 */
template<class Archive, unsigned DIM>
inline void load_construct_data(
    Archive & ar, AnoikisCellKillerVertex<DIM> * t, const unsigned int file_version)
{
    // Retrieve data from archive required to construct new instance
    AbstractCellPopulation<DIM>* p_cell_population;
    ar >> p_cell_population;

    // Invoke inplace constructor to initialise instance
    ::new(t)AnoikisCellKillerVertex<DIM>(p_cell_population);
}
}
} // namespace ...

#endif /*AnoikisCELLKILLERVertex_HPP_*/
