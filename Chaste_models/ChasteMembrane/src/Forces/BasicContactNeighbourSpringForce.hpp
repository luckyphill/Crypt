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

#ifndef BasicContactNeighbourSpringForce_HPP_
#define BasicContactNeighbourSpringForce_HPP_

#include "AbstractForce.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>


template<unsigned  ELEMENT_DIM, unsigned SPACE_DIM=ELEMENT_DIM>
class BasicContactNeighbourSpringForce : public AbstractForce<ELEMENT_DIM, SPACE_DIM>
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
        archive & mSpringStiffness; // Epithelial covers stem and transit
        archive & mMeinekeDivisionRestingSpringLength;
        archive & mMeinekeSpringGrowthDuration;
    }

protected:


    double mSpringStiffness;

    double mRestLength;

    double mCutOffLength;

    
    // Spring growth parameters for newly divided cells
    double mMeinekeSpringStiffness;

    double mMeinekeDivisionRestingSpringLength;

    double mMeinekeSpringGrowthDuration;

    
    bool m1DColumnOfCells = false; // Determines if we're using 1D or not. Could be much better implemented using the SPACE_DIM variable

    bool mDebugMode = false;

public:

    /**
     * Constructor.
     */
    BasicContactNeighbourSpringForce();

    /**
     * Destructor.
     */
    virtual ~BasicContactNeighbourSpringForce();

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

    void AddForceContribution(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation);

    std::set<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* >> FindContactNeighbourPairs(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation);

    std::set<std::pair<Node<SPACE_DIM>*, Node<SPACE_DIM>* >> Find1DContactPairs(AbstractCellPopulation<ELEMENT_DIM,SPACE_DIM>& rCellPopulation);


    void SetSpringStiffness(double SpringStiffness);

    void SetRestLength(double RestLength);

    void SetCutOffLength(double CutOffLength);

    
    // Spring growth for newly divided cells
    void SetMeinekeSpringStiffness(double springStiffness);

    void SetMeinekeDivisionRestingSpringLength(double divisionRestingSpringLength);

    void SetMeinekeSpringGrowthDuration(double springGrowthDuration);

    void SetDebugMode(bool debugStatus);

    void Set1D(bool dimStatus);
    
    virtual void OutputForceParameters(out_stream& rParamsFile);
};


#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(BasicContactNeighbourSpringForce)

#endif /*BasicContactNeighbourSpringForce_HPP_*/

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