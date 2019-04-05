/*

A simplified force calculator
Expects only one type of cell, and provides one type of spring length, stiffness, and cutoff length
Implements the cell property method for determining if two cells should have a growing spring between them
As of 19/12/2018 the only CCM that works with this is SimpleWntContactInhibitionCellCycleModel


This implements a linear spring for the internal nodes of a twin-node cell
*/

#include "IsNan.hpp"
#include "AbstractCellProperty.hpp"

#include "TransitCellProliferativeType.hpp"
#include "StemCellProliferativeType.hpp"
#include "NodeBasedCellPopulation.hpp"

#include "Debug.hpp"

#include "BasicNonLinearSpringForceNewPhaseModel.hpp"


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
BasicNonLinearSpringForceNewPhaseModel<ELEMENT_DIM,SPACE_DIM>::BasicNonLinearSpringForceNewPhaseModel()
   : BasicNonLinearSpringForce<ELEMENT_DIM,SPACE_DIM>()
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
BasicNonLinearSpringForceNewPhaseModel<ELEMENT_DIM,SPACE_DIM>::~BasicNonLinearSpringForceNewPhaseModel()
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
c_vector<double, SPACE_DIM> BasicNonLinearSpringForceNewPhaseModel<ELEMENT_DIM,SPACE_DIM>::CalculateForceBetweenNodes(unsigned nodeAGlobalIndex,
                                                                                    unsigned nodeBGlobalIndex,
                                                                                    AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation)
{
    MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>* p_tissue = static_cast<MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>*>(&rCellPopulation);
    // We should only ever calculate the force between two distinct nodes
    assert(nodeAGlobalIndex != nodeBGlobalIndex);

    CellPtr p_cell_A = rCellPopulation.GetCellUsingLocationIndex(nodeAGlobalIndex);
    CellPtr p_cell_B = rCellPopulation.GetCellUsingLocationIndex(nodeBGlobalIndex);

    c_vector<double, SPACE_DIM> zero_vector;
    for (unsigned i=0; i < SPACE_DIM; i++)
    {
        zero_vector[i] = 0;
    }

    Node<SPACE_DIM>* p_node_a = rCellPopulation.GetNode(nodeAGlobalIndex);
    Node<SPACE_DIM>* p_node_b = rCellPopulation.GetNode(nodeBGlobalIndex);

    // Get the node locations
    c_vector<double, SPACE_DIM> node_a_location = p_node_a->rGetLocation();
    c_vector<double, SPACE_DIM> node_b_location = p_node_b->rGetLocation();


    // Get the unit vector parallel to the line joining the two nodes
    c_vector<double, SPACE_DIM> unitForceDirection;

    unitForceDirection = rCellPopulation.rGetMesh().GetVectorFromAtoB(node_a_location, node_b_location);

    // Calculate the distance between the two nodes
    double distance_between_nodes = norm_2(unitForceDirection);
    assert(distance_between_nodes > 0);
    assert(!std::isnan(distance_between_nodes));

    unitForceDirection /= distance_between_nodes;


    double rest_length = this->mRestLength;
    double spring_constant = this->mSpringStiffness;

    if (distance_between_nodes > this->mCutOffLength)
    {
        return zero_vector;
    }


    // Checks if both cells have the same parent
    // *****************************************************************************************
    // Implements cell sibling tracking
    double ageA = p_cell_A->GetAge();
    double ageB = p_cell_B->GetAge();

    double parentA = p_cell_A->GetCellData()->GetItem("parent");
    double parentB = p_cell_B->GetCellData()->GetItem("parent");

    double minimum_length = p_tissue->GetMeinekeDivisionSeparation();

    double duration = this->mMeinekeSpringGrowthDuration;

    if (ageA < duration && ageA == ageB && parentA == parentB)
    // if (ageA < duration && ageB < duration && parentA == parentB)
    {
        // Make the spring length grow.
        double lambda = this->mMeinekeDivisionRestingSpringLength;
        rest_length = minimum_length + (lambda - minimum_length) * ageA/duration;
        // rest_length = lambda + (rest_length - lambda) * ageA/mMeinekeSpringGrowthDuration;
        double overlap = distance_between_nodes - rest_length;
        c_vector<double, 2> temp = spring_constant * unitForceDirection * overlap; 
        return temp;
    }
    // *****************************************************************************************

    double overlap = distance_between_nodes - rest_length;
    bool is_closer_than_rest_length = (overlap <= 0);

    if (is_closer_than_rest_length) //overlap is negative
    {
        // log(x+1) is undefined for x<=-1
        assert(overlap > -rest_length);
        c_vector<double, 2> temp = spring_constant * unitForceDirection * rest_length * log(1.0 + overlap/rest_length);
        return temp;
    }
    else
    {
        double alpha = this->mAttractionParameter;
        c_vector<double, 2> temp = spring_constant * unitForceDirection * overlap * exp(-alpha * overlap/rest_length);
        return temp;
        // return zero_vector;
    }

}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicNonLinearSpringForceNewPhaseModel<ELEMENT_DIM,SPACE_DIM>::OutputForceParameters(out_stream& rParamsFile)
{

    // Call method on direct parent class
    BasicNonLinearSpringForce<ELEMENT_DIM,SPACE_DIM>::OutputForceParameters(rParamsFile);
    // Call method on direct parent class
}

/////////////////////////////////////////////////////////////////////////////
// Explicit instantiation
/////////////////////////////////////////////////////////////////////////////

template class BasicNonLinearSpringForceNewPhaseModel<1,1>;
template class BasicNonLinearSpringForceNewPhaseModel<1,2>;
template class BasicNonLinearSpringForceNewPhaseModel<2,2>;
template class BasicNonLinearSpringForceNewPhaseModel<1,3>;
template class BasicNonLinearSpringForceNewPhaseModel<2,3>;
template class BasicNonLinearSpringForceNewPhaseModel<3,3>;

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(BasicNonLinearSpringForceNewPhaseModel)