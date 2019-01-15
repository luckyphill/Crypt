#ifndef SimpleANOIKISCELLKILLER_HPP_
#define SimpleANOIKISCELLKILLER_HPP_
#include <cxxtest/TestSuite.h>
#include "CheckpointArchiveTypes.hpp"
#include "AbstractCellBasedTestSuite.hpp"

#include <boost/archive/text_oarchive.hpp>
#include <boost/archive/text_iarchive.hpp>

#include "AbstractCellKiller.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

#include "AnoikisCellTagged.hpp"
#include "SmartPointers.hpp"
/*
 * Cell killer that removes any epithelial cell that has detached from the non-epithelial
 * region and entered the lumen
 */

class SimpleAnoikisCellKiller : public AbstractCellKiller<2>
{
private:

	// Number of cells removed by Anoikis
	unsigned mCellsRemovedByAnoikis;

    std::vector<c_vector<double,3> > mLocationsOfAnoikisCells;

    std::vector<std::pair<CellPtr, double>> mCellsForDelayedAnoikis;

    bool mSlowDeath;

    double mPoppedUpLifeExpectancy;

    double mResistantPoppedUpLifeExpectancy;

    double mPopUpDistance = 1.5; // The distance above the membrane when a cell is considered to have popped up

    unsigned mCellKillCount = 0; // Tracks the number of cells killed by anoikis

    // The output file directory for the simulation data that corresponds to the number of cells
    // killed by anoikis
    out_stream mAnoikisOutputFile;

    std::string mOutputDirectory;

    friend class boost::serialization::access;
    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
        archive & boost::serialization::base_object<AbstractCellKiller<2> >(*this);
        archive & mCellsRemovedByAnoikis;
        archive & mOutputDirectory;
    }

    //Property for tagging cells
    //AnoikisCellTagged* mp_anoikis_tagged = new AnoikisCellTagged;
    // Decides if the cell is removed immediately after being marked for death, or undergoes a slower apoptotis death
    

public:

    /**
     * Default constructor.
     *
     * @param pCellPopulation pointer to a tissue
     * @param sloughOrifice whether to slough compressed cells at crypt orifice
     */
	SimpleAnoikisCellKiller(AbstractCellPopulation<2>* pCellPopulation);

	// Destructor
	~SimpleAnoikisCellKiller();

    void SetOutputDirectory(std::string outputDirectory);

    std::string GetOutputDirectory();

    /*
     * @return mCutOffRadius
     */
    double GetCutOffRadius();

    void SetPopUpDistance(double popUpDistance);

    bool HasCellPoppedUp(unsigned nodeIndex);

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

};

#include "SerializationExportWrapper.hpp"
CHASTE_CLASS_EXPORT(SimpleAnoikisCellKiller)

namespace boost
{
    namespace serialization
    {
        template<class Archive>
        inline void save_construct_data(
            Archive & ar, const SimpleAnoikisCellKiller * t, const unsigned int file_version)
        {
            const AbstractCellPopulation<2>* const p_cell_population = t->GetCellPopulation();
            ar << p_cell_population;
        }

        template<class Archive>
        inline void load_construct_data(
            Archive & ar, SimpleAnoikisCellKiller * t, const unsigned int file_version)
        {
            AbstractCellPopulation<2>* p_cell_population;
            ar >> p_cell_population;

            // Invoke inplace constructor to initialise instance
            ::new(t)SimpleAnoikisCellKiller(p_cell_population);
        }
    }
}

#endif /* SimpleANOIKISCELLKILLER_HPP_ */
