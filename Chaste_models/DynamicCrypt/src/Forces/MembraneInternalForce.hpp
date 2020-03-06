#ifndef MEMBRANEInternalFORCE_HPP
#define MEMBRANEInternalFORCE_HPP

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>

#include "AbstractForce.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "DifferentiatedCellProliferativeType.hpp"


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

class MembraneInternalForce : public AbstractForce<2>
{
	friend class TestCrossSectionModelInteractionForce;

private :

	/** Parameter that defines the stiffness of the basement membrane */
	double mMembraneStiffness;

	double mTargetCurvatureStem;

	double mMembraneRestoringRate;

	double mCutOffLength = 1.5;
	
	// Stiffness of reaction with any other cell
	double mExternalStiffness;

	double mSpringBackedStiffness;

	bool mUseSpringBacked = false;

	bool mIsPeriodic = false;

	std::vector<std::vector<CellPtr>> mMembraneSections;

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
		archive & mMembraneStiffness;
	}

public :

	/**
	 * Constructor.
	 */
	MembraneInternalForce();

	MembraneInternalForce(std::vector<std::vector<CellPtr>> membraneSections);

	MembraneInternalForce(std::vector<std::vector<CellPtr>> membraneSections, bool isPeriodic);

	/**
	 * Destructor.
	 */
	~MembraneInternalForce();

	/**
	 * Pure virtual, must implement
	 */
	void AddForceContribution(AbstractCellPopulation<2>& rCellPopulation); // 
	
	// Add the force interactions
	void AddTensionForceContribution(AbstractCellPopulation<2>& rCellPopulation);
	void AddExternalForceContribution(AbstractCellPopulation<2>& rCellPopulation);
	void AddCurvatureForceContribution(AbstractCellPopulation<2>& rCellPopulation);

	/**
	 * Pure virtual, must implement
	 */
	void OutputForceParameters(out_stream& rParamsFile);

	double GetAngleFromTriplet(AbstractCellPopulation<2>& rCellPopulation,c_vector<double, 2> leftNode,	c_vector<double, 2> centreNode,	c_vector<double, 2> rightNode);
	double FindParametricCurvature(AbstractCellPopulation<2>& rCellPopulation,c_vector<double, 2> leftCell,c_vector<double, 2> centreCell,c_vector<double, 2> rightCell);
	double GetTargetAngle(AbstractCellPopulation<2>& rCellPopulation, CellPtr centre_cell,c_vector<double, 2> leftCell,c_vector<double, 2> centreCell,c_vector<double, 2> rightCell);
	double GetTargetCurvature(AbstractCellPopulation<2>& rCellPopulation, CellPtr centreCell);
	

	/* Set method for Basement Membrane Parameter
	 */
	void SetMembraneStiffness(double MembraneStiffness);
	void SetExternalStiffness(double ExternalStiffness);

	void SetMembraneRestoringRate(double membraneRestoringRate);
	void SetTargetCurvatureStem(double targetCurvatureStem);
	void SetCutOffLength(double cutOffLength);


	void SetIsPeriodic(bool isPeriodic);

	void UseSpringBackedMembrane(bool usedSpringBacked);

	void SetMembraneSections(std::vector<std::vector<CellPtr>> membraneSections);

};

#include "SerializationExportWrapper.hpp"
CHASTE_CLASS_EXPORT(MembraneInternalForce)

#endif /*MEMBRANEInternalFORCE_HPP*/
