#include "IsNan.hpp"
#include "AbstractCellProperty.hpp"

#include "TransitCellProliferativeType.hpp"
#include "StemCellProliferativeType.hpp"
#include "NodeBasedCellPopulation.hpp"

#include "Debug.hpp"
#include "StromalType.hpp"
#include "StromalInternalForce.hpp"


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
StromalInternalForce<ELEMENT_DIM,SPACE_DIM>::StromalInternalForce()
   : AbstractTwoBodyInteractionForce<ELEMENT_DIM,SPACE_DIM>(),
    mSpringStiffness(15.0),
    mRestLength(1.0),
    mCutOffLength(1.1),
    mAttractionParameter(5.0)

{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
StromalInternalForce<ELEMENT_DIM,SPACE_DIM>::~StromalInternalForce()
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
c_vector<double, SPACE_DIM> StromalInternalForce<ELEMENT_DIM,SPACE_DIM>::CalculateForceBetweenNodes(unsigned nodeAGlobalIndex,
                                                                                    unsigned nodeBGlobalIndex,
                                                                                    AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation)
{

    MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>* p_tissue = static_cast<MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>*>(&rCellPopulation);
    // We should only ever calculate the force between two distinct nodes
    assert(nodeAGlobalIndex != nodeBGlobalIndex);

    CellPtr pCellA = rCellPopulation.GetCellUsingLocationIndex(nodeAGlobalIndex);
    CellPtr pCellB = rCellPopulation.GetCellUsingLocationIndex(nodeBGlobalIndex);

    c_vector<double, SPACE_DIM> zero_vector;
    for (unsigned i=0; i < SPACE_DIM; i++)
    {
        zero_vector[i] = 0;
    }

    if (!pCellA->GetCellProliferativeType()->IsType<StromalType>() || !pCellB->GetCellProliferativeType()->IsType<StromalType>())
    {
        return zero_vector;
    }
    else
    {
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


        double rest_length = mRestLength;
        double spring_constant = mSpringStiffness;

        if (distance_between_nodes > mCutOffLength)
        {
            return zero_vector;
        }


        // Checks if both cells have the same parent
        // *****************************************************************************************
        // Implements cell sibling tracking
        double ageA = pCellA->GetAge();
        double ageB = pCellB->GetAge();

        double parentA = pCellA->GetCellData()->GetItem("parent");
        double parentB = pCellB->GetCellData()->GetItem("parent");

        double minimum_length = 1.5 * p_tissue->GetMeinekeDivisionSeparation();


        if (ageA < mMeinekeSpringGrowthDuration && ageA == ageB && parentA == parentB)
        {
            // Make the spring length grow.
            double lambda = mMeinekeDivisionRestingSpringLength;
            rest_length = minimum_length + (lambda - minimum_length) * ageA/mMeinekeSpringGrowthDuration;
            // rest_length = lambda + (rest_length - lambda) * ageA/mMeinekeSpringGrowthDuration;
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
            double alpha = mAttractionParameter;
            c_vector<double, 2> temp = spring_constant * unitForceDirection * overlap * exp(-alpha * overlap/rest_length);
            return temp;
        }
    }

}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void StromalInternalForce<ELEMENT_DIM,SPACE_DIM>::SetAttractionParameter(double attractionParameter)
{
    mAttractionParameter = attractionParameter;
}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void StromalInternalForce<ELEMENT_DIM,SPACE_DIM>::SetSpringStiffness(double SpringStiffness)
{
    assert(SpringStiffness > 0.0);
    mSpringStiffness = SpringStiffness;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void StromalInternalForce<ELEMENT_DIM,SPACE_DIM>::SetRestLength(double RestLength)
{
    assert(RestLength > 0.0);
    mRestLength = RestLength;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void StromalInternalForce<ELEMENT_DIM,SPACE_DIM>::SetCutOffLength(double CutOffLength)
{
    assert(CutOffLength > 0.0);
    mCutOffLength = CutOffLength;
}


// For growing spring length
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void StromalInternalForce<ELEMENT_DIM,SPACE_DIM>::SetMeinekeSpringStiffness(double springStiffness)
{
    assert(springStiffness > 0.0);
    mMeinekeSpringStiffness = springStiffness;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void StromalInternalForce<ELEMENT_DIM,SPACE_DIM>::SetMeinekeDivisionRestingSpringLength(double divisionRestingSpringLength)
{
    assert(divisionRestingSpringLength <= 1.0);
    assert(divisionRestingSpringLength >= 0.0);

    mMeinekeDivisionRestingSpringLength = divisionRestingSpringLength;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void StromalInternalForce<ELEMENT_DIM,SPACE_DIM>::SetMeinekeSpringGrowthDuration(double springGrowthDuration)
{
    assert(springGrowthDuration >= 0.0);

    mMeinekeSpringGrowthDuration = springGrowthDuration;
}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void StromalInternalForce<ELEMENT_DIM,SPACE_DIM>::OutputForceParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<SpringStiffness>" << mSpringStiffness << "</SpringStiffness>\n";

    // Call method on direct parent class
    AbstractTwoBodyInteractionForce<ELEMENT_DIM,SPACE_DIM>::OutputForceParameters(rParamsFile);
    // Call method on direct parent class
}

/////////////////////////////////////////////////////////////////////////////
// Explicit instantiation
/////////////////////////////////////////////////////////////////////////////

template class StromalInternalForce<1,1>;
template class StromalInternalForce<1,2>;
template class StromalInternalForce<2,2>;
template class StromalInternalForce<1,3>;
template class StromalInternalForce<2,3>;
template class StromalInternalForce<3,3>;

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(StromalInternalForce)