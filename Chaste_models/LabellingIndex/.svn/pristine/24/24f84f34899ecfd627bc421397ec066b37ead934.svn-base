#include "MorphogenCellwiseSourceParabolicPde.hpp"

#include "AbstractCentreBasedCellPopulation.hpp"
#include "VertexBasedCellPopulation.hpp"
#include "PottsBasedCellPopulation.hpp"
#include "CaBasedCellPopulation.hpp"
#include "ApoptoticCellProperty.hpp"
#include "Exception.hpp"
#include "CellLabel.hpp"
#include "Debug.hpp"

template<unsigned DIM>
MorphogenCellwiseSourceParabolicPde<DIM>::MorphogenCellwiseSourceParabolicPde(AbstractCellPopulation<DIM,DIM>& rCellPopulation,
        double duDtCoefficient,
        double diffusionCoefficient,
        double uptakeCoefficient,
        double sourceWidth)
		: CellwiseSourceParabolicPde<DIM>(rCellPopulation,duDtCoefficient, diffusionCoefficient, uptakeCoefficient ),
		  mSourceWidth(sourceWidth)
{
}

template<unsigned DIM>
const AbstractCellPopulation<DIM,DIM>& MorphogenCellwiseSourceParabolicPde<DIM>::rGetCellPopulation() const
{
    return this->mrCellPopulation;
}

template<unsigned DIM>
double MorphogenCellwiseSourceParabolicPde<DIM>::ComputeDuDtCoefficientFunction(const ChastePoint<DIM>& )
{
    return this->mDuDtCoefficient;
}


template<unsigned DIM>
double MorphogenCellwiseSourceParabolicPde<DIM>::ComputeSourceTerm(const ChastePoint<DIM>& rX, double u, Element<DIM,DIM>* pElement)
{
    NEVER_REACHED;
    return 0.0;
}

template<unsigned DIM>
c_matrix<double,DIM,DIM> MorphogenCellwiseSourceParabolicPde<DIM>::ComputeDiffusionTerm(const ChastePoint<DIM>& rX, Element<DIM,DIM>* pElement)
{
    return this->mDiffusionCoefficient*identity_matrix<double>(DIM);
}

template<unsigned DIM>
double MorphogenCellwiseSourceParabolicPde<DIM>::ComputeSourceTermAtNode(const Node<DIM>& rNode, double u)
{
    double coefficient = 0.0;

    double x = rNode.rGetLocation()[0];
    //double y = rNode.rGetLocation()[1];

    //if (x*x+y*y <4)

    if (x>-0.5*mSourceWidth && x<0.5*mSourceWidth)
    {
    	coefficient = this->mUptakeCoefficient;
    }

    double decay_coeficient = 0.01;

    return coefficient - u*decay_coeficient;
}

/////////////////////////////////////////////////////////////////////////////
// Explicit instantiation
/////////////////////////////////////////////////////////////////////////////

template class MorphogenCellwiseSourceParabolicPde<1>;
template class MorphogenCellwiseSourceParabolicPde<2>;
template class MorphogenCellwiseSourceParabolicPde<3>;

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(MorphogenCellwiseSourceParabolicPde)
