

#ifndef WNTCELLCYCLEMODELMembraneCell_HPP_
#define WNTCELLCYCLEMODELMembraneCell_HPP_

#include "WntConcentration.hpp"
#include "RandomNumberGenerator.hpp"


class WntCellCycleModelMembraneCell : public AbstractCellCycleModel
{
	
public:
	WntCellCycleModelMembraneCell();
	WntCellCycleModelMembraneCell(const WntCellCycleModelMembraneCell& rModel);

    /** Empty virtual destructor so archiving works with static libraries. */
    ~WntCellCycleModelMembraneCell();

    bool IsAbovetWntThreshold();
    AbstractCellCycleModel* CreateCellCycleModel();
    double mNicheDivisionRegimeThreshold = 0.66;
    double mTransientRegimeThreshold = 0.33;

    double mNicheCellCycleTime = 0.0;
    double mTransientCellCycleTime = 0.0;

    //Store the vairables twice - one is fixed, the other can be modified
    double mStoredNicheCellCycleTime = 0.0;
    double mStoredTransientCellCycleTime = 0.0;

    double mMaxCompressionForDivision = 0.88;
    
    
    //From AbstractCellCycleModel
    bool ReadyToDivide();
    void ResetForDivision();
    void InitialiseDaughterCell();
    double GetAverageTransitCellCycleTime(); //Forced to implement these, but they won't do anything
    double GetAverageStemCellCycleTime();

    void SetNicheCellCycleTime(double nicheCellCycleTime);
    void SetTransientCellCycleTime(double transientCellCycleTime);
    void SetCellCycleTimesForDaughter();
    void OutputCellCycleModelParameters(out_stream& rParamsFile);
    bool IsCompressed();


};

#include "SerializationExportWrapper.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(WntCellCycleModelMembraneCell)

#endif /*WNTCELLCYCLEMODELMembraneCell_HPP_*/