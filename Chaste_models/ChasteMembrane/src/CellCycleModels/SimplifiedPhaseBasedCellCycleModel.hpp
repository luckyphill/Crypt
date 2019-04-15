
#ifndef SimplifiedPhaseBasedCELLCYCLEMODEL_HPP_
#define SimplifiedPhaseBasedCELLCYCLEMODEL_HPP_

#include "ChasteSerialization.hpp"
#include "ClassIsAbstract.hpp"

#include <boost/serialization/base_object.hpp>

#include <vector>

#include "AbstractCellCycleModel.hpp"
#include "SimplifiedCellCyclePhases.hpp"
#include "SimulationTime.hpp"


/**
 * The SimplifiedPhaseBasedCellCycleModel contains basic information to all phase based cell-cycle models.
 * It handles assignment of aspects of cell cycle phase.
 *
 */
class SimplifiedPhaseBasedCellCycleModel : public AbstractCellCycleModel
{
private:

    /** Needed for serialization. */
    friend class boost::serialization::access;
    /**
     * Archive the object and its member variables.
     *
     * @param archive the archive
     * @param version the current version of this class
     */
    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
        archive & boost::serialization::base_object<AbstractCellCycleModel>(*this);
        archive & mCurrentCellCyclePhase;
        archive & mPDuration;
        archive & mMinimumPDuration;
        archive & mWDuration;
    }

protected:

    /** The phase of the cell cycle that this model is in (specified in CellCyclePhases.hpp) */
    SimplifiedCellCyclePhase mCurrentCellCyclePhase;

    double mBasePDuration;
    /**
     * How long the pausable phase lasts for
     */
    double mPDuration;

    /**
     * Minimum possible duration of the Growth phase
     */
    double mMinimumPDuration = 1;

    /**
     * Duration of W phase for all cell types.
     */
    double mWDuration;

    /**
     * The fraction of the cells' equilibrium volume in P phase below which these cells are quiescent.
     */
    double mQuiescentVolumeFraction;

    /**
     * The cell equilibrium volume while in P phase.
     */
    double mEquilibriumVolume;

    /**
     * The time when the current period of quiescence began.
     */
    double mCurrentQuiescentOnsetTime;

    /**
     * How long the current period of quiescence has lasted.
     * Has units of hours.
     */
    double mCurrentQuiescentDuration;

    double mWntThreshold;

    bool mPopUpDivision = false; // If we allow cells to continue cycling when they pop up

    /**
     * Protected copy-constructor for use by CreateCellCycleModel.
     * The only way for external code to create a copy of a cell cycle model
     * is by calling that method, to ensure that a model of the correct subclass is created.
     * This copy-constructor helps subclasses to ensure that all member variables are correctly copied when this happens.
     *
     * This method is called by child classes to set member variables for a daughter cell upon cell division.
     * Note that the parent cell cycle model will have had ResetForDivision() called just before CreateCellCycleModel() is called,
     * so performing an exact copy of the parent is suitable behaviour. Any daughter-cell-specific initialisation
     * can be done in InitialiseDaughterCell().
     *
     * @param rModel the cell cycle model to copy.
     */
    SimplifiedPhaseBasedCellCycleModel(const SimplifiedPhaseBasedCellCycleModel& rModel);

public:

    /**
     * Default constructor - creates an SimplifiedPhaseBasedCellCycleModel.
     */
    SimplifiedPhaseBasedCellCycleModel();

    ~SimplifiedPhaseBasedCellCycleModel();

    AbstractCellCycleModel* CreateCellCycleModel();

    void Initialise();

    void Initialise(SimplifiedCellCyclePhase phase);

    void InitialiseDaughterCell();
    
    /** See AbstractCellCycleModel::ResetForDivision() */
    void ResetForDivision();

    /**
     * Set the phase the cell-cycle model is currently in.
     */
    void UpdateCellCyclePhase();

    /**
     * @return the current cell cycle phase
     */
    SimplifiedCellCyclePhase GetCurrentCellCyclePhase();

    bool ReadyToDivide();

 
    double GetBasePDuration();

    double GetPDuration();

    /**
     * Set mBasePDuration.
     *
     * This is the mean value for the normal distribution
     */
    void SetBasePDuration(double basePDuration);

    void SetPDuration();

    /**
     * Set mWDuration.
     */
    void SetWDuration(double wDuration);

    double GetWDuration();


    bool IsAgeLessThan(double comparison);

    bool IsAgeGreaterThan(double comparison);

    /**
     * @return the typical cell cycle duration for a transit cell, in hours.
     * This method is overridden in some subclasses.
     */
    double GetAverageTransitCellCycleTime();

    /**
     * @return the typical cell cycle duration for a stem cell, in hours.
     * This method is overridden in some subclasses.
     */
    double GetAverageStemCellCycleTime();

    /**
     * @return mMinimumGapDuration
     */
    double GetMinimumPDuration();

    /**
     * Set mMinimumGapDuration
     *
     * @param minimumGapDuration the new value of mMinimumGapDuration
     */
    void SetMinimumPDuration(double minimumGapDuration);

    /**
     * @param quiescentVolumeFraction
     */
    void SetQuiescentVolumeFraction(double quiescentVolumeFraction);

    /**
     * @return mQuiescentVolumeFraction
     */
    double GetQuiescentVolumeFraction() const;

    /**
     * @param equilibriumVolume
     */
    void SetEquilibriumVolume(double equilibriumVolume);

    /**
     * @return mEquilibriumVolume
     */
    double GetEquilibriumVolume() const;

    /**
     * @return mCurrentQuiescentDuration
     */
    double GetCurrentQuiescentDuration() const;

    /**
     * @return mCurrentQuiescentOnsetTime
     */
    double GetCurrentQuiescentOnsetTime() const;


    void SetWntThreshold(double wntThreshold);

    void SetPopUpDivision(bool popUpDivision);

    double GetWntThreshold();

    double GetWntLevel();
    /**
     * Outputs cell cycle model parameters to file.
     *
     *
     * @param rParamsFile the file stream to which the parameters are output
     */
    virtual void OutputCellCycleModelParameters(out_stream& rParamsFile);
};

#include "SerializationExportWrapper.hpp"
CHASTE_CLASS_EXPORT(SimplifiedPhaseBasedCellCycleModel)

#endif /*SimplifiedPhaseBasedCELLCYCLEMODEL_HPP_*/
