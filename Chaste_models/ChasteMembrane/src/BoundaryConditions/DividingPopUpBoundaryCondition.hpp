#ifndef DividingPopUpBoundaryCondition_HPP_
#define DividingPopUpBoundaryCondition_HPP_

#include <cxxtest/TestSuite.h>
#include "CheckpointArchiveTypes.hpp"

#include "AbstractCellPopulationBoundaryCondition.hpp"
#include "SimplifiedPhaseBasedCellCycleModel.hpp"
#include "SimplifiedCellCyclePhases.hpp"
#include "Debug.hpp"

// This "boundary condition" allows dividing cells to pop up
// It forces twin cells in W phase to keep their division axis parallel to
// the membrane axis. At this stage the membrane axis is assumed to be
// vertical

class DividingPopUpBoundaryCondition : public AbstractCellPopulationBoundaryCondition<2>
{
private:

    friend class boost::serialization::access;
    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
        archive & boost::serialization::base_object<AbstractCellPopulationBoundaryCondition<2> >(*this);
    }


public:
    DividingPopUpBoundaryCondition(AbstractCellPopulation<2>* pCellPopulation)
        : AbstractCellPopulationBoundaryCondition<2>(pCellPopulation)

    {
    }

    void ImposeBoundaryCondition(const std::map<Node<2>*, c_vector<double, 2> >& rOldLocations)
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

                        // Take the average of the two
                        double average_position = (location[0] + location_neighbour[0]) / 2;
                        
                        // No movement allowed in the x direction
                        p_node->rGetModifiableLocation()[0] = average_position;
                        p_node_neighbour->rGetModifiableLocation()[0] = average_position;
                        break;
                    }
                }
            }
        }
    }

    bool VerifyBoundaryCondition()
    {
        bool condition_satisfied = true;

        return condition_satisfied;
    }

    void OutputCellPopulationBoundaryConditionParameters(out_stream& rParamsFile)
    {
        AbstractCellPopulationBoundaryCondition<2>::OutputCellPopulationBoundaryConditionParameters(rParamsFile);
    }
};

#endif