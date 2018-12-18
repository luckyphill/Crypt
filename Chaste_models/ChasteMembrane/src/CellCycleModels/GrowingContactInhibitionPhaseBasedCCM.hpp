/*
 * A first attempt at a cell cycle model that will grow then divide
 * Rather than divide and grow
 * It also incorporates contact inhibition
 * Written by Phillip Brown, big chunks pinched from ContactInhibitionCellCycleModel
*/


#ifndef GROWINGCONTACTINHIBITIONPHASEBASEDCCM_HPP_
#define GROWINGCONTACTINHIBITIONPHASEBASEDCCM_HPP_

#include "RandomNumberGenerator.hpp"
#include "AbstractSimplePhaseBasedCellCycleModel.hpp"

#include "CellCyclePhases.hpp"
#include "WntConcentration.hpp"


class GrowingContactInhibitionPhaseBasedCCM : public AbstractSimplePhaseBasedCellCycleModel
{
	

protected:

    /**
     * The fraction of the cells' equilibrium volume in G1 phase below which these cells are quiescent.
     */
    double mQuiescentVolumeFraction;

    /**
     * The cell equilibrium volume while in G1 phase.
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


    double mGrowthOnsetTime;

    double mGrowthDuration;

    double mDivisionOnsetTime;

    double mDivisionDuration;

    // Stores the size of the growing cell as a multiple of its G1 preferred radius
    double mNewlyDividedRadius; // The radius after it has just divided
    
    double mPreferredRadius; // The updated radius of the cell given its process through the cycle
    double mReferencePreferredRadius; // The natural radius that it sticks at during G1
    
    double mInteractionRadius; // Distance from the cell centre, updated according to process through cycle
    double mInteractionWidth; // Distance from the cell surface where interactions can occur


    bool mUsingWnt = false; // Used to determine if a Wnt Concentration is being used

    double mG1LongDuration = 0.0;
    double mG1ShortDuration = 0.0;

    double mNicheLimitConcentration = 0.0;
    double mTransientLimitConcentration = 0.0;



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
    GrowingContactInhibitionPhaseBasedCCM(const GrowingContactInhibitionPhaseBasedCCM& rModel);

public:
	GrowingContactInhibitionPhaseBasedCCM();

    /** Empty virtual destructor so archiving works with static libraries. */
    //~GrowingContactInhibitionPhaseBasedCCM();

    
    AbstractCellCycleModel* CreateCellCycleModel();

    /**
     * Overridden UpdateCellCyclePhase() method.
     */
    void UpdateCellCyclePhase();

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


    // For tracking how big the cell should be
    double GetGrowthDuration() const;

    double GetGrowthOnsetTime() const;

    double GetDivisionDuration() const;

    // Returns the preferred radius for spring force calculations
    double GetPreferredRadius() const;

    double GetInteractionRadius() const;


    void SetNewlyDividedRadius(double newlyDividedRadius);

    void SetPreferredRadius(double preferedRadius);

    void SetInteractionRadius(double interactionRadius);

    void CalculatePreferredRadius();

    void SetG1LongDuration(double g1LongDuration);
    void SetG1ShortDuration(double g1ShortDuration);
    void SetNicheLimitConcentration(double nicheLimitConcentration);
    void SetTransientLimitConcentration(double transientLimitConcentration);

    void SetUsingWnt(bool usingWnt);

    CellCyclePhase GetCellPhase();

    void SetG1Duration();



    /**
     * Overridden OutputCellCycleModelParameters() method.
     *
     * @param rParamsFile the file stream to which the parameters are output
     */
    virtual void OutputCellCycleModelParameters(out_stream& rParamsFile);


};

#include "SerializationExportWrapper.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(GrowingContactInhibitionPhaseBasedCCM)

#endif /*GROWINGCONTACTINHIBITIONPHASEBASEDCCM_HPP_*/