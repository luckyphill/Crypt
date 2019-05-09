#ifndef ModifiedProliferativeCompartment_HPP_
#define ModifiedProliferativeCompartment_HPP_

#include "AbstractCellMutationState.hpp"

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>

/**
 * Specifies that a cell has been tagged for death by anoikis
 */
class ModifiedProliferativeCompartment : public AbstractCellProperty
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

    ModifiedProliferativeCompartment(unsigned colour=5)
        : AbstractCellProperty(),
          mColour(colour)
    {
    }

    ~ModifiedProliferativeCompartment()
    {}

    unsigned GetColour() const
    {
        return mColour;
    }
};

#include "SerializationExportWrapper.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(ModifiedProliferativeCompartment)

#endif /* ModifiedProliferativeCompartment_HPP_ */




