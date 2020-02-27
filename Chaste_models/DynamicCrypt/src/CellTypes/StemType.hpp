
/*
 * A membrane cell type CREATED BY: Phillip Brown
 */

#ifndef StemTYPE_HPP_
#define StemTYPE_HPP_

#include "AbstractCellProliferativeType.hpp"
#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>

/**
 * Subclass of AbstractCellProliferativeType defining a differentiated cell.
 */
class StemType : public AbstractCellProliferativeType
{
private:
    /** Needed for serialization. */
    friend class boost::serialization::access;
    /**
     * Archive the cell proliferative type.
     *
     * @param archive the archive
     * @param version the current version of this class
     */
    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
        archive & boost::serialization::base_object<AbstractCellProliferativeType>(*this);
    }

public:
    /**
     * Constructor.
     */
    StemType();
};

#include "SerializationExportWrapper.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(StemType)

#endif /*StemTYPE_HPP_*/
