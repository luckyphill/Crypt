/*
 * A membrane cell type
 */

#include "PanethType.hpp"

PanethType::PanethType()
    : AbstractCellProliferativeType(6)
{}

#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(PanethType)
