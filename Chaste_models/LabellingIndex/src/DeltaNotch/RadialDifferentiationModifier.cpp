#include "RadialDifferentiationModifier.hpp"
#include "DifferentiatedCellProliferativeType.hpp"

template<unsigned DIM>
RadialDifferentiationModifier<DIM>::RadialDifferentiationModifier()
    : AbstractCellBasedSimulationModifier<DIM>(),
      mRadius(DOUBLE_UNSET)
{
}

template<unsigned DIM>
RadialDifferentiationModifier<DIM>::~RadialDifferentiationModifier()
{
}

template<unsigned DIM>
void RadialDifferentiationModifier<DIM>::UpdateAtEndOfTimeStep(AbstractCellPopulation<DIM,DIM>& rCellPopulation)
{
    DifferentiateCells(rCellPopulation);
}

template<unsigned DIM>
void RadialDifferentiationModifier<DIM>::SetupSolve(AbstractCellPopulation<DIM,DIM>& rCellPopulation, std::string outputDirectory)
{
    DifferentiateCells(rCellPopulation);
}

template<unsigned DIM>
void RadialDifferentiationModifier<DIM>::DifferentiateCells(AbstractCellPopulation<DIM,DIM>& rCellPopulation)
{
    assert(mRadius!=DOUBLE_UNSET);

    // Iterate over cell population
    for (typename AbstractCellPopulation<DIM>::Iterator cell_iter = rCellPopulation.Begin();
         cell_iter != rCellPopulation.End();
         ++cell_iter)
    {
        // Get distance from centre of cell population
        double r = norm_2(rCellPopulation.GetLocationOfCellCentre(*cell_iter));

        if (r > mRadius)
        {
            boost::shared_ptr<AbstractCellProperty> p_diff_type =
                    cell_iter->rGetCellPropertyCollection().GetCellPropertyRegistry()->template Get<DifferentiatedCellProliferativeType>();
            cell_iter->SetCellProliferativeType(p_diff_type);
        }
    }
}

template<unsigned DIM>
double RadialDifferentiationModifier<DIM>::GetRadius()
{
    return mRadius;
}

template<unsigned DIM>
void RadialDifferentiationModifier<DIM>::SetRadius(double radius)
{
    mRadius = radius;
}

template<unsigned DIM>
void RadialDifferentiationModifier<DIM>::OutputSimulationModifierParameters(out_stream& rParamsFile)
{
    *rParamsFile << "\t\t\t<mRadius>" << mRadius << "</mRadius>\n";

    // Call method on direct parent class
    AbstractCellBasedSimulationModifier<DIM>::OutputSimulationModifierParameters(rParamsFile);
}

// Explicit instantiation
template class RadialDifferentiationModifier<1>;
template class RadialDifferentiationModifier<2>;
template class RadialDifferentiationModifier<3>;

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(RadialDifferentiationModifier)

