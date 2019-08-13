#include "WeakenedMembraneAdhesion.hpp"

WeakenedMembraneAdhesion::WeakenedMembraneAdhesion()
: AbstractCellProperty(),
  mColour(5)
{
}

WeakenedMembraneAdhesion::~WeakenedMembraneAdhesion()
{	
}

unsigned WeakenedMembraneAdhesion::GetColour() const
{
	return mColour;
}


#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(WeakenedMembraneAdhesion)
