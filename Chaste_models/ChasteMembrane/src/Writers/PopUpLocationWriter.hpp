#ifndef PopUpLocationWriter_HPP_
#define PopUpLocationWriter_HPP_

#include "AbstractCellPopulationWriter.hpp"
#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>
#include "Debug.hpp"

/**
 * A class written using the visitor pattern for writing the number of cells in each proliferative phase to file.
 *
 * The output file is called cellcyclephases.dat by default.
 */
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
class PopUpLocationWriter : public AbstractCellPopulationWriter<ELEMENT_DIM, SPACE_DIM>
{
private:
	/** Needed for serialization. */
	friend class boost::serialization::access;

	template<class Archive>
	void serialize(Archive & archive, const unsigned int version)
	{
		archive & boost::serialization::base_object<AbstractCellPopulationWriter<ELEMENT_DIM, SPACE_DIM> >(*this);
	}

public:

	/**
	 * Default constructor.
	 */
	PopUpLocationWriter();

	void VisitAnyPopulation(AbstractCellPopulation<SPACE_DIM, SPACE_DIM>* pCellPopulation);


	// Need to exist because of the parent class
	virtual void Visit(MeshBasedCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation);

	virtual void Visit(CaBasedCellPopulation<SPACE_DIM>* pCellPopulation);

	virtual void Visit(NodeBasedCellPopulation<SPACE_DIM>* pCellPopulation);

	virtual void Visit(PottsBasedCellPopulation<SPACE_DIM>* pCellPopulation);

	virtual void Visit(VertexBasedCellPopulation<SPACE_DIM>* pCellPopulation);
};

#include "SerializationExportWrapper.hpp"
// Declare identifier for the serializer
EXPORT_TEMPLATE_CLASS_ALL_DIMS(PopUpLocationWriter)

#endif /*PopUpLocationWriter_HPP_*/
