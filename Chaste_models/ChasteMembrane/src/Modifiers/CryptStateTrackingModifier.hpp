
#ifndef CryptStateTrackingMODIFIER_HPP_
#define CryptStateTrackingMODIFIER_HPP_

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>

#include "AbstractCellBasedSimulationModifier.hpp"

/**
 * A modifier class which at each simulation time step calculates the volume of each cell
 * and stores it in in the CellData property as "volume". To be used in conjunction with
 * contact inhibition cell cycle models.
 */
template<unsigned DIM>
class CryptStateTrackingModifier : public AbstractCellBasedSimulationModifier<DIM,DIM>
{
    /** Needed for serialization. */
    friend class boost::serialization::access;
    /**
     * Boost Serialization method for archiving/checkpointing.
     * Archives the object and its member variables.
     *
     * @param archive  The boost archive.
     * @param version  The current version of this class.
     */
    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
        archive & boost::serialization::base_object<AbstractCellBasedSimulationModifier<DIM,DIM> >(*this);
    }

private:

    double mCurrentTotal = 0;

    double mRunningAverage = 0;

    unsigned mObservationCount = 0;

    unsigned mBirthCount = 0;

    unsigned mMaxBirthPosition = 0;

public:

    /**
     * Default constructor.
     */
    CryptStateTrackingModifier();

    /**
     * Destructor.
     */
    virtual ~CryptStateTrackingModifier();

    // Required for the Abstract class inheriting from
    // Probably for doing things before starting to solve
    virtual void SetupSolve(AbstractCellPopulation<DIM,DIM>& rCellPopulation, std::string outputDirectory);

    // After all movement is done I think
    virtual void UpdateAtEndOfTimeStep(AbstractCellPopulation<DIM,DIM>& rCellPopulation);

    // When everything is complete
    virtual void UpdateAtEndOfSolve(AbstractCellPopulation<DIM,DIM>& rCellPopulation);


    // Does the stuff    
    void UpdateRunningAverage(AbstractCellPopulation<DIM,DIM>& rCellPopulation);
    void UpdateBirthStats(AbstractCellPopulation<DIM,DIM>& rCellPopulation);
    
    // Makes the stuff accessable
    double GetAverageCount();
    unsigned GetBirthCount();
    unsigned GetMaxBirthPosition();

    /**
     * Overridden OutputSimulationModifierParameters() method.
     * Output any simulation modifier parameters to file.
     *
     * @param rParamsFile the file stream to which the parameters are output
     */
    void OutputSimulationModifierParameters(out_stream& rParamsFile);
};

#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(CryptStateTrackingModifier)

#endif /*CryptStateTrackingMODIFIER_HPP_*/
