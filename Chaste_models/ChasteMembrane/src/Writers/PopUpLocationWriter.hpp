#ifndef PopUpLocationWRITER_HPP_
#define PopUpLocationWRITER_HPP_

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
class PopUpLocationWriter : public AbstractCellWriter<ELEMENT_DIM, SPACE_DIM>
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
    PopUpLocationWriter();

    double GetCellDataForVtkOutput(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation);

    virtual void VisitCell(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation);
};

#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_ALL_DIMS(PopUpLocationWriter)

#endif /* PopUpLocationWRITER_HPP_ */