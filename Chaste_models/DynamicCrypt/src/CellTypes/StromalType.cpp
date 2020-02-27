/*
 * A membrane cell type
 */

#include "StromalType.hpp"

StromalType::StromalType()
    : AbstractCellProliferativeType(2)
{}

#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(StromalType)
