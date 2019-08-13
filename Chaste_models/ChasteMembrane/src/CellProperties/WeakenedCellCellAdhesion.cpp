#include "WeakenedCellCellAdhesion.hpp"

WeakenedCellCellAdhesion::WeakenedCellCellAdhesion()
: AbstractCellProperty(),
  mColour(5)
{
}

WeakenedCellCellAdhesion::~WeakenedCellCellAdhesion()
{	
}

unsigned WeakenedCellCellAdhesion::GetColour() const
{
	return mColour;
}


#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(WeakenedCellCellAdhesion)
