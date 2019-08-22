// Provides a normal force to restrain the epithelial cells to the membrane
// Assume that the column of cells are arranged up the y axis
// TO make this work, no membrane cells should be introduced
// then the interaction between epithelial/stromal cells can be
// managed by other spring force calculators that account for neighbours

#ifndef ConstantForce_HPP_
#define ConstantForce_HPP_

#include "AbstractForce.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "DifferentiatedCellProliferativeType.hpp"
#include "WeakenedMembraneAdhesion.hpp"

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>


template<unsigned  ELEMENT_DIM, unsigned SPACE_DIM=ELEMENT_DIM>
class ConstantForce : public AbstractForce<ELEMENT_DIM, SPACE_DIM>
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
		archive & mForce;
	}

protected:

	double mForce;


	unsigned mAxis;


public:

	/**
	 * Constructor.
	 */
	ConstantForce();

	/**
	 * Destructor.
	 */
	virtual ~ConstantForce();

	void AddForceContribution(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation);

	void SetForce(double Force);

	void SetAxis(unsigned Axis);
   
	virtual void OutputForceParameters(out_stream& rParamsFile);
};


#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_ALL_DIMS(ConstantForce)

#endif /*ConstantForce_HPP_*/