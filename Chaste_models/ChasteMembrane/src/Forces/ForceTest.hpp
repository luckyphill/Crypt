#ifndef FORCETEST_HPP_
#define FORCETEST_HPP_

#include "AbstractTwoBodyInteractionForce.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>

template<unsigned  ELEMENT_DIM, unsigned SPACE_DIM=ELEMENT_DIM>
class ForceTest : public AbstractTwoBodyInteractionForce<ELEMENT_DIM, SPACE_DIM>
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
		archive & boost::serialization::base_object<AbstractTwoBodyInteractionForce<ELEMENT_DIM, SPACE_DIM> >(*this);
		archive & mEpithelialSpringStiffness; // Epithelial covers stem and transit
	}

protected:


	double mEpithelialSpringStiffness; // Epithelial covers stem and transit


	double mEpithelialRestLength; // Epithelial covers stem and transit


	double mEpithelialCutOffLength; // Epithelial covers stem and transit

public:

	/**
	 * Constructor.
	 */
	ForceTest();

	/**
	 * Destructor.
	 */
	virtual ~ForceTest();

	c_vector<double, SPACE_DIM> CalculateForceBetweenNodes(unsigned nodeAGlobalIndex,
													 unsigned nodeBGlobalIndex,
													 AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation);

	void SetEpithelialSpringStiffness(double epithelialSpringStiffness); // Epithelial covers stem and transit

	void SetEpithelialRestLength(double epithelialRestLength); // Epithelial covers stem and transit

	void SetEpithelialCutOffLength(double epithelialCutOffLength);
	
	virtual void OutputForceParameters(out_stream& rParamsFile);
};

#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_ALL_DIMS(ForceTest)

#endif /*ForceTest_HPP_*/
