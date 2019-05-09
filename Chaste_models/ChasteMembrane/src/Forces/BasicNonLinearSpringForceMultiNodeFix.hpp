/*

BasicNonLinearSpringForceMultiNodeFix

This spring force must only be used in pair with BasicNonLinearSpringForceNewPhaseModel
It looks thorugh all the node pairs. If it finds a cell paired with both nodes of a dividing cell
it removes the force applied to the furthest of the twin nodes. This prevents a dividing
cell from having fore applied twice

*/

#ifndef BasicNonLinearSpringForceMultiNodeFix_HPP_
#define BasicNonLinearSpringForceMultiNodeFix_HPP_

#include "AbstractForce.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>


template<unsigned  ELEMENT_DIM, unsigned SPACE_DIM=ELEMENT_DIM>
class BasicNonLinearSpringForceMultiNodeFix : public AbstractForce<ELEMENT_DIM, SPACE_DIM>
{
    friend class TestForces_CM;

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
        archive & mSpringStiffness; // Epithelial covers stem and transit
    }

protected:


    double mSpringStiffness;

    double mRestLength;

    double mCutOffLength;

    double mAttractionParameter;

    // Spring growth parameters for newly divided cells
    double mMeinekeSpringStiffness;

    double mMeinekeDivisionRestingSpringLength;

    double mMeinekeSpringGrowthDuration;

    double mModifierFraction = 1.0;

public:

    /**
     * Constructor.
     */
    BasicNonLinearSpringForceMultiNodeFix();

    /**
     * Destructor.
     */
    virtual ~BasicNonLinearSpringForceMultiNodeFix();

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


    std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > FindShortestInteraction(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation, Node<SPACE_DIM>* pnodeA, Node<SPACE_DIM>* pnodeB);

    std::vector<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* >> FindOneInteractionBetweenCellPairs(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation, std::vector<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* >> r_node_pairs);

    Node<SPACE_DIM>* FindTwinNode(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation, Node<SPACE_DIM>* pnodeA);

    void SetSpringStiffness(double SpringStiffness);

    void SetRestLength(double RestLength);

    void SetCutOffLength(double CutOffLength);

    void SetAttractionParameter(double attractionParameter);

    // Spring growth for newly divided cells
    void SetMeinekeSpringStiffness(double springStiffness);

    void SetMeinekeDivisionRestingSpringLength(double divisionRestingSpringLength);

    void SetMeinekeSpringGrowthDuration(double springGrowthDuration);

    void SetModifierFraction(double modifierFraction);
    
    virtual void OutputForceParameters(out_stream& rParamsFile);
};


#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(BasicNonLinearSpringForceMultiNodeFix)

#endif /*BasicNonLinearSpringForceMultiNodeFix_HPP_*/
