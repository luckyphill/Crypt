#ifndef LINEARSPRINGFORCEMEMBRANECELLNodeBased_HPP_
#define LINEARSPRINGFORCEMEMBRANECELLNodeBased_HPP_

#include "AbstractForce.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>

/**
 * A force law initially employed by Meineke et al (2001) in their off-lattice
 * model of the intestinal crypt (doi:10.1046/j.0960-7722.2001.00216.x).
 *
 * Each pair of neighbouring nodes are assumed to be connected by a linear
 * spring. The force of node \f$i\f$ is given
 * by
 *
 * \f[
 * \mathbf{F}_{i}(t) = \sum_{j} \mu_{i,j} ( || \mathbf{r}_{i,j} || - s_{i,j}(t) ) \hat{\mathbf{r}}_{i,j}.
 * \f]
 *
 * Here \f$\mu_{i,j}\f$ is the spring constant for the spring between nodes
 * \f$i\f$ and \f$j\f$, \f$s_{i,j}(t)\f$ is its natural length at time \f$t\f$,
 * \f$\mathbf{r}_{i,j}\f$ is their relative displacement and a hat (\f$\hat{}\f$)
 * denotes a unit vector.
 *
 * Length is scaled by natural length.
 * Time is in hours.
 */
template<unsigned  ELEMENT_DIM, unsigned SPACE_DIM=ELEMENT_DIM>
class LinearSpringForceMembraneCellNodeBased : public AbstractForce<ELEMENT_DIM, SPACE_DIM>
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

	bool m1DColumnOfCells = false; // Determines if we're using 1D or not. Could be much better implemented using the SPACE_DIM variable


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
	LinearSpringForceMembraneCellNodeBased();

	/**
	 * Destructor.
	 */
	virtual ~LinearSpringForceMembraneCellNodeBased();

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

	void AddForceContribution(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation);

	std::set<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* >> FindContactNeighbourPairs(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation);

	std::set<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* >> Find1DContactPairs(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation);


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

	void Set1D(bool dimStatus);
	
	virtual void OutputForceParameters(out_stream& rParamsFile);
};


#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_ALL_DIMS(LinearSpringForceMembraneCellNodeBased)

#endif /*LINEARSPRINGFORCEMEMBRANECELLNodeBased_HPP_*/

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