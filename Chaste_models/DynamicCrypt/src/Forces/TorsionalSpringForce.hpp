#ifndef TorsionalSpringForce_HPP
#define TorsionalSpringForce_HPP

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>

#include "AbstractForce.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

#include "TransitCellProliferativeType.hpp"
#include "StemCellProliferativeType.hpp"

#include <cmath>
#include <list>
#include <fstream>

/**
 * A force class that defines the force due to the basement membrane.
 */

/*
 * Created by: PHILLIP BROWN, 27/10/2017
 * Initial Structure borrows heavily from "EpithelialLayerBasementMembraneForce.hpp"
 * as found in the Chaste Paper Tutorials for the CryptFissionPlos2016 project
 */

class TorsionalSpringForce : public AbstractForce<2>
{
	friend class TestCrossSectionModelInteractionForce;

private :

	/** Parameter that defines the stiffness of the basement membrane */
	double mTorsionalStiffness;

	/** Target curvature for the layer of cells */
	double mTargetCurvature;

	// Needed for the rotation calucaltopn
	double mDt;

	double mDampingConstant;

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
		// If Archive is an output archive, then '&' resolves to '<<'
		// If Archive is an input archive, then '&' resolves to '>>'
		archive & boost::serialization::base_object<AbstractForce<2> >(*this);
		archive & mTorsionalStiffness;
		archive & mTargetCurvature;
		archive & mDt;
		archive & mDampingConstant;
	}

public :

	/**
	 * Constructor.
	 */
	TorsionalSpringForce();

	/**
	 * Destructor.
	 */
	~TorsionalSpringForce();

	double GetTargetAngle(AbstractCellPopulation<2>& rCellPopulation, CellPtr centre_cell,
																		c_vector<double, 2> leftCell,
																		c_vector<double, 2> centreCell,
																		c_vector<double, 2> rightCell);
	
	/**
	 * Pure virtual, must implement
	 */
	void AddForceContribution(AbstractCellPopulation<2>& rCellPopulation); // 

	/**
	 * Pure virtual, must implement
	 */
	void OutputForceParameters(out_stream& rParamsFile);

	/* Set method for Basement Membrane Parameter
	 */
	void SetTorsionalStiffness(double basementMembraneTorsionalStiffness);

	/* Value of Target Curvature in epithelial layer */
	void SetTargetCurvature(double targetCurvature);

	void SetDt(double dt);

	void SetDampingConstant(double dampingConstant);

	double GetAngleFromTriplet(AbstractCellPopulation<2>& rCellPopulation,
															c_vector<double, 2> leftNode,
															c_vector<double, 2> centreNode,
															c_vector<double, 2> rightNode);

	double FindParametricCurvature(AbstractCellPopulation<2>& rCellPopulation,
									c_vector<double, 2> leftMidpoint,
									c_vector<double, 2> centreMidpoint,
									c_vector<double, 2> rightMidpoint);
	
	// Returns each distinct membrane section
	std::vector<std::vector<unsigned>> GetMembraneSections(AbstractCellPopulation<2>& rCellPopulation);

};

#include "SerializationExportWrapper.hpp"
CHASTE_CLASS_EXPORT(TorsionalSpringForce)

#endif /*TorsionalSpringForce_HPP*/
