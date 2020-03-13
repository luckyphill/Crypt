
#include "AnoikisCellKillerVertex.hpp"
#include "VertexBasedCellPopulation.hpp"
#include "EpithelialType.hpp"
#include "StromalType.hpp"

template<unsigned DIM>
AnoikisCellKillerVertex<DIM>::AnoikisCellKillerVertex(AbstractCellPopulation<DIM>* pCellPopulation)
    : AbstractCellKiller<DIM>(pCellPopulation)
{
    if (dynamic_cast<VertexBasedCellPopulation<DIM>*>(pCellPopulation) == nullptr)
    {
        EXCEPTION("AnoikisCellKillerVertex only works with a VertexBasedCellPopulation.");
    }
}

template<unsigned DIM>
void AnoikisCellKillerVertex<DIM>::CheckAndLabelCellsForApoptosisOrDeath()
{
    MutableVertexMesh<DIM, DIM>& vertex_mesh = static_cast<VertexBasedCellPopulation<DIM>*>(this->mpCellPopulation)->rGetMesh();

    unsigned stromalCells = 0;

    // Iterate over cell population
    for (typename AbstractCellPopulation<DIM>::Iterator cell_iter = this->mpCellPopulation->Begin();
         cell_iter != this->mpCellPopulation->End();
         ++cell_iter)
    {
        // Only consider cells with the CellLabel property
        if (cell_iter->GetCellProliferativeType()->template IsType<EpithelialType>())
        {
            // Get the element index corresponding to this cell
            unsigned elem_index = this->mpCellPopulation->GetLocationIndexUsingCell(*cell_iter);

            // Get the set of neighbouring element indices
            std::set<unsigned> neighbouring_elem_indices = vertex_mesh.GetNeighbouringElementIndices(elem_index);
            unsigned stromalCells = 0;
            // Check if any of the corresponding cells are stromal cells
            for (std::set<unsigned>::iterator elem_iter = neighbouring_elem_indices.begin();
                 elem_iter != neighbouring_elem_indices.end();
                 ++elem_iter)
            {
                if (this->mpCellPopulation->GetCellUsingLocationIndex(*elem_iter)->GetCellProliferativeType()->template IsType<StromalType>())
                {
                    stromalCells++;
                    break;
                }
            }

            // ...and if none do, then kill this cell
            if (stromalCells == 0)
            {
                cell_iter->Kill();
            }
        }
    }
}

template<unsigned DIM>
void AnoikisCellKillerVertex<DIM>::OutputCellKillerParameters(out_stream& rParamsFile)
{
    // There are no member variables, so just call method on direct parent class
    AbstractCellKiller<DIM>::OutputCellKillerParameters(rParamsFile);
}

// Explicit instantiation
template class AnoikisCellKillerVertex<1>;
template class AnoikisCellKillerVertex<2>;
template class AnoikisCellKillerVertex<3>;

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(AnoikisCellKillerVertex)
