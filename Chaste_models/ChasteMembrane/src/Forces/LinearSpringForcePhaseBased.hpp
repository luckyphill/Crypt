/*
MODIFIED BY PHILLIP BROWN: 01/11/2017
- Added a "membrane cell" in order to test a method of introducing a membrane
- Also had to add in each cell type cross pair spring stiffness
MODIFICATIONS around lines 120, 240

MODIFIED BY AXEL ALMET FOR RESEARCH: 22/11/14
Copyright (c) 2005-2014, University of Oxford.
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

#ifndef LINEARSPRINGFORCEPHASEBased_HPP_
#define LINEARSPRINGFORCEPHASEBased_HPP_

#include "AbstractForce.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>

template<unsigned  ELEMENT_DIM, unsigned SPACE_DIM=ELEMENT_DIM>
class LinearSpringForcePhaseBased : public AbstractForce<ELEMENT_DIM, SPACE_DIM>
{
    friend class TestForces;

private:

    /** Needed for serialization. */
    friend class boost::serialization::access;
    /**
     * Archive the object and its member variables.
     *
     * @param archive the archive
     * @param version the current version of this class
     */
    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
        archive & boost::serialization::base_object<AbstractForce<ELEMENT_DIM, SPACE_DIM> >(*this);
        archive & mEpithelialSpringStiffness; // Epithelial covers stem and transit
        archive & mMembraneSpringStiffness;
        archive & mStromalSpringStiffness; // Stromal is the differentiated "filler" cells
        archive & mEpithelialMembraneSpringStiffness;
        archive & mMembraneStromalSpringStiffness;
        archive & mStromalEpithelialSpringStiffness;
        archive & mMeinekeDivisionRestingSpringLength;
        archive & mMeinekeSpringGrowthDuration;
    }

protected:


    double mEpithelialSpringStiffness; // Epithelial covers stem and transit
    double mMembraneSpringStiffness;
    double mStromalSpringStiffness; // Stromal is the differentiated "filler" cells
    double mEpithelialMembraneSpringStiffness;
    double mMembraneStromalSpringStiffness;
    double mStromalEpithelialSpringStiffness;

    double mEpithelialPreferredRadius; // Epithelial covers stem and transit
    double mMembranePreferredRadius;
    double mStromalPreferredRadius; // Stromal is the differentiated "filler" cells

    double mEpithelialInteractionRadius; // Epithelial covers stem and transit
    double mMembraneInteractionRadius;
    double mStromalInteractionRadius; // Stromal is the differentiated "filler" cells


    /**
     * Initial resting spring length after cell division.
     * Has units of cell size at equilibrium rest length
     *
     * The value of this parameter should be larger than mDivisionSeparation,
     * because of pressure from neighbouring springs.
     */
    double mMeinekeDivisionRestingSpringLength;

    /**
     * The time it takes for the springs rest length to increase from
     * mMeinekeDivisionRestingSpringLength to its natural length.
     *
     * The value of this parameter is usually the same as the M Phase of the cell cycle and defaults to 1.
     */
    double mMeinekeSpringGrowthDuration;

    bool mDebugMode = false;

public:

    /**
     * Constructor.
     */
    LinearSpringForcePhaseBased();

    /**
     * Destructor.
     */
    virtual ~LinearSpringForcePhaseBased();

    /**
     * Overridden CalculateForceBetweenNodes() method.
     *
     * Calculates the force between two nodes.
     *
     * Note that this assumes they are connected and is called by AddForceContribution()
     *
     * @param nodeAGlobalIndex index of one neighbouring node
     * @param nodeBGlobalIndex index of the other neighbouring node
     * @param rCellPopulation the cell population
     * @return The force exerted on Node A by Node B.
     */
    c_vector<double, SPACE_DIM> CalculateForceBetweenNodes(unsigned nodeAGlobalIndex,
                                                     unsigned nodeBGlobalIndex,
                                                     AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation);

    // Work out the contact neighbours/nodes
    std::set<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* >> GetContactNeighbours(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation);
    
    void AddForceContribution(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation);


    void SetEpithelialSpringStiffness(double epithelialSpringStiffness); // Epithelial covers stem and transit
    void SetMembraneSpringStiffness(double membraneSpringStiffness);
    void SetStromalSpringStiffness(double stromalSpringStiffness); // Stromal is the differentiated "filler" cells
    void SetEpithelialMembraneSpringStiffness(double epithelialMembraneSpringStiffness);
    void SetMembraneStromalSpringStiffness(double membraneStromalSpringStiffness);
    void SetStromalEpithelialSpringStiffness(double stromalEpithelialSpringStiffness);

    void SetEpithelialPreferredRadius(double epithelialPreferredRadius); // Epithelial covers stem and transit
    void SetMembranePreferredRadius(double membranePreferredRadius);
    void SetStromalPreferredRadius(double stromalPreferredRadius); // Stromal is the differentiated "filler" cells

    void SetEpithelialInteractionRadius(double epithelialInteractionRadius); // Epithelial covers stem and transit
    void SetMembraneInteractionRadius(double membraneInteractionRadius);
    void SetStromalInteractionRadius(double stromalInteractionRadius); // Stromal is the differentiated "filler" cells

    /**
     * Set mMeinekeDivisionRestingSpringLength.
     *
     * @param divisionRestingSpringLength the new value of mMeinekeDivisionRestingSpringLength
     */
    void SetMeinekeDivisionRestingSpringLength(double divisionRestingSpringLength);

    /**
     * Set mMeinekeSpringGrowthDuration.
     *
     * @param springGrowthDuration the new value of mMeinekeSpringGrowthDuration
     */
    void SetMeinekeSpringGrowthDuration(double springGrowthDuration);

    /**
     * Overridden OutputForceParameters() method.
     *
     * @param rParamsFile the file stream to which the parameters are output
     */

    void SetDebugMode(bool debugStatus);
    
    virtual void OutputForceParameters(out_stream& rParamsFile);
};


#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(LinearSpringForcePhaseBased)

#endif /*LINEARSPRINGFORCEPHASEBased_HPP_*/

#ifndef ND_SORT_FUNCTION
#define ND_SORT_FUNCTION
// Need to declare this sort function outide the class, otherwise it won't work
template<unsigned  ELEMENT_DIM, unsigned SPACE_DIM=ELEMENT_DIM>
bool nd_sort(std::tuple< Node<SPACE_DIM>*, c_vector<double, SPACE_DIM>, double > i,
                 std::tuple< Node<SPACE_DIM>*, c_vector<double, SPACE_DIM>, double > j)
{ 
    return (std::get<2>(i)<std::get<2>(j)); 
};
#endif
