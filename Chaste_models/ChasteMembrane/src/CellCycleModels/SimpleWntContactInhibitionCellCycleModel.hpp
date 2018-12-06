#ifndef SIMPLEWNTCONTACTINHIBITIONCELLCYCLEMODEL_HPP_
#define SIMPLEWNTCONTACTINHIBITIONCELLCYCLEMODEL_HPP_

#include "ContactInhibitionCellCycleModel.hpp"

/**
 * Simple  wnt and stress-based cell-cycle model.
 *
 * A simple stress-dependent cell-cycle model that inherits from
 * AbstractSimpleCellCycleModel. The duration of G1 phase depends
 * on the local stress, interpreted here as deviation from target
 * volume (or area/length in 2D/1D).
 *
 * This model allows for quiescence imposed by transient periods
 * of high stress, followed by relaxation.
 *
 * Note that in this cell cycle model, quiescence is implemented
 * by extending the G1 phase. If a cell is compressed during G2
 * or S phases then it will still divide, and thus cells whose
 * volumes are smaller than the given threshold may still divide.
 */
class SimpleWntContactInhibitionCellCycleModel : public ContactInhibitionCellCycleModel
{
private:

    friend class boost::serialization::access;

    /**
     * Boost Serialization method for archiving/checkpointing
     * @param archive  The boost archive.
     * @param version  The current version of this class.
     */
    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
        archive & boost::serialization::base_object<ContactInhibitionCellCycleModel>(*this);
        archive & mWntThreshold;
    }

    /**
     * Non-dimensionalized Wnt threshold, above which cells proliferate if not quiescent.
     */
    double mWntThreshold;

    /**
     * @return the Wnt level experienced by the cell.
     */
    double GetWntLevel();

    /**
     * Stochastically set the G1 duration. The G1 duration is taken
     * from a normal distribution whose mean is the G1 duration given
     * in AbstractCellCycleModel for the cell type and whose standard deviation
     * is 1.
     *
     * Called on cell creation at the start of a simulation, and for both
     * parent and daughter cells at cell division.
     */
    void SetG1Duration();

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
    SimpleWntContactInhibitionCellCycleModel(const SimpleWntContactInhibitionCellCycleModel& rModel);

public:

    /**
     * Constructor.
     */
    SimpleWntContactInhibitionCellCycleModel();

    /**
     * Overridden UpdateCellCyclePhase() method.
     */
    void UpdateCellCyclePhase();

    /**
     * Overridden builder method to create new instances of
     * the cell-cycle model.
     *
     * @return new cell-cycle model
     *
     */
    AbstractCellCycleModel* CreateCellCycleModel();

    /**
     * @param wntThreshold
     */
    void SetWntThreshold(double wntThreshold);

    /**
     * @return mWntThreshold
     */
    double GetWntThreshold();

    /**
     * Outputs cell cycle model parameters to file.
     *
     * @param rParamsFile the file stream to which the parameters are output
     */
    virtual void OutputCellCycleModelParameters(out_stream& rParamsFile);
};

// Declare identifier for the serializer
#include "SerializationExportWrapper.hpp"
CHASTE_CLASS_EXPORT(SimpleWntContactInhibitionCellCycleModel)

#endif // SIMPLEWNTCONTACTINHIBITIONCELLCYCLEMODEL_HPP_
