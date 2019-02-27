
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
        archive & mMinimumWDuration;
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
    double mMinimumPDuration;

    /**
     * Duration of M phase for all cell types.
     */
    double mWDuration;

    double mQuiescentVolumeFraction;

    double mEquilibriumVolume;

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

    /**
     * Destructor.
     */
    virtual ~SimplifiedPhaseBasedCellCycleModel();

    /**
     * See AbstractCellCycleModel::ResetForDivision()
     *
     * @return whether the cell is ready to divide (enter M phase).
     */
    virtual bool ReadyToDivide();

    /** See AbstractCellCycleModel::ResetForDivision() */
    virtual void ResetForDivision();

    /**
     * Set the phase the cell-cycle model is currently in. This method is called
     * from ReadyToDivide() just prior to deciding whether to divide the cell,
     * based on how far through the cell cycle it is, i.e. whether it has
     * completed M, G1, S and G2 phases.
     *
     * As this method is pure virtual, it must be overridden
     * in subclasses.
     */
    void UpdateCellCyclePhase();

    /**
     * @return the current cell cycle phase
     */
    SimplifiedCellCyclePhase GetCurrentCellCyclePhase() const;

    /**
     * @return the duration of the G1 phase of the cell cycle
     */
    double GetPDuration() const;

    /**
     * @return the duration of the M phase of the cell cycle mMDuration
     */
    double GetWDuration() const;

    /**
     * Set mSDuration.
     *
     * @param sDuration  the new value of mSDuration
     */
    void SetBasePDuration(double basePDuration);

    /**
     * Set mG2Duration.
     *
     * @param g2Duration  the new value of mG2Duration
     */
    void SetWDuration(double wDuration);

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
    double GetMinimumWDuration() const;

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
     * Outputs cell cycle model parameters to file.
     *
     * As this method is pure virtual, it must be overridden
     * in subclasses.
     *
     * @param rParamsFile the file stream to which the parameters are output
     */
    virtual void OutputCellCycleModelParameters(out_stream& rParamsFile);
};

CLASS_IS_ABSTRACT(SimplifiedPhaseBasedCellCycleModel)

#endif /*SimplifiedPhaseBasedCELLCYCLEMODEL_HPP_*/
