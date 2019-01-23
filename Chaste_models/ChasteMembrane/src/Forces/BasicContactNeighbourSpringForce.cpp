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

#include "BasicContactNeighbourSpringForce.hpp"


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
BasicContactNeighbourSpringForce<ELEMENT_DIM,SPACE_DIM>::BasicContactNeighbourSpringForce()
   : AbstractForce<ELEMENT_DIM,SPACE_DIM>(),
    mSpringStiffness(15.0),
    mRestLength(1.0),
    mCutOffLength(1.1)
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
BasicContactNeighbourSpringForce<ELEMENT_DIM,SPACE_DIM>::~BasicContactNeighbourSpringForce()
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
std::set<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* >> BasicContactNeighbourSpringForce<ELEMENT_DIM,SPACE_DIM>::FindContactNeighbourPairs(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation)
{

    MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>* p_tissue = static_cast<MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>*>(&rCellPopulation);

    // Loop through list of nodes, and pull out the neighbours
    // Use algorithm to decide if neighbours should be contacting each other
    // Use these contacts to calculate the forces
    // Need to be careful not to examine node pairs twice, so compare to node pairs vector
    std::list<CellPtr> cells =  p_tissue->rGetCells();

    // A set of pairs of contact neighbours
    // Implemented as a set for speed of search
    // The algorithm loops through r_node_pairs and checks if the pair exists in contact_nodes
    // If it does, then calculations happen
    // This check prevents calculating the forces twice
    std::set<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* >> contact_nodes;


    for (std::list<CellPtr>::iterator cell_iter = cells.begin(); cell_iter != cells.end(); ++cell_iter)
    {
        Node<SPACE_DIM>* p_node =  p_tissue->GetNodeCorrespondingToCell(*cell_iter);
        c_vector<double, SPACE_DIM> node_location = p_node->rGetLocation();

        std::vector<unsigned>& neighbours = p_node->rGetNeighbours();

        
        std::vector<  std::tuple< Node<SPACE_DIM>*, c_vector<double, SPACE_DIM>, double >  >  neighbour_data;
        for (std::vector<unsigned>::iterator neighbour_node = neighbours.begin(); neighbour_node != neighbours.end(); neighbour_node++)
        {
            
            Node<SPACE_DIM>* temp_node =  p_tissue->GetNode(*neighbour_node);
            c_vector<double, SPACE_DIM> neighbour_location = temp_node->rGetLocation();

            // Get the unit vector parallel to the line joining the two nodes
            c_vector<double, SPACE_DIM> direction;

            direction = rCellPopulation.rGetMesh().GetVectorFromAtoB(node_location, neighbour_location);
            double distance = norm_2(direction);

            std::tuple< Node<SPACE_DIM>*, c_vector<double, SPACE_DIM>, double > particular_data = std::make_tuple(temp_node, direction, distance);

            neighbour_data.push_back(particular_data);

        }

        std::sort(neighbour_data.begin(), neighbour_data.end(), nd_sort<ELEMENT_DIM,SPACE_DIM>);

        // Algorithm for determining if neighbour is in contact

        // Vector containing neighbours that are in contact as determined by the algorithm
        std::vector<  std::tuple< Node<SPACE_DIM>*, c_vector<double, SPACE_DIM>, double >  > contact_neighbours;

        // Only loop if there are any neighbours to begin with
        if(neighbour_data.size() > 0)
        {
            // The closest neighbour will always be added
            contact_neighbours.push_back(neighbour_data[0]);
            std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>*> particular_pair = std::make_pair( std::get<0>(neighbour_data[0]), p_node);
            std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>*> particular_pair_flipped = std::make_pair(p_node, std::get<0>(neighbour_data[0]));
            contact_nodes.insert(particular_pair);
            contact_nodes.insert(particular_pair_flipped);

            // Only do the comparison if there are more than 1 neighbours
            if (neighbour_data.size() > 1)
            {
                double R = mRestLength; // Preferred radius of the centre cell
                double R_inter = mRestLength; // Interaction radius of centre cell
                
                typename std::vector<  std::tuple< Node<SPACE_DIM>*, c_vector<double, SPACE_DIM>, double >  >::iterator nd_it;
                
                // Loop through ordered vector of closest to furthest neighbours
                for( nd_it = std::next(neighbour_data.begin(),1); nd_it != neighbour_data.end(); nd_it ++)
                {
                    double distance_nd = std::get<2>((*nd_it));

                    bool satisfied = true; // Assume that it is a contact neighbour until we contradict it
                    
                    if ( distance_nd > R_inter ) // If candidate is too far away, then it's out automatically
                    {

                        satisfied = false;

                    } 
                    else // If it is within the distance, then have to go through the deeper check
                    {
                        // Loop through all the neighbours that are determined to be in contact
                        typename std::vector<  std::tuple< Node<SPACE_DIM>*, c_vector<double, SPACE_DIM>, double >  >::iterator cn_it;
                        for( cn_it = contact_neighbours.begin(); cn_it != contact_neighbours.end(); cn_it ++)
                        {                        
                            
                            // Find the angle between this neighbour and all of those stored in the contact neighbours vector
                            // If all of the angle/length/neighbour size combinations are sufficient for all current contact neighbours, add this item to contact neighbours

                            // Working for cn
                            double distance_cn = std::get<2>((*cn_it));
                            c_vector<double, SPACE_DIM> vec_cn = std::get<1>((*cn_it));
                            

                            // Need to work out what the preferred radius of the contact neighbour is
                            double r_cn = mRestLength; //preferred radius of contact neighbour
                                                    
                            // Now working for nd
                            
                            c_vector<double, SPACE_DIM> vec_nd = std::get<1>((*nd_it));


                            // Need to work out what the preferred radius of the candidate neighbour is
                            double r_nd = mRestLength; //preferred radius of candidate neighbour cell

                            // Bring together collected data
                            // Only works for 2 D
                            double inner_product = vec_cn[0] * vec_nd[0] + vec_cn[1] * vec_nd[1];

                            double acos_arg = inner_product / (distance_cn * distance_nd);

                            double angle_cn_nd = acos(acos_arg);

                            // Occasionally the argument steps out of the bounds for acos, for instance -1.0000000000000002
                            // This is enough to make the acos function return nans
                            // This line of code is not ideal, but catches the error for the time being
                            if (isnan(angle_cn_nd) && acos_arg > -1.00000000000005) 
                            {
                                angle_cn_nd = acos(-1);
                            }
                            
                            
                            double cea_cn = (pow(distance_cn,2) + pow(R,2)- pow(r_cn,2))/(2 * distance_cn * R);
                            double contact_edge_angle_cn = acos(cea_cn);
                            //double minimum_angle = .4;

                            // In this case, the candidate cell is not a contact neighbour because it is not close enough to squash the centre cell
                            // and it is too close to the contact neighbour cell, so the cn cell will be between the two
                            if (angle_cn_nd < contact_edge_angle_cn && distance_nd > R + r_nd)
                            {
                                satisfied = false;
                                break;
                            }

                            if (angle_cn_nd < contact_edge_angle_cn && distance_nd < R + r_nd)
                            {
                                double cea_nd = (pow(distance_nd,2) + pow(R,2)- pow(r_nd,2))/(2 * distance_nd * R);
                                double contact_edge_angle_nd = acos(cea_nd);
                                // In this case the candidate cell IS close enough to squash the centre cell, but it doesn't because it is too far behind
                                // the contact neighbour
                                if (contact_edge_angle_nd + angle_cn_nd < contact_edge_angle_cn)
                                {
                                    satisfied = false;
                                    break;
                                }
                            }


                        }
                    }
                        

                    if (satisfied)
                    {
                        // If all of the conditions are satisfied, then the node is a contact node
                        contact_neighbours.push_back((*nd_it));
                        std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>*> contact_pair = std::make_pair(std::get<0>((*nd_it)), p_node);
                        contact_nodes.insert(contact_pair);
                        std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>*> contact_pair_flipped = std::make_pair( p_node, std::get<0>((*nd_it)));
                        contact_nodes.insert(contact_pair_flipped);

                    }
                }
            }
        }
    }

    return contact_nodes;

};

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
std::set<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* >> BasicContactNeighbourSpringForce<ELEMENT_DIM,SPACE_DIM>::Find1DContactPairs(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation)
{
    MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>* p_tissue = static_cast<MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>*>(&rCellPopulation);

    double max_distance = mCutOffLength;

    // Loop through list of nodes, and pull out the neighbours
    // Use algorithm to decide if neighbours should be contacting each other
    // Use these contacts to calculate the forces
    // Need to be careful not to examine node pairs twice, so compare to node pairs vector
    std::list<CellPtr> cells =  p_tissue->rGetCells();

    // A set of pairs of contact neighbours
    // Implemented as a set for speed of search
    // The algorithm loops through r_node_pairs and checks if the pair exists in contact_nodes
    // If it does, then calculations happen
    // This check prevents calculating the forces twice
    std::set<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* >> contact_nodes;


    for (std::list<CellPtr>::iterator cell_iter = cells.begin(); cell_iter != cells.end(); ++cell_iter)
    {
        Node<SPACE_DIM>* p_node =  p_tissue->GetNodeCorrespondingToCell(*cell_iter);
        c_vector<double, SPACE_DIM> node_location = p_node->rGetLocation();

        std::vector<unsigned>& neighbours = p_node->rGetNeighbours();
        
        Node<SPACE_DIM>* p_node_above;
        double above_distance = max_distance;
        Node<SPACE_DIM>* p_node_below;
        double below_distance = -max_distance;

        for (std::vector<unsigned>::iterator neighbour_node = neighbours.begin(); neighbour_node != neighbours.end(); neighbour_node++)
        {
            
            Node<SPACE_DIM>* temp_node =  p_tissue->GetNode(*neighbour_node);
            c_vector<double, SPACE_DIM> neighbour_location = temp_node->rGetLocation();

            double distance_between_nodes = neighbour_location[1] - node_location[1];
            assert(distance_between_nodes != 0); // If the nodes are on the exact same spot, then we have problems

            if (distance_between_nodes > 0)
            {
                if (distance_between_nodes < above_distance)
                {
                    above_distance = distance_between_nodes;
                    p_node_above = temp_node;
                }
            }
            // If positive, neighbour is above
            // If negative, neighbour is below
            if (distance_between_nodes < 0)
            {
                if (distance_between_nodes > below_distance)
                {
                    below_distance = distance_between_nodes;
                    p_node_below = temp_node;
                }
            }

        }

        // Add the contact nodes if they have been set
        if (above_distance != max_distance)
        {
            std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>*> contact_pair = std::make_pair(p_node_above, p_node);
            contact_nodes.insert(contact_pair);
        }
        if (below_distance != -max_distance)
        {
            std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>*> contact_pair = std::make_pair(p_node_below, p_node);
            contact_nodes.insert(contact_pair);
        }

        // Should get a maximum of two neighbours per node, one above, and one below

    }
    return contact_nodes;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicContactNeighbourSpringForce<ELEMENT_DIM,SPACE_DIM>::AddForceContribution(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation)
{
   
    //AbstractCentreBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>* p_tissue = static_cast<AbstractCentreBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>*>(&rCellPopulation);
    MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>* p_tissue = static_cast<MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>*>(&rCellPopulation);
    std::vector< std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > >& r_node_pairs = p_tissue->rGetNodePairs();


    // Checks if this is a 1D columnor a 2D column (i.e. cells can pop up)
    std::set< std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > > contact_nodes;
    if (m1DColumnOfCells)
    {
        contact_nodes = Find1DContactPairs(rCellPopulation);
    }else
    {
        contact_nodes = FindContactNeighbourPairs(rCellPopulation);
    }
    
    /*
        The set produced by FindContactNeighbourPairs has each pair duplicated
        I think this will always happen because of the way the neighbour finding algorithm works, but it also does it intentionally
        As a result, we need to make sure we are only applying the force once.
        To do this, we loop through the in-built r_node_pairs and apply the force if any given pair appears in the set also
        There is probably a more efficient way to do this, but it will require better understanding of the algorithm
    */

    // The following for loop is purely for debugging in the test TestContactNeighbours.hpp
    if (mDebugMode){
        for (typename std::set< std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > >::iterator iter = contact_nodes.begin();
            iter != contact_nodes.end();
            iter++)
        {
            std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > pair = *iter;
            unsigned node_a_index = pair.first->GetIndex();
            unsigned node_b_index = pair.second->GetIndex();
            PRINT_2_VARIABLES(node_a_index, node_b_index)
        }
    }

    for (typename std::vector< std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > >::iterator iter = r_node_pairs.begin();
        iter != r_node_pairs.end();
        iter++)
    {
        std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > pair = *iter;
        if( contact_nodes.find(pair) != contact_nodes.end() )
        {
            std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > pair = *iter;
        
            unsigned node_a_index = pair.first->GetIndex();
            unsigned node_b_index = pair.second->GetIndex();
            //PRINT_2_VARIABLES(node_a_index, node_b_index)
    
            // Calculate the force between nodes
            c_vector<double, SPACE_DIM> force = CalculateForceBetweenNodes(node_a_index, node_b_index, rCellPopulation);
            for (unsigned j=0; j<SPACE_DIM; j++)
            {
                //PRINT_VARIABLE(force[j])
                assert(!std::isnan(force[j]));
            }

    
            // Add the force contribution to each node
            c_vector<double, SPACE_DIM> negative_force = -1.0 * force;
            pair.first->AddAppliedForceContribution(force);
            pair.second->AddAppliedForceContribution(negative_force);
        }
    }

    // These for loops are for checking the positions and applied forces

    //  std::list<CellPtr> cells =  p_tissue->rGetCells();

    //  for (std::list<CellPtr>::iterator cell_iter = cells.begin(); cell_iter != cells.end(); ++cell_iter)
    //     {
    //         Node<SPACE_DIM>* p_node =  p_tissue->GetNodeCorrespondingToCell(*cell_iter);
    //         c_vector<double, 2> pos;
    //         pos = p_node->rGetLocation();
    //         PRINT_3_VARIABLES(p_node->GetIndex() , pos[0],pos[1])
    //     }

    // for (std::list<CellPtr>::iterator cell_iter = cells.begin(); cell_iter != cells.end(); ++cell_iter)
    // {
    //     Node<SPACE_DIM>* p_node =  p_tissue->GetNodeCorrespondingToCell(*cell_iter);
    //     c_vector<double, 2> force;
    //     force = p_node->rGetAppliedForce();
    //     PRINT_3_VARIABLES(p_node->GetIndex(), force[0], force[1])
    // }
}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
c_vector<double, SPACE_DIM> BasicContactNeighbourSpringForce<ELEMENT_DIM,SPACE_DIM>::CalculateForceBetweenNodes(unsigned nodeAGlobalIndex,
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


    // Checks if both cells are in M phase and checks if they have the same parent
    // *****************************************************************************************
    // Implements cell sibling tracking
    double ageA = p_cell_A->GetAge();
    double ageB = p_cell_B->GetAge();

    double parentA = p_cell_A->GetCellData()->GetItem("parent");
    double parentB = p_cell_B->GetCellData()->GetItem("parent");


    if (ageA < mMeinekeSpringGrowthDuration && ageA == ageB && parentA == parentB)
    {
        // Make the spring length grow.
        double lambda = mMeinekeDivisionRestingSpringLength;
        rest_length = lambda + (rest_length - lambda) * ageA/mMeinekeSpringGrowthDuration;
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
    }

}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicContactNeighbourSpringForce<ELEMENT_DIM,SPACE_DIM>::SetSpringStiffness(double SpringStiffness)
{
    assert(SpringStiffness > 0.0);
    mSpringStiffness = SpringStiffness;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicContactNeighbourSpringForce<ELEMENT_DIM,SPACE_DIM>::SetRestLength(double RestLength)
{
    assert(RestLength > 0.0);
    mRestLength = RestLength;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicContactNeighbourSpringForce<ELEMENT_DIM,SPACE_DIM>::SetCutOffLength(double CutOffLength)
{
    assert(CutOffLength > 0.0);
    mCutOffLength = CutOffLength;
}


// For growing spring length
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicContactNeighbourSpringForce<ELEMENT_DIM,SPACE_DIM>::SetMeinekeSpringStiffness(double springStiffness)
{
    assert(springStiffness > 0.0);
    mMeinekeSpringStiffness = springStiffness;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicContactNeighbourSpringForce<ELEMENT_DIM,SPACE_DIM>::SetMeinekeDivisionRestingSpringLength(double divisionRestingSpringLength)
{
    assert(divisionRestingSpringLength <= 1.0);
    assert(divisionRestingSpringLength >= 0.0);

    mMeinekeDivisionRestingSpringLength = divisionRestingSpringLength;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicContactNeighbourSpringForce<ELEMENT_DIM,SPACE_DIM>::SetMeinekeSpringGrowthDuration(double springGrowthDuration)
{
    assert(springGrowthDuration >= 0.0);

    mMeinekeSpringGrowthDuration = springGrowthDuration;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicContactNeighbourSpringForce<ELEMENT_DIM,SPACE_DIM>::SetDebugMode(bool debugStatus)
{
    mDebugMode = debugStatus;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicContactNeighbourSpringForce<ELEMENT_DIM,SPACE_DIM>::Set1D(bool dimStatus)
{
    m1DColumnOfCells = dimStatus;
}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void BasicContactNeighbourSpringForce<ELEMENT_DIM,SPACE_DIM>::OutputForceParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<SpringStiffness>" << mSpringStiffness << "</SpringStiffness>\n";

    *rParamsFile << "\t\t\t<MeinekeDivisionRestingSpringLength>" << mMeinekeDivisionRestingSpringLength << "</MeinekeDivisionRestingSpringLength>\n";
    *rParamsFile << "\t\t\t<MeinekeSpringGrowthDuration>" << mMeinekeSpringGrowthDuration << "</MeinekeSpringGrowthDuration>\n";

}

/////////////////////////////////////////////////////////////////////////////
// Explicit instantiation
/////////////////////////////////////////////////////////////////////////////

template class BasicContactNeighbourSpringForce<1,1>;
template class BasicContactNeighbourSpringForce<1,2>;
template class BasicContactNeighbourSpringForce<2,2>;
template class BasicContactNeighbourSpringForce<1,3>;
template class BasicContactNeighbourSpringForce<2,3>;
template class BasicContactNeighbourSpringForce<3,3>;

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(BasicContactNeighbourSpringForce)