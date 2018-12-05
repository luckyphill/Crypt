/*

A simplified force calculator for the sake of checking resting position
cutoff length is equivalent to sensing radius
restlength is the distance that the membrane cell prefers to have the epithelial cell centre

*/

#include "IsNan.hpp"
#include "AbstractCellProperty.hpp"

#include "MembraneCellProliferativeType.hpp"
#include "TransitCellProliferativeType.hpp"
#include "StemCellProliferativeType.hpp"

#include "Debug.hpp"

#include "BasicNonLinearSpringForce.hpp"


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
BasicNonLinearSpringForce<ELEMENT_DIM,SPACE_DIM>::BasicNonLinearSpringForce()
   : AbstractTwoBodyInteractionForce<ELEMENT_DIM,SPACE_DIM>(),
    mEpithelialMembraneSpringStiffness(15.0),
    mEpithelialMembraneRestLength(1.0),
    mEpithelialMembraneCutOffLength(1.5)

{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
BasicNonLinearSpringForce<ELEMENT_DIM,SPACE_DIM>::~BasicNonLinearSpringForce()
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
c_vector<double, SPACE_DIM> BasicNonLinearSpringForce<ELEMENT_DIM,SPACE_DIM>::CalculateForceBetweenNodes(unsigned nodeAGlobalIndex,
                                                                                    unsigned nodeBGlobalIndex,
                                                                                    AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation)
{
    // We should only ever calculate the force between two distinct nodes
    assert(nodeAGlobalIndex != nodeBGlobalIndex);

    CellPtr p_cell_A = rCellPopulation.GetCellUsingLocationIndex(nodeAGlobalIndex);
    CellPtr p_cell_B = rCellPopulation.GetCellUsingLocationIndex(nodeBGlobalIndex);

    // First, determine what we've got
    bool membraneA = p_cell_A->GetCellProliferativeType()->IsType<MembraneCellProliferativeType>();
    bool membraneB = p_cell_B->GetCellProliferativeType()->IsType<MembraneCellProliferativeType>();

    c_vector<double, 2> zero_vector;
    zero_vector[0] = 0;
    zero_vector[1] = 0;

    if (membraneA && membraneB)
    {
        return zero_vector;

    } else {

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


        double rest_length = mEpithelialMembraneRestLength;
        double spring_constant = mEpithelialMembraneSpringStiffness;

        if (distance_between_nodes > mEpithelialMembraneCutOffLength)
        {
            return zero_vector;
            PRINT_2_VARIABLES(nodeAGlobalIndex,nodeBGlobalIndex)
        } 

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
            double alpha = 1.8; // 3.0
            c_vector<double, 2> temp = spring_constant * unitForceDirection * overlap * exp(-alpha * overlap/rest_length);
            return temp;
        }
    }

}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicNonLinearSpringForce<ELEMENT_DIM,SPACE_DIM>::SetEpithelialMembraneSpringStiffness(double epithelialMembraneSpringStiffness)
{
    assert(epithelialMembraneSpringStiffness > 0.0);
    mEpithelialMembraneSpringStiffness = epithelialMembraneSpringStiffness;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicNonLinearSpringForce<ELEMENT_DIM,SPACE_DIM>::SetEpithelialMembraneRestLength(double epithelialMembraneRestLength)
{
    assert(epithelialMembraneRestLength > 0.0);
    mEpithelialMembraneRestLength = epithelialMembraneRestLength;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicNonLinearSpringForce<ELEMENT_DIM,SPACE_DIM>::SetEpithelialMembraneCutOffLength(double epithelialMembraneCutOffLength)
{
    assert(epithelialMembraneCutOffLength > 0.0);
    mEpithelialMembraneCutOffLength = epithelialMembraneCutOffLength;
}



template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicNonLinearSpringForce<ELEMENT_DIM,SPACE_DIM>::OutputForceParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<EpithelialMembraneSpringStiffness>" << mEpithelialMembraneSpringStiffness << "</EpithelialMembraneSpringStiffness>\n";
    
    *rParamsFile << "\t\t\t<EpithelialMembraneRestLength>" << mEpithelialMembraneRestLength << "</EpithelialMembraneRestLength>\n";
    
    *rParamsFile << "\t\t\t<EpithelialMembraneCutOffLength>" << mEpithelialMembraneCutOffLength << "</EpithelialMembraneCutOffLength>\n";

    // Call method on direct parent class
    AbstractTwoBodyInteractionForce<ELEMENT_DIM,SPACE_DIM>::OutputForceParameters(rParamsFile);
    // Call method on direct parent class
}

/////////////////////////////////////////////////////////////////////////////
// Explicit instantiation
/////////////////////////////////////////////////////////////////////////////

template class BasicNonLinearSpringForce<1,1>;
template class BasicNonLinearSpringForce<1,2>;
template class BasicNonLinearSpringForce<2,2>;
template class BasicNonLinearSpringForce<1,3>;
template class BasicNonLinearSpringForce<2,3>;
template class BasicNonLinearSpringForce<3,3>;

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(BasicNonLinearSpringForce)