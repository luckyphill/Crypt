/*
Applies a constant force to along an axis
To apply a force in the +ve Axis the force is +ve
To apply a force in the -ve Axis the force is -ve 
*/

#include "IsNan.hpp"
#include "AbstractCellProperty.hpp"

#include "TransitCellProliferativeType.hpp"
#include "StemCellProliferativeType.hpp"
#include "WeakenedMembraneAdhesion.hpp"

#include "Debug.hpp"
#include "Exception.hpp"

#include "ConstantForce.hpp"


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
ConstantForce<ELEMENT_DIM,SPACE_DIM>::ConstantForce()
   : AbstractForce<ELEMENT_DIM,SPACE_DIM>(),
	mForce(1),
	mAxis(2)
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
ConstantForce<ELEMENT_DIM,SPACE_DIM>::~ConstantForce()
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void ConstantForce<ELEMENT_DIM,SPACE_DIM>::AddForceContribution(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation)
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

		c_vector<double, SPACE_DIM> constantForce;
		for (unsigned i=0; i < SPACE_DIM; i++)
		{
			constantForce[i] = 0;
			if ( i == mAxis - 1 )
			{
				constantForce[i] = mForce;
			}
		}

		p_node->AddAppliedForceContribution(constantForce);


	}


}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void ConstantForce<ELEMENT_DIM,SPACE_DIM>::SetForce(double Force)
{
	mForce = Force;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void ConstantForce<ELEMENT_DIM,SPACE_DIM>::SetAxis(unsigned Axis)
{
	if (Axis > SPACE_DIM)
	{
		EXCEPTION("Axis must be no greater than the number of space dimensions");
	}
	mAxis = Axis;
}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void ConstantForce<ELEMENT_DIM,SPACE_DIM>::OutputForceParameters(out_stream& rParamsFile)
{
	*rParamsFile << "\t\t\t<Force>" << mForce << "</Force>\n";
	*rParamsFile << "\t\t\t<Axis>" << mAxis << "</Axis>\n";

}

/////////////////////////////////////////////////////////////////////////////
// Explicit instantiation
/////////////////////////////////////////////////////////////////////////////

template class ConstantForce<1,1>;
template class ConstantForce<1,2>;
template class ConstantForce<2,2>;
template class ConstantForce<1,3>;
template class ConstantForce<2,3>;
template class ConstantForce<3,3>;

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
EXPORT_TEMPLATE_CLASS_ALL_DIMS(ConstantForce)