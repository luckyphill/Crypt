

#ifndef BOUNDARYCELLPROPERTY_HPP
#define BOUNDARYCELLPROPERTY_HPP

#include <cxxtest/TestSuite.h>
#include "CheckpointArchiveTypes.hpp"
#include <boost/serialization/base_object.hpp>

#include "AbstractCellProperty.hpp"

class BoundaryCellProperty : public AbstractCellProperty
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

    BoundaryCellProperty(unsigned colour=5)
        : AbstractCellProperty(),
          mColour(colour)
    {
    }

    ~BoundaryCellProperty()
    {}

    unsigned GetColour() const
    {
        return mColour;
    }
};

#include "SerializationExportWrapper.hpp"
CHASTE_CLASS_EXPORT(BoundaryCellProperty)

#endif /*BOUNDARYCELLPROPERTY_HPP*/