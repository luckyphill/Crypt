// Standard includes for tests
#include <cxxtest/TestSuite.h>
#include "AbstractCellBasedTestSuite.hpp"
#include "CheckpointArchiveTypes.hpp"
#include "SmartPointers.hpp"
#include "CommandLineArguments.hpp"

// Simulators and output
#include "OffLatticeSimulation.hpp" //Simulates the evolution of the population
#include "OffLatticeSimulationTooManyCells.hpp"

// Forces
#include "GeneralisedLinearSpringForce.hpp"
#include "NormalAdhesionForce.hpp"
#include "BasicNonLinearSpringForce.hpp"
#include "DividingRotationForce.hpp"

#include "NodesOnlyMesh.hpp"

#include "NodeBasedCellPopulation.hpp"

// Proliferative types
#include "DifferentiatedCellProliferativeType.hpp"
#include "TransitCellProliferativeType.hpp"

//Cell cycle models
#include "NoCellCycleModel.hpp"
#include "UniformCellCycleModel.hpp"
#include "UniformContactInhibition.hpp"
#include "WntUniformContactInhibition.hpp"
#include "SimpleWntContactInhibitionCellCycleModel.hpp"

#include "WildTypeCellMutationState.hpp"

// Boundary conditions
#include "BoundaryCellProperty.hpp"
#include "CryptBoundaryCondition.hpp"

// Cell killers
#include "SimpleSloughingCellKiller.hpp"
#include "TopAndBottomSloughing.hpp"
#include "SimpleAnoikisCellKiller.hpp"

//Division Rules
#include "StickToMembraneDivisionRule.hpp"

// Modifiers
#include "VolumeTrackingModifier.hpp"

//Division Rules
#include "StickToMembraneDivisionRule.hpp"

// Wnt Concentration for position tracking
#include "WntConcentration.hpp"

// Misc
#include "FakePetscSetup.hpp"
#include "Debug.hpp"

class TestBasicCylindricalCrypt : public AbstractCellBasedTestSuite
{
	public:

	void Test2DPlane() throw(Exception)
	{
		// This will build a 2D plane of cells, with uniform CCM and correct boundary conditions
		// The purpose of this test is to have a first try at buildong a 2/3D model

		// Standard command line input to control output
		bool java_visualiser = false;
        double sampling_multiple = 100000;
        if(CommandLineArguments::Instance()->OptionExists("-sm"))
        {   
            sampling_multiple = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-sm");
            java_visualiser = true;
        }

        // Simulation parameters
		double dt = 0.01;
		double end_time = 100;

		// Cell population parameters
		unsigned node_counter = 0;
		double maxInteractionRadius = 2.0;
		double top = 20;
		double circumference = 16;
		
		// Cell cycle model parameters
		double minimumCycleTime = 10;

		// Cell population vectors
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> location_indices;

		double x;
		double y;

		// Make a grid top x circumference
		// Not trying to make hexagonal packing at this point
		for (unsigned i = 0; i < top; i++)
		{
			for (unsigned j = 0; j < circumference; j++)
			{
				x = i;
				y = j;
				Node<2>* new_node =  new Node<2>(node_counter,  false,  x, y);
				nodes.push_back(new_node);
				location_indices.push_back(node_counter);
				node_counter++;
			}
		}

		NodesOnlyMesh<3> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, maxInteractionRadius);

		std::vector<CellPtr> cells;

		MAKE_PTR(DifferentiatedCellProliferativeType, p_diff_type);
		MAKE_PTR(TransitCellProliferativeType, p_trans_type);

		// Make the cells and the cell cycle models
		for (unsigned i = 0; i < top; i++)
		{
			for (unsigned j = 0; j < circumference; j++)
			{
				UniformCellCycleModel* p_cycle_model = new UniformCellCycleModel();
				double birth_time = 12 * RandomNumberGenerator::Instance()->ranf();
				p_cycle_model->SetBirthTime(-birth_time);

				CellPtr p_cell(new Cell(p_state, p_cycle_model));
				p_cell->SetCellProliferativeType(p_trans_type);
				p_cell->InitialiseCellCycleModel();

				cells.push_back(p_cell);
			}
		}

		NodeBasedCellPopulation<3> cell_population(mesh, cells, location_indices);




		// A simulator with a stopping even when there are too many cells
		OffLatticeSimulationTooManyCells simulator(cell_population);
		simulator.SetOutputDirectory("Test2DPlane");

		// ********************************************************************************************
        // File outputs
        // Files are only output if the command line argument -sm exists and a sampling multiple is set
        simulator.SetSamplingTimestepMultiple(sampling_multiple);
        cell_population.SetOutputResultsForChasteVisualizer(java_visualiser);
        // ********************************************************************************************

        simulator.SetEndTime(end_time);
		simulator.SetDt(dt);

		// ********************************************************************************************
		// Set force parameters
		MAKE_PTR(BasicNonLinearSpringForce<3>, p_force);
		p_force->SetSpringStiffness(epithelialStiffness);
		p_force->SetRestLength(2 * epithelialPreferredRadius);
		p_force->SetCutOffLength(3 * epithelialPreferredRadius);
		
		p_force->SetMeinekeSpringStiffness(meinekeStiffness);
		p_force->SetMeinekeSpringGrowthDuration(1);

		MAKE_PTR(NormalAdhesionForce<3>, p_adhesion);
        p_adhesion->SetMembraneEpithelialSpringStiffness(membraneEpithelialSpringStiffness);
		
		// ********************************************************************************************
		// These two parameters are inately linked - the initial separation of the daughter nodes
		// and the initial resting spring length
		p_force->SetMeinekeDivisionRestingSpringLength(0.05);
		cell_population.SetMeinekeDivisionSeparation(0.05); // Set how far apart the cells will be upon division
		// ********************************************************************************************

		MAKE_PTR_ARGS(SimpleSloughingCellKiller, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(top);
		simulator.AddCellKiller(p_sloughing_killer);


	};

}