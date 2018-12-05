#ifndef CRYPTBOUNDARYCONDITION_HPP_
#define CRYPTBOUNDARYCONDITION_HPP_

#include <cxxtest/TestSuite.h>
#include "CheckpointArchiveTypes.hpp"

#include "AbstractCellPopulationBoundaryCondition.hpp"
#include "BoundaryCellProperty.hpp"
#include "Debug.hpp"

// Forces all cells marked with the BoundaryCellProperty to keep their y position 0

class CryptBoundaryCondition : public AbstractCellPopulationBoundaryCondition<2>
{
private:

    friend class boost::serialization::access;
    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
        archive & boost::serialization::base_object<AbstractCellPopulationBoundaryCondition<2> >(*this);
    }

public:
    CryptBoundaryCondition(AbstractCellPopulation<2>* pCellPopulation)
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
            //double y_coordinate = p_node->rGetLocation()[1];
            //double x_coordinate = p_node->rGetLocation()[0];

            if (cell_iter->HasCellProperty<BoundaryCellProperty>())
            {
                // PRINT_VARIABLE(rOldLocations[p_node])
                typename std::map<Node<2>*, c_vector<double, 2> >::const_iterator it = rOldLocations.find(p_node);
                c_vector<double, 2> previous_location = it->second;
                p_node->rGetModifiableLocation()[0] = previous_location[0];
                p_node->rGetModifiableLocation()[1] = previous_location[1]; //5.19; //rOldLocations[p_node][1];
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