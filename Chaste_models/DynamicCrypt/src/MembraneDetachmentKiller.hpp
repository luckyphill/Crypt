#ifndef MembraneDetachmentKILLER_HPP_
#define MembraneDetachmentKILLER_HPP_
#include <cxxtest/TestSuite.h>
#include "CheckpointArchiveTypes.hpp"
#include "AbstractCellBasedTestSuite.hpp"

#include <boost/archive/text_oarchive.hpp>
#include <boost/archive/text_iarchive.hpp>
#include <boost/serialization/base_object.hpp>

#include "AbstractCellKiller.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

#include "SmartPointers.hpp"
/*
 * Cell killer that removes any epithelial cell that has detached from the non-epithelial
 * region and entered the lumen
 */

class MembraneDetachmentKiller : public AbstractCellKiller<2>
{
private:


	//Cut off radius for NodeBasedCellPopulations
	double mCutOffRadius;

	bool mSlowDeath;


	friend class boost::serialization::access;
	template<class Archive>
	void serialize(Archive & archive, const unsigned int version)
	{
		archive & boost::serialization::base_object<AbstractCellKiller<2> >(*this);
		archive & mCutOffRadius;
	}
	

public:

	/**
	 * Default constructor.
	 *
	 * @param pCellPopulation pointer to a tissue
	 * @param sloughOrifice whether to slough compressed cells at crypt orifice
	 */
	MembraneDetachmentKiller(AbstractCellPopulation<2>* pCellPopulation);

	// Destructor
	~MembraneDetachmentKiller();

	/*
	 * @return mCutOffRadius
	 */
	double GetCutOffRadius();

	/*
	 * Method to defin mCutOffRadius by
	 * cutOffRadius
	 */
	void SetCutOffRadius(double cutOffRadius);

	std::set<unsigned> GetNeighbouringNodeIndices(unsigned nodeIndex);

	bool HasCellPoppedUp(unsigned nodeIndex);

	/**
	 *  Loops over and kills cells by anoikis or at the orifice if instructed.
	 */
	void CheckAndLabelCellsForApoptosisOrDeath();


	/**
	 * Outputs cell killer parameters to file
	 *
	 * As this method is pure virtual, it must be overridden
	 * in subclasses.
	 *
	 * @param rParamsFile the file stream to which the parameters are output
	 */
	void OutputCellKillerParameters(out_stream& rParamsFile);
	void SetSlowDeath(bool slowDeath);

};

#include "SerializationExportWrapper.hpp"
CHASTE_CLASS_EXPORT(MembraneDetachmentKiller)

namespace boost
{
	namespace serialization
	{
		template<class Archive>
		inline void save_construct_data(
			Archive & ar, const MembraneDetachmentKiller * t, const unsigned int file_version)
		{
			const AbstractCellPopulation<2>* const p_cell_population = t->GetCellPopulation();
			ar << p_cell_population;

		}

		template<class Archive>
		inline void load_construct_data(
			Archive & ar, MembraneDetachmentKiller * t, const unsigned int file_version)
		{
			AbstractCellPopulation<2>* p_cell_population;
			ar >> p_cell_population;

			// Invoke inplace constructor to initialise instance
			::new(t)MembraneDetachmentKiller(p_cell_population);
		}
	}
}

#endif /* MembraneDetachmentKILLER_HPP_ */
