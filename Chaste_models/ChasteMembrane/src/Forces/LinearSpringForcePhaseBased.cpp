/*
Initial strucure borrows heavily from EpithelialLayerBasementMembraneForce by Axel Almet
- Added mutation that turns a differentiated cell into a "membrane cell" in 
in order to test a method of introducing a membrane
- The modifications here only change the way the "mutant" cells interact with each
other. Otherwise they are still considered "differentiated" cells for other interactions
*/

#include "IsNan.hpp"
#include "AbstractCellProperty.hpp"

#include "MembraneCellProliferativeType.hpp"
#include "TransitCellProliferativeType.hpp"
#include "StemCellProliferativeType.hpp"

#include "Debug.hpp"

#include "LinearSpringForcePhaseBased.hpp"
#include "GrowingContactInhibitionPhaseBasedCCM.hpp"


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::LinearSpringForcePhaseBased()
   : AbstractForce<ELEMENT_DIM,SPACE_DIM>(),
    mEpithelialSpringStiffness(15.0), // Epithelial covers stem and transit
    mMembraneSpringStiffness(15.0),
    mStromalSpringStiffness(15.0), // Stromal is the differentiated "filler" cells
    mEpithelialMembraneSpringStiffness(15.0),
    mMembraneStromalSpringStiffness(15.0),
    mStromalEpithelialSpringStiffness(15.0),
    mEpithelialPreferredRadius(1.0),
    mMembranePreferredRadius(0.1),
    mStromalPreferredRadius(1.0),
    mEpithelialInteractionRadius(1.5), // Epithelial covers stem and transit
    mMembraneInteractionRadius(0.15),
    mStromalInteractionRadius(1.5) // Stromal is the differentiated "filler" cells
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::~LinearSpringForcePhaseBased()
{
}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
std::set<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* >> LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::GetContactNeighbours(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation)
{

    MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>* p_tissue = static_cast<MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>*>(&rCellPopulation);

    unsigned debug_node = 71;
    unsigned other_debug_node = 66;

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

        if (mDebugMode && (p_node->GetIndex()==debug_node || p_node->GetIndex()==other_debug_node))
        {
            // Print the candidate neighbours
            TRACE("    ")
            PRINT_VARIABLE(SimulationTime::Instance()->GetTime())
            TRACE("Candidate neighbours for node with index:")
            PRINT_VARIABLE(p_node->GetIndex())
        }
        
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
            if (mDebugMode && (p_node->GetIndex()==debug_node || p_node->GetIndex()==other_debug_node))
            {
                // Print the candidate neighbours
                PRINT_2_VARIABLES(std::get<0>(particular_data)->GetIndex(), std::get<2>(particular_data))
            }
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
                double R = 0; // Preferred radius of the centre cell
                double R_inter = 0; // Interaction radius of centre cell
                
                bool membrane_center = (*cell_iter)->GetCellProliferativeType()->IsType<MembraneCellProliferativeType>();
                bool stromal_center = (*cell_iter)->GetCellProliferativeType()->IsType<DifferentiatedCellProliferativeType>();
                bool epi_center = ( (*cell_iter)->GetCellProliferativeType()->IsType<TransitCellProliferativeType>() || (*cell_iter)->GetCellProliferativeType()->IsType<StemCellProliferativeType>() );
                
                if(membrane_center)     {R = mMembranePreferredRadius;}
                if(stromal_center)      {R = mStromalPreferredRadius;}
                if(epi_center)          
                {
                    GrowingContactInhibitionPhaseBasedCCM* pCCM = static_cast<GrowingContactInhibitionPhaseBasedCCM*>((*cell_iter)->GetCellCycleModel());
                    R = pCCM->GetPreferredRadius();
                } // Multiply by time fraction in CMM phase p_cell_cn->GetCellCycleModel()->

                if(membrane_center)     {R_inter = mMembraneInteractionRadius;}
                if(stromal_center)      {R_inter = mStromalInteractionRadius;}
                if(epi_center)
                {
                    GrowingContactInhibitionPhaseBasedCCM* pCCM = static_cast<GrowingContactInhibitionPhaseBasedCCM*>((*cell_iter)->GetCellCycleModel());
                    R_inter = pCCM->GetInteractionRadius();
                }
                assert(R != 0);

                
                typename std::vector<  std::tuple< Node<SPACE_DIM>*, c_vector<double, SPACE_DIM>, double >  >::iterator nd_it;
                
                // Loop through ordered vector of closest to furthest neighbours
                for( nd_it = std::next(neighbour_data.begin(),1); nd_it != neighbour_data.end(); nd_it ++)
                {
                    double distance_nd = std::get<2>((*nd_it));

                    bool satisfied = true; // Assume that it is a contact neighbour until we contradict it
                    
                    if ( distance_nd > R_inter ) // If candidate is too far away, then it's out automatically
                    {

                        satisfied = false;
                        if (mDebugMode && (p_node->GetIndex()==debug_node || p_node->GetIndex()==other_debug_node))
                        {
                            // Print the candidate neighbours
                            TRACE("Too far")
                            PRINT_VARIABLE(std::get<0>((*nd_it))->GetIndex())
                        }

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
                            double r_cn = 0; //preferred radius of contact neighbour
                            
                            Node<SPACE_DIM>* p_node_cn = std::get<0>((*cn_it));
                            CellPtr p_cell_cn = p_tissue->GetCellUsingLocationIndex(p_node_cn->GetIndex());
                            
                            bool membrane_cn = p_cell_cn->GetCellProliferativeType()->IsType<MembraneCellProliferativeType>();
                            bool stromal_cn = p_cell_cn->GetCellProliferativeType()->IsType<DifferentiatedCellProliferativeType>();
                            bool epi_cn = ( p_cell_cn->GetCellProliferativeType()->IsType<TransitCellProliferativeType>() || p_cell_cn->GetCellProliferativeType()->IsType<StemCellProliferativeType>() );
                            
                            if(membrane_cn)     {r_cn = mMembranePreferredRadius;}
                            if(stromal_cn)      {r_cn = mStromalPreferredRadius;}
                            if(epi_cn)
                            {
                                GrowingContactInhibitionPhaseBasedCCM* pCCM = static_cast<GrowingContactInhibitionPhaseBasedCCM*>(p_cell_cn->GetCellCycleModel());
                                r_cn = pCCM->GetPreferredRadius();
                            }
                            assert(r_cn != 0);

                            
                            // Now working for nd
                            
                            c_vector<double, SPACE_DIM> vec_nd = std::get<1>((*nd_it));


                            // Need to work out what the preferred radius of the candidate neighbour is
                            double r_nd = 0; //preferred radius of candidate neighbour cell

                            Node<SPACE_DIM>* p_node_nd = std::get<0>((*nd_it));
                            CellPtr p_cell_nd = p_tissue->GetCellUsingLocationIndex(p_node_nd->GetIndex());

                            bool membrane_nd = p_cell_nd->GetCellProliferativeType()->IsType<MembraneCellProliferativeType>();
                            bool stromal_nd = p_cell_nd->GetCellProliferativeType()->IsType<DifferentiatedCellProliferativeType>();
                            bool epi_nd = ( p_cell_nd->GetCellProliferativeType()->IsType<TransitCellProliferativeType>() || p_cell_nd->GetCellProliferativeType()->IsType<StemCellProliferativeType>() );
                            
                            if(membrane_nd)     {r_nd = mMembranePreferredRadius;}
                            if(stromal_nd)      {r_nd = mStromalPreferredRadius;}
                            if(epi_nd)
                            {
                                GrowingContactInhibitionPhaseBasedCCM* pCCM = static_cast<GrowingContactInhibitionPhaseBasedCCM*>(p_cell_nd->GetCellCycleModel());
                                r_nd = pCCM->GetPreferredRadius();
                            }
                            assert(r_nd != 0);



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
                                if (mDebugMode && (p_node->GetIndex() == debug_node || p_node->GetIndex() == other_debug_node))
                                {
                                    // Print the candidate neighbours
                                    TRACE("Far away and behind")
                                    PRINT_VARIABLE(std::get<0>((*nd_it))->GetIndex())
                                }
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
                                    if (mDebugMode && (p_node->GetIndex()== debug_node || p_node->GetIndex() == other_debug_node))
                                    {
                                        // Print the candidate neighbours
                                        TRACE("Close and behind")
                                        PRINT_VARIABLE(std::get<0>((*nd_it))->GetIndex())
                                    }
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
                if (mDebugMode && (p_node->GetIndex() == debug_node || p_node->GetIndex() == other_debug_node))
                {
                    // Print the candidate neighbours
                    TRACE("Contact neighbours for node with index")
                    PRINT_VARIABLE(p_node->GetIndex())
                    typename std::vector<  std::tuple< Node<SPACE_DIM>*, c_vector<double, SPACE_DIM>, double >  >::iterator cn_it;
                    for( cn_it = contact_neighbours.begin(); cn_it != contact_neighbours.end(); cn_it ++)
                    { 

                        PRINT_VARIABLE(std::get<0>((*cn_it))->GetIndex())
                    }
                }
            }
        }
    }
    return contact_nodes;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::AddForceContribution(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation)
{
   
    //AbstractCentreBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>* p_tissue = static_cast<AbstractCentreBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>*>(&rCellPopulation);
    MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>* p_tissue = static_cast<MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>*>(&rCellPopulation);
    std::vector< std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > >& r_node_pairs = p_tissue->rGetNodePairs();

    std::set<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* >> contact_nodes = GetContactNeighbours(rCellPopulation);

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
    
            // Calculate the force between nodes
            c_vector<double, SPACE_DIM> force = CalculateForceBetweenNodes(node_a_index, node_b_index, rCellPopulation);
            for (unsigned j=0; j<SPACE_DIM; j++)
            {
                //PRINT_2_VARIABLES(node_a_index, node_b_index)
                assert(!std::isnan(force[j]));
            }
    
            // Add the force contribution to each node
            c_vector<double, SPACE_DIM> negative_force = -1.0 * force;
            pair.first->AddAppliedForceContribution(force);
            pair.second->AddAppliedForceContribution(negative_force);
        }
    }
}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
c_vector<double, SPACE_DIM> LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::CalculateForceBetweenNodes(unsigned nodeAGlobalIndex,
                                                                                    unsigned nodeBGlobalIndex,
                                                                                    AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation)
{
    // We should only ever calculate the force between two distinct nodes
    assert(nodeAGlobalIndex != nodeBGlobalIndex);

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

    // We have three types of cells, with 6 different possible pairings as demarked by the 6 different spring stiffnesses
    // Need to check which types we have and set spring_constant accordingly

    CellPtr p_cell_A = rCellPopulation.GetCellUsingLocationIndex(nodeAGlobalIndex);
    CellPtr p_cell_B = rCellPopulation.GetCellUsingLocationIndex(nodeBGlobalIndex);

    // First, determine what we've got
    bool membraneA = p_cell_A->GetCellProliferativeType()->IsType<MembraneCellProliferativeType>();
    bool membraneB = p_cell_B->GetCellProliferativeType()->IsType<MembraneCellProliferativeType>();

    bool stromalA = p_cell_A->GetCellProliferativeType()->IsType<DifferentiatedCellProliferativeType>();
    bool stromalB = p_cell_B->GetCellProliferativeType()->IsType<DifferentiatedCellProliferativeType>();

    bool epiA = ( p_cell_A->GetCellProliferativeType()->IsType<TransitCellProliferativeType>() || p_cell_A->GetCellProliferativeType()->IsType<StemCellProliferativeType>() );
    bool epiB = ( p_cell_B->GetCellProliferativeType()->IsType<TransitCellProliferativeType>() || p_cell_B->GetCellProliferativeType()->IsType<StemCellProliferativeType>() );

    double preferredRadiusA = 0.0;
    double preferredRadiusB = 0.0;

    double spring_constant = 0.0;

    // Determine rest lengths and spring stiffnesses
    if (membraneA)
    {
        preferredRadiusA = mMembranePreferredRadius;
        if (membraneB)
        {
            if (distance_between_nodes >= mMembraneInteractionRadius)
            {
                return zero_vector<double>(SPACE_DIM);
            }
            preferredRadiusB = mMembranePreferredRadius;
            spring_constant = mMembraneSpringStiffness;
        }
        if (stromalB)
        {   
            if (distance_between_nodes >= std::max(mStromalInteractionRadius, mMembraneInteractionRadius))
            {
                return zero_vector<double>(SPACE_DIM);
            }
            preferredRadiusB = mStromalPreferredRadius;
            spring_constant = mMembraneStromalSpringStiffness;
        }
        if (epiB)
        {
            // GrowingContactInhibitionPhaseBasedCCM* pCCM = static_cast<GrowingContactInhibitionPhaseBasedCCM*>(p_cell_B->GetCellCycleModel());
            // preferredRadiusB = pCCM->GetPreferredRadius();
            // double epiInteractionRadius = pCCM->GetInteractionRadius();
            double epiInteractionRadius = mEpithelialInteractionRadius;
            preferredRadiusB = mEpithelialPreferredRadius;
            if (distance_between_nodes >= std::max(epiInteractionRadius, mMembraneInteractionRadius))
            {
                return zero_vector<double>(SPACE_DIM);
            }
            spring_constant = mEpithelialMembraneSpringStiffness;
        }
    }

    if (stromalA)
    {
        preferredRadiusA = mStromalPreferredRadius;

        if (membraneB)
        {
            if (distance_between_nodes >= std::max(mStromalInteractionRadius, mMembraneInteractionRadius))
            {
                return zero_vector<double>(SPACE_DIM);
            }
            preferredRadiusB = mMembranePreferredRadius;
            spring_constant = mMembraneStromalSpringStiffness;
        }
        if (stromalB)
        {
            if (distance_between_nodes >= mStromalInteractionRadius)
            {
                return zero_vector<double>(SPACE_DIM);
            }
            preferredRadiusB = mStromalPreferredRadius;
            spring_constant = mStromalSpringStiffness;
        }
        if (epiB)
        {
            GrowingContactInhibitionPhaseBasedCCM* pCCM = static_cast<GrowingContactInhibitionPhaseBasedCCM*>(p_cell_B->GetCellCycleModel());
            preferredRadiusB = pCCM->GetPreferredRadius();
            double epiInteractionRadius = pCCM->GetInteractionRadius();
            if (distance_between_nodes >= std::max(epiInteractionRadius, mStromalInteractionRadius))
            {
                return zero_vector<double>(SPACE_DIM);
            }
            spring_constant = mStromalEpithelialSpringStiffness;
            // PRINT_VARIABLE(preferredRadiusB)
        }
    }

    if (epiA)
    {
        GrowingContactInhibitionPhaseBasedCCM* pCCM = static_cast<GrowingContactInhibitionPhaseBasedCCM*>(p_cell_A->GetCellCycleModel());
        preferredRadiusA = pCCM->GetPreferredRadius();
        double epiInteractionRadius = pCCM->GetInteractionRadius();
        // PRINT_VARIABLE(preferredRadiusA)
        // PRINT_VARIABLE(nodeAGlobalIndex)

        if (membraneB)
        {
            if (distance_between_nodes >= std::max(epiInteractionRadius, mMembraneInteractionRadius))
            {
                return zero_vector<double>(SPACE_DIM);
            }
            preferredRadiusB = mMembranePreferredRadius;
            spring_constant = mEpithelialMembraneSpringStiffness;
            // If we have a membrane, the prefereed radius of the epithelial cell doesn't change
            preferredRadiusA = mEpithelialPreferredRadius;

        }
        if (stromalB)
        {
            if (distance_between_nodes >= std::max(epiInteractionRadius, mStromalInteractionRadius))
            {
                return zero_vector<double>(SPACE_DIM);
            }
            preferredRadiusB = mStromalPreferredRadius;
            spring_constant = mStromalEpithelialSpringStiffness;
        }
       
        if (epiB)
        {
            if (distance_between_nodes >= epiInteractionRadius)
            {
                return zero_vector<double>(SPACE_DIM);
            }
            GrowingContactInhibitionPhaseBasedCCM* pCCM = static_cast<GrowingContactInhibitionPhaseBasedCCM*>(p_cell_B->GetCellCycleModel());
            preferredRadiusB = pCCM->GetPreferredRadius();
            spring_constant = mEpithelialSpringStiffness;
        }
    }

    //assert(spring_constant > 0);
    
    double rest_length = preferredRadiusA + preferredRadiusB;

    if (p_cell_A->HasApoptosisBegun())
    {
        double time_until_death_a = p_cell_A->GetTimeUntilDeath();
        preferredRadiusA = preferredRadiusA * time_until_death_a / p_cell_A->GetApoptosisTime();
    }
    if (p_cell_B->HasApoptosisBegun())
    {
        double time_until_death_b = p_cell_B->GetTimeUntilDeath();
        preferredRadiusB = preferredRadiusB * time_until_death_b / p_cell_B->GetApoptosisTime();
    }

    rest_length = preferredRadiusA + preferredRadiusB;
   
    double overlap = distance_between_nodes - rest_length;
    bool is_closer_than_rest_length = (overlap <= 0);

    if (is_closer_than_rest_length) //overlap is negative
    {
        // log(x+1) is undefined for x<=-1
        assert(overlap > -rest_length);
        c_vector<double, 2> temp = spring_constant * unitForceDirection * rest_length * log(1.0 + overlap/(rest_length));
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
void LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::SetEpithelialSpringStiffness(double epithelialSpringStiffness)
{
    assert(epithelialSpringStiffness> 0.0);
    mEpithelialSpringStiffness = epithelialSpringStiffness;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::SetMembraneSpringStiffness(double membraneSpringStiffness)
{
    //assert(membraneSpringStiffness > 0.0);
    mMembraneSpringStiffness = membraneSpringStiffness;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::SetStromalSpringStiffness(double stromalSpringStiffness)
{
    assert(stromalSpringStiffness > 0.0);
    mStromalSpringStiffness = stromalSpringStiffness;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::SetEpithelialMembraneSpringStiffness(double epithelialMembraneSpringStiffness)
{
    assert(epithelialMembraneSpringStiffness > 0.0);
    mEpithelialMembraneSpringStiffness = epithelialMembraneSpringStiffness;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::SetMembraneStromalSpringStiffness(double membraneStromalSpringStiffness)
{
    assert(membraneStromalSpringStiffness > 0.0);
    mMembraneStromalSpringStiffness = membraneStromalSpringStiffness;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::SetStromalEpithelialSpringStiffness(double stromalEpithelialSpringStiffness)
{
    assert(stromalEpithelialSpringStiffness > 0.0);
    mStromalEpithelialSpringStiffness = stromalEpithelialSpringStiffness;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::SetEpithelialPreferredRadius(double epithelialPreferredRadius)
{
    assert(epithelialPreferredRadius> 0.0);
    mEpithelialPreferredRadius = epithelialPreferredRadius;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::SetMembranePreferredRadius(double membranePreferredRadius)
{
    assert(membranePreferredRadius > 0.0);
    mMembranePreferredRadius = membranePreferredRadius;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::SetStromalPreferredRadius(double stromalPreferredRadius)
{
    assert(stromalPreferredRadius > 0.0);
    mStromalPreferredRadius = stromalPreferredRadius;
}



template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::SetEpithelialInteractionRadius(double epithelialInteractionRadius)
{
    assert(epithelialInteractionRadius> 0.0);
    mEpithelialInteractionRadius = epithelialInteractionRadius;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::SetMembraneInteractionRadius(double membraneInteractionRadius)
{
    assert(membraneInteractionRadius > 0.0);
    mMembraneInteractionRadius = membraneInteractionRadius;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::SetStromalInteractionRadius(double stromalInteractionRadius)
{
    assert(stromalInteractionRadius > 0.0);
    mStromalInteractionRadius = stromalInteractionRadius;
}



template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::SetMeinekeDivisionRestingSpringLength(double divisionRestingSpringLength)
{
    assert(divisionRestingSpringLength <= 1.0);
    assert(divisionRestingSpringLength >= 0.0);

    mMeinekeDivisionRestingSpringLength = divisionRestingSpringLength;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::SetMeinekeSpringGrowthDuration(double springGrowthDuration)
{
    assert(springGrowthDuration >= 0.0);

    mMeinekeSpringGrowthDuration = springGrowthDuration;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::SetDebugMode(bool debugStatus)
{
    mDebugMode = debugStatus;
}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void LinearSpringForcePhaseBased<ELEMENT_DIM,SPACE_DIM>::OutputForceParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<EpithelialSpringStiffness>" << mEpithelialSpringStiffness << "</EpithelialSpringStiffness>\n";
    *rParamsFile << "\t\t\t<MembraneSpringStiffness>" << mMembraneSpringStiffness << "</MembraneSpringStiffness>\n";
    *rParamsFile << "\t\t\t<StromalSpringStiffness>" << mStromalSpringStiffness << "</StromalSpringStiffness>\n";
    *rParamsFile << "\t\t\t<EpithelialMembraneSpringStiffness>" << mEpithelialMembraneSpringStiffness << "</EpithelialMembraneSpringStiffness>\n";
    *rParamsFile << "\t\t\t<MembranetromalSpringStiffness>" << mMembraneStromalSpringStiffness << "</MembranetromalSpringStiffness>\n";
    *rParamsFile << "\t\t\t<StromalEpithelialSpringStiffness>" << mStromalEpithelialSpringStiffness << "</StromalEpithelialSpringStiffness>\n";

    *rParamsFile << "\t\t\t<EpithelialPreferredRadius>" << mEpithelialPreferredRadius << "</EpithelialPreferredRadius>\n";
    *rParamsFile << "\t\t\t<MembranePreferredRadius>" << mMembranePreferredRadius << "</MembranePreferredRadius>\n";
    *rParamsFile << "\t\t\t<StromalPreferredRadius>" << mStromalPreferredRadius << "</StromalPreferredRadius>\n";

    *rParamsFile << "\t\t\t<EpithelialInteractionRadius>" << mEpithelialInteractionRadius << "</EpithelialInteractionRadius>\n";
    *rParamsFile << "\t\t\t<MembraneInteractionRadius>" << mMembraneInteractionRadius << "</MembraneInteractionRadius>\n";
    *rParamsFile << "\t\t\t<StromalInteractionRadius>" << mStromalInteractionRadius << "</StromalInteractionRadius>\n";

    *rParamsFile << "\t\t\t<MeinekeDivisionRestingSpringLength>" << mMeinekeDivisionRestingSpringLength << "</MeinekeDivisionRestingSpringLength>\n";
    *rParamsFile << "\t\t\t<MeinekeSpringGrowthDuration>" << mMeinekeSpringGrowthDuration << "</MeinekeSpringGrowthDuration>\n";

}

/////////////////////////////////////////////////////////////////////////////
// Explicit instantiation
/////////////////////////////////////////////////////////////////////////////

template class LinearSpringForcePhaseBased<1,1>;
template class LinearSpringForcePhaseBased<1,2>;
template class LinearSpringForcePhaseBased<2,2>;
template class LinearSpringForcePhaseBased<1,3>;
template class LinearSpringForcePhaseBased<2,3>;
template class LinearSpringForcePhaseBased<3,3>;

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(LinearSpringForcePhaseBased)