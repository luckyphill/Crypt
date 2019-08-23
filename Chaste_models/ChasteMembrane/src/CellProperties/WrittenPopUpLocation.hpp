#ifndef WrittenPopUpLocation_HPP_
#define WrittenPopUpLocation_HPP_

#include "AbstractCellMutationState.hpp"
#include "AbstractCellProperty.hpp"

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>
#include "Debug.hpp"
/**
 * Specifies that a cell has been tagged for death by anoikis
 */
class WrittenPopUpLocation : public AbstractCellProperty
{
private:

	unsigned mColour;

	friend class boost::serialization::access;
	template<class Archive>
	void serialize(Archive & archive, const unsigned int version)
	{
		archive & boost::serialization::base_object<AbstractCellProperty>(*this);
		archive & mColour;
	}

public:

	WrittenPopUpLocation();

	~WrittenPopUpLocation();

	unsigned GetColour() const;
};

#include "SerializationExportWrapper.hpp"
// Declare identifier for the serializer
CHASTE_CLASS_EXPORT(WrittenPopUpLocation)

#endif /* WrittenPopUpLocation_HPP_ */




