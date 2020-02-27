#include "BoundaryCellProperty.hpp"

BoundaryCellProperty::BoundaryCellProperty()
: AbstractCellProperty(),
  mColour(5)
{
}

BoundaryCellProperty::~BoundaryCellProperty()
{	
}

unsigned BoundaryCellProperty::GetColour() const
{
	return mColour;
}


#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(BoundaryCellProperty)
