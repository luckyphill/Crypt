#ifndef BasicContactNeighbourSpringForce_HPP_
#define BasicContactNeighbourSpringForce_HPP_

#include "AbstractForce.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>


template<unsigned  ELEMENT_DIM, unsigned SPACE_DIM=ELEMENT_DIM>
class BasicContactNeighbourSpringForce : public AbstractForce<ELEMENT_DIM, SPACE_DIM>
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
        archive & mSpringStiffness; // Epithelial covers stem and transit
        archive & mMeinekeDivisionRestingSpringLength;
        archive & mMeinekeSpringGrowthDuration;
    }

protected:


    double mSpringStiffness;

    double mRestLength;

    double mCutOffLength;

    
    // Spring growth parameters for newly divided cells
    double mMeinekeSpringStiffness;

    double mMeinekeDivisionRestingSpringLength;

    double mMeinekeSpringGrowthDuration;

    
    bool m1DColumnOfCells = false; // Determines if we're using 1D or not. Could be much better implemented using the SPACE_DIM variable

    bool mDebugMode = false;

public:

    /**
     * Constructor.
     */
    BasicContactNeighbourSpringForce();

    /**
     * Destructor.
     */
    virtual ~BasicContactNeighbourSpringForce();

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


    void SetSpringStiffness(double SpringStiffness);

    void SetRestLength(double RestLength);

    void SetCutOffLength(double CutOffLength);

    
    // Spring growth for newly divided cells
    void SetMeinekeSpringStiffness(double springStiffness);

    void SetMeinekeDivisionRestingSpringLength(double divisionRestingSpringLength);

    void SetMeinekeSpringGrowthDuration(double springGrowthDuration);

    void SetDebugMode(bool debugStatus);

    void Set1D(bool dimStatus);
    
    virtual void OutputForceParameters(out_stream& rParamsFile);
};


#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(BasicContactNeighbourSpringForce)

#endif /*BasicContactNeighbourSpringForce_HPP_*/

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