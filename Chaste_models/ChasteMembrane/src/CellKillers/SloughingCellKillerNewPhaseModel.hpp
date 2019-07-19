#ifndef SLOUGHINGCELLKILLERNewPhaseModel_HPP_
#define SLOUGHINGCELLKILLERNewPhaseModel_HPP_
#include <cxxtest/TestSuite.h>
#include "CheckpointArchiveTypes.hpp"
#include "AbstractCellBasedTestSuite.hpp"

#include <boost/archive/text_oarchive.hpp>
#include <boost/archive/text_iarchive.hpp>

#include "AbstractCellKiller.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

/*
 * Cell killer that removes any epithelial cell that has detached from the non-epithelial
 * region and entered the lumen
 */

class SloughingCellKillerNewPhaseModel : public AbstractCellKiller<2>
{
private:

    friend class boost::serialization::access;
    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
        archive & boost::serialization::base_object<AbstractCellKiller<2> >(*this);
        archive & mCellKillCount;
        archive & mCryptTop;
    }

    double mCellKillCount = 0; // Tracks the number of cells killed by anoikis

public:

    /**
     * Default constructor.
     *
     * @param pCellPopulation pointer to a tissue
     * @param sloughOrifice whether to slough compressed cells at crypt orifice
     */
	SloughingCellKillerNewPhaseModel(AbstractCellPopulation<2>* pCellPopulation);

	// Destructor
	~SloughingCellKillerNewPhaseModel();

    double mCryptTop;

    /**
     *  Loops over and kills cells by anoikis or at the orifice if instructed.
     */
    void CheckAndLabelCellsForApoptosisOrDeath();

    void SetCryptTop(double cryptTop);

    unsigned GetCellKillCount();

    /**
     * Outputs cell killer parameters to file
     *
     * As this method is pure virtual, it must be overridden
     * in subclasses.
     *
     * @param rParamsFile the file stream to which the parameters are output
     */
    void OutputCellKillerParameters(out_stream& rParamsFile);

};

#include "SerializationExportWrapper.hpp"
CHASTE_CLASS_EXPORT(SloughingCellKillerNewPhaseModel)

namespace boost
{
    namespace serialization
    {
        template<class Archive>
        inline void save_construct_data(
            Archive & ar, const SloughingCellKillerNewPhaseModel * t, const unsigned int file_version)
        {
            const AbstractCellPopulation<2>* const p_cell_population = t->GetCellPopulation();
            ar << p_cell_population;
        }

        template<class Archive>
        inline void load_construct_data(
            Archive & ar, SloughingCellKillerNewPhaseModel * t, const unsigned int file_version)
        {
            AbstractCellPopulation<2>* p_cell_population;
            ar >> p_cell_population;

            // Invoke inplace constructor to initialise instance
            ::new(t)SloughingCellKillerNewPhaseModel(p_cell_population);
        }
    }
}

#endif /* SLOUGHINGCELLKILLERNewPhaseModel_HPP_ */
