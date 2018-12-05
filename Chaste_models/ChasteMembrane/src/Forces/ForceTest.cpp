#include "ForceTest.hpp"
#include "IsNan.hpp"
#include "AbstractCellProperty.hpp"

#include "PanethCellMutationState.hpp"
#include "MembraneCellProliferativeType.hpp"
#include "TransitCellProliferativeType.hpp"
#include "StemCellProliferativeType.hpp"

#include "Debug.hpp"

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
ForceTest<ELEMENT_DIM,SPACE_DIM>::ForceTest()
   : AbstractTwoBodyInteractionForce<ELEMENT_DIM,SPACE_DIM>(),
    mEpithelialSpringStiffness(15.0), // Epithelial covers stem and transit
    mEpithelialRestLength(1.0),
    mEpithelialCutOffLength(1.5) // Epithelial covers stem and transit
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
ForceTest<ELEMENT_DIM,SPACE_DIM>::~ForceTest()
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
c_vector<double, SPACE_DIM> ForceTest<ELEMENT_DIM,SPACE_DIM>::CalculateForceBetweenNodes(unsigned nodeAGlobalIndex,
                                                                                    unsigned nodeBGlobalIndex,
                                                                                    AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation)
{
    c_vector<double, 2> retval;
    retval[0] = 0;
    retval[1] = 0;
    return retval;

}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void ForceTest<ELEMENT_DIM,SPACE_DIM>::SetEpithelialSpringStiffness(double epithelialSpringStiffness)
{
    assert(epithelialSpringStiffness> 0.0);
    mEpithelialSpringStiffness = epithelialSpringStiffness;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void ForceTest<ELEMENT_DIM,SPACE_DIM>::SetEpithelialRestLength(double epithelialRestLength)
{
    assert(epithelialRestLength> 0.0);
    mEpithelialRestLength = epithelialRestLength;
}



template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void ForceTest<ELEMENT_DIM,SPACE_DIM>::SetEpithelialCutOffLength(double epithelialCutOffLength)
{
    assert(epithelialCutOffLength> 0.0);
    mEpithelialCutOffLength = epithelialCutOffLength;
}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void ForceTest<ELEMENT_DIM,SPACE_DIM>::OutputForceParameters(out_stream& rParamsFile)
{
    TRACE("OutputForceParameters");

    // Call method on direct parent class
}

/////////////////////////////////////////////////////////////////////////////
// Explicit instantiation
/////////////////////////////////////////////////////////////////////////////

template class ForceTest<1,1>;
template class ForceTest<1,2>;
template class ForceTest<2,2>;
template class ForceTest<1,3>;
template class ForceTest<2,3>;
template class ForceTest<3,3>;

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
EXPORT_TEMPLATE_CLASS_ALL_DIMS(ForceTest)