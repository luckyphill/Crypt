
#include "PopUpLocationWriter.hpp"
#include "AbstractCellPopulation.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "CaBasedCellPopulation.hpp"
#include "NodeBasedCellPopulation.hpp"
#include "PottsBasedCellPopulation.hpp"
#include "VertexBasedCellPopulation.hpp"

#include "SimplifiedCellCyclePhases.hpp"
#include "SimplifiedPhaseBasedCellCycleModel.hpp"
#include "AnoikisCellKillerNewPhaseModel.hpp"
#include "SloughingCellKillerNewPhaseModel.hpp"
#include "NodeBasedCellPopulation.hpp"

#include "AnoikisCellTagged.hpp"

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
PopUpLocationWriter<ELEMENT_DIM, SPACE_DIM>::PopUpLocationWriter()
	: AbstractCellPopulationWriter<ELEMENT_DIM, SPACE_DIM>("popup_location.txt")
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void PopUpLocationWriter<ELEMENT_DIM, SPACE_DIM>::VisitAnyPopulation(AbstractCellPopulation<SPACE_DIM, SPACE_DIM>* pCellPopulation)
{

	if (PetscTools::AmMaster())
	{
		std::list<CellPtr> cells = pCellPopulation->rGetCells();
		for (std::list<CellPtr>::iterator it = cells.begin(); it != cells.end(); ++it)
		{
			CellPtr p_cell = *it;

			// First, decide if the cell has popped up and hasn't been written
			if ( p_cell->HasCellProperty<AnoikisCellTagged>()  &&  !p_cell->GetCellData()->GetItem("written"))
			{
				// If it needs to be written, check if it is a multinode cell
				unsigned location_index = pCellPopulation->GetLocationIndexUsingCell(p_cell);
				double parent1 = (*it)->GetCellData()->GetItem("parent");
							
				double value = 0.0;
				if (SPACE_DIM == 2)
				{
					value = pCellPopulation->GetNode(location_index)->rGetLocation()[1];
				}
				*this->mpOutStream << ", " << value << ", " << parent;
				p_cell->GetCellData()->SetItem("written",true);
			}
		}
	}
}



template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void PopUpLocationWriter<ELEMENT_DIM, SPACE_DIM>::Visit(NodeBasedCellPopulation<SPACE_DIM>* pCellPopulation)
{
	VisitAnyPopulation(pCellPopulation);
}




// Irrelevant at this point in time. They need to exist since they are pure virtual in the Abstract class

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void PopUpLocationWriter<ELEMENT_DIM, SPACE_DIM>::Visit(MeshBasedCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation)
{
	//VisitAnyPopulation(pCellPopulation);
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void PopUpLocationWriter<ELEMENT_DIM, SPACE_DIM>::Visit(CaBasedCellPopulation<SPACE_DIM>* pCellPopulation)
{
	VisitAnyPopulation(pCellPopulation);
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void PopUpLocationWriter<ELEMENT_DIM, SPACE_DIM>::Visit(PottsBasedCellPopulation<SPACE_DIM>* pCellPopulation)
{
	VisitAnyPopulation(pCellPopulation);
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void PopUpLocationWriter<ELEMENT_DIM, SPACE_DIM>::Visit(VertexBasedCellPopulation<SPACE_DIM>* pCellPopulation)
{
	VisitAnyPopulation(pCellPopulation);
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
