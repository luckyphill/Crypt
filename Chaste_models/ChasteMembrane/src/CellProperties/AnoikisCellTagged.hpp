#ifndef ANOIKISCELLTAGGED_HPP_
#define ANOIKISCELLTAGGED_HPP_

#include "AbstractCellMutationState.hpp"

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>
#include "Debug.hpp"
/**
 * Specifies that a cell has been tagged for death by anoikis
 */
class AnoikisCellTagged : public AbstractCellProperty
{
private:

    unsigned mColour;

    friend class boost::serialization::access;
    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
        archive & boost::serialization::base_object<AbstractCellProperty>(*this);
        archive & mColour;
    }

public:

    AnoikisCellTagged(unsigned colour=5)
        : AbstractCellProperty(),
          mColour(colour)
    {
    }

    ~AnoikisCellTagged()
    {}

    unsigned GetColour() const
    {
        return mColour;
    }
};

#include "SerializationExportWrapper.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(AnoikisCellTagged)

#endif /* ANOIKISCELLTAGGED_HPP_ */




