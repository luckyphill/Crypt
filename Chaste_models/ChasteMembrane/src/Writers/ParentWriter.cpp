#include "ParentWriter.hpp"
#include "AbstractCellPopulation.hpp"
#include "TransitCellProliferativeType.hpp"

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
ParentWriter<ELEMENT_DIM, SPACE_DIM>::ParentWriter()
    : AbstractCellWriter<ELEMENT_DIM, SPACE_DIM>("cell_parents.txt")
{
    this->mVtkCellDataName = "Location indices";
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
double ParentWriter<ELEMENT_DIM, SPACE_DIM>::GetCellDataForVtkOutput(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation)
{
    // The method GetCellDataForVtkOutput() is not suitable for this class, so we simply return zero
    return 0.0;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void ParentWriter<ELEMENT_DIM, SPACE_DIM>::VisitCell(CellPtr pCell, AbstractCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation)
{

    *this->mpOutStream <<  ", " << pCell->GetCellId() << ", " << pCell->GetCellData()->GetItem("parent");

}

// Explicit instantiation
template class ParentWriter<1,1>;
template class ParentWriter<1,2>;
template class ParentWriter<2,2>;
template class ParentWriter<1,3>;
template class ParentWriter<2,3>;
template class ParentWriter<3,3>;

#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
EXPORT_TEMPLATE_CLASS_ALL_DIMS(ParentWriter)
