#ifndef MonolayerNODEBASEDCELLPOPULATION_HPP_
#define MonolayerNODEBASEDCELLPOPULATION_HPP_

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>


#include "ObjectCommunicator.hpp"
#include "NodeBasedCellPopulation.hpp"
#include "MonolayerNodeBasedCellPopulation.hpp"
#include "NodesOnlyMesh.hpp"
#include "AnoikisCellTagged.hpp"

/**
 * A MonolayerNodeBasedCellPopulation is a CellPopulation consisting of only nodes in space with associated cells.
 * There are no elements and no mesh.
 * It is prefixed "Monolayer" because it applies to crypt models that allow cells to pop out of the membrane plane
 * The only difference this has with NodeBasedCellPopulation is that it specifies the Damping constant acording
 * to the cell's popped-up status
 */
template<unsigned DIM>
class MonolayerNodeBasedCellPopulation : public NodeBasedCellPopulation<DIM>
{

private:

	double mDampingConstantPoppedUp;

    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
        archive & boost::serialization::base_object<NodeBasedCellPopulation<DIM> >(*this);
        archive & mDampingConstantPoppedUp;

    }

public:

	/**
     * Default constructor.
     *
     * Note that the cell population will take responsibility for freeing the memory used by the nodes.
     *
     * @param rMesh a mutable nodes-only mesh
     * @param rCells a vector of cells
     * @param locationIndices an optional vector of location indices that correspond to real cells
     * @param deleteMesh whether to delete nodes-only mesh in destructor
     * @param validate whether to call Validate() in the constructor or not
     */
    MonolayerNodeBasedCellPopulation(NodesOnlyMesh<DIM>& rMesh,
                            std::vector<CellPtr>& rCells,
                            const std::vector<unsigned> locationIndices=std::vector<unsigned>(),
                            bool deleteMesh=false,
                            bool validate=true);

    /**
     * Constructor for use by the de-serializer.
     *
     * @param rMesh a mutable nodes-only mesh
     */
    MonolayerNodeBasedCellPopulation(NodesOnlyMesh<DIM>& rMesh);

    /**
     * Destructor.
     *
     * Frees all our node memory.
     */
    virtual ~MonolayerNodeBasedCellPopulation();


	// Overwrites the method from AbstractCentreBasedCellPopulation to enable different
	// drag coefficients for whatever reason seen fit
	// Here I will give popped up cells a different drag coefficient due to not being 
	// attached to the basement membrane/basal lamina

	virtual double GetDampingConstant(unsigned nodeIndex);

	double GetDampingConstantPoppedUp();
	void SetDampingConstantPoppedUp(double dampingConstantPoppedUp);
};

#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(MonolayerNodeBasedCellPopulation)

#endif /*MonolayerNODEBASEDCELLPOPULATION_HPP_*/