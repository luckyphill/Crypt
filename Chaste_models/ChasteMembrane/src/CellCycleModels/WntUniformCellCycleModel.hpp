#ifndef WNTUNIFORMCELLCYCLEMODEL_HPP_
#define WNTUNIFORMCELLCYCLEMODEL_HPP_

#include "UniformCellCycleModel.hpp"
#include "WntConcentration.hpp"


class WntUniformCellCycleModel : public UniformCellCycleModel
{
	
public:
	WntUniformCellCycleModel();
	WntUniformCellCycleModel(const WntUniformCellCycleModel& rModel);

    /** Empty virtual destructor so archiving works with static libraries. */
    ~WntUniformCellCycleModel();

    bool IsAbovetWntThreshold();
    AbstractCellCycleModel* CreateCellCycleModel();
    void OutputCellCycleModelParameters(out_stream& rParamsFile);
    virtual bool ReadyToDivide();
    virtual void ResetForDivision();

    double mNicheDivisionRegimeThreshold = 0.66;
    double mTransientRegimeThreshold = 0.33;

    double mNicheCellCycleTime;
    double mTransientCellCycleTime;

    void SetNicheCellCycleTime(double nicheCellCycleTime);
    void SetTransientCellCycleTime(double transientCellCycleTime);


};

#include "SerializationExportWrapper.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(WntUniformCellCycleModel)

#endif /*WNTUNIFORMCELLCYCLEMODEL_HPP_*/