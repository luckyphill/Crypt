/*
 * A membrane cell type
 */

#include "StemType.hpp"

StemType::StemType()
    : AbstractCellProliferativeType(5)
{}

#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(StemType)
