/*
 * A membrane cell type
 */

#include "EpithelialType.hpp"

EpithelialType::EpithelialType()
    : AbstractCellProliferativeType(4)
{}

#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(EpithelialType)
