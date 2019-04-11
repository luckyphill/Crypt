
#include "NodePairWriter.hpp"
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

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
NodePairWriter<ELEMENT_DIM, SPACE_DIM>::NodePairWriter()
    : AbstractCellPopulationCountWriter<ELEMENT_DIM, SPACE_DIM>("node_pairs.txt")
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NodePairWriter<ELEMENT_DIM, SPACE_DIM>::VisitAnyPopulation(AbstractCellPopulation<SPACE_DIM, SPACE_DIM>* pCellPopulation)
{

    if (PetscTools::AmMaster())
    {
        // At everytime step, print out all the node pairs in order they appear in the vector
        NodeBasedCellPopulation<SPACE_DIM>* p_tissue = static_cast<NodeBasedCellPopulation<SPACE_DIM>*>(pCellPopulation);

        std::vector< std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > > node_pairs = p_tissue->rGetNodePairs();
        for (typename std::vector< std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* > >::iterator iter = node_pairs.begin();
                iter != node_pairs.end();
                    ++iter)
        {
            std::pair< Node<SPACE_DIM>*, Node<SPACE_DIM>* > node_pair_AB = (*iter);
            Node<SPACE_DIM>* pnodeA = node_pair_AB.first;
            Node<SPACE_DIM>* pnodeB = node_pair_AB.second;

            CellPtr cellA = p_tissue->GetCellUsingLocationIndex(pnodeA->GetIndex());
            CellPtr cellB = p_tissue->GetCellUsingLocationIndex(pnodeB->GetIndex());

            *this->mpOutStream << ", " << cellA->GetCellId() << ", " << cellB->GetCellId();
        }
    }
}



template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NodePairWriter<ELEMENT_DIM, SPACE_DIM>::Visit(NodeBasedCellPopulation<SPACE_DIM>* pCellPopulation)
{
    VisitAnyPopulation(pCellPopulation);
}




// Irrelevant at this point in time. They need to exist since they are pure virtual in the Abstract class

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NodePairWriter<ELEMENT_DIM, SPACE_DIM>::Visit(MeshBasedCellPopulation<ELEMENT_DIM, SPACE_DIM>* pCellPopulation)
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
void NodePairWriter<ELEMENT_DIM, SPACE_DIM>::Visit(CaBasedCellPopulation<SPACE_DIM>* pCellPopulation)
{
    VisitAnyPopulation(pCellPopulation);
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NodePairWriter<ELEMENT_DIM, SPACE_DIM>::Visit(PottsBasedCellPopulation<SPACE_DIM>* pCellPopulation)
{
    VisitAnyPopulation(pCellPopulation);
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void NodePairWriter<ELEMENT_DIM, SPACE_DIM>::Visit(VertexBasedCellPopulation<SPACE_DIM>* pCellPopulation)
{
    VisitAnyPopulation(pCellPopulation);
}

// Explicit instantiation
template class NodePairWriter<1,1>;
template class NodePairWriter<1,2>;
template class NodePairWriter<2,2>;
template class NodePairWriter<1,3>;
template class NodePairWriter<2,3>;
template class NodePairWriter<3,3>;

#include "SerializationExportWrapperForCpp.hpp"
// Declare identifier for the serializer
EXPORT_TEMPLATE_CLASS_ALL_DIMS(NodePairWriter)
