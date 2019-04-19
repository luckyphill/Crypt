
#include "DividingPopUpBoundaryCondition.hpp"
#include "AbstractCentreBasedCellPopulation.hpp"
#include "VertexBasedCellPopulation.hpp"
#include "SimplifiedPhaseBasedCellCycleModel.hpp"
#include "SimplifiedCellCyclePhases.hpp"
#include "Debug.hpp"

DividingPopUpBoundaryCondition::DividingPopUpBoundaryCondition(AbstractCellPopulation<2>* pCellPopulation)
        : AbstractCellPopulationBoundaryCondition<2>(pCellPopulation)
{

}


void DividingPopUpBoundaryCondition::ImposeBoundaryCondition(const std::map<Node<2>*, c_vector<double, 2> >& rOldLocations)
{
    for (AbstractCellPopulation<2>::Iterator cell_iter = this->mpCellPopulation->Begin();
             cell_iter != this->mpCellPopulation->End();
             ++cell_iter)
        {

            unsigned node_index = this->mpCellPopulation->GetLocationIndexUsingCell(*cell_iter);
            Node<2>* p_node = this->mpCellPopulation->GetNode(node_index);

            SimplifiedPhaseBasedCellCycleModel* p_ccm = static_cast<SimplifiedPhaseBasedCellCycleModel*>(cell_iter->GetCellCycleModel());


            if (p_ccm->GetCurrentCellCyclePhase() == W_PHASE)
            {
                // Must find its pair
                std::vector<unsigned>& neighbours = p_node->rGetNeighbours();
                std::vector<unsigned>::iterator neighbour;

                typename std::map<Node<2>*, c_vector<double, 2> >::const_iterator it = rOldLocations.find(p_node);
                c_vector<double, 2> location = this->mpCellPopulation->GetLocationOfCellCentre(*cell_iter);

                Node<2>* p_node_neighbour;
                c_vector<double, 2> location_neighbour;

                for (neighbour = neighbours.begin(); neighbour != neighbours.end(); neighbour++)
                {
                    CellPtr p_neighbour_cell = mpCellPopulation->GetCellUsingLocationIndex(*neighbour);
                    p_node_neighbour = this->mpCellPopulation->GetNode(*neighbour);

                    
                    if ( p_neighbour_cell->GetCellData()->GetItem("parent") == (*cell_iter)->GetCellData()->GetItem("parent") )
                    {
                        location_neighbour = this->mpCellPopulation->GetLocationOfCellCentre(p_neighbour_cell);

                        // // // Take the average of the two
                        // double average_position = (location[0] + location_neighbour[0]) / 2;
                        
                        // // No movement allowed in the x direction
                        // p_node->rGetModifiableLocation()[0] = average_position;
                        // p_node_neighbour->rGetModifiableLocation()[0] = average_position;

                        // Move to 3/4 position

                        double difference = abs(location[0] - location_neighbour[0]);

                        double frd = 0.05;
                        double fru = 1 - frd;
                        if (location[0] > location_neighbour[0])
                        {
                            p_node->rGetModifiableLocation()[0] -= frd * difference;
                            p_node_neighbour->rGetModifiableLocation()[0] += fru * difference;
                        } else 
                        {
                            p_node->rGetModifiableLocation()[0] += fru * difference;
                            p_node_neighbour->rGetModifiableLocation()[0] -= frd * difference;
                        }

                        // Move to furthest position

                        // double max_position = fmax(location[0], location_neighbour[0]);
                        // p_node->rGetModifiableLocation()[0] = max_position;
                        // p_node_neighbour->rGetModifiableLocation()[0] = max_position;
                        break;
                    }
                }
            }
        }  
}

bool DividingPopUpBoundaryCondition::VerifyBoundaryCondition()
{

    return true;
}

void DividingPopUpBoundaryCondition::OutputCellPopulationBoundaryConditionParameters(out_stream& rParamsFile)
{
    // Call method on direct parent class
    AbstractCellPopulationBoundaryCondition::OutputCellPopulationBoundaryConditionParameters(rParamsFile);
}


// // Serialization for Boost >= 1.36
// #include "SerializationExportWrapperForCpp.hpp"
// EXPORT_TEMPLATE_CLASS_ALL_DIMS(DividingPopUpBoundaryCondition)
