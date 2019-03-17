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
    mCutOffLength(1.1)
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::~BasicNonLinearSpringForceMultiNodeFix()
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
std::vector<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* >> BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::FindPairsToRemove(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation)
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

        std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > node_pair_AB = (*iter);

        CellPtr cellA = rCellPopulation.GetCellUsingLocationIndex(node_pair_AB.first->GetIndex());
        CellPtr cellB = rCellPopulation.GetCellUsingLocationIndex(node_pair_AB.second->GetIndex());

        typename std::vector< std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > >::iterator it; 
        it = std::find_if( interactions.begin(), interactions.end(),
            [&rCellPopulation, node_pair_AB, cellA, cellB](const std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* >& interaction_pair)
            {
                // The interaction we are interested in is one that is already in the vector
                // but is between an external cell and the other internal node
                // In this case, adding it to the interaction vector will have an external cell
                // providing a force to both nodes

                CellPtr cell1 = rCellPopulation.GetCellUsingLocationIndex(interaction_pair.first->GetIndex());
                CellPtr cell2 = rCellPopulation.GetCellUsingLocationIndex(interaction_pair.second->GetIndex());

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

                unsigned result = ages_A1*ages_B2 * ids_A1*ids_B2 * parents_A1*parents_B2  +  ages_A2*ages_B1 * ids_A2*ids_B1  * parents_A2*parents_B1;

                if ((node_pair_AB.first->GetIndex() == 13 && node_pair_AB.second->GetIndex() == 11) || (node_pair_AB.first->GetIndex() == 11 && node_pair_AB.second->GetIndex() == 13))
                {
                    PRINT_VARIABLE(result)
                    PRINT_VARIABLE(node_pair_AB.first->GetIndex())
                    PRINT_VARIABLE(node_pair_AB.second->GetIndex())
                    PRINT_VARIABLE(interaction_pair.first->GetIndex())
                    PRINT_VARIABLE(interaction_pair.second->GetIndex())
                    PRINT_3_VARIABLES(ages_B2, ids_B2, parents_B2)
                    PRINT_2_VARIABLES(cellB->GetCellData()->GetItem("parent"), cell2->GetCellData()->GetItem("parent"))
                }
                

                return result == 1;
                // If neither forward or flipped match, result is 0, returns 0 - this interaction is not the interaction vector
                // If one of forward or flipped match, result is 1, returns 1 - the interaction is in the interaction vetctor
                // If we have found the twin nodes of a growing cell and they are already in the vector, result is 2, returns 0
                // If twin nodes are already in there, we don't care if it is a match because this is only to get rid of the
                // longer interaction within a cell with twin nodes
            });

        if (it != interactions.end())
        {
            // We have found an duplicated cell-cell interaction
            std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > node_pair_12 = (*it);

            // Check which one is longer
            c_vector<double, SPACE_DIM> directionAB = rCellPopulation.rGetMesh().GetVectorFromAtoB(node_pair_AB.first->rGetLocation(), node_pair_AB.second->rGetLocation());
            double distanceAB = norm_2(directionAB);

            c_vector<double, SPACE_DIM> direction12 = rCellPopulation.rGetMesh().GetVectorFromAtoB(node_pair_12.first->rGetLocation(), node_pair_12.second->rGetLocation());
            double distance12 = norm_2(direction12);

            // Put the longer one in the removed_interactions vector
            // Put the shorter one int the interactions vector
            if (distanceAB < distance12)
            {
                // The pair in the interactions vector is longer, so remove it
                // and replace it with the new pair
                removed_interactions.push_back(node_pair_12);
                interactions.erase(it);
                interactions.push_back(node_pair_AB);

            } else
            {
                // The pair in the interations vector is meant to be there
                // Put the new pair in the removed vector
                removed_interactions.push_back(node_pair_AB);
            }


        } else 
        {
            // We have found a cell-cell interaction not in the vector, add it to the interactions vector
            interactions.push_back(node_pair_AB);

        }


    }

    return removed_interactions;
    // return interactions;

};

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::AddForceContribution(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation)
{
   
    //AbstractCentreBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>* p_tissue = static_cast<AbstractCentreBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>*>(&rCellPopulation);
    MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>* p_tissue = static_cast<MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>*>(&rCellPopulation);
    std::vector< std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > >& r_node_pairs = p_tissue->rGetNodePairs();


    // Checks if this is a 1D columnor a 2D column (i.e. cells can pop up)
    std::vector< std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > > nodes_to_remove;
    nodes_to_remove = FindPairsToRemove(rCellPopulation);




    for (typename std::vector< std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > >::iterator iter = r_node_pairs.begin();
        iter != r_node_pairs.end();
        iter++)
    {
        std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > pair = *iter;
        if( find(nodes_to_remove.begin(), nodes_to_remove.end(), pair) != nodes_to_remove.end() )
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
            pair.first->AddAppliedForceContribution(-force);
            pair.second->AddAppliedForceContribution(-negative_force);
        }
    }
}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
c_vector<double, SPACE_DIM> BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::CalculateForceBetweenNodes(unsigned nodeAGlobalIndex,
                                                                                    unsigned nodeBGlobalIndex,
                                                                                    AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation)
{
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


    double rest_length = mRestLength;
    double spring_constant = mSpringStiffness;

    if (distance_between_nodes > mCutOffLength)
    {
        return zero_vector;
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
        double alpha = 1.8; // 3.0
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