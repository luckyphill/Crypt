#ifndef SIMPLESLOUGHINGCELLKILLER_HPP_
#define SIMPLESLOUGHINGCELLKILLER_HPP_
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

template<unsigned  ELEMENT_DIM, unsigned SPACE_DIM=ELEMENT_DIM>
class SimpleSloughingCellKiller : public AbstractCellKiller<SPACE_DIM>
{
private:

    friend class boost::serialization::access;
    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
        archive & boost::serialization::base_object<AbstractCellKiller<SPACE_DIM> >(*this);
        archive & mCellKillCount;
        archive & mCryptTop;
    }

    unsigned mCellKillCount = 0; // Tracks the number of cells killed by anoikis

public:

    /**
     * Default constructor.
     *
     * @param pCellPopulation pointer to a tissue
     * @param sloughOrifice whether to slough compressed cells at crypt orifice
     */
	SimpleSloughingCellKiller(AbstractCellPopulation<SPACE_DIM>* pCellPopulation);

	// Destructor
	~SimpleSloughingCellKiller();

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
EXPORT_TEMPLATE_CLASS_SAME_DIMS(SimpleSloughingCellKiller)

// namespace boost
// {
//     namespace serialization
//     {
//         template<class Archive, unsigned SPACE_DIM>
//         inline void save_construct_data(
//             Archive & ar, const SimpleSloughingCellKiller<SPACE_DIM> * t, const unsigned int file_version)
//         {
//             const AbstractCellPopulation<SPACE_DIM>* const p_cell_population = t->GetCellPopulation();
//             ar << p_cell_population;
//         }

//         template<class Archive>
//         inline void load_construct_data(
//             Archive & ar, SimpleSloughingCellKiller<SPACE_DIM> * t, const unsigned int file_version)
//         {
//             AbstractCellPopulation<SPACE_DIM>* p_cell_population;
//             ar >> p_cell_population;

//             // Invoke inplace constructor to initialise instance
//             ::new(t)SimpleSloughingCellKiller<SPACE_DIM>(p_cell_population);
//         }
//     }
// }

#endif /* SIMPLESLOUGHINGCELLKILLER_HPP_ */
