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

#ifndef DIFFERENTIALADHESIONCASWITCHINGUPDATERULE_HPP_
#define DIFFERENTIALADHESIONCASWITCHINGUPDATERULE_HPP_

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>

#include "AbstractCaSwitchingUpdateRule.hpp"
#include "CaBasedCellPopulation.hpp"
#include "CellLabel.hpp"

/**
 * A switching update rule for use in cell-based simulations
 * using the cellular CA model.
 *
 * The probability of performing a switch depends on the cells neighbouring each cells.
 */
template<unsigned DIM>
class DifferentialAdhesionCaSwitchingUpdateRule : public AbstractCaSwitchingUpdateRule<DIM>
{
friend class TestCaSwitchingUpdateRules;

private:
    /**
     * Cell-cell adhesion energy parameter.
     * Set to the default value 0.1 in the constructor.
     * \todo provide units
     */
    double mCellCellAdhesionEnergyParameter;

    /**
     * LabelledCell-LabelledCell adhesion energy parameter.
     * Set to the default value 0.1 in the constructor.
     * \todo provide units
     */
    double mLabelledCellLabelledCellAdhesionEnergyParameter;

    /**
     * LablledCell-cell adhesion energy parameter.
     * Set to the default value 0.1 in the constructor.
     * \todo provide units
     */
    double mLabelledCellCellAdhesionEnergyParameter;

    /**
     * Cell-boundary adhesion energy parameter.
     * Set to the default value 0.2 in the constructor.
     * \todo provide units
     */
    double mCellBoundaryAdhesionEnergyParameter;

    /**
     * LabelledCell-boundary adhesion energy parameter.
     * Set to the default value 0.2 in the constructor.
     * \todo provide units
     */
    double mLabelledCellBoundaryAdhesionEnergyParameter;

    /**
     * Temperature, i.e. how much the cells fluctuate
     * (defaults to 0.1)
     */
    double mTemperature;

    friend class boost::serialization::access;
    /**
     * Boost Serialization method for archiving/checkpointing.
     * Archives the object and its member variables.
     *
     * @param archive  The boost archive.
     * @param version  The current version of this class.
     */
    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
        archive & boost::serialization::base_object<AbstractCaSwitchingUpdateRule<DIM> >(*this);
        archive & mCellCellAdhesionEnergyParameter;
        archive & mLabelledCellLabelledCellAdhesionEnergyParameter;
        archive & mLabelledCellCellAdhesionEnergyParameter;
        archive & mCellBoundaryAdhesionEnergyParameter;
        archive & mLabelledCellBoundaryAdhesionEnergyParameter;
        archive & mTemperature;
    }

public:

    /**
     * Constructor.
     */
    DifferentialAdhesionCaSwitchingUpdateRule();

    /**
     * Destructor.
     */
    ~DifferentialAdhesionCaSwitchingUpdateRule();


    /**
      * Helper method to calculate the hamiltoninandifference of a given switch.
      *
      * @param currentNodeIndex The index of the current node/lattice site
      * @param neighbourNodeIndex The index of the neighbour node/lattice site
      * @param rCellPopulation The cell population

      * @return The hamiltonian difference from switching.
      */
     double EvaluateHamiltonian(unsigned currentNodeIndex,
                                unsigned neighbourNodeIndex,
                                CaBasedCellPopulation<DIM>& rCellPopulation);

    /**
      * Calculate the probability of a given switch. Here this is TODO...
      *
      * @param currentNodeIndex The index of the current node/lattice site
      * @param neighbourNodeIndex The index of the neighbour node/lattice site
      * @param rCellPopulation The cell population
      * @param dt is the time interval
      * @param deltaX defines the size of the lattice site
      * @return The probability of the cells associated to the current node and the target node switching.
      */
     double EvaluateSwitchingProbability(unsigned currentNodeIndex,
                                        unsigned neighbourNodeIndex,
                                        CaBasedCellPopulation<DIM>& rCellPopulation,
                                        double dt,
                                        double deltaX);

     /**
       * @return mCellCellAdhesionEnergyParameter
       */
     double GetCellCellAdhesionEnergyParameter();

     /**
      * Set mCellCellAdhesionEnergyParameter.
      *
      * @param cellCellAdhesionEnergyEnergyParameter the new value of mCellCellAdhesionEnergyParameter
      */
     void SetCellCellAdhesionEnergyParameter(double cellCellAdhesionEnergyEnergyParameter);

     /**
      * @return mLabelledCellLabelledCellAdhesionEnergyParameter
      */
     double GetLabelledCellLabelledCellAdhesionEnergyParameter();

     /**
      * Set mLabelledCellLabelledCellAdhesionEnergyParameter.
      *
      * @param labelledCellLabelledCellAdhesionEnergyParameter the new value of mLabelledCellLabelledCellAdhesionEnergyParameter
      */
     void SetLabelledCellLabelledCellAdhesionEnergyParameter(double labelledCellLabelledCellAdhesionEnergyParameter);

     /**
      * @return mLabelledCellCellAdhesionEnergyParameter
      */
     double GetLabelledCellCellAdhesionEnergyParameter();
     /**
      * Set mLabelledCellCellAdhesionEnergyParameter.
      *
      * @param labelledCellCellAdhesionEnergyParameter the new value of mLabelledCelldCellAdhesionEnergyParameter
      */
     void SetLabelledCellCellAdhesionEnergyParameter(double labelledCellCellAdhesionEnergyParameter);

     /**
      * @return mCellBoundaryAdhesionEnergyParameter
      */
     double GetCellBoundaryAdhesionEnergyParameter();

     /**
      * Set mCellBoundaryAdhesionEnergyParameter.
      *
      * @param cellBoundaryAdhesionEnergyParameter the new value of mCellBoundaryAdhesionEnergyParameter
      */
     void SetCellBoundaryAdhesionEnergyParameter(double cellBoundaryAdhesionEnergyParameter);

     /**
       * @return mLabelledCellBoundaryAdhesionEnergyParameter
       */
      double GetLabelledCellBoundaryAdhesionEnergyParameter();

     /**
      * Set mLabelledCellBoundaryAdhesionEnergyParameter.
      *
      * @param labelledCellBoundaryAdhesionEnergyParameter the new value of mLabelledCellBoundaryAdhesionEnergyParameter
      */
     void SetLabelledCellBoundaryAdhesionEnergyParameter(double labelledCellBoundaryAdhesionEnergyParameter);

     /**
       * @return mTemperature
       */
      double GetTemperature();

     /**
      * Set mTemperature.
      *
      * @param temperature the new value of mTemperature
      */
     void SetTemperature(double temperature);


     /**
      * Overridden OutputUpdateRuleParameters() method.
      *
      * @param rParamsFile the file stream to which the parameters are output
      */
     void OutputUpdateRuleParameters(out_stream& rParamsFile);
};

#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(DifferentialAdhesionCaSwitchingUpdateRule)

#endif /*DIFFERENTIALADHESIONCASWITCHINGUPDATERULE_HPP_*/
