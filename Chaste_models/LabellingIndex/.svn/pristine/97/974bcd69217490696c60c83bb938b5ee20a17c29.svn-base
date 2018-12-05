#ifndef CELLWISESOURCEMORPHOGENPDE_HPP_
#define CELLWISESOURCEMORPHOGENPDE_HPP_

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>


#include "CellwiseSourceParabolicPde.hpp"

/**
 *  A PDE which has a source at each labelled non-apoptotic cell.
 *
 *  Modified from CellwiseSourceParabolicPde so only labelled cells have a source
 *
 */
template<unsigned DIM>
class MorphogenCellwiseSourceParabolicPde : public CellwiseSourceParabolicPde<DIM>
{

private:
    /*
     * Stores how side the central region of source cells is.
     */
    double mSourceWidth;

    /** Needed for serialization.*/
    friend class boost::serialization::access;
    /**
     * Serialize the PDE and its member variables.
     *
     * @param archive the archive
     * @param version the current version of this class
     */
    template<class Archive>
    void serialize(Archive & archive, const unsigned int version)
    {
       archive & boost::serialization::base_object<CellwiseSourceParabolicPde<DIM> >(*this);
       archive & mSourceWidth;
    }

public:

    /**
	 * Constructor.
	 *
	 * @param rCellPopulation reference to the cell population
	 * @param duDtCoefficient rate of reaction (defaults to 1.0)
	 * @param diffusionCoefficient rate of diffusion (defaults to 1.0)
	 * @param uptakeCoefficient the coefficient of consumption of nutrient by cells (defaults to 0.0)
	 * @param sourceWidth the width of the source of morphgen in the centte of the mesh (defaults to 1.0)
	 */
    MorphogenCellwiseSourceParabolicPde(AbstractCellPopulation<DIM, DIM>& rCellPopulation,
                                   double duDtCoefficient = 1.0,
                                   double diffusionCoefficient = 1.0,
                                   double uptakeCoefficient = 0.0,
                                   double sourceWidth = 2.0);

    /**
         * @return const reference to the cell population (used in archiving).
         */
        const AbstractCellPopulation<DIM>& rGetCellPopulation() const;


    /**
	 * Overridden ComputeDuDtCoefficientFunction() method
	 *
	 * @return the function c(x) in "c(x) du/dt = Grad.(DiffusionTerm(x)*Grad(u))+LinearSourceTerm(x)+NonlinearSourceTerm(x, u)"
	 *
	 * @param rX the point in space at which the function c is computed
	 */
	virtual double ComputeDuDtCoefficientFunction(const ChastePoint<DIM>& rX);

	/**
	 * Overridden ComputeSourceTerm() method.
	 *
	 * @return computed source term.
	 *
	 * @param rX the point in space at which the nonlinear source term is computed
	 * @param u the value of the dependent variable at the point
	 */
	virtual double ComputeSourceTerm(const ChastePoint<DIM>& rX,
									 double u,
									 Element<DIM,DIM>* pElement=NULL);


	/**
	 * Overridden ComputeSourceTermAtNode() method.
	 *
	 * @return computed source term at a node.
	 *
	 * @param rNode the node at which the nonlinear source term is computed
	 * @param u the value of the dependent variable at the node
	 */
	virtual double ComputeSourceTermAtNode(const Node<DIM>& rNode, double u);

	/**
	 * Overridden ComputeDiffusionTerm() method.
	 *
	 * @param rX The point in space at which the diffusion term is computed
	 * @param pElement The mesh element that x is contained in (optional).
	 *
	 * @return a matrix.
	 */
	virtual c_matrix<double,DIM,DIM> ComputeDiffusionTerm(const ChastePoint<DIM>& rX, Element<DIM,DIM>* pElement=NULL);

};

#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(MorphogenCellwiseSourceParabolicPde)

namespace boost
{
namespace serialization
{
/**
 * Serialize information required to construct a MorphogenCellwiseSourceParabolicPde.
 */
template<class Archive, unsigned DIM>
inline void save_construct_data(
    Archive & ar, const MorphogenCellwiseSourceParabolicPde<DIM>* t, const unsigned int file_version)
{
    // Save data required to construct instance
    const AbstractCellPopulation<DIM, DIM>* p_cell_population = &(t->rGetCellPopulation());
    ar & p_cell_population;
}

/**
 * De-serialize constructor parameters and initialise a MorphogenCellwiseSourceParabolicPde.
 */
template<class Archive, unsigned DIM>
inline void load_construct_data(
    Archive & ar, MorphogenCellwiseSourceParabolicPde<DIM>* t, const unsigned int file_version)
{
    // Retrieve data from archive required to construct new instance
    AbstractCellPopulation<DIM, DIM>* p_cell_population;
    ar >> p_cell_population;

    // Invoke inplace constructor to initialise instance
    ::new(t)MorphogenCellwiseSourceParabolicPde<DIM>(*p_cell_population);
}
}
} // namespace ...

#endif /*CELLWISESOURCEMORPHOGENPDE_HPP_*/
