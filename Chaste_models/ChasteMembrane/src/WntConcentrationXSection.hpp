/*

Copyright (c) 2005-2017, University of Oxford.
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

#ifndef WNTCONCENTRATIONXSection_HPP_
#define WNTCONCENTRATIONXSection_HPP_

#include "ChasteSerialization.hpp"
#include "SerializableSingleton.hpp"
#include <boost/serialization/base_object.hpp>

#include <iostream>

#include "AbstractCellPopulation.hpp"

/**
 * Possible types of WntConcentrationXSection, currently:
 *  NONE - for testing and to remove Wnt dependence
 *  LINEAR - Drops at constant rate
 *  EXPONENTIAL - Drops exponentially
 */
typedef enum WntConcentrationXSectionType_
{
    NONE,
    LINEAR,
    EXPONENTIAL
} WntConcentrationXSectionType;


/**
 *  Singleton Wnt concentration object.
 */
template<unsigned DIM>
class WntConcentrationXSection : public SerializableSingleton<WntConcentrationXSection<DIM> >
{
private:

    /** Pointer to the singleton instance of WntConcentrationXSection */
    static WntConcentrationXSection* mpInstance;

    /**
     * The length of the crypt.
     */
    double mCryptLength;

    /**
     * The position where the crypt starts i.e. the base
     */
    double mCryptStart;

    // The minimum Wnt concentration for dividing
    double mWntThreshold;

    /**
     * Whether this WntConcentrationXSection object has had its crypt length and start set.
     */
    bool mLengthSet;

    bool mStartSet;

    bool mThresholdSet;

    /**
     * The type of WntConcentrationXSection current options are
     * NONE - returns zero everywhere
     * LINEAR - decreases from 1 to zero at height specified by mWntConcentrationXSectionParameter
     * RADIAL - decreases from 1 to zero at height specified by mWntConcentrationXSectionParameter
     */
    WntConcentrationXSectionType mWntType;

    /**
     * The cell population in which the WntConcentrationXSection occurs.
     */
    AbstractCellPopulation<DIM>* mpCellPopulation;

    /**
     * Whether this WntConcentrationXSection object has had its type set.
     */
    bool mTypeSet;

    /**
     * A value to return for testing purposes.
     */
    double mConstantWntValueForTesting;

    /**
     * Whether to return the testing value
     * (when false WntConcentrationXSection works with CellPopulation).
     */
    bool mUseConstantWntValueForTesting;

    /**
     * For LINEAR or RADIAL Wnt type:
     * The proportion of the crypt that has a Wnt gradient.
     * The Wnt concentration goes from one at the base to zero at this height up the crypt.
     *
     * For EXPONENTIAL Wnt type:
     * The parameter lambda in the Wnt concentration
     * Wnt = exp(-height/lambda)
     */
    double mWntConcentrationXSectionParameter;

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
        bool is_set_up = IsWntSetUp();
        archive & is_set_up;
        if (is_set_up)
        {
            archive & mCryptLength;
            archive & mCryptStart;
            archive & mLengthSet;
            archive & mStartSet;
            archive & mWntType;
            archive & mpCellPopulation;
            archive & mTypeSet;
            archive & mConstantWntValueForTesting;
            archive & mUseConstantWntValueForTesting;
            archive & mWntConcentrationXSectionParameter;
        }
    }

protected:

    /**
     * Protected constuctor. Not to be called, use Instance() instead.
     */
    WntConcentrationXSection();

public:

    /**
     * Return a pointer to the WntConcentrationXSection object.
     * The first time this is called, the object is created.
     *
     * @return  A pointer to the singleton WntConcentrationXSection object.
     */
    static WntConcentrationXSection* Instance();

    /**
     * Destructor - frees up the singleton instance.
     */
    virtual ~WntConcentrationXSection();

    /**
     * Destroy the current WntConcentrationXSection instance.
     *  Should be called at the end of a simulation.
     */
    static void Destroy();

    /**
     * Get the Wnt level at a given height in the crypt.
     *
     * @param height the height of the cell at which we want the Wnt concentration
     * @return the Wnt concentration at this height in the crypt (dimensionless)
     */
    double GetWntLevel(double height);

    /**
     * Get the Wnt level at a given cell in the crypt. The crypt
     * must be set for this.
     *
     * @param pCell the cell at which we want the Wnt concentration
     * @return the Wnt concentration at this cell
     */
    double GetWntLevel(CellPtr pCell);


    /**
     * Set the crypt. Must be called before GetWntLevel().
     *
     * @param rCellPopulation reference to the cell population
     */
    void SetCellPopulation(AbstractCellPopulation<DIM>& rCellPopulation);

    /**
     * @return reference to the CellPopulation.
     */
    AbstractCellPopulation<DIM>& rGetCellPopulation();

    /**
     * @return mCryptLength
     */
    double GetCryptLength();

    /**
     * Set mCryptLength. Must be called before GetWntLevel().
     *
     * @param cryptLength  the new value of mCryptLength
     */
    void SetCryptLength(double cryptLength);

    double GetCryptStart();



    /**
     * Set mCryptStart. Must be called before GetWntLevel().
     *
     * @param cryptStart  the new value of mCryptStart
     */
    void SetCryptStart(double cryptStart);

    double GetWntThreshold();


    /**
     * Set mCryptStart. Must be called before GetWntLevel().
     *
     * @param cryptStart  the new value of mCryptStart
     */
    void SetWntThreshold(double wntThreshold);

    /**
     * @return the type of Wnt concentration.
     */
    WntConcentrationXSectionType GetType();

    /**
     * Set the type of Wnt concentration. Must be called before GetWntLevel().
     *
     * @param type the type of Wnt concentration
     */
    void SetType(WntConcentrationXSectionType type);

    /**
     * Force the Wnt concentration to return a given value for all cells.
     * Only for testing.
     *
     * @param value the constant value to set the Wnt concentration to be
     */
    void SetConstantWntValueForTesting(double value);

    /**
     * Whether a Wnt concentration has been set up.
     *
     * For archiving, and to let a CellBasedSimulation
     * find out whether whether a WntConcentrationXSection has
     * been set up or not, i.e. whether stem cells should
     * be motile.
     *
     * @return whether the Wnt concentration is set up
     */
    bool IsWntSetUp();

    /**
     * @return mWntConcentrationXSectionParameter
     */
    double GetWntConcentrationXSectionParameter();

    /**
     * Set mWntConcentrationXSectionParameter.
     *
     * @param wntConcentrationXSectionParameter the new value of mWntConcentrationXSectionParameter
     */
    void SetWntConcentrationXSectionParameter(double wntConcentrationXSectionParameter);

};

#endif /*WNTCONCENTRATIONXSection_HPP_*/
