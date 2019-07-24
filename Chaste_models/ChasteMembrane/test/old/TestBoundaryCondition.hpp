// Standard includes for tests
#include <cxxtest/TestSuite.h>
#include "AbstractCellBasedTestSuite.hpp"
#include "CheckpointArchiveTypes.hpp"
#include "SmartPointers.hpp"
#include "CommandLineArguments.hpp"

#include "SimpleWntContactInhibitionCellCycleModel.hpp"
#include "NodeBasedCellPopulation.hpp"
#include "NodesOnlyMesh.hpp"
#include "OffLatticeSimulation.hpp" //Simulates the evolution of the population
#include "StickToMembraneDivisionRule.hpp"
#include "TransitCellProliferativeType.hpp"
#include "WildTypeCellMutationState.hpp"
#include "WntConcentration.hpp"

// Forces
#include "DividingRotationForce.hpp"
#include "BasicNonLinearSpringForceMultiNodeFix.hpp"

// Cell Cycle Models
#include "SimplifiedPhaseBasedCellCycleModel.hpp"
#include "SimplifiedCellCyclePhases.hpp"

// Boundary Condition
#include "DividingPopUpBoundaryCondition.hpp"

// Modifiers
#include "VolumeTrackingModifier.hpp"

// Misc
#include "FakePetscSetup.hpp"
#include "Debug.hpp"


class TestBoundaryCondition : public AbstractCellBasedTestSuite
{
	public:
	void TestDividingPopUpBoundaryCondition() throw(Exception)
	{
		

		std::vector<Node<2>*> nodes;

		Node<2>* node1 =  new Node<2>(0,  false,  0, 0);
		Node<2>* node2 =  new Node<2>(1,  false,  1, 0.2);
		nodes.push_back(node1);
		nodes.push_back(node2);

		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, 2);

		std::vector<CellPtr> cells;


		MAKE_PTR(TransitCellProliferativeType, p_trans_type);
		MAKE_PTR(WildTypeCellMutationState, p_state);
		
		for (unsigned i = 0; i <2; i++)
		{
			SimplifiedPhaseBasedCellCycleModel* p_cycle_model = new SimplifiedPhaseBasedCellCycleModel();

			p_cycle_model->SetWDuration(10);
			p_cycle_model->SetBasePDuration(5);
			p_cycle_model->SetDimension(2);
			p_cycle_model->SetEquilibriumVolume(2);
			p_cycle_model->SetQuiescentVolumeFraction(0.8);
			p_cycle_model->SetWntThreshold(0.5);

			p_cycle_model->SetBirthTime(-4);
			p_cycle_model->SetBasePDuration(10);

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);
			p_cell->InitialiseCellCycleModel();
			p_cell->GetCellData()->SetItem("volume", 0.7);

			p_cycle_model->Initialise();

			cells.push_back(p_cell);
		}




		NodeBasedCellPopulation<2> cell_population(mesh, cells);
		cell_population.SetMeinekeDivisionSeparation(0.05); // Set how far apart the cells will be upon division

		for (unsigned i = 0; i <2; i++)
		{
			CellPtr cellA = cell_population.GetCellUsingLocationIndex(i);
			cellA->GetCellData()->SetItem("parent", 1);
			cellA->GetCellData()->SetItem("volume", 0.7);
		}

		WntConcentration<2>::Instance()->SetType(LINEAR);
        WntConcentration<2>::Instance()->SetCellPopulation(cell_population);
        WntConcentration<2>::Instance()->SetCryptLength(10);

        OffLatticeSimulation<2> simulator(cell_population);
        simulator.SetOutputDirectory("TestBoundaryCondition");
        simulator.SetSamplingTimestepMultiple(1);
        simulator.SetEndTime(0.002);
        simulator.SetDt(0.002);

        MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

		simulator.Solve();

		MAKE_PTR_ARGS(DividingPopUpBoundaryCondition, p_dbc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_dbc);

		simulator.SetEndTime(0.004);
		simulator.Solve();

		MeshBasedCellPopulation<2,2>* p_tissue = static_cast<MeshBasedCellPopulation<2,2>*>(&simulator.rGetCellPopulation());
		std::list<CellPtr> newcells =  p_tissue->rGetCells();
		for (std::list<CellPtr>::iterator cell_iter = newcells.begin(); cell_iter!= newcells.end(); ++cell_iter)
		{
			c_vector<double, 2> location = p_tissue->GetLocationOfCellCentre(*cell_iter);
			assert(location[0]==0.95);
			PRINT_2_VARIABLES(location[0], location[1]);
		}

		WntConcentration<2>::Instance()->Destroy();

	};
};