#ifndef StopCreepBoundaryCONDITION_HPP_
#define StopCreepBoundaryCONDITION_HPP_

#include "AbstractCellPopulationBoundaryCondition.hpp"

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>
#include <boost/serialization/vector.hpp>

/**
 * Stops cells creeping around the top of the membrane
 */
template<class T>
class StopCreepBoundaryCondition : public AbstractCellPopulationBoundaryCondition<2,2>
{
private:

    /**
     * A point on the boundary plane.
     */
    c_vector<double, 2> mPointOnPlane;

    /**
     * The outward-facing unit normal vector to the boundary plane.
     */
    c_vector<double, 2> mNormalToPlane;

    /**
     * Whether to jiggle the cells on the bottom surface, initialised to false
     * in the constructor.
     */
    bool mUseJiggledNodesOnPlane;

    /** Needed for serialization. */
    friend class boost::serialization::access;
    /**
     * Serialize the object and its member variables.
     *
     * @param archive the archive
     * @param version the current version of this class
     */
    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
        archive & boost::serialization::base_object<AbstractCellPopulationBoundaryCondition<2, 2> >(*this);
        //archive & mUseJiggledNodesOnPlane;
    }

public:

    /**
     * Constructor.
     *
     * @param pCellPopulation pointer to the cell population
     * @param point a point on the boundary plane
     * @param normal the outward-facing unit normal vector to the boundary plane
     */
    StopCreepBoundaryCondition(AbstractCellPopulation<2, 2>* pCellPopulation,
                           c_vector<double, 2> point,
                           c_vector<double, 2> normal);

    /**
     * @return #mPointOnPlane.
     */
    const c_vector<double, 2>& rGetPointOnPlane() const;

    /**
     * @return #mNormalToPlane.
     */
    const c_vector<double, 2>& rGetNormalToPlane() const;

    /**
     * Set method for mUseJiggledNodesOnPlane
     *
     * @param useJiggledNodesOnPlane whether to jiggle the nodes on the surface of the plane, can help stop overcrowding on plane.
     */
    void SetUseJiggledNodesOnPlane(bool useJiggledNodesOnPlane);

    /** @return #mUseJiggledNodesOnPlane. */
    bool GetUseJiggledNodesOnPlane();

    /**
     * Overridden ImposeBoundaryCondition() method.
     *
     * Apply the cell population boundary conditions.
     *
     * @param rOldLocations the node locations before any boundary conditions are applied
     */
    void ImposeBoundaryCondition(const std::map<Node<2>*, c_vector<double, 2> >& rOldLocations);

    /**
     * Overridden VerifyBoundaryCondition() method.
     * Verify the boundary conditions have been applied.
     * This is called after ImposeBoundaryCondition() to ensure the condition is still satisfied.
     *
     * @return whether the boundary conditions are satisfied.
     */
    bool VerifyBoundaryCondition();

    /**
     * Overridden OutputCellPopulationBoundaryConditionParameters() method.
     * Output cell population boundary condition parameters to file.
     *
     * @param rParamsFile the file stream to which the parameters are output
     */
    void OutputCellPopulationBoundaryConditionParameters(out_stream& rParamsFile);
};

// #include "SerializationExportWrapper.hpp"
// EXPORT_TEMPLATE_CLASS_ALL_DIMS(StopCreepBoundaryCondition)

// namespace boost
// {
// namespace serialization
// {
// /**
//  * Serialize information required to construct a StopCreepBoundaryCondition.
//  */
// template<class Archive, unsigned 2, unsigned 2>
// inline void save_construct_data(
//     Archive & ar, const StopCreepBoundaryCondition<2, 2>* t, const unsigned int file_version)
// {
//     // Save data required to construct instance
//     const AbstractCellPopulation<2, 2>* const p_cell_population = t->GetCellPopulation();
//     ar << p_cell_population;

//     // Archive c_vectors one component at a time
//     c_vector<double, 2> point = t->rGetPointOnPlane();
//     for (unsigned i=0; i<2; i++)
//     {
//         ar << point[i];
//     }
//     c_vector<double, 2> normal = t->rGetNormalToPlane();
//     for (unsigned i=0; i<2; i++)
//     {
//         ar << normal[i];
//     }
// }

// /**
//  * De-serialize constructor parameters and initialize a StopCreepBoundaryCondition.
//  */
// template<class Archive, unsigned 2, unsigned 2>
// inline void load_construct_data(
//     Archive & ar, StopCreepBoundaryCondition<2, 2>* t, const unsigned int file_version)
// {
//     // Retrieve data from archive required to construct new instance
//     AbstractCellPopulation<2, 2>* p_cell_population;
//     ar >> p_cell_population;

//     // Archive c_vectors one component at a time
//     c_vector<double, 2> point;
//     for (unsigned i=0; i<2; i++)
//     {
//         ar >> point[i];
//     }
//     c_vector<double, 2> normal;
//     for (unsigned i=0; i<2; i++)
//     {
//         ar >> normal[i];
//     }

//     // Invoke inplace constructor to initialise instance
//     ::new(t)StopCreepBoundaryCondition<2, 2>(p_cell_population, point, normal);
// }
// }
// } // namespace ...

#endif /*StopCreepBoundaryCONDITION_HPP_*/
