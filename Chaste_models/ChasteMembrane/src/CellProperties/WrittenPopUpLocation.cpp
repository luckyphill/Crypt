#include "WrittenPopUpLocation.hpp"

WrittenPopUpLocation::WrittenPopUpLocation()
: AbstractCellProperty(),
  mColour(5)
{
}

WrittenPopUpLocation::~WrittenPopUpLocation()
{	
}

unsigned WrittenPopUpLocation::GetColour() const
{
	return mColour;
}


#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(WrittenPopUpLocation)
