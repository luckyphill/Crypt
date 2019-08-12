/*

A division rule to keep the cells both on the membrane

*/

#ifndef StickToMembraneDIVISIONRULE_HPP_
#define StickToMembraneDIVISIONRULE_HPP_

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>
#include <boost/serialization/vector.hpp>
#include "AbstractCentreBasedDivisionRule.hpp"
#include "AbstractCentreBasedCellPopulation.hpp"
#include "Debug.hpp"

// Forward declaration prevents circular include chain
// template<unsigned ELEMENT_DIM, unsigned SPACE_DIM> class AbstractCentreBasedCellPopulation;
// template<unsigned ELEMENT_DIM, unsigned SPACE_DIM> class AbstractCentreBasedDivisionRule;

/**
 * A class to generate two daughter cell positions, located a distance
 * AbstractCentreBasedCellPopulation::mMeinekeDivisionSeparation apart,
 * along a random axis. The midpoint between the two daughter cell
 * positions corresponds to the parent cell's position.
 */
template<unsigned SPACE_DIM>
class StickToMembraneDivisionRule : public AbstractCentreBasedDivisionRule<SPACE_DIM>
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
		archive & boost::serialization::base_object<AbstractCentreBasedDivisionRule<SPACE_DIM> >(*this);
		archive & mMembraneAxis;
		archive & mWiggle;
		archive & mMaxAngle;
	}

	c_vector<double, SPACE_DIM> mMembraneAxis;
	bool mWiggle = false;
	double mMaxAngle = 0.01; // maxmium wiggle angle above or below membrane axis

public:

	/**
	 * Default constructor.
	 */
	StickToMembraneDivisionRule();

	// Constructor with membrane axis
	StickToMembraneDivisionRule(c_vector<double, SPACE_DIM> membraneAxis);

	/**
	 * Empty destructor.
	 */
	~StickToMembraneDivisionRule();

	/**
	 * Overridden CalculateCellDivisionVector() method.
	 *
	 * @param pParentCell  The cell to divide
	 * @param rCellPopulation  The centre-based cell population
	 *
	 * @return the two daughter cell positions.
	 */
	std::pair<c_vector<double, SPACE_DIM>, c_vector<double, SPACE_DIM> > CalculateCellDivisionVector(CellPtr pParentCell,
		AbstractCentreBasedCellPopulation<SPACE_DIM>& rCellPopulation);

	//For flat membrane, the membrane will have an axis that is constant so can be defined at compilation
	//Use this to define the direction of division
	//In more complicated simulations this will need to be calculated individually for each cell
	void SetMembraneAxis(c_vector<double, SPACE_DIM> membraneAxis);

	const c_vector<double, SPACE_DIM>& rGetDivisionVector() const;

	void SetWiggleDivision(bool wiggle);

	void SetMaxAngle(double maxangle);
};

#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(StickToMembraneDivisionRule)

namespace boost
{
	namespace serialization
	{
		/**
		 * Serialize information required to construct a StickToMembraneDivisionRule.
		 */
		template<class Archive, unsigned SPACE_DIM>
		inline void save_construct_data(Archive & ar, const StickToMembraneDivisionRule<SPACE_DIM>* t, const unsigned int file_version)
		{
			// Archive c_vector one component at a time
			c_vector<double, SPACE_DIM> vector = t->rGetDivisionVector();
			for (unsigned i=0; i<SPACE_DIM; i++)
			{
				ar << vector[i];
			}
		}

		/**
		 * De-serialize constructor parameters and initialize a StickToMembraneDivisionRule.
		 */
		template<class Archive, unsigned SPACE_DIM>
		inline void load_construct_data(Archive & ar, StickToMembraneDivisionRule<SPACE_DIM>* t, const unsigned int file_version)
		{
			// Archive c_vector one component at a time
			c_vector<double, SPACE_DIM> vector;
			for (unsigned i=0; i<SPACE_DIM; i++)
			{
				ar >> vector[i];
			}

			// Invoke inplace constructor to initialise instance
			::new(t)StickToMembraneDivisionRule<SPACE_DIM>(vector);
		}
	}
} // namespace ...

#endif // StickToMembraneDIVISIONRULE_HPP_
