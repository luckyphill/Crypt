/*
THIS MUST ONLY BE USED WITH OUT MEMBRANE CELLS
CURRENTLY ASSUMES ALL CELLS CAN CONTACT THE MEMBRANE

Assumes a monolayer of cells arranged in a column
It applies a force to keep them on the imaginary membrane wall
This force calculator is to be used in place of membrane cells 
*/

#include "IsNan.hpp"
#include "AbstractCellProperty.hpp"

#include "MembraneCellProliferativeType.hpp"
#include "TransitCellProliferativeType.hpp"
#include "StemCellProliferativeType.hpp"

#include "Debug.hpp"

#include "NormalAdhesionForce.hpp"


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
NormalAdhesionForce<ELEMENT_DIM,SPACE_DIM>::NormalAdhesionForce()
   : AbstractForce<ELEMENT_DIM,SPACE_DIM>(),
    mMembraneEpithelialSpringStiffness(15.0),
    mMembranePreferredRadius(0.1),
    mEpithelialPreferredRadius(0.5)
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
NormalAdhesionForce<ELEMENT_DIM,SPACE_DIM>::~NormalAdhesionForce()
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NormalAdhesionForce<ELEMENT_DIM,SPACE_DIM>::AddForceContribution(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation)
{
   
    //AbstractCentreBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>* p_tissue = static_cast<AbstractCentreBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>*>(&rCellPopulation);
    MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>* p_tissue = static_cast<MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>*>(&rCellPopulation);

    std::list<CellPtr> cells =  p_tissue->rGetCells();

    // Loop through each epithelial node/ stromal node (in this case) and add the retaining force
    // At this stage it assumes that the etherial membrane is a flat line on the y axis
    for (std::list<CellPtr>::iterator cell_iter = cells.begin(); cell_iter != cells.end(); ++cell_iter)
    {
        Node<SPACE_DIM>* p_node =  p_tissue->GetNodeCorrespondingToCell(*cell_iter);
        c_vector<double, SPACE_DIM> node_location = p_node->rGetLocation();

        c_vector<double, SPACE_DIM> restraining_force;
        restraining_force[1] = 0;

        double rest_length = mMembranePreferredRadius + mEpithelialPreferredRadius;
        double spring_constant = mMembraneEpithelialSpringStiffness;

        double overlap = node_location[0] - rest_length;
        bool is_closer_than_rest_length = (overlap <= 0);

        if (is_closer_than_rest_length) //overlap is negative
        {
            // log(x+1) is undefined for x<=-1
            assert(overlap > -rest_length);
            restraining_force[0] = - spring_constant * rest_length * log(1.0 + overlap/rest_length);

        }
        else
        {
            //assert(overlap > -rest_length);
            double alpha = 1.8; // 3.0
            restraining_force[0] = - spring_constant * overlap * exp(-alpha * overlap/rest_length);

        }

        //restraining_force[0] = - spring_constant * overlap / 3; // Use 3 to so linear intercepts exp at it's peak 

        p_node->AddAppliedForceContribution(restraining_force);


    }


}



template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NormalAdhesionForce<ELEMENT_DIM,SPACE_DIM>::SetMembraneEpithelialSpringStiffness(double membraneEpithelialSpringStiffness)
{
    assert(membraneEpithelialSpringStiffness > 0.0);
    mMembraneEpithelialSpringStiffness = membraneEpithelialSpringStiffness;
}



template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NormalAdhesionForce<ELEMENT_DIM,SPACE_DIM>::SetMembranePreferredRadius(double membranePreferredRadius)
{
    assert(membranePreferredRadius > 0.0);
    mMembranePreferredRadius = membranePreferredRadius;
}
template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NormalAdhesionForce<ELEMENT_DIM,SPACE_DIM>::SetEpithelialPreferredRadius(double stromalPreferredRadius)
{
    assert(stromalPreferredRadius > 0.0);
    mEpithelialPreferredRadius = stromalPreferredRadius;
}




template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NormalAdhesionForce<ELEMENT_DIM,SPACE_DIM>::OutputForceParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<MembraneEpithelialSpringStiffness>" << mMembraneEpithelialSpringStiffness << "</MembraneEpithelialSpringStiffness>\n";

    *rParamsFile << "\t\t\t<MembranePreferredRadius>" << mMembranePreferredRadius << "</MembranePreferredRadius>\n";
    *rParamsFile << "\t\t\t<EpithelialPreferredRadius>" << mEpithelialPreferredRadius << "</EpithelialPreferredRadius>\n";

}

/////////////////////////////////////////////////////////////////////////////
// Explicit instantiation
/////////////////////////////////////////////////////////////////////////////

template class NormalAdhesionForce<1,1>;
template class NormalAdhesionForce<1,2>;
template class NormalAdhesionForce<2,2>;
template class NormalAdhesionForce<1,3>;
template class NormalAdhesionForce<2,3>;
template class NormalAdhesionForce<3,3>;

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(NormalAdhesionForce)