#include "ChasteSerialization.hpp"
#include "ClassIsAbstract.hpp"

#include "AbstractCellPopulation.hpp"
#include "AbstractCellBasedSimulationModifier.hpp"
#include "AbstractCentreBasedCellPopulation.hpp"
#include "PushForceModifier.hpp"

#include "Debug.hpp"


PushForceModifier::PushForceModifier()
	:AbstractCellBasedSimulationModifier<2>()
{
}

PushForceModifier::~PushForceModifier()
{

}


void PushForceModifier::UpdateAtEndOfTimeStep(AbstractCellPopulation<2>& rCellPopulation)
{
	ApplyForce(rCellPopulation);
}

void PushForceModifier::SetupSolve(AbstractCellPopulation<2>& rCellPopulation, std::string outputDirectory)
{
	ApplyForce(rCellPopulation);
}

void PushForceModifier::OutputSimulationModifierParameters(out_stream& rParamsFile)
{
	AbstractCellBasedSimulationModifier<2>::OutputSimulationModifierParameters(rParamsFile);
}

void PushForceModifier::SetNode(Node<2>* node)
{
	mpNode = node;
}

void PushForceModifier::SetCell(CellPtr cell)
{
	mpCell = cell;
}

void PushForceModifier::SetForce(c_vector<double, 2> force)
{
	mForce = force;
}

void PushForceModifier::ApplyForce(AbstractCellPopulation<2>& rCellPopulation)
{
	TRACE("Modifier works");
	AbstractCentreBasedCellPopulation<2>* p_tissue = static_cast<AbstractCentreBasedCellPopulation<2>*>(&rCellPopulation);
	Node<2>* node = p_tissue->GetNodeCorrespondingToCell(mpCell);
	c_vector<double, 2> temp_force = node->rGetAppliedForce();
	PRINT_2_VARIABLES(temp_force[0], temp_force[1]);
	
	// //Node<2>* node = rCellPopulation.GetNodeCorrespondingToCell(mpCell);
	// node->AddAppliedForceContribution(mForce);
	// PRINT_VARIABLE(mpNode->GetIndex());
	// temp_force = node->rGetAppliedForce();
	// PRINT_2_VARIABLES(temp_force[0], temp_force[1]);
}

// #include "SerializationExportWrapperForCpp.hpp"
// EXPORT_TEMPLATE_CLASS_SAME_DIMS(PushForceModifier)