/*
A simple non linear spring force law for developing the basement membrane
This is initially used to make sure the resting position from the wall matches
what has been analyitically calculated

*/

#ifndef BasicNonLinearSpringForceNewPhaseModel_HPP_
#define BasicNonLinearSpringForceNewPhaseModel_HPP_

#include "AbstractTwoBodyInteractionForce.hpp"
#include "BasicNonLinearSpringForce.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>

template<unsigned  ELEMENT_DIM, unsigned SPACE_DIM=ELEMENT_DIM>
class BasicNonLinearSpringForceNewPhaseModel : public BasicNonLinearSpringForce<ELEMENT_DIM, SPACE_DIM>
{

public:

    /**
     * Constructor.
     */
    BasicNonLinearSpringForceNewPhaseModel();

    /**
     * Destructor.
     */
    virtual ~BasicNonLinearSpringForceNewPhaseModel();

    /**
     * Overridden CalculateForceBetweenNodes() method.
     *
     * Calculates the force between two nodes.
     * In this version of the force calculator, cell interaction between two growing cells is controlled slightly differently
     */
    c_vector<double, SPACE_DIM> CalculateForceBetweenNodes(unsigned nodeAGlobalIndex,
                                                     unsigned nodeBGlobalIndex,
                                                     AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation);


    virtual void OutputForceParameters(out_stream& rParamsFile);
};

#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(BasicNonLinearSpringForceNewPhaseModel)

#endif /*BASICNONLINEARSPRINGFORCE_HPP_*/