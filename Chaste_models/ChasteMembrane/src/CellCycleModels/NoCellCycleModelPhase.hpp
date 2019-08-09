
#ifndef NOCELLCYCLEMODELPHASE_HPP_
#define NOCELLCYCLEMODELPHASE_HPP_

#include "NoCellCycleModel.hpp"
#include "SimplifiedCellCyclePhases.hpp"

#include <boost/serialization/base_object.hpp>

/**
 * A 'dummy' cell-cycle model class that can be used in simulations featuring no
 * cell proliferation.
 * This one gives a phase if asked
 */
class NoCellCycleModelPhase : public NoCellCycleModel
{
    friend class TestSimpleCellCycleModels;

private:

    /** Needed for serialization. */
    friend class boost::serialization::access;
    /**
     * Archive the cell-cycle model.
     *
     * @param archive the archive
     * @param version the current version of this class
     */
    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
        archive & boost::serialization::base_object<NoCellCycleModel>(*this);
    }

public:

    /**
     * Default constructor.
     */
    NoCellCycleModelPhase();

    SimplifiedCellCyclePhase GetCurrentCellCyclePhase();

    /**
     * Overridden OutputCellCycleModelParameters() method.
     *
     * @param rParamsFile the file stream to which the parameters are output
     */
    void OutputCellCycleModelParameters(out_stream& rParamsFile);
};

#include "SerializationExportWrapper.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(NoCellCycleModelPhase)

#endif /*NOCELLCYCLEMODELPHASE_HPP_*/
