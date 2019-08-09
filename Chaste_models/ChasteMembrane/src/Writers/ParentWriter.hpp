#ifndef ParentWriter_HPP_
#define ParentWriter_HPP_

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>
#include "AbstractCellWriter.hpp"

/**
 * A class written using the visitor pattern for writing the applied force on each cell
 * to file. This class is designed for use with a NodeBasedCellPopulation (or its
 * subclasses) only; if used with other cell populations, the writer will output
 * DOUBLE_UNSET for each component of cell's applied force.
 *
 * The output file is called cellappliedforce.dat by default. If VTK is switched on,
 * then the writer also specifies the VTK output for each cell, which is stored in
 * the VTK cell data "Cell applied force" by default.
 */
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
class ParentWriter : public AbstractCellWriter<ELEMENT_DIM, SPACE_DIM>
{
private:

	/** Needed for serialization. */
	friend class boost::serialization::access;

	/**
	 * Serialize the object and its member variables.
	 *
	 * @param archive the archive
	 * @param version the current version of this class
	 */
	template<class Archive>
	void serialize(Archive & archive, const unsigned int version)
	{
		archive & boost::serialization::base_object<AbstractCellWriter<ELEMENT_DIM, SPACE_DIM> >(*this);
	}

public:

	/**
	 * Default constructor.
	 */
	ParentWriter();

	/**
	 * Overridden GetVectorCellDataForVtkOutput() method.
	 *
	 * Get a c_vector associated with a cell. This method reduces duplication
	 * of code between the methods VisitCell() and AddVtkData().
	 *
	 * @param pCell a cell
	 * @param pCellPopulation a pointer to the cell population owning the cell.
	 *
	 * @return data associated with the cell
	 */
	double GetCellDataForVtkOutput(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation);

	/**
	 * Overridden VisitCell() method.
	 *
	 * Visit a cell and write its applied force.
	 *
	 * Outputs a line of space-separated values of the form:
	 * ...[location index] [cell id] [x-pos] [y-pos] [z-pos] [x-force] [y-force] [z-force] ...
	 * with [y-<>] and [z-<>] included for 2 and 3 dimensional simulations, respectively.
	 *
	 * This is appended to the output written by AbstractCellBasedWriter, which is a single
	 * value [present simulation time], followed by a tab.
	 *
	 * @param pCell a cell
	 * @param pCellPopulation a pointer to the cell population owning the cell
	 */
	virtual void VisitCell(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation);
};

#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_ALL_DIMS(ParentWriter)

#endif /* ParentWriter_HPP_ */