#ifndef LINEARSPRINGFORCEPHASEBased_HPP_
#define LINEARSPRINGFORCEPHASEBased_HPP_

#include "AbstractForce.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>

template<unsigned  ELEMENT_DIM, unsigned SPACE_DIM=ELEMENT_DIM>
class LinearSpringForcePhaseBased : public AbstractForce<ELEMENT_DIM, SPACE_DIM>
{
	friend class TestForces;

private:

	/** Needed for serialization. */
	friend class boost::serialization::access;
	/**
	 * Archive the object and its member variables.
	 *
	 * @param archive the archive
	 * @param version the current version of this class
	 */
	template<class Archive>
	void serialize(Archive & archive, const unsigned int version)
	{
		archive & boost::serialization::base_object<AbstractForce<ELEMENT_DIM, SPACE_DIM> >(*this);
		archive & mEpithelialSpringStiffness; // Epithelial covers stem and transit
		archive & mMembraneSpringStiffness;
		archive & mStromalSpringStiffness; // Stromal is the differentiated "filler" cells
		archive & mEpithelialMembraneSpringStiffness;
		archive & mMembraneStromalSpringStiffness;
		archive & mStromalEpithelialSpringStiffness;
		archive & mMeinekeDivisionRestingSpringLength;
		archive & mMeinekeSpringGrowthDuration;
	}

protected:


	double mEpithelialSpringStiffness; // Epithelial covers stem and transit
	double mMembraneSpringStiffness;
	double mStromalSpringStiffness; // Stromal is the differentiated "filler" cells
	double mEpithelialMembraneSpringStiffness;
	double mMembraneStromalSpringStiffness;
	double mStromalEpithelialSpringStiffness;

	double mEpithelialPreferredRadius; // Epithelial covers stem and transit
	double mMembranePreferredRadius;
	double mStromalPreferredRadius; // Stromal is the differentiated "filler" cells

	double mEpithelialInteractionRadius; // Epithelial covers stem and transit
	double mMembraneInteractionRadius;
	double mStromalInteractionRadius; // Stromal is the differentiated "filler" cells


	/**
	 * Initial resting spring length after cell division.
	 * Has units of cell size at equilibrium rest length
	 *
	 * The value of this parameter should be larger than mDivisionSeparation,
	 * because of pressure from neighbouring springs.
	 */
	double mMeinekeDivisionRestingSpringLength;

	/**
	 * The time it takes for the springs rest length to increase from
	 * mMeinekeDivisionRestingSpringLength to its natural length.
	 *
	 * The value of this parameter is usually the same as the M Phase of the cell cycle and defaults to 1.
	 */
	double mMeinekeSpringGrowthDuration;

	bool mDebugMode = false;

public:

	/**
	 * Constructor.
	 */
	LinearSpringForcePhaseBased();

	/**
	 * Destructor.
	 */
	virtual ~LinearSpringForcePhaseBased();

	/**
	 * Overridden CalculateForceBetweenNodes() method.
	 *
	 * Calculates the force between two nodes.
	 *
	 * Note that this assumes they are connected and is called by AddForceContribution()
	 *
	 * @param nodeAGlobalIndex index of one neighbouring node
	 * @param nodeBGlobalIndex index of the other neighbouring node
	 * @param rCellPopulation the cell population
	 * @return The force exerted on Node A by Node B.
	 */
	c_vector<double, SPACE_DIM> CalculateForceBetweenNodes(unsigned nodeAGlobalIndex,
													 unsigned nodeBGlobalIndex,
													 AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation);

	// Work out the contact neighbours/nodes
	std::set<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* >> GetContactNeighbours(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation);
	
	void AddForceContribution(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation);


	void SetEpithelialSpringStiffness(double epithelialSpringStiffness); // Epithelial covers stem and transit
	void SetMembraneSpringStiffness(double membraneSpringStiffness);
	void SetStromalSpringStiffness(double stromalSpringStiffness); // Stromal is the differentiated "filler" cells
	void SetEpithelialMembraneSpringStiffness(double epithelialMembraneSpringStiffness);
	void SetMembraneStromalSpringStiffness(double membraneStromalSpringStiffness);
	void SetStromalEpithelialSpringStiffness(double stromalEpithelialSpringStiffness);

	void SetEpithelialPreferredRadius(double epithelialPreferredRadius); // Epithelial covers stem and transit
	void SetMembranePreferredRadius(double membranePreferredRadius);
	void SetStromalPreferredRadius(double stromalPreferredRadius); // Stromal is the differentiated "filler" cells

	void SetEpithelialInteractionRadius(double epithelialInteractionRadius); // Epithelial covers stem and transit
	void SetMembraneInteractionRadius(double membraneInteractionRadius);
	void SetStromalInteractionRadius(double stromalInteractionRadius); // Stromal is the differentiated "filler" cells

	/**
	 * Set mMeinekeDivisionRestingSpringLength.
	 *
	 * @param divisionRestingSpringLength the new value of mMeinekeDivisionRestingSpringLength
	 */
	void SetMeinekeDivisionRestingSpringLength(double divisionRestingSpringLength);

	/**
	 * Set mMeinekeSpringGrowthDuration.
	 *
	 * @param springGrowthDuration the new value of mMeinekeSpringGrowthDuration
	 */
	void SetMeinekeSpringGrowthDuration(double springGrowthDuration);

	/**
	 * Overridden OutputForceParameters() method.
	 *
	 * @param rParamsFile the file stream to which the parameters are output
	 */

	void SetDebugMode(bool debugStatus);
	
	virtual void OutputForceParameters(out_stream& rParamsFile);
};


#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_ALL_DIMS(LinearSpringForcePhaseBased)

#endif /*LINEARSPRINGFORCEPHASEBased_HPP_*/

#ifndef ND_SORT_FUNCTION
#define ND_SORT_FUNCTION
// Need to declare this sort function outide the class, otherwise it won't work
template<unsigned  ELEMENT_DIM, unsigned SPACE_DIM=ELEMENT_DIM>
bool nd_sort(std::tuple< Node<SPACE_DIM>*, c_vector<double, SPACE_DIM>, double > i,
				 std::tuple< Node<SPACE_DIM>*, c_vector<double, SPACE_DIM>, double > j)
{ 
	return (std::get<2>(i)<std::get<2>(j)); 
};
#endif
