#include "MonolayerNodeBasedCellPopulation.hpp"
#include "MathsCustomFunctions.hpp"
#include "VtkMeshWriter.hpp"
#include "AnoikisCellTagged.hpp"

template<unsigned DIM>
MonolayerNodeBasedCellPopulation<DIM>::MonolayerNodeBasedCellPopulation(NodesOnlyMesh<DIM>& rMesh,
                                      std::vector<CellPtr>& rCells,
                                      const std::vector<unsigned> locationIndices,
                                      bool deleteMesh,
                                      bool validate)
    : NodeBasedCellPopulation<DIM>(rMesh, rCells, locationIndices)
{
}

template<unsigned DIM>
MonolayerNodeBasedCellPopulation<DIM>::MonolayerNodeBasedCellPopulation(NodesOnlyMesh<DIM>& rMesh)
    : NodeBasedCellPopulation<DIM>(rMesh)
{

}

template<unsigned DIM>
MonolayerNodeBasedCellPopulation<DIM>::~MonolayerNodeBasedCellPopulation()
{
    NodeBasedCellPopulation<DIM>::Clear();
}

template<unsigned DIM>
double MonolayerNodeBasedCellPopulation<DIM>::GetDampingConstant(unsigned nodeIndex)
{
    if (this->IsGhostNode(nodeIndex) || this->IsParticle(nodeIndex))
    {
        return this->GetDampingConstantNormal();
    }
    else
    {
        CellPtr p_cell = this->GetCellUsingLocationIndex(nodeIndex);
        if (p_cell->HasCellProperty<AnoikisCellTagged>())
        {
            return GetDampingConstantPoppedUp();
        }
        else
        {
            return this->GetDampingConstantNormal();
        }
    }

}

template<unsigned DIM>
double MonolayerNodeBasedCellPopulation<DIM>::GetDampingConstantPoppedUp()
{
  return mDampingConstantPoppedUp;
}

template<unsigned DIM>
void MonolayerNodeBasedCellPopulation<DIM>::SetDampingConstantPoppedUp(double dampingConstantPoppedUp)
{
  mDampingConstantPoppedUp = dampingConstantPoppedUp;
}


template class MonolayerNodeBasedCellPopulation<1>;
template class MonolayerNodeBasedCellPopulation<2>;
template class MonolayerNodeBasedCellPopulation<3>;

#include "SerializationExportWrapperForCpp.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(MonolayerNodeBasedCellPopulation)