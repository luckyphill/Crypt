// Provides a normal force to restrain the epithelial cells to the membrane
// Assume that the column of cells are arranged up the y axis
// TO make this work, no membrane cells should be introduced
// then the interaction between epithelial/stromal cells can be
// managed by other spring force calculators that account for neighbours

#ifndef NormalAdhesionForce_HPP_
#define NormalAdhesionForce_HPP_

#include "AbstractForce.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "DifferentiatedCellProliferativeType.hpp"
#include "WeakenedMembraneAdhesion.hpp"

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>


template<unsigned  ELEMENT_DIM, unsigned SPACE_DIM=ELEMENT_DIM>
class NormalAdhesionForce : public AbstractForce<ELEMENT_DIM, SPACE_DIM>
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
        archive & mMembraneEpithelialSpringStiffness;
    }

protected:

    double mMembraneEpithelialSpringStiffness;


    double mMembranePreferredRadius;
    double mEpithelialPreferredRadius; // Epithelial is the differentiated "filler" cells

    double mAdhesionForceLawParameter; // A parameter to set how quickly the force drops off with distance

    double mWeakeningFraction; // The fraction of mMembraneEpithelialSpringStiffness seen by a cell with the WeakenedMembraneAdhesion mutation


    bool mDebugMode = false;

public:

    /**
     * Constructor.
     */
    NormalAdhesionForce();

    /**
     * Destructor.
     */
    virtual ~NormalAdhesionForce();

    void AddForceContribution(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation);

    void SetMembraneEpithelialSpringStiffness(double membraneEpithelialSpringStiffness);

    void SetMembranePreferredRadius(double membranePreferredRadius);
    void SetEpithelialPreferredRadius(double stromalPreferredRadius); // Epithelial is the differentiated "filler" cells
    void SetAdhesionForceLawParameter(double adhesionForceLawParameter);
    void SetWeakeningFraction(double weakeningFraction);

   
    virtual void OutputForceParameters(out_stream& rParamsFile);
};


#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(NormalAdhesionForce)

#endif /*NormalAdhesionForce_HPP_*/