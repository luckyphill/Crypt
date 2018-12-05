#ifndef RADIALDIFFERENTIATIONMODIFIER_HPP_
#define RADIALDIFFERENTIATIONMODIFIER_HPP_

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>

#include "AbstractCellBasedSimulationModifier.hpp"

/**
 * A modifier class which at each simulation time step sets any cell outside a given radius
 * to be differentiated.
 */
template<unsigned DIM>
class RadialDifferentiationModifier : public AbstractCellBasedSimulationModifier<DIM,DIM>
{
    /** Radius of differentiation. */
    double mRadius;

    /** Needed for serialization. */
    friend class boost::serialization::access;
    /**
     * Boost Serialization method for archiving/checkpointing.
     * Archives the object and its member variables.
     *
     * @param archive  The boost archive.
     * @param version  The current version of this class.
     */
    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
        archive & boost::serialization::base_object<AbstractCellBasedSimulationModifier<DIM,DIM> >(*this);
        archive & mRadius;
    }

public:

    /**
     * Default constructor.
     */
    RadialDifferentiationModifier();

    /**
     * Destructor.
     */
    virtual ~RadialDifferentiationModifier();

    /**
     * Overridden UpdateAtEndOfTimeStep() method.
     *
     * Specify what to do in the simulation at the end of each time step.
     *
     * @param rCellPopulation reference to the cell population
     */
    virtual void UpdateAtEndOfTimeStep(AbstractCellPopulation<DIM,DIM>& rCellPopulation);

    /**
     * Overridden SetupSolve() method.
     *
     * Specify what to do in the simulation before the start of the time loop.
     *
     * @param rCellPopulation reference to the cell population
     * @param outputDirectory the output directory, relative to where Chaste output is stored
     */
    virtual void SetupSolve(AbstractCellPopulation<DIM,DIM>& rCellPopulation, std::string outputDirectory);

    /**
     * Helper method to differentiate cells outside the given Radius
     *
     * @param rCellPopulation reference to the cell population
     */
    void DifferentiateCells(AbstractCellPopulation<DIM,DIM>& rCellPopulation);

    /**
     * @return mRadius.
     */
    double GetRadius();

    /**
     * Set mRadius.
     *
     * @param radius the new value for mRadius.
     *
     */
    void SetRadius(double radius);

    /**
     * Overridden OutputSimulationModifierParameters() method.
     * Output any simulation modifier parameters to file.
     *
     * @param rParamsFile the file stream to which the parameters are output
     */
    void OutputSimulationModifierParameters(out_stream& rParamsFile);
};

#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(RadialDifferentiationModifier)

#endif /*RADIALDIFFERENTIATIONMODIFIER_HPP_*/
