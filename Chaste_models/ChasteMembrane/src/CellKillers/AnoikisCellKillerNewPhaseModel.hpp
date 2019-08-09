#ifndef ANOIKISCELLKILLERNewPhaseModel_HPP_
#define ANOIKISCELLKILLERNewPhaseModel_HPP_
#include <cxxtest/TestSuite.h>
#include "CheckpointArchiveTypes.hpp"
#include "AbstractCellBasedTestSuite.hpp"

#include <boost/archive/text_oarchive.hpp>
#include <boost/archive/text_iarchive.hpp>
#include <boost/serialization/base_object.hpp>

#include "AbstractCellKiller.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

#include "AnoikisCellTagged.hpp"
#include "SmartPointers.hpp"
/*
 * Cell killer that removes any epithelial cell that has detached from the non-epithelial
 * region and entered the lumen
 */

class AnoikisCellKillerNewPhaseModel : public AbstractCellKiller<2>
{
private:


	std::vector<std::pair<CellPtr, double>> mCellsForDelayedAnoikis;

	bool mSlowDeath;

	double mPoppedUpLifeExpectancy;

	double mResistantPoppedUpLifeExpectancy;

	double mPopUpDistance = 1.5; // The distance above the membrane when a cell is considered to have popped up

	double mCellKillCount = 0; // Tracks the number of cells killed by anoikis


	friend class boost::serialization::access;
	template<class Archive>
	void serialize(Archive & archive, const unsigned int version)
	{
		archive & boost::serialization::base_object<AbstractCellKiller<2> >(*this);
		archive & mSlowDeath;
		archive & mPoppedUpLifeExpectancy;
		archive & mResistantPoppedUpLifeExpectancy;
		archive & mPopUpDistance; // The distance above the membrane when a cell is considered to have popped up
		archive & mCellKillCount;
	}

   

public:

	/**
	 * Default constructor.
	 *
	 * @param pCellPopulation pointer to a tissue
	 * @param sloughOrifice whether to slough compressed cells at crypt orifice
	 */
	AnoikisCellKillerNewPhaseModel(AbstractCellPopulation<2>* pCellPopulation);

	// Destructor
	~AnoikisCellKillerNewPhaseModel();

	void SetOutputDirectory(std::string outputDirectory);

	/*
	 * @return mCutOffRadius
	 */
	double GetCutOffRadius();

	void SetPopUpDistance(double popUpDistance);

	bool HasCellPoppedUp(unsigned nodeIndex);

	bool IsPoppedUpCellInVector(CellPtr check_cell);

	/**
	 *  Loops over and kills cells by anoikis or at the orifice if instructed.
	 */
	void CheckAndLabelCellsForApoptosisOrDeath();

	void PopulateAnoikisList();

	std::vector<CellPtr> GetCellsReadyToDie();

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
	void SetPoppedUpLifeExpectancy(double poppedUpLifeExpectancy);
	void SetResistantPoppedUpLifeExpectancy(double resistantPoppedUpLifeExpectancy);

	unsigned GetCellKillCount();
	void ResetCellKillCount();

};

#include "SerializationExportWrapper.hpp"
CHASTE_CLASS_EXPORT(AnoikisCellKillerNewPhaseModel)

namespace boost
{
	namespace serialization
	{
		template<class Archive>
		inline void save_construct_data(
			Archive & ar, const AnoikisCellKillerNewPhaseModel * t, const unsigned int file_version)
		{
			const AbstractCellPopulation<2>* const p_cell_population = t->GetCellPopulation();
			ar << p_cell_population;
		}

		template<class Archive>
		inline void load_construct_data(
			Archive & ar, AnoikisCellKillerNewPhaseModel * t, const unsigned int file_version)
		{
			AbstractCellPopulation<2>* p_cell_population;
			ar >> p_cell_population;

			// Invoke inplace constructor to initialise instance
			::new(t)AnoikisCellKillerNewPhaseModel(p_cell_population);
		}
	}
}


#endif /* ANOIKISCELLKILLERNewPhaseModel_HPP_ */
