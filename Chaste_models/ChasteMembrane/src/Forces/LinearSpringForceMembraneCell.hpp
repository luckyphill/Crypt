

#ifndef LINEARSPRINGFORCEMEMBRANECELL_HPP_
#define LINEARSPRINGFORCEMEMBRANECELL_HPP_

#include "AbstractTwoBodyInteractionForce.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>

/**
 * A force law initially employed by Meineke et al (2001) in their off-lattice
 * model of the intestinal crypt (doi:10.1046/j.0960-7722.2001.00216.x).
 *
 * Each pair of neighbouring nodes are assumed to be connected by a linear
 * spring. The force of node \f$i\f$ is given
 * by
 *
 * \f[
 * \mathbf{F}_{i}(t) = \sum_{j} \mu_{i,j} ( || \mathbf{r}_{i,j} || - s_{i,j}(t) ) \hat{\mathbf{r}}_{i,j}.
 * \f]
 *
 * Here \f$\mu_{i,j}\f$ is the spring constant for the spring between nodes
 * \f$i\f$ and \f$j\f$, \f$s_{i,j}(t)\f$ is its natural length at time \f$t\f$,
 * \f$\mathbf{r}_{i,j}\f$ is their relative displacement and a hat (\f$\hat{}\f$)
 * denotes a unit vector.
 *
 * Length is scaled by natural length.
 * Time is in hours.
 */
template<unsigned  ELEMENT_DIM, unsigned SPACE_DIM=ELEMENT_DIM>
class LinearSpringForceMembraneCell : public AbstractTwoBodyInteractionForce<ELEMENT_DIM, SPACE_DIM>
{
    friend class TestForces;

private:

    /** Needed for serialization. */
    friend class boost::serialization::access;
    /**
     * Archive the object and its member variables.
     *
     * @param archive the archive
     * @param version the current version of this class
     */
    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
        archive & boost::serialization::base_object<AbstractTwoBodyInteractionForce<ELEMENT_DIM, SPACE_DIM> >(*this);
        archive & mEpithelialSpringStiffness; // Epithelial covers stem and transit
        archive & mMembraneSpringStiffness;
        archive & mStromalSpringStiffness; // Stromal is the differentiated "filler" cells
        archive & mEpithelialMembraneSpringStiffness;
        archive & mMembraneStromalSpringStiffness;
        archive & mStromalEpithelialSpringStiffness;
        archive & mMeinekeDivisionRestingSpringLength;
        archive & mMeinekeSpringGrowthDuration;
    }

protected:


    double mEpithelialSpringStiffness; // Epithelial covers stem and transit
    double mMembraneSpringStiffness;
    double mStromalSpringStiffness; // Stromal is the differentiated "filler" cells
    double mEpithelialMembraneSpringStiffness;
    double mMembraneStromalSpringStiffness;
    double mStromalEpithelialSpringStiffness;

    double mEpithelialRestLength; // Epithelial covers stem and transit
    double mMembraneRestLength;
    double mStromalRestLength; // Stromal is the differentiated "filler" cells
    double mEpithelialMembraneRestLength;
    double mMembraneStromalRestLength;
    double mStromalEpithelialRestLength;

    double mEpithelialCutOffLength; // Epithelial covers stem and transit
    double mMembraneCutOffLength;
    double mStromalCutOffLength; // Stromal is the differentiated "filler" cells
    double mEpithelialMembraneCutOffLength;
    double mMembraneStromalCutOffLength;
    double mStromalEpithelialCutOffLength;


    /**
     * Initial resting spring length after cell division.
     * Has units of cell size at equilibrium rest length
     *
     * The value of this parameter should be larger than mDivisionSeparation,
     * because of pressure from neighbouring springs.
     */
    double mMeinekeDivisionRestingSpringLength;

    /**
     * The time it takes for the springs rest length to increase from
     * mMeinekeDivisionRestingSpringLength to its natural length.
     *
     * The value of this parameter is usually the same as the M Phase of the cell cycle and defaults to 1.
     */
    double mMeinekeSpringGrowthDuration;

public:

    /**
     * Constructor.
     */
    LinearSpringForceMembraneCell();

    /**
     * Destructor.
     */
    virtual ~LinearSpringForceMembraneCell();

    /**
     * Overridden CalculateForceBetweenNodes() method.
     *
     * Calculates the force between two nodes.
     *
     * Note that this assumes they are connected and is called by AddForceContribution()
     *
     * @param nodeAGlobalIndex index of one neighbouring node
     * @param nodeBGlobalIndex index of the other neighbouring node
     * @param rCellPopulation the cell population
     * @return The force exerted on Node A by Node B.
     */
    c_vector<double, SPACE_DIM> CalculateForceBetweenNodes(unsigned nodeAGlobalIndex,
                                                     unsigned nodeBGlobalIndex,
                                                     AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation);

    void SetEpithelialSpringStiffness(double epithelialSpringStiffness); // Epithelial covers stem and transit
    void SetMembraneSpringStiffness(double membraneSpringStiffness);
    void SetStromalSpringStiffness(double stromalSpringStiffness); // Stromal is the differentiated "filler" cells
    void SetEpithelialMembraneSpringStiffness(double epithelialMembraneSpringStiffness);
    void SetMembraneStromalSpringStiffness(double membraneStromalSpringStiffness);
    void SetStromalEpithelialSpringStiffness(double stromalEpithelialSpringStiffness);

    void SetEpithelialRestLength(double epithelialRestLength); // Epithelial covers stem and transit
    void SetMembraneRestLength(double membraneRestLength);
    void SetStromalRestLength(double stromalRestLength); // Stromal is the differentiated "filler" cells
    void SetEpithelialMembraneRestLength(double epithelialMembraneRestLength);
    void SetMembraneStromalRestLength(double membraneStromalRestLength);
    void SetStromalEpithelialRestLength(double stromalEpithelialRestLength);

    void SetEpithelialCutOffLength(double epithelialCutOffLength); // Epithelial covers stem and transit
    void SetMembraneCutOffLength(double membraneCutOffLength);
    void SetStromalCutOffLength(double stromalCutOffLength); // Stromal is the differentiated "filler" cells
    void SetEpithelialMembraneCutOffLength(double epithelialMembraneCutOffLength);
    void SetMembraneStromalCutOffLength(double membraneStromalCutOffLength);
    void SetStromalEpithelialCutOffLength(double stromalEpithelialCutOffLength);

    /**
     * Set mMeinekeDivisionRestingSpringLength.
     *
     * @param divisionRestingSpringLength the new value of mMeinekeDivisionRestingSpringLength
     */
    void SetMeinekeDivisionRestingSpringLength(double divisionRestingSpringLength);

    /**
     * Set mMeinekeSpringGrowthDuration.
     *
     * @param springGrowthDuration the new value of mMeinekeSpringGrowthDuration
     */
    void SetMeinekeSpringGrowthDuration(double springGrowthDuration);

    /**
     * Overridden OutputForceParameters() method.
     *
     * @param rParamsFile the file stream to which the parameters are output
     */
    virtual void OutputForceParameters(out_stream& rParamsFile);
};

#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(LinearSpringForceMembraneCell)

#endif /*LINEARSPRINGFORCEMEMBRANECELL_HPP_*/
