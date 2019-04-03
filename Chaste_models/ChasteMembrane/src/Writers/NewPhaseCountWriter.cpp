
#include "NewPhaseCountWriter.hpp"
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

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
NewPhaseCountWriter<ELEMENT_DIM, SPACE_DIM>::NewPhaseCountWriter()
    : AbstractCellPopulationCountWriter<ELEMENT_DIM, SPACE_DIM>("cellcyclephases.txt")
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NewPhaseCountWriter<ELEMENT_DIM, SPACE_DIM>::VisitAnyPopulation(AbstractCellPopulation<SPACE_DIM, SPACE_DIM>* pCellPopulation)
{

    if (PetscTools::AmMaster())
    {
        // Loop through all cells
        // Get the cell cycle model
        // Get the phase
        // Add to sum
        // Output to file
        unsigned wCount = 0;
        unsigned pCount = 0;
        unsigned g0Count = 0;

        std::list<CellPtr> cells = pCellPopulation->rGetCells();
        for (std::list<CellPtr>::iterator it = cells.begin(); it != cells.end(); ++it)
        {
            SimplifiedPhaseBasedCellCycleModel* p_ccm = static_cast<SimplifiedPhaseBasedCellCycleModel*>((*it)->GetCellCycleModel());

            if (p_ccm->GetCurrentCellCyclePhase() == W_PHASE)
            {
                wCount++;
            }

            if (p_ccm->GetCurrentCellCyclePhase() == P_PHASE)
            {
                pCount++;
            }

            if (p_ccm->GetCurrentCellCyclePhase() == G0_PHASE)
            {
                g0Count++;
            }
        }

        double total = pCount + g0Count + (double)wCount/2;

        *this->mpOutStream << ", " << wCount << ", " << pCount << ", " << g0Count << ", " << unsigned(total);

    }
}



template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NewPhaseCountWriter<ELEMENT_DIM, SPACE_DIM>::Visit(NodeBasedCellPopulation<SPACE_DIM>* pCellPopulation)
{
    VisitAnyPopulation(pCellPopulation);
}




// Irrelevant at this point in time. They need to exist since they are pure virtual in the Abstract class

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NewPhaseCountWriter<ELEMENT_DIM, SPACE_DIM>::Visit(MeshBasedCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation)
{
    std::vector<unsigned> cell_cycle_phase_count = pCellPopulation->GetCellCyclePhaseCount();

    if (PetscTools::AmMaster())
    {
        for (unsigned i=0; i < cell_cycle_phase_count.size(); i++)
        {
            *this->mpOutStream << cell_cycle_phase_count[i] << "\t";
        }
    }
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NewPhaseCountWriter<ELEMENT_DIM, SPACE_DIM>::Visit(CaBasedCellPopulation<SPACE_DIM>* pCellPopulation)
{
    VisitAnyPopulation(pCellPopulation);
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NewPhaseCountWriter<ELEMENT_DIM, SPACE_DIM>::Visit(PottsBasedCellPopulation<SPACE_DIM>* pCellPopulation)
{
    VisitAnyPopulation(pCellPopulation);
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NewPhaseCountWriter<ELEMENT_DIM, SPACE_DIM>::Visit(VertexBasedCellPopulation<SPACE_DIM>* pCellPopulation)
{
    VisitAnyPopulation(pCellPopulation);
}

// Explicit instantiation
template class NewPhaseCountWriter<1,1>;
template class NewPhaseCountWriter<1,2>;
template class NewPhaseCountWriter<2,2>;
template class NewPhaseCountWriter<1,3>;
template class NewPhaseCountWriter<2,3>;
template class NewPhaseCountWriter<3,3>;

#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
EXPORT_TEMPLATE_CLASS_ALL_DIMS(NewPhaseCountWriter)
