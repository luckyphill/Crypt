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
    DividingPopUpBoundaryCondition(AbstractCellPopulation<2>* pCellPopulation);

    void ImposeBoundaryCondition(const std::map<Node<2>*, c_vector<double, 2> >& rOldLocations);

    bool VerifyBoundaryCondition();

    void OutputCellPopulationBoundaryConditionParameters(out_stream& rParamsFile);

};

#endif