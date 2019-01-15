/*

A division rule to keep the cells both on the membrane

*/

#ifndef StickToMembraneDIVISIONRULE_HPP_
#define StickToMembraneDIVISIONRULE_HPP_

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>
#include "AbstractCentreBasedDivisionRule.hpp"
#include "AbstractCentreBasedCellPopulation.hpp"

// Forward declaration prevents circular include chain
// template<unsigned ELEMENT_DIM, unsigned SPACE_DIM> class AbstractCentreBasedCellPopulation;
// template<unsigned ELEMENT_DIM, unsigned SPACE_DIM> class AbstractCentreBasedDivisionRule;

/**
 * A class to generate two daughter cell positions, located a distance
 * AbstractCentreBasedCellPopulation::mMeinekeDivisionSeparation apart,
 * along a random axis. The midpoint between the two daughter cell
 * positions corresponds to the parent cell's position.
 */
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM=ELEMENT_DIM>
class StickToMembraneDivisionRule : public AbstractCentreBasedDivisionRule<ELEMENT_DIM, SPACE_DIM>
{
private:
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
        archive & boost::serialization::base_object<AbstractCentreBasedDivisionRule<2u> >(*this);
    }

    c_vector<double, 2> mMembraneAxis;
    bool mWiggle = false;
    double mMaxAngle = 0.01; // maxmium wiggle angle above or below membrane axis

public:

    /**
     * Default constructor.
     */
    StickToMembraneDivisionRule()
    {
    }

    /**
     * Empty destructor.
     */
    virtual ~StickToMembraneDivisionRule()
    {
    }

    /**
     * Overridden CalculateCellDivisionVector() method.
     *
     * @param pParentCell  The cell to divide
     * @param rCellPopulation  The centre-based cell population
     *
     * @return the two daughter cell positions.
     */
    virtual std::pair<c_vector<double, SPACE_DIM>, c_vector<double, SPACE_DIM> > CalculateCellDivisionVector(CellPtr pParentCell,
        AbstractCentreBasedCellPopulation<ELEMENT_DIM, SPACE_DIM>& rCellPopulation);

    //For flat membrane, the membrane will have an axis that is constant so can be defined at compilation
    //Use this to define the direction of division
    //In more complicated simulations this will need to be calculated individually for each cell
    void SetMembraneAxis(c_vector<double, SPACE_DIM> membraneAxis);

    void SetWiggleDivision(bool wiggle);

    void SetMaxAngle(double maxangle);
};

#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_ALL_DIMS(StickToMembraneDivisionRule)

#endif // StickToMembraneDIVISIONRULE_HPP_
