#ifndef DividingRotationForce_HPP
#define DividingRotationForce_HPP

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>

#include "AbstractForce.hpp"
#include "MeshBasedCellPopulation.hpp"

#include <cmath>
#include <list>
#include <fstream>

// A force that keeps dividing cells in the correct plane

class DividingRotationForce : public AbstractForce<2>
{
    friend class TestCrossSectionModelInteractionForce;

private :

    /** Parameter that defines the stiffness of the basement membrane */
    double mTorsionalStiffness;

    // The plane that the membrane is in
    c_vector<double, 2> mMembraneAxis;

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

    }

public :

    /**
     * Constructor.
     */
	DividingRotationForce();

    /**
     * Destructor.
     */
    ~DividingRotationForce();

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
    void SetTorsionalStiffness(double torsionalStiffness);


    // Define the membrane axis
    void SetMembraneAxis(c_vector<double, 2> membraneAxis);

    std::vector<std::pair<Node<2>*, Node<2>*>> GetNodePairs(AbstractCellPopulation<2>& rCellPopulation);

    
};

#include "SerializationExportWrapper.hpp"
CHASTE_CLASS_EXPORT(DividingRotationForce)

#endif /*DividingRotationForce_HPP*/
