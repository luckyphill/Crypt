#ifndef NodePairWriter_HPP_
#define NodePairWriter_HPP_

#include "AbstractCellPopulationCountWriter.hpp"
#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>

/**
 * A class written using the visitor pattern for writing the number of cells in each proliferative phase to file.
 *
 * The output file is called cellcyclephases.dat by default.
 */
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
class NodePairWriter : public AbstractCellPopulationCountWriter<ELEMENT_DIM, SPACE_DIM>
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
		archive & boost::serialization::base_object<AbstractCellPopulationCountWriter<ELEMENT_DIM, SPACE_DIM> >(*this);
	}

public:

	/**
	 * Default constructor.
	 */
	NodePairWriter();

	/**
	 * Visit the population and write the number of cells in the population that have each proliferative phase.
	 *
	 * Outputs a line of tab-separated values of the form:
	 * [num G0 phase] [num G1 phase] [num S phase] [num G2 phase] [num M phase]
	 *
	 * where [num G0 phase] denotes the number of cells in the population that are in G0 phase,
	 * and so on. These counts are computed through the cell population method GetCellCyclePhaseCount().
	 *
	 * This line is appended to the output written by AbstractCellBasedWriter, which is a single
	 * value [present simulation time], followed by a tab.
	 *
	 * @param pCellPopulation the population to write.
	 */
	void VisitAnyPopulation(AbstractCellPopulation<SPACE_DIM, SPACE_DIM>* pCellPopulation);

	/**
	 * Visit the population and write the number of cells in the population that have each proliferative phase.
	 *
	 * Outputs a line of tab-separated values of the form:
	 * [num G0 phase] [num G1 phase] [num S phase] [num G2 phase] [num M phase]
	 *
	 * where [num G0 phase] denotes the number of cells in the population that are in G0 phase,
	 * and so on. These counts are computed through the cell population method GetCellCyclePhaseCount().
	 *
	 * This line is appended to the output written by AbstractCellBasedWriter, which is a single
	 * value [present simulation time], followed by a tab.
	 *
	 * @param pCellPopulation a pointer to the MeshBasedCellPopulation to visit.
	 */
	virtual void Visit(MeshBasedCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation);

	/**
	 * Visit the population and write the number of cells in the population that have each proliferative phase.
	 *
	 * Outputs a line of tab-separated values of the form:
	 * [num G0 phase] [num G1 phase] [num S phase] [num G2 phase] [num M phase]
	 *
	 * where [num G0 phase] denotes the number of cells in the population that are in G0 phase,
	 * and so on. These counts are computed through the cell population method GetCellCyclePhaseCount().
	 *
	 * This line is appended to the output written by AbstractCellBasedWriter, which is a single
	 * value [present simulation time], followed by a tab.
	 *
	 * @param pCellPopulation a pointer to the CaBasedCellPopulation to visit.
	 */
	virtual void Visit(CaBasedCellPopulation<SPACE_DIM>* pCellPopulation);

	/**
	 * Visit the population and write the number of cells in the population that have each proliferative phase.
	 *
	 * Outputs a line of tab-separated values of the form:
	 * [num G0 phase] [num G1 phase] [num S phase] [num G2 phase] [num M phase]
	 *
	 * where [num G0 phase] denotes the number of cells in the population that are in G0 phase,
	 * and so on. These counts are computed through the cell population method GetCellCyclePhaseCount().
	 *
	 * This line is appended to the output written by AbstractCellBasedWriter, which is a single
	 * value [present simulation time], followed by a tab.
	 *
	 * @param pCellPopulation a pointer to the NodeBasedCellPopulation to visit.
	 */
	virtual void Visit(NodeBasedCellPopulation<SPACE_DIM>* pCellPopulation);

	/**
	 * Visit the population and write the number of cells in the population that have each proliferative phase.
	 *
	 * Outputs a line of tab-separated values of the form:
	 * [num G0 phase] [num G1 phase] [num S phase] [num G2 phase] [num M phase]
	 *
	 * where [num G0 phase] denotes the number of cells in the population that are in G0 phase,
	 * and so on. These counts are computed through the cell population method GetCellCyclePhaseCount().
	 *
	 * This line is appended to the output written by AbstractCellBasedWriter, which is a single
	 * value [present simulation time], followed by a tab.
	 *
	 * @param pCellPopulation a pointer to the PottsBasedCellPopulation to visit.
	 */
	virtual void Visit(PottsBasedCellPopulation<SPACE_DIM>* pCellPopulation);

	/**
	 * Visit the population and write the number of cells in the population that have each proliferative phase.
	 *
	 * Outputs a line of tab-separated values of the form:
	 * [num G0 phase] [num G1 phase] [num S phase] [num G2 phase] [num M phase]
	 *
	 * where [num G0 phase] denotes the number of cells in the population that are in G0 phase,
	 * and so on. These counts are computed through the cell population method GetCellCyclePhaseCount().
	 *
	 * This line is appended to the output written by AbstractCellBasedWriter, which is a single
	 * value [present simulation time], followed by a tab.
	 *
	 * @param pCellPopulation a pointer to the VertexBasedCellPopulation to visit.
	 */
	virtual void Visit(VertexBasedCellPopulation<SPACE_DIM>* pCellPopulation);
};

#include "SerializationExportWrapper.hpp"
// Declare identifier for the serializer
EXPORT_TEMPLATE_CLASS_ALL_DIMS(NodePairWriter)

#endif /*NodePairWriter_HPP_*/
