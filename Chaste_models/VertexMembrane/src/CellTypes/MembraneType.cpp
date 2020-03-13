/*
 * A membrane cell type
 */

#include "MembraneType.hpp"

MembraneType::MembraneType()
    : AbstractCellProliferativeType(3)
{}

#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(MembraneType)
