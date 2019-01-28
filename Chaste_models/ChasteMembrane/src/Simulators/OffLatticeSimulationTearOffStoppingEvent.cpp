/*

Copyright (c) 2005-2015, University of Oxford.
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

#include "OffLatticeSimulationTearOffStoppingEvent.hpp"
#include "Debug.hpp"

bool OffLatticeSimulationTearOffStoppingEvent::StoppingEventHasOccurred()
{

  c_vector<double, 2> end_force = mp_node->rGetAppliedForce();
  //PRINT_VARIABLE(m_push_force[0])
  if (end_force[0] > 0.99 * m_push_force[0])
  {
    // It has broken off
    //TRACE("borked")

    return true;
  }

  if (end_force[0] < conv_limit && SimulationTime::Instance()->GetTime()>mstart)
  {
    // It has reached equilibrium
    //TRACE("Stuck")
    return true;
  }
  //TRACE("trying agains")
  return false;
}

void OffLatticeSimulationTearOffStoppingEvent::SetSingleNode(Node<2>* pnode)
{
  mp_node = pnode;
}

void OffLatticeSimulationTearOffStoppingEvent::SetPushForce(c_vector<double, 2> push_force)
{
  m_push_force = push_force;
}

void OffLatticeSimulationTearOffStoppingEvent::SetSimulationStartTime(double start)
{
  mstart = start;
}

OffLatticeSimulationTearOffStoppingEvent::OffLatticeSimulationTearOffStoppingEvent(
        AbstractCellPopulation<2>& rCellPopulation)
    : OffLatticeSimulation<2>(rCellPopulation)
{
}




// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(OffLatticeSimulationTearOffStoppingEvent)
