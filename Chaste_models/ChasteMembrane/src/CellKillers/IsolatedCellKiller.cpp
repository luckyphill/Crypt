/*
 * LAST MODIFIED: 1/3/2018
 * Sloughing cell killer removes epithelial cells that have reached the top of the crypt
 */

#include "IsolatedCellKiller.hpp"
#include "AbstractCellKiller.hpp"
#include "AbstractCellProperty.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "NodeBasedCellPopulation.hpp"
#include "Debug.hpp"



template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
IsolatedCellKiller<ELEMENT_DIM,SPACE_DIM>::IsolatedCellKiller(AbstractCellPopulation<SPACE_DIM>* pCellPopulation)
    : AbstractCellKiller<SPACE_DIM>(pCellPopulation)
{
    // Sets up output file
//	OutputFileHandler output_file_handler(mOutputDirectory + "SloughingData/", false);
//	mSloughingOutputFile = output_file_handler.OpenOutputFile("results.anoikis");
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
IsolatedCellKiller<ELEMENT_DIM,SPACE_DIM>::~IsolatedCellKiller()
{
//    mSloughingOutputFile->close();
}


template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void IsolatedCellKiller<ELEMENT_DIM,SPACE_DIM>::CheckAndLabelCellsForApoptosisOrDeath()
{

	NodeBasedCellPopulation<SPACE_DIM>* p_tissue = static_cast<NodeBasedCellPopulation<SPACE_DIM>*> (this->mpCellPopulation);

	for (typename AbstractCellPopulation<SPACE_DIM>::Iterator cell_iter = p_tissue->Begin();
			cell_iter != p_tissue->End();
			++cell_iter)
	{
        unsigned nodeIndex = this->mpCellPopulation->GetLocationIndexUsingCell(*cell_iter);
		// unsigned nodeIndex = p_tissue->GetNodeCorrespondingToCell(cell_iter->GetIndex());

        std::set<unsigned> neighbours;
        double radius = 1.5; // Distance to check for neighbours

        neighbours = p_tissue->GetNodesWithinNeighbourhoodRadius(nodeIndex, radius);

        if(neighbours.empty())
        {
            TRACE("Killing isolated cell")
            cell_iter->Kill();
            mCellKillCount++;
        }

	}
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
unsigned IsolatedCellKiller<ELEMENT_DIM,SPACE_DIM>::GetCellKillCount()
{
    return mCellKillCount;
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void IsolatedCellKiller<ELEMENT_DIM,SPACE_DIM>::OutputCellKillerParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<CellsRemovedBySloughing>" << 1 << "</CellsRemovedBySloughing> \n";

    // Call direct parent class
    AbstractCellKiller<SPACE_DIM>::OutputCellKillerParameters(rParamsFile);
}

template class IsolatedCellKiller<1,1>;
template class IsolatedCellKiller<1,2>;
template class IsolatedCellKiller<2,2>;
template class IsolatedCellKiller<1,3>;
template class IsolatedCellKiller<2,3>;
template class IsolatedCellKiller<3,3>;



// #include "SerializationExportWrapperForCpp.hpp"
// EXPORT_TEMPLATE_CLASS_SAME_DIMS(IsolatedCellKiller)
