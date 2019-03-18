/*
Initial structure borrows heavily from EpithelialLayerBasementMembraneForce by Axel Almet
- This is a stripped down version of the force calculator, that assumes only one cell type
- It is intended to be a simple force calculator using the same laws as in GeneralisedLinearSpringForce, with contact neighbour tracking 
*/

#include "IsNan.hpp"
#include "AbstractCellProperty.hpp"

#include "MembraneCellProliferativeType.hpp"
#include "TransitCellProliferativeType.hpp"
#include "StemCellProliferativeType.hpp"

#include "Debug.hpp"

#include "BasicNonLinearSpringForceMultiNodeFix.hpp"


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::BasicNonLinearSpringForceMultiNodeFix()
   : AbstractForce<ELEMENT_DIM,SPACE_DIM>(),
    mSpringStiffness(15.0),
    mRestLength(1.0),
    mCutOffLength(1.1),
    mAttractionParameter(5.0)
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::~BasicNonLinearSpringForceMultiNodeFix()
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
std::vector<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* >> BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::FindOneInteractionBetweenCellPair(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation)
{

    MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>* p_tissue = static_cast<MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>*>(&rCellPopulation);

    // Loop through list of nodes, finds the cell in W phase and
    // if both nodes are interacting with a cell then only the 
    // shortest interaction is considered - that is to say in this calculator the longer interaction
    // is negated by applying the opposite force.

    std::list<CellPtr> cells =  p_tissue->rGetCells();

    
    std::vector< std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > > interactions;
    std::vector< std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > > removed_interactions;
    std::vector< std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > > r_node_pairs = p_tissue->rGetNodePairs();

    for (typename std::vector< std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > >::iterator iter = r_node_pairs.begin();
        iter != r_node_pairs.end();
        iter++)
    {

        // Loop through all the node pairs and store the interactions
        // If an interaction already exists, then compare the distances and keep the shorter one
        // Move the longer one into removed_interactions

        std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > test_pair_AB = (*iter);

        CellPtr cellA = rCellPopulation.GetCellUsingLocationIndex(test_pair_AB.first->GetIndex());
        CellPtr cellB = rCellPopulation.GetCellUsingLocationIndex(test_pair_AB.second->GetIndex());

        typename std::vector< std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > >::iterator existing_it; 
        existing_it = std::find_if( interactions.begin(), interactions.end(),
            [&rCellPopulation, cellA, cellB](const std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* >& existing_pair)
            {
                // The vector r_node_pairs contains all the node-node interactions
                // The vector interactions contains all the cell-cell interactions
                // There should at most be one interaction between any cell-cell pair
                // Some cells are made up of two nodes, since they are growing
                // In this case we need to make sure that no cell has both of it's nodes interacting with the same cell
                // If we detect that a cell has both nodes interacting with the same cell, then we need to pick only the shorter interaction

                bool result = false;

                CellPtr cell1 = rCellPopulation.GetCellUsingLocationIndex(existing_pair.first->GetIndex());
                CellPtr cell2 = rCellPopulation.GetCellUsingLocationIndex(existing_pair.second->GetIndex());

                bool ages_A1 = cellA->GetAge() == cell1->GetAge();
                bool ages_B2 = cellB->GetAge() == cell2->GetAge();

                bool ids_A1 = cellA->GetCellId() != cell1->GetCellId();
                bool ids_B2 = cellB->GetCellId() != cell2->GetCellId();

                bool parents_A1 = cellA->GetCellData()->GetItem("parent") == cell1->GetCellData()->GetItem("parent");
                bool parents_B2 = cellB->GetCellData()->GetItem("parent") == cell2->GetCellData()->GetItem("parent");

                bool ages_A2 = cellA->GetAge() == cell2->GetAge();
                bool ages_B1 = cellB->GetAge() == cell1->GetAge();

                bool ids_A2 = cellA->GetCellId() != cell2->GetCellId();
                bool ids_B1 = cellB->GetCellId() != cell1->GetCellId();

                bool parents_A2 = cellA->GetCellData()->GetItem("parent") == cell2->GetCellData()->GetItem("parent");
                bool parents_B1 = cellB->GetCellData()->GetItem("parent") == cell1->GetCellData()->GetItem("parent");

                // If this equals 1, then a growing cell has one node in each of the two pairs considered
                // If this equals 2, then two growing cells are present, both with one node in each pair considered
                unsigned contains_twin_node = ages_A1*ids_A1*parents_A1 + ages_B2*ids_B2*parents_B2   +  ages_A2*ids_A2*parents_A2 + ages_B1*ids_B1*parents_B1;

                if (contains_twin_node)
                {
                    // There are at least 5 cases to examine when there are twin nodes
                    // 3 should produce true and two should produce false
                    result = true;

                    // If the two interaction aren't with the same external node, becomes false
                    if (parents_A1 + parents_B2 + parents_A2 + parents_B1 == 1)
                    {
                        return false;
                    }

                    // If one interaction is between the twin nodes, produce false
                    bool ages_AB = cellA->GetAge() == cellB->GetAge();
                    bool ages_12 = cell1->GetAge() == cell2->GetAge();

                    bool parents_AB = cellA->GetCellData()->GetItem("parent") == cellB->GetCellData()->GetItem("parent");
                    bool parents_12 = cell1->GetCellData()->GetItem("parent") == cell2->GetCellData()->GetItem("parent");

                    if (ages_AB*parents_AB + ages_12*parents_12)
                    {
                        return false;
                    }
                   
                }                

                return result;
                // If neither forward or flipped match, result is 0, returns 0 - this interaction is not the interaction vector
                // If one of forward or flipped match, result is 1, returns 1 - the interaction is in the interaction vetctor
                // If we have found the twin nodes of a growing cell and they are already in the vector, result is 2, returns 0
                // If twin nodes are already in there, we don't care if it is a match because this is only to get rid of the
                // longer interaction within a cell with twin nodes
            });

        if (existing_it != interactions.end())
        {
            // We have found a duplicated cell-cell interaction
            std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > existing_pair_12 = (*existing_it);

            // Check which one is longer
            c_vector<double, SPACE_DIM> test_directionAB = rCellPopulation.rGetMesh().GetVectorFromAtoB(test_pair_AB.first->rGetLocation(), test_pair_AB.second->rGetLocation());
            double test_distanceAB = norm_2(test_directionAB);

            c_vector<double, SPACE_DIM> existing_direction12 = rCellPopulation.rGetMesh().GetVectorFromAtoB(existing_pair_12.first->rGetLocation(), existing_pair_12.second->rGetLocation());
            double existing_distance12 = norm_2(existing_direction12);

            // Put the longer one in the removed_interactions vector
            // Put the shorter one int the interactions vector
            if (test_distanceAB < existing_distance12)
            {
                // The pair in the interactions vector is longer, so remove it
                // and replace it with the new pair
                removed_interactions.push_back(existing_pair_12);
                interactions.erase(existing_it);
                interactions.push_back(test_pair_AB);

            } else
            {
                // The pair in the interations vector is meant to be there
                // Put the new pair in the removed vector
                removed_interactions.push_back(test_pair_AB);
            }


        } else 
        {
            // We have found a cell-cell interaction not in the vector, add it to the interactions vector
            interactions.push_back(test_pair_AB);

        }


    }

    assert(interactions.size() + removed_interactions.size() == r_node_pairs.size());

    return interactions;


};

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::AddForceContribution(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation)
{
   
    //AbstractCentreBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>* p_tissue = static_cast<AbstractCentreBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>*>(&rCellPopulation);
    MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>* p_tissue = static_cast<MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>*>(&rCellPopulation);

    // Checks if this is a 1D columnor a 2D column (i.e. cells can pop up)
    std::vector< std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > > interactions;
    interactions = FindOneInteractionBetweenCellPair(rCellPopulation);

    for (typename std::vector< std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > >::iterator iter = interactions.begin();
        iter != interactions.end();
        iter++)
    {
        std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > pair = *iter;
        
        unsigned node_a_index = pair.first->GetIndex();
        unsigned node_b_index = pair.second->GetIndex();

        // Calculate the force between nodes
        c_vector<double, SPACE_DIM> force = CalculateForceBetweenNodes(node_a_index, node_b_index, rCellPopulation);
        for (unsigned j=0; j<SPACE_DIM; j++)
        {
            assert(!std::isnan(force[j]));
        }


        // Add the force contribution to each node
        c_vector<double, SPACE_DIM> negative_force = -1.0 * force;
        pair.first->AddAppliedForceContribution(force);
        pair.second->AddAppliedForceContribution(negative_force);

    }
}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
c_vector<double, SPACE_DIM> BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::CalculateForceBetweenNodes(unsigned nodeAGlobalIndex,
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
void BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::SetSpringStiffness(double SpringStiffness)
{
    assert(SpringStiffness > 0.0);
    mSpringStiffness = SpringStiffness;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::SetRestLength(double RestLength)
{
    assert(RestLength > 0.0);
    mRestLength = RestLength;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::SetCutOffLength(double CutOffLength)
{
    assert(CutOffLength > 0.0);
    mCutOffLength = CutOffLength;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::SetAttractionParameter(double attractionParameter)
{
    mAttractionParameter = attractionParameter;
}

// For growing spring length
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::SetMeinekeSpringStiffness(double springStiffness)
{
    assert(springStiffness > 0.0);
    mMeinekeSpringStiffness = springStiffness;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::SetMeinekeDivisionRestingSpringLength(double divisionRestingSpringLength)
{
    assert(divisionRestingSpringLength <= 1.0);
    assert(divisionRestingSpringLength >= 0.0);

    mMeinekeDivisionRestingSpringLength = divisionRestingSpringLength;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::SetMeinekeSpringGrowthDuration(double springGrowthDuration)
{
    assert(springGrowthDuration >= 0.0);

    mMeinekeSpringGrowthDuration = springGrowthDuration;
}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::OutputForceParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<SpringStiffness>" << mSpringStiffness << "</SpringStiffness>\n";

}

/////////////////////////////////////////////////////////////////////////////
// Explicit instantiation
/////////////////////////////////////////////////////////////////////////////

template class BasicNonLinearSpringForceMultiNodeFix<1,1>;
template class BasicNonLinearSpringForceMultiNodeFix<1,2>;
template class BasicNonLinearSpringForceMultiNodeFix<2,2>;
template class BasicNonLinearSpringForceMultiNodeFix<1,3>;
template class BasicNonLinearSpringForceMultiNodeFix<2,3>;
template class BasicNonLinearSpringForceMultiNodeFix<3,3>;

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(BasicNonLinearSpringForceMultiNodeFix)