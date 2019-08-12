

#ifndef BOUNDARYCELLPROPERTY_HPP
#define BOUNDARYCELLPROPERTY_HPP

#include <cxxtest/TestSuite.h>
#include "CheckpointArchiveTypes.hpp"
#include <boost/serialization/base_object.hpp>

#include "AbstractCellProperty.hpp"
#include "Debug.hpp"

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

    BoundaryCellProperty();

    ~BoundaryCellProperty();

    unsigned GetColour() const;
};

#include "SerializationExportWrapper.hpp"
CHASTE_CLASS_EXPORT(BoundaryCellProperty)

#endif /*BOUNDARYCELLPROPERTY_HPP*/