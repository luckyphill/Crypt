#include "ChasteSerialization.hpp"
#include "ClassIsAbstract.hpp"

#include "AbstractCellPopulation.hpp"
#include "AbstractCellBasedSimulationModifier.hpp"
#include "AbstractCentreBasedCellPopulation.hpp"
#include "AbstractForce.hpp"
#include "PushForce.hpp"

#include "Debug.hpp"

PushForce::PushForce()
	:AbstractForce<2>()
{
}

PushForce::~PushForce()
{

}

void PushForce::SetCell(CellPtr cell)
{
	mpCell = cell;
}

void PushForce::SetForce(c_vector<double, 2> force)
{
	mForce = force;
}

void PushForce::SetForceOffTime(double off_time)
{
	mOffTime = off_time;
}

void PushForce::AddForceContribution(AbstractCellPopulation<2>& rCellPopulation)
{
	AbstractCentreBasedCellPopulation<2>* p_tissue = static_cast<AbstractCentreBasedCellPopulation<2>*>(&rCellPopulation);
	Node<2>* node = p_tissue->GetNodeCorrespondingToCell(mpCell);
	if(SimulationTime::Instance()->GetTime() < mOffTime)
	{
		node->AddAppliedForceContribution(mForce);
	}
	
	c_vector<double, 2> temp_force = node->rGetAppliedForce();
	//PRINT_2_VARIABLES(temp_force[0], temp_force[1]);
}

void PushForce::OutputForceParameters(out_stream& rParamsFile)
{
	AbstractForce::OutputForceParameters(rParamsFile);
}