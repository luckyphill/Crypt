
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
		std::vector<CellPtr> popped;
		std::list<CellPtr> cells = pCellPopulation->rGetCells();
		for (std::list<CellPtr>::iterator it = cells.begin(); it != cells.end(); ++it)
		{
			CellPtr p_cell = *it;

			// First, decide if the cell has popped up and hasn't been written
			if ( p_cell->HasCellProperty<AnoikisCellTagged>()  &&  !p_cell->GetCellData()->GetItem("written"))
			{
				// If it needs to be written, check if it is a multinode cell
				SimplifiedPhaseBasedCellCycleModel* p_ccm = static_cast<SimplifiedPhaseBasedCellCycleModel*>(p_cell->GetCellCycleModel());
				SimplifiedCellCyclePhase phase = p_ccm->GetCurrentCellCyclePhase();

				if (phase != W_PHASE)
				{
					// If its a single node cell, write it straight away
					unsigned location_index = pCellPopulation->GetLocationIndexUsingCell(p_cell);
							
					double value = 0.0;
					if (SPACE_DIM == 2)
					{
						value = pCellPopulation->GetNode(location_index)->rGetLocation()[1];
					}
					*this->mpOutStream << ", " << value;
					p_cell->GetCellData()->SetItem("written",true);
				} 
				else
				{
					// If it's a multinode cell, we need to find it's twin
					// The twin _must_ pop up at the same instant in time by design
					popped.push_back(p_cell);
					p_cell->GetCellData()->SetItem("written",true);
				}
			}
		}

		// We now have to look through the vector and identify the pairs
		for (std::vector<CellPtr>::iterator it1 = popped.begin(); it1 != popped.end(); ++it1)
		{
			double parent1 = (*it1)->GetCellData()->GetItem("parent");
			std::vector<CellPtr>::iterator it2;
			for ( it2 = std::next(it1,1); it2 != popped.end(); ++it2)
			{
    			double parent2 = (*it2)->GetCellData()->GetItem("parent");
				if (parent1 == parent2)
				{
					break;
				}
			}

			assert(it2 != popped.end());
			unsigned location1 = pCellPopulation->GetLocationIndexUsingCell(*it1);
			double position1 = pCellPopulation->GetNode(location1)->rGetLocation()[1];

			unsigned location2 = pCellPopulation->GetLocationIndexUsingCell(*it2);
			double position2 = pCellPopulation->GetNode(location2)->rGetLocation()[1];

			// write the average between the two centres
			double value = (position1 + position2)/2;
			*this->mpOutStream << ", " << value;

			// Remove it2 from the vector
			popped.erase(it2);
			
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
