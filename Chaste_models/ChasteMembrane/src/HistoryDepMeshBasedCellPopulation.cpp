/*

Copyright (c) 2005-2018, University of Oxford.
All rights reserved.

University of Oxford means the Chancellor, Masters and Scholars of the
University of Oxford, having an administrative office at Wellington
Square, Oxford OX1 2JD, UK.

This file is part of Chaste.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of the University of Oxford nor the names of its
   contributors may be used to endorse or promote products derived from this
   software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

#include "MeshBasedCellPopulation.hpp"
#include "HistoryDepMeshBasedCellPopulation.hpp"
#include "VtkMeshWriter.hpp"
#include "CellBasedEventHandler.hpp"
#include "Cylindrical2dMesh.hpp"
#include "Cylindrical2dVertexMesh.hpp"
#include "NodesOnlyMesh.hpp"
#include "CellId.hpp"
#include "CellVolumesWriter.hpp"
#include "CellPopulationElementWriter.hpp"
#include "VoronoiDataWriter.hpp"
#include "NodeVelocityWriter.hpp"
#include "CellPopulationAreaWriter.hpp"

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
HistoryDepMeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>::HistoryDepMeshBasedCellPopulation(MutableMesh<ELEMENT_DIM,SPACE_DIM>& rMesh,
                                      std::vector<CellPtr>& rCells,
                                      const std::vector<unsigned> locationIndices,
                                      bool deleteMesh,
                                      bool validate)
    : MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>(rMesh, rCells, locationIndices, deleteMesh, validate)
{
    // mpMutableMesh = static_cast<MutableMesh<ELEMENT_DIM,SPACE_DIM>* >(&(this->mrMesh));
    // // assert(this->mCells.size() <= this->mrMesh.GetNumNodes());

    // if (validate)
    // {
    //     this->Validate();
    // }

    //  // Initialise the applied force at each node to zero
    // for (typename AbstractMesh<ELEMENT_DIM, SPACE_DIM>::NodeIterator node_iter = this->rGetMesh().GetNodeIteratorBegin();
    //      node_iter != this->rGetMesh().GetNodeIteratorEnd();
    //      ++node_iter)
    // {
    //     node_iter->ClearAppliedForce();
    // }


}

// template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
// HistoryDepMeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>::HistoryDepMeshBasedCellPopulation(MutableMesh<ELEMENT_DIM,SPACE_DIM>& rMesh)
//     : MeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>(rMesh)
// {
// }

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
HistoryDepMeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>::~HistoryDepMeshBasedCellPopulation()
{
}

template<unsigned ELEMENT_DIM, unsigned SPACE_DIM>
void HistoryDepMeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>::OutputCellPopulationParameters(out_stream& rParamsFile)
{
    // *rParamsFile << "\t\t<UseAreaBasedDampingConstant>" << mUseAreaBasedDampingConstant << "</UseAreaBasedDampingConstant>\n";
    // *rParamsFile << "\t\t<AreaBasedDampingConstantParameter>" <<  mAreaBasedDampingConstantParameter << "</AreaBasedDampingConstantParameter>\n";
    // *rParamsFile << "\t\t<WriteVtkAsPoints>" << mWriteVtkAsPoints << "</WriteVtkAsPoints>\n";
    // *rParamsFile << "\t\t<OutputMeshInVtk>" << mOutputMeshInVtk << "</OutputMeshInVtk>\n";
    // *rParamsFile << "\t\t<HasVariableRestLength>" << mHasVariableRestLength << "</HasVariableRestLength>\n";

    // Call method on direct parent class
    HistoryDepMeshBasedCellPopulation<ELEMENT_DIM,SPACE_DIM>::OutputCellPopulationParameters(rParamsFile);
}

// Explicit instantiation
template class HistoryDepMeshBasedCellPopulation<1,1>;
template class HistoryDepMeshBasedCellPopulation<1,2>;
template class HistoryDepMeshBasedCellPopulation<2,2>;
template class HistoryDepMeshBasedCellPopulation<1,3>;
template class HistoryDepMeshBasedCellPopulation<2,3>;
template class HistoryDepMeshBasedCellPopulation<3,3>;

// Serialization for Boost >= 1.36
// #include "SerializationExportWrapperForCpp.hpp"
// EXPORT_TEMPLATE_CLASS_ALL_DIMS(HistoryDepMeshBasedCellPopulation)
