/*
 * A membrane cell type
 */

#include "MembraneCellProliferativeType.hpp"

MembraneCellProliferativeType::MembraneCellProliferativeType()
    : AbstractCellProliferativeType(3)
{}

#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(MembraneCellProliferativeType)
