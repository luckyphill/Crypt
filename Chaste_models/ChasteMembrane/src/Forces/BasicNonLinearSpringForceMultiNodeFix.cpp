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
#include "SimplifiedPhaseBasedCellCycleModel.hpp"
#include "SimplifiedCellCyclePhases.hpp"


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
std::vector<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* >> BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::FindOneInteractionBetweenCellPairs(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation, std::vector< std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > > r_node_pairs)
{

    // Loop through list of nodes, finds the cell in W phase and
    // if both nodes are interacting with a cell then only the 
    // shortest interaction is considered - that is to say in this calculator the longer interaction
    // is negated by applying the opposite force.

    
    std::vector< std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > > interactions;

    // std::sort (r_node_pairs.begin(), r_node_pairs.end(), 
    //     [&](const std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > pairA, const std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > pairB)
    //     {
    //         unsigned smallerA = pairA.first->GetIndex() < pairA.second->GetIndex() ? pairA.first->GetIndex() : pairA.second->GetIndex();
    //         unsigned smallerB = pairB.first->GetIndex() < pairB.second->GetIndex() ? pairB.first->GetIndex() : pairB.second->GetIndex();

    //         if (smallerA == smallerB)
    //         {   
    //             unsigned largerA = pairA.first->GetIndex() > pairA.second->GetIndex() ? pairA.first->GetIndex() : pairA.second->GetIndex();
    //             unsigned largerB = pairB.first->GetIndex() > pairB.second->GetIndex() ? pairB.first->GetIndex() : pairB.second->GetIndex();

    //             return largerA < largerB;
    //         }
            

    //         return smallerA < smallerB;
    //     });

    // Using a set because it is quick to search
    // When making the parent pairs, the lower parent number goes first (there will always be a lower)
    std::set< std::pair<unsigned, unsigned> > completed_parent_pairs;


    for (typename std::vector< std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > >::iterator iter = r_node_pairs.begin();
        iter != r_node_pairs.end();
        ++iter)
    {
        std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > node_pair_AB = (*iter);

        Node<SPACE_DIM>* pnodeA = node_pair_AB.first;
        Node<SPACE_DIM>* pnodeB = node_pair_AB.second;
        assert(pnodeA != pnodeB);

        CellPtr cellA = rCellPopulation.GetCellUsingLocationIndex(pnodeA->GetIndex());
        CellPtr cellB = rCellPopulation.GetCellUsingLocationIndex(pnodeB->GetIndex());

        SimplifiedPhaseBasedCellCycleModel* pccmA = static_cast<SimplifiedPhaseBasedCellCycleModel*>(cellA->GetCellCycleModel());
        SimplifiedPhaseBasedCellCycleModel* pccmB = static_cast<SimplifiedPhaseBasedCellCycleModel*>(cellB->GetCellCycleModel());

        SimplifiedCellCyclePhase phaseA = pccmA->GetCurrentCellCyclePhase();
        SimplifiedCellCyclePhase phaseB = pccmB->GetCurrentCellCyclePhase();

        unsigned parentA = cellA->GetCellData()->GetItem("parent");
        unsigned parentB = cellB->GetCellData()->GetItem("parent");

        c_vector<double, SPACE_DIM> direction = rCellPopulation.rGetMesh().GetVectorFromAtoB(pnodeA->rGetLocation(), pnodeB->rGetLocation());
        double distance = norm_2(direction);

        // Easiest pairs to categorise: 
        // cellA and cellB are both single node cells - put straight into vector
        // pnodeA and pnodeB are twin nodes of one cell - put straight into vector
        if (distance < this->mCutOffLength)
        {
            if ((phaseA != W_PHASE && phaseB != W_PHASE) || ( parentA == parentB && phaseA == W_PHASE && phaseB == W_PHASE))
            {
                interactions.push_back(node_pair_AB);
            }
            else
            {
                unsigned lower;
                unsigned higer;

                assert(parentA != parentB);
                assert(phaseA == W_PHASE || phaseB == W_PHASE);

                lower = parentA < parentB ? parentA: parentB;
                higer = parentA > parentB ? parentA: parentB;

                assert(lower < higer);



                std::pair<unsigned, unsigned> parent_pair = std::make_pair(lower, higer);

                std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > pair_to_add; // To be determined

                // If the parent pair doesn't exist, then we need to look through all interactions between these two cells
                if (completed_parent_pairs.find(parent_pair) == completed_parent_pairs.end())
                {
                    // If the nodes are part of the same cell at this point, then something terrible
                    // has gone wrong
                    assert(parentA != parentB);
                    // Assuming there are no errors, we will always solve a cell-cell interaction in this scope
                    // Commenting this out for the moment, and placing it in specific cases that are suspected to work
                    completed_parent_pairs.insert(parent_pair);

                    if (phaseA == W_PHASE && phaseB != W_PHASE)
                    {
                        pair_to_add = FindShortestInteraction(rCellPopulation, pnodeA, pnodeB);

                    }

                    if (phaseA != W_PHASE && phaseB == W_PHASE)
                    {
                        pair_to_add = FindShortestInteraction(rCellPopulation, pnodeB, pnodeA);

                    }

                    if (phaseA == W_PHASE && phaseB == W_PHASE)
                    {
                        // Need to find all interactions between the two multinode cells, and compare the lengths

                        // Find the other nodes
                        // This returns the origin node if no twin was found

                        Node<SPACE_DIM>* pnodeC = FindTwinNode(rCellPopulation, pnodeA);
                        Node<SPACE_DIM>* pnodeD = FindTwinNode(rCellPopulation, pnodeB);

                        // If neither has a twin
                        if (pnodeA == pnodeC && pnodeB == pnodeD)
                        {
                            // This will happen for a short period immediately after starting
                            // because all cells start out as W_PHASE, and none of them will have
                            // twin node
                            pair_to_add = node_pair_AB;
                        }
                        // If both have twins - the most common situation
                        if (pnodeA != pnodeC && pnodeB != pnodeD)
                        {
                            std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > forwards;
                            std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > bacwards;

                            forwards = FindShortestInteraction(rCellPopulation, pnodeA, pnodeB);
                            bacwards = FindShortestInteraction(rCellPopulation, pnodeC, pnodeD);

                            // Pick the shorter of the two outcomes
                            c_vector<double, SPACE_DIM> direction_forwards = rCellPopulation.rGetMesh().GetVectorFromAtoB(forwards.first->rGetLocation(), forwards.second->rGetLocation());
                            c_vector<double, SPACE_DIM> direction_bacwards = rCellPopulation.rGetMesh().GetVectorFromAtoB(bacwards.first->rGetLocation(), bacwards.second->rGetLocation());

                            double distance_forwards = norm_2(direction_forwards);
                            double distance_bacwards = norm_2(direction_bacwards);

                            pair_to_add = (distance_forwards > distance_bacwards) ? bacwards : forwards;
                        }
                        // If only A has a twin
                        if (pnodeA != pnodeC && pnodeB == pnodeD)
                        {
                            pair_to_add = FindShortestInteraction(rCellPopulation, pnodeA, pnodeB);
                        }
                        // If only B has a twin
                        if (pnodeA == pnodeC && pnodeB != pnodeD)
                        {
                            pair_to_add = FindShortestInteraction(rCellPopulation, pnodeB, pnodeA);
                        }

                    }
                    // correct pair identified
                    interactions.push_back(pair_to_add);
                }
            }
        }
    }


    // std::sort (interactions.begin(), interactions.end(), 
    //     [&](const std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > pairA, const std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > pairB)
    //     {
    //         unsigned smallerA = pairA.first->GetIndex() < pairA.second->GetIndex() ? pairA.first->GetIndex() : pairA.second->GetIndex();
    //         unsigned smallerB = pairB.first->GetIndex() < pairB.second->GetIndex() ? pairB.first->GetIndex() : pairB.second->GetIndex();

    //         if (smallerA == smallerB)
    //         {   
    //             unsigned largerA = pairA.first->GetIndex() > pairA.second->GetIndex() ? pairA.first->GetIndex() : pairA.second->GetIndex();
    //             unsigned largerB = pairB.first->GetIndex() > pairB.second->GetIndex() ? pairB.first->GetIndex() : pairB.second->GetIndex();

    //             return largerA < largerB;
    //         }
            

    //         return smallerA < smallerB;
    //     });
    
    return interactions;

};

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
Node<SPACE_DIM>* BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::FindTwinNode(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation, Node<SPACE_DIM>* pnodeA)
{
    // Look through the neighbours of node A until it's twin node is found. If no twin is found, return pnodeA
    // This should only be used on cells in W_PHASE, the check should be done outside this function

    // Duplicating work, but needed for assert statement
    CellPtr cellA = rCellPopulation.GetCellUsingLocationIndex(pnodeA->GetIndex());
    SimplifiedPhaseBasedCellCycleModel* pccmA = static_cast<SimplifiedPhaseBasedCellCycleModel*>(cellA->GetCellCycleModel());
    assert(pccmA->GetCurrentCellCyclePhase() == W_PHASE);

    std::vector<unsigned>& neighbours = pnodeA->rGetNeighbours();

    // Go through the neighbours to see if one of them is the twin to A
    // If one of them is, check if AB or BC is longer, and return the shorter pair
    std::vector<unsigned>::iterator it;
    for (it = neighbours.begin(); it!=neighbours.end(); ++it)
    {
        // If neighbour is part of the same cell as A
        unsigned index = (*it);
        CellPtr cellB = rCellPopulation.GetCellUsingLocationIndex(index);
        Node<SPACE_DIM>* pnodeB = rCellPopulation.GetNode(index);

        if (cellB->GetCellData()->GetItem("parent") == cellA->GetCellData()->GetItem("parent") && cellB->GetCellId() != cellA->GetCellId() && cellA->GetAge() == cellB->GetAge())
        {
            return pnodeB;
        }
    }

    return pnodeA;

}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::FindShortestInteraction(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation, Node<SPACE_DIM>* pnodeA, Node<SPACE_DIM>* pnodeB)
{

    // This function expects cell A to be the cell in W phase

    // A -   -   -   -  B
    //  \            -
    //   \        -
    //    \    -
    //     C -

    // A and B are neighbours
    // C is the twin node to A
    // B and C might also be neighbours
    // If they are, we need to decide if AB or BC is longer


    // Duplicating effort, but makes the input arguments slightly nicer
    CellPtr cellA = rCellPopulation.GetCellUsingLocationIndex(pnodeA->GetIndex());
    std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > node_pair_AB = std::make_pair(pnodeA, pnodeB);

    // By default, the shortest pair is the one given unless proved otherwise
    std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > shortest_pair = node_pair_AB;


    Node<SPACE_DIM>* pnodeC = FindTwinNode(rCellPopulation, pnodeA);

    // If there is no twin node for A, the function FindTwinNode returns A
    if (pnodeA != pnodeC)
    {
        std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > node_pair_BC = std::make_pair(pnodeB, pnodeC);
    
        c_vector<double, SPACE_DIM> directionAB = rCellPopulation.rGetMesh().GetVectorFromAtoB(pnodeA->rGetLocation(), pnodeB->rGetLocation());
        c_vector<double, SPACE_DIM> directionBC = rCellPopulation.rGetMesh().GetVectorFromAtoB(pnodeB->rGetLocation(), pnodeC->rGetLocation());
    
        double distanceAB = norm_2(directionAB);
        double distanceBC = norm_2(directionBC);
    
        assert(distanceAB > 0);
        assert(distanceBC > 0);
        // Put the longer one in the removed_interactions vector
        // Put the shorter one in the interactions vector
    
        if (abs(distanceAB - distanceBC) < 1e-5)
        {
            // TRACE("Unicorn found")
            // PRINT_VARIABLE(SimulationTime::Instance()->GetTime())
            // PRINT_2_VARIABLES(distanceAB, distanceBC)
            // printf("%.16f\n", distanceAB);
            // printf("%.16f\n", distanceBC);
            // PRINT_3_VARIABLES(pnodeA->GetIndex(), pnodeB->GetIndex(), pnodeC->GetIndex())
            // PRINT_VARIABLE(pnodeA->rGetLocation()[1])
            // PRINT_VARIABLE(pnodeB->rGetLocation()[1])
            // PRINT_VARIABLE(pnodeC->rGetLocation()[1])
        }
        if (distanceAB < distanceBC)
        {
            shortest_pair =  node_pair_AB;
        }
        else
        {
            shortest_pair =  node_pair_BC;
        }
    }
    return shortest_pair;

}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicNonLinearSpringForceMultiNodeFix<ELEMENT_DIM,SPACE_DIM>::AddForceContribution(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation)
{
   
    MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>* p_tissue = static_cast<MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>*>(&rCellPopulation);

    

    std::vector< std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > > r_node_pairs = p_tissue->rGetNodePairs();

    std::vector< std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > > interactions;
    interactions = FindOneInteractionBetweenCellPairs(rCellPopulation, r_node_pairs);
    

    for (typename std::vector< std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > >::iterator iter = interactions.begin();
        iter != interactions.end();
        ++iter)
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


    double rest_length = mRestLength;
    double spring_constant = mSpringStiffness;

    if (distance_between_nodes > mCutOffLength)
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

    double duration = mMeinekeSpringGrowthDuration;

    PRINT_VARIABLE(duration)
    PRINT_VARIABLE(ageA)
    PRINT_VARIABLE(ageB)
    PRINT_VARIABLE(parentA)
    PRINT_VARIABLE(parentB)

    if (ageA < duration && ageB < duration && parentA == parentB)
    {
        // Make the spring length grow.
        double lambda = mMeinekeDivisionRestingSpringLength;
        PRINT_VARIABLE(lambda)
        
        // Increase the minimum length slightly compared to the division separation
        // This will cause a slight outwards force after a cell has just divided
        // Otherwise, the new node will appear at precisely the resting length, and so will have
        // no outwards force. If there is a squashed cell close to this one, a large
        // unbalanced force will appear. This may be the cause of "new node pass through"
        // where nodes will move through each other
        // minimum_length *= 1.5;
        
        // This version uses a rough force balance to make sure the
        // force from the internal spring roughly balances the force from the external spring
        // It assumes a compression of 0.75
        minimum_length = (minimum_length + 0.1)/0.7;
        PRINT_VARIABLE(minimum_length)

        rest_length = minimum_length + (lambda - minimum_length) * ageA/duration;
        TRACE("Growing cell")


    }
    // *****************************************************************************************

    double overlap = distance_between_nodes - rest_length;
    bool is_closer_than_rest_length = (overlap <= 0);
    PRINT_VARIABLE(distance_between_nodes)
    PRINT_VARIABLE(rest_length)
    PRINT_VARIABLE(overlap)

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
        
        // Multi-node cells have a stronger internal attraction
        // Using a linear spring instead
        if (ageA < duration && parentA == parentB)
        {
            c_vector<double, 2> temp = spring_constant * unitForceDirection * overlap;
        }
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