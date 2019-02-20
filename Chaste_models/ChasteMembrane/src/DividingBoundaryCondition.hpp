#ifndef DividingBoundaryCondition_HPP_
#define DividingBoundaryCondition_HPP_

#include <cxxtest/TestSuite.h>
#include "CheckpointArchiveTypes.hpp"

#include "AbstractCellPopulationBoundaryCondition.hpp"
#include "CellCyclePhases.hpp"
#include "Debug.hpp"

// If a cell is in M phase (and in the crypt monolayer) it doesn't move perpendicular to the membrane axis
// In this case, perpendicular is 

class DividingBoundaryCondition : public AbstractCellPopulationBoundaryCondition<2>
{
private:

    friend class boost::serialization::access;
    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
        archive & boost::serialization::base_object<AbstractCellPopulationBoundaryCondition<2> >(*this);
    }


public:
    DividingBoundaryCondition(AbstractCellPopulation<2>* pCellPopulation)
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

            AbstractPhaseBasedCellCycleModel* p_ccm = static_cast<AbstractPhaseBasedCellCycleModel*>(cell_iter->GetCellCycleModel());


            if (p_ccm->GetCurrentCellCyclePhase() == M_PHASE)
            {

                typename std::map<Node<2>*, c_vector<double, 2> >::const_iterator it = rOldLocations.find(p_node);
                c_vector<double, 2> previous_location = it->second;
                
                // No movement allowed in the x direction
                p_node->rGetModifiableLocation()[0] = previous_location[0];

            }
        }
    }

    bool VerifyBoundaryCondition()
    {
        bool condition_satisfied = true;

        // for (AbstractCellPopulation<2>::Iterator cell_iter = this->mpCellPopulation->Begin();
        //      cell_iter != this->mpCellPopulation->End();
        //      ++cell_iter)
        // {
        //     unsigned node_index = this->mpCellPopulation->GetLocationIndexUsingCell(*cell_iter);
        //     Node<2>* p_node = this->mpCellPopulation->GetNode(node_index);

        //     double y_coordinate = p_node->rGetLocation()[1];
        //     double x_coordinate = p_node->rGetLocation()[0];
        //     typename std::map<Node<2>*, c_vector<double, 2> >::const_iterator it = rOldLocations.find(p_node);
        //     c_vector<double, 2> previous_location = it->second;
        //     if (cell_iter->HasCellProperty<BoundaryCellProperty>() && y_coordinate != previous_location[1] || x_coordinate != previous_location[0])
        //     {
        //         condition_satisfied = false;
        //         break;
        //     }
        // }
        return condition_satisfied;
    }

    void OutputCellPopulationBoundaryConditionParameters(out_stream& rParamsFile)
    {
        AbstractCellPopulationBoundaryCondition<2>::OutputCellPopulationBoundaryConditionParameters(rParamsFile);
    }
};

#endif