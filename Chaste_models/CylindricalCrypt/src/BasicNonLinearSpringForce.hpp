/*
A simple non linear spring force law for developing the basement membrane
This is initially used to make sure the resting position from the wall matches
what has been analyitically calculated

*/

#ifndef BASICNONLINEARSPRINGFORCE_HPP_
#define BASICNONLINEARSPRINGFORCE_HPP_

#include "AbstractTwoBodyInteractionForce.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>

template<unsigned  ELEMENT_DIM, unsigned SPACE_DIM=ELEMENT_DIM>
class BasicNonLinearSpringForce : public AbstractTwoBodyInteractionForce<ELEMENT_DIM, SPACE_DIM>
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

        archive & mSpringStiffness;

    }

protected:


    double mSpringStiffness;

    double mRestLength;

    double mCutOffLength;

    
    // Spring growth parameters for newly divided cells
    double mMeinekeSpringStiffness;

    double mMeinekeDivisionRestingSpringLength;

    double mMeinekeSpringGrowthDuration;

public:

    /**
     * Constructor.
     */
    BasicNonLinearSpringForce();

    /**
     * Destructor.
     */
    virtual ~BasicNonLinearSpringForce();

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


    void SetSpringStiffness(double SpringStiffness);

    void SetRestLength(double RestLength);

    void SetCutOffLength(double CutOffLength);

    
    // Spring growth for newly divided cells
    void SetMeinekeSpringStiffness(double springStiffness);

    void SetMeinekeDivisionRestingSpringLength(double divisionRestingSpringLength);

    void SetMeinekeSpringGrowthDuration(double springGrowthDuration);

   /**
     * Overridden OutputForceParameters() method.
     *
     * @param rParamsFile the file stream to which the parameters are output
     */
    virtual void OutputForceParameters(out_stream& rParamsFile);
};

#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(BasicNonLinearSpringForce)

#endif /*BASICNONLINEARSPRINGFORCE_HPP_*/
