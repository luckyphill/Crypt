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

#ifndef LINEARSPRINGFORCEMEMBRANECELL_HPP_
#define LINEARSPRINGFORCEMEMBRANECELL_HPP_

#include "AbstractTwoBodyInteractionForce.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>

/**
 * A force law initially employed by Meineke et al (2001) in their off-lattice
 * model of the intestinal crypt (doi:10.1046/j.0960-7722.2001.00216.x).
 *
 * Each pair of neighbouring nodes are assumed to be connected by a linear
 * spring. The force of node \f$i\f$ is given
 * by
 *
 * \f[
 * \mathbf{F}_{i}(t) = \sum_{j} \mu_{i,j} ( || \mathbf{r}_{i,j} || - s_{i,j}(t) ) \hat{\mathbf{r}}_{i,j}.
 * \f]
 *
 * Here \f$\mu_{i,j}\f$ is the spring constant for the spring between nodes
 * \f$i\f$ and \f$j\f$, \f$s_{i,j}(t)\f$ is its natural length at time \f$t\f$,
 * \f$\mathbf{r}_{i,j}\f$ is their relative displacement and a hat (\f$\hat{}\f$)
 * denotes a unit vector.
 *
 * Length is scaled by natural length.
 * Time is in hours.
 */
template<unsigned  ELEMENT_DIM, unsigned SPACE_DIM=ELEMENT_DIM>
class LinearSpringForceMembraneCell : public AbstractTwoBodyInteractionForce<ELEMENT_DIM, SPACE_DIM>
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
        archive & boost::serialization::base_object<AbstractTwoBodyInteractionForce<ELEMENT_DIM, SPACE_DIM> >(*this);
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

    double mEpithelialRestLength; // Epithelial covers stem and transit
    double mMembraneRestLength;
    double mStromalRestLength; // Stromal is the differentiated "filler" cells
    double mEpithelialMembraneRestLength;
    double mMembraneStromalRestLength;
    double mStromalEpithelialRestLength;

    double mEpithelialCutOffLength; // Epithelial covers stem and transit
    double mMembraneCutOffLength;
    double mStromalCutOffLength; // Stromal is the differentiated "filler" cells
    double mEpithelialMembraneCutOffLength;
    double mMembraneStromalCutOffLength;
    double mStromalEpithelialCutOffLength;


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

public:

    /**
     * Constructor.
     */
    LinearSpringForceMembraneCell();

    /**
     * Destructor.
     */
    virtual ~LinearSpringForceMembraneCell();

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

    void SetEpithelialSpringStiffness(double epithelialSpringStiffness); // Epithelial covers stem and transit
    void SetMembraneSpringStiffness(double membraneSpringStiffness);
    void SetStromalSpringStiffness(double stromalSpringStiffness); // Stromal is the differentiated "filler" cells
    void SetEpithelialMembraneSpringStiffness(double epithelialMembraneSpringStiffness);
    void SetMembraneStromalSpringStiffness(double membraneStromalSpringStiffness);
    void SetStromalEpithelialSpringStiffness(double stromalEpithelialSpringStiffness);

    void SetEpithelialRestLength(double epithelialRestLength); // Epithelial covers stem and transit
    void SetMembraneRestLength(double membraneRestLength);
    void SetStromalRestLength(double stromalRestLength); // Stromal is the differentiated "filler" cells
    void SetEpithelialMembraneRestLength(double epithelialMembraneRestLength);
    void SetMembraneStromalRestLength(double membraneStromalRestLength);
    void SetStromalEpithelialRestLength(double stromalEpithelialRestLength);

    void SetEpithelialCutOffLength(double epithelialCutOffLength); // Epithelial covers stem and transit
    void SetMembraneCutOffLength(double membraneCutOffLength);
    void SetStromalCutOffLength(double stromalCutOffLength); // Stromal is the differentiated "filler" cells
    void SetEpithelialMembraneCutOffLength(double epithelialMembraneCutOffLength);
    void SetMembraneStromalCutOffLength(double membraneStromalCutOffLength);
    void SetStromalEpithelialCutOffLength(double stromalEpithelialCutOffLength);

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
    virtual void OutputForceParameters(out_stream& rParamsFile);
};

#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(LinearSpringForceMembraneCell)

#endif /*LINEARSPRINGFORCEMEMBRANECELL_HPP_*/
