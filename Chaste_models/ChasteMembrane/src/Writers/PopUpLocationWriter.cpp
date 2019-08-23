

#include "PopUpLocationWriter.hpp"
#include "AbstractCellPopulation.hpp"
#include "AbstractCellProperty.hpp"
#include "TransitCellProliferativeType.hpp"
#include "AnoikisCellTagged.hpp"
#include "WrittenPopUpLocation.hpp"

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
PopUpLocationWriter<ELEMENT_DIM, SPACE_DIM>::PopUpLocationWriter()
	: AbstractCellWriter<ELEMENT_DIM, SPACE_DIM>("popup_location.txt")
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
double PopUpLocationWriter<ELEMENT_DIM, SPACE_DIM>::GetCellDataForVtkOutput(CellPtr p_cell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* p_cellPopulation)
{
	return 0.0;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void PopUpLocationWriter<ELEMENT_DIM, SPACE_DIM>::VisitCell(CellPtr p_cell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* p_cellPopulation)
{
	
	double dt = SimulationTime::Instance()->GetTimeStep();
	if ( p_cell->HasCellProperty<AnoikisCellTagged>()  &&  !p_cell->GetCellData()->GetItem("written"))
	{

		unsigned location_index = p_cellPopulation->GetLocationIndexUsingCell(p_cell);
		
		double value = 0.0;
		if (SPACE_DIM == 2)
		{
			value = p_cellPopulation->GetNode(location_index)->rGetLocation()[1];
		}
		*this->mpOutStream << ", " << value;
		p_cell->GetCellData()->SetItem("written",true);
	}
}

// Explicit instantiation
template class PopUpLocationWriter<1,1>;
template class PopUpLocationWriter<1,2>;
template class PopUpLocationWriter<2,2>;
template class PopUpLocationWriter<1,3>;
template class PopUpLocationWriter<2,3>;
template class PopUpLocationWriter<3,3>;

#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
EXPORT_TEMPLATE_CLASS_ALL_DIMS(PopUpLocationWriter)
