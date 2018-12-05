/*

Copyright (c) 2005-2016, University of Oxford.
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

#include "AdhesionCaSwitchingUpdateRule.hpp"

#include "Debug.hpp"

template<unsigned DIM>
AdhesionCaSwitchingUpdateRule<DIM>::AdhesionCaSwitchingUpdateRule()
    : AbstractCaSwitchingUpdateRule<DIM>(),
      mCellCellAdhesionEnergyParameter(0.2), // Educated guess
      mCellBoundaryAdhesionEnergyParameter(0.2), // Educated guess
      mTemperature(0.1) // Educated guess
{
}

template<unsigned DIM>
AdhesionCaSwitchingUpdateRule<DIM>::~AdhesionCaSwitchingUpdateRule()
{
}

template<unsigned DIM>
double AdhesionCaSwitchingUpdateRule<DIM>::EvaluateHamiltonian(unsigned currentNodeIndex,
                                                                      unsigned neighbourNodeIndex,
                                                                      CaBasedCellPopulation<DIM>& rCellPopulation)
{
    // Energy before and after switch
    double H_0=0.0;
    double H_1=0.0;

    bool is_cell_on_node_1 = rCellPopulation.IsCellAttachedToLocationIndex(currentNodeIndex);
    bool is_cell_on_node_2 = rCellPopulation.IsCellAttachedToLocationIndex(neighbourNodeIndex);

    std::set<unsigned> node_1_neighbouring_node_indices = rCellPopulation.rGetMesh().GetVonNeumannNeighbouringNodeIndices(currentNodeIndex);

    // Remove node 2 from neighbouring indices
    node_1_neighbouring_node_indices.erase(neighbourNodeIndex);

    for (std::set<unsigned>::iterator iter = node_1_neighbouring_node_indices.begin();
                 iter != node_1_neighbouring_node_indices.end();
                 ++iter)
    {
        if(rCellPopulation.IsCellAttachedToLocationIndex(*iter))
        {
            // Cell attached to neighbour node

            if (is_cell_on_node_1)
            {
                H_0 += mCellCellAdhesionEnergyParameter;
            }
            else // no cell on node 1
            {
                H_0 += mCellBoundaryAdhesionEnergyParameter;
            }

            if (is_cell_on_node_2)
            {
                H_1 += mCellCellAdhesionEnergyParameter;
            }
            else // no cell on node 2
            {
                H_1 += mCellBoundaryAdhesionEnergyParameter;
            }
        }
        else // No cell on neighbour node
        {
            if (is_cell_on_node_1)
            {
                H_0 += mCellBoundaryAdhesionEnergyParameter;
            }
            // else // no cell on node 1 or neighbour so no contribution
            if (is_cell_on_node_2)
            {
                H_1 += mCellBoundaryAdhesionEnergyParameter;
            }
            //else // no cell on node 2 or neighbour so no contribution
        }
    }

    std::set<unsigned> node_2_neighbouring_node_indices = rCellPopulation.rGetMesh().GetVonNeumannNeighbouringNodeIndices(neighbourNodeIndex);
    // Remove node 2 from neighbouring indices
    node_2_neighbouring_node_indices.erase(currentNodeIndex);

    for (std::set<unsigned>::iterator iter = node_2_neighbouring_node_indices.begin();
                 iter != node_2_neighbouring_node_indices.end();
                 ++iter)
    {

        if(rCellPopulation.IsCellAttachedToLocationIndex(*iter))
        {
            // Cell attached to neighbour node
            if (is_cell_on_node_1)
            {
                H_1 += mCellCellAdhesionEnergyParameter;
            }
            else // no cell on node 1
            {
                H_1 += mCellBoundaryAdhesionEnergyParameter;
            }
            if (is_cell_on_node_2)
            {
                H_0 += mCellCellAdhesionEnergyParameter;
            }
            else // no cell on node 2
            {
                H_0 += mCellBoundaryAdhesionEnergyParameter;
            }
        }
        else // No cell on neighbour node
        {
            if (is_cell_on_node_1)
            {
                H_1 += mCellBoundaryAdhesionEnergyParameter;
            }
            // else // no cell on node 1 or neighbour so no contribution
            if (is_cell_on_node_2)
            {
                H_0 += mCellBoundaryAdhesionEnergyParameter;
            }
            // else // no cell on node 1 or neighbour so no contribution
        }
    }

    return H_1-H_0;
}

template<unsigned DIM>
double AdhesionCaSwitchingUpdateRule<DIM>::EvaluateSwitchingProbability(unsigned currentNodeIndex,
                                                                      unsigned neighbourNodeIndex,
                                                                      CaBasedCellPopulation<DIM>& rCellPopulation,
                                                                      double dt,
                                                                      double deltaX)
{

    // Check if cell will have a moore neighbour after the move?
    bool cells_connected = false;

    bool is_cell_on_node_1 = rCellPopulation.IsCellAttachedToLocationIndex(currentNodeIndex);
    bool is_cell_on_node_2 = rCellPopulation.IsCellAttachedToLocationIndex(neighbourNodeIndex);

    // To get here need at least one cell
    assert(is_cell_on_node_1 || is_cell_on_node_2);

    if ( !is_cell_on_node_1 || !is_cell_on_node_2 )
    {
        if (is_cell_on_node_1)
        {
            assert(!is_cell_on_node_2);

            std::set<unsigned> node_2_neighbouring_node_indices = rCellPopulation.rGetMesh().GetMooreNeighbouringNodeIndices(neighbourNodeIndex);
            // Remove node 1 from neighbouring indices
            node_2_neighbouring_node_indices.erase(currentNodeIndex);

            for (std::set<unsigned>::iterator iter = node_2_neighbouring_node_indices.begin();
                             iter != node_2_neighbouring_node_indices.end();
                             ++iter)
            {
                if(rCellPopulation.IsCellAttachedToLocationIndex(*iter))
                {
                    cells_connected = true;
                }
            }
        }
        else
        {
            assert(is_cell_on_node_2);
            assert(!is_cell_on_node_1);

            std::set<unsigned> node_1_neighbouring_node_indices = rCellPopulation.rGetMesh().GetMooreNeighbouringNodeIndices(currentNodeIndex);
            // Remove node 1 from neighbouring indices
            node_1_neighbouring_node_indices.erase(neighbourNodeIndex);

            for (std::set<unsigned>::iterator iter = node_1_neighbouring_node_indices.begin();
                            iter != node_1_neighbouring_node_indices.end();
                            ++iter)
            {
                if(rCellPopulation.IsCellAttachedToLocationIndex(*iter))
                {
                    cells_connected = true;
                }
            }
        }

    }
    else
    {
        assert(is_cell_on_node_1);
        assert(is_cell_on_node_2);
        // Two cells so must be connected after move
        cells_connected = true;
    }


    double probability_of_switch = 0.0;


    if (!is_cell_on_node_1 || !is_cell_on_node_2) // Only consider switch if cell and node
    {
        if(cells_connected)
        {
            double hamiltonian_difference = EvaluateHamiltonian(currentNodeIndex,neighbourNodeIndex,rCellPopulation);

            if (hamiltonian_difference<=0)
            {
                probability_of_switch =  dt;
            }
            else
            {
                probability_of_switch = dt*exp(-hamiltonian_difference/mTemperature);
            }
        }
    }

   return probability_of_switch;


}

template<unsigned DIM>
double AdhesionCaSwitchingUpdateRule<DIM>::GetCellCellAdhesionEnergyParameter()
{
    return mCellCellAdhesionEnergyParameter;
}

template<unsigned DIM>
void AdhesionCaSwitchingUpdateRule<DIM>::SetCellCellAdhesionEnergyParameter(double cellCellAdhesionEnergyParameter)
{
    mCellCellAdhesionEnergyParameter = cellCellAdhesionEnergyParameter;
}

template<unsigned DIM>
double AdhesionCaSwitchingUpdateRule<DIM>::GetCellBoundaryAdhesionEnergyParameter()
{
    return mCellBoundaryAdhesionEnergyParameter;
}

template<unsigned DIM>
void AdhesionCaSwitchingUpdateRule<DIM>::SetCellBoundaryAdhesionEnergyParameter(double cellBoundaryAdhesionEnergyParameter)
{
    mCellBoundaryAdhesionEnergyParameter = cellBoundaryAdhesionEnergyParameter;
}


template<unsigned DIM>
double AdhesionCaSwitchingUpdateRule<DIM>::GetTemperature()
{
    return mTemperature;
}

template<unsigned DIM>
void AdhesionCaSwitchingUpdateRule<DIM>::SetTemperature(double temperature)
{
    mTemperature = temperature;
}

template<unsigned DIM>
void AdhesionCaSwitchingUpdateRule<DIM>::OutputUpdateRuleParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<CellCellAdhesionEnergyParameter>" << mCellCellAdhesionEnergyParameter << "</CellCellAdhesionEnergyParameter>\n";
    *rParamsFile << "\t\t\t<CellBoundaryAdhesionEnergyParameter>" << mCellBoundaryAdhesionEnergyParameter << "</CellBoundaryAdhesionEnergyParameter>\n";

    *rParamsFile << "\t\t\t<Temperature>" << mTemperature << "</Temperature>\n";

    // Call method on direct parent class
    AbstractCaSwitchingUpdateRule<DIM>::OutputUpdateRuleParameters(rParamsFile);
}

// Explicit instantiation
template class AdhesionCaSwitchingUpdateRule<1u>;
template class AdhesionCaSwitchingUpdateRule<2u>;
template class AdhesionCaSwitchingUpdateRule<3u>;

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(AdhesionCaSwitchingUpdateRule)
