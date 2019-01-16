// Standard includes for tests
#include <cxxtest/TestSuite.h>
#include "AbstractCellBasedTestSuite.hpp"
#include "CheckpointArchiveTypes.hpp"
#include "SmartPointers.hpp"
#include "CommandLineArguments.hpp"

// Simulators and output
#include "OffLatticeSimulation.hpp" //Simulates the evolution of the population
// #include "OffLatticeSimulation.hpp"

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
#include "UniformParentTrackingCellCycleModel.hpp"

#include "WildTypeCellMutationState.hpp"

// Boundary conditions
// #include "BoundaryCellProperty.hpp"
// #include "CryptBoundaryCondition.hpp"

// Cell killers
#include "SimpleSloughingCellKiller.hpp"
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
		double dt = 0.005;
		double end_time = 100;

		// Cell population parameters
		unsigned node_counter = 0;
		double maxInteractionRadius = 0.8;
		double top = 10;
		double circumference = 8;
		double maxPopUpDistance = 1.0;
		
		// Cell population vectors
		std::vector<Node<3>*> nodes;
		std::vector<unsigned> location_indices;

		// Force parameters
		double epithelialPreferredRadius = 0.5;
		double epithelialStiffness = 25;
		double membraneEpithelialSpringStiffness = 10;
        if(CommandLineArguments::Instance()->OptionExists("-ms"))
        {
        	membraneEpithelialSpringStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ms");
        }
        if(CommandLineArguments::Instance()->OptionExists("-ees"))
        {
        	epithelialStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ees");
        }
        double meinekeStiffness = epithelialStiffness;

		double x;
		double y;
		double z;

		// Make a grid top x circumference
		// Not trying to make hexagonal packing at this point
		for (unsigned i = 0; i < circumference; i++)
		{
			for (unsigned j = 0; j < top; j++)
			{
				x = i;
				y = j;
				z = 0.3 + 0.6 * RandomNumberGenerator::Instance()->ranf();
				Node<3>* new_node =  new Node<3>(node_counter,  false,  x, y, z);
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
		MAKE_PTR(WildTypeCellMutationState, p_state);

		// Make the cells and the cell cycle models
		for (unsigned i = 0; i < top; i++)
		{
			for (unsigned j = 0; j < circumference; j++)
			{
				UniformParentTrackingCellCycleModel* p_cycle_model = new UniformParentTrackingCellCycleModel();
				// UniformCellCycleModel* p_cycle_model = new UniformCellCycleModel();
				double birth_time = 2 + 10 * RandomNumberGenerator::Instance()->ranf();
				p_cycle_model->SetBirthTime(-birth_time);

				CellPtr p_cell(new Cell(p_state, p_cycle_model));
				p_cell->SetCellProliferativeType(p_trans_type);
				p_cell->InitialiseCellCycleModel();

				cells.push_back(p_cell);
			}
		}

		NodeBasedCellPopulation<3> cell_population(mesh, cells, location_indices);
		
		{ //Division vector rules
			c_vector<double, 3> membraneAxis;
			membraneAxis(0) = 0;
			membraneAxis(1) = 1;
			membraneAxis(2) = 0;

			MAKE_PTR(StickToMembraneDivisionRule<3>, pCentreBasedDivisionRule);
			pCentreBasedDivisionRule->SetMembraneAxis(membraneAxis);
			pCentreBasedDivisionRule->SetWiggleDivision(true);

			cell_population.SetCentreBasedDivisionRule(pCentreBasedDivisionRule);

		}

		OffLatticeSimulation<3> simulator(cell_population);
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
		
		simulator.AddForce(p_force);
		simulator.AddForce(p_adhesion);

		// ********************************************************************************************
		// These two parameters are inately linked - the initial separation of the daughter nodes
		// and the initial resting spring length
		p_force->SetMeinekeDivisionRestingSpringLength(0.05);
		cell_population.SetMeinekeDivisionSeparation(0.05); // Set how far apart the cells will be upon division
		// ********************************************************************************************

		MAKE_PTR_ARGS(SimpleSloughingCellKiller<3>, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(top);
		simulator.AddCellKiller(p_sloughing_killer);

		MAKE_PTR_ARGS(SimpleAnoikisCellKiller<3>, p_anoikis_killer, (&cell_population));
		p_anoikis_killer->SetPopUpDistance(maxPopUpDistance);
		simulator.AddCellKiller(p_anoikis_killer);

		simulator.Solve();


	};

};