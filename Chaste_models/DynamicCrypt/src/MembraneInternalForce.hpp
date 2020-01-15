#ifndef MEMBRANEInternalFORCE_HPP
#define MEMBRANEInternalFORCE_HPP

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>

#include "AbstractForce.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

#include "TransitCellProliferativeType.hpp"
#include "StemCellProliferativeType.hpp"
#include "MembraneCellProliferativeType.hpp"

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
		archive & mMembraneStiffness
	}

public :

	/**
	 * Constructor.
	 */
	MembraneInternalForce();

	/**
	 * Destructor.
	 */
	~MembraneInternalForce();

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
	void SetMembraneStiffness(double MembraneStiffness);

	void SetMembraneSections(std::vector<std::vector<CellPtr>> membraneSections);

};

#include "SerializationExportWrapper.hpp"
CHASTE_CLASS_EXPORT(MembraneInternalForce)

#endif /*MEMBRANEInternalFORCE_HPP*/
