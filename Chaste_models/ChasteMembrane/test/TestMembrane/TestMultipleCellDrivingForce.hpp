// Standard includes for tests
#include <cxxtest/TestSuite.h>
#include "AbstractCellBasedTestSuite.hpp"
#include "CheckpointArchiveTypes.hpp"
#include "SmartPointers.hpp"
#include "CommandLineArguments.hpp"

// Simulators and output
#include "OffLatticeSimulation.hpp" //Simulates the evolution of the population
#include "OffLatticeSimulationTearOffStoppingEvent.hpp"

#include "LinearSpringForcePhaseBased.hpp"
#include "LinearSpringForceMembraneCellNodeBased.hpp"
#include "PushForce.hpp"

#include "HoneycombMeshGenerator.hpp" //Generates mesh
#include "NodesOnlyMesh.hpp"
#include "CellsGenerator.hpp"

#include "NodeBasedCellPopulation.hpp"

// Proliferative types
#include "MembraneCellProliferativeType.hpp"
#include "DifferentiatedCellProliferativeType.hpp"
#include "TransitCellProliferativeType.hpp"
#include "StemCellProliferativeType.hpp"

//Cell cycle models
#include "NoCellCycleModel.hpp"
#include "UniformCellCycleModel.hpp"
#include "GrowingContactInhibitionPhaseBasedCCM.hpp"

#include "WildTypeCellMutationState.hpp"

// Boundary conditions
#include "BoundaryCellProperty.hpp"
#include "CryptBoundaryCondition.hpp"

#include "SimpleSloughingCellKiller.hpp"
#include "AnoikisCellKiller.hpp"

//Division Rules
#include "StickToMembraneDivisionRule.hpp"

// Modifiers
#include "VolumeTrackingModifier.hpp"

#include "PushForceModifier.hpp"
#include "BasicNonLinearSpringForce.hpp"

// Writers
#include "EpithelialCellDragForceWriter.hpp"
#include "EpithelialCellForceWriter.hpp"

// Misc
#include "FakePetscSetup.hpp"
#include "Debug.hpp"

class TestMultipleCellDrivingForce : public AbstractCellBasedTestSuite
{
	public:
	void TestMultipleCellDrivingForceTest() throw(Exception)
	{
		// This test can be used to observe how a cell interacts with the membrane layer
		// You can add a force to the cell to see how it moves along the wall
		// You can change how far it starts from the wall to see how it is pulled in

		// Specifically, this test outputs the cell velocity data of all the cells on the membrane
		// given a driving force on the bottom most cell


		TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-x"));
        double x_distance = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-x");

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-y"));
        double y_distance = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-y");

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-yf"));
        double y_force = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-yf");

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-xf"));
        double x_force = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-xf");

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-ms"));
        double membrane_spacing = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ms"); // Distance between membrane nodes

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-ems"));
        double epithelialMembraneStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ems"); // The only spring stiffness to worry about

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-ees"));
        double epithelialStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ees");

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-mir"));
        double membraneInteractionRadius = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-mir"); // The furthest that a membrane node can detect the epithelial cell

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-eir"));
        double epithelialInteractionRadius = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-eir");

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-mpr"));
        double membranePreferredRadius = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-mpr");

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-epr"));
        double epithelialPreferredRadius = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-epr");


        bool multiple_cells = true;
        unsigned n = 1;
        if(CommandLineArguments::Instance()->OptionExists("-n"))
        {	
        	multiple_cells = true;
        	n = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-n");

        }

        double end_time = 5;
        if(CommandLineArguments::Instance()->OptionExists("-t"))
        {	
        	end_time = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-t");

        }

        double wall_height = 21;
        if(CommandLineArguments::Instance()->OptionExists("-wh"))
        {	
        	wall_height = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-wh");

        }

		bool debugging = false;

	
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> membrane_nodes;
		std::vector<unsigned> location_indices;
		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned node_counter = 0;

		double dt = 0.001;
		
		double sampling_multiple = 1;

		// Values that produce a working simulation in the comments
		double membraneStiffness = 5.0; 			// 5.0

		double maxInteractionRadius = 4.0;


		double springGrowthDuration = 1.0;

		//double wall_height = 21;
		double left_side = 0;
		double wall_top = wall_height;
		double wall_bottom = 0;

		// Drawing the membrane
		for (double y = wall_bottom; y <= wall_top; y+=membrane_spacing)
		{
			double x = left_side;
			nodes.push_back(new Node<2>(node_counter,  false,  x, y));
			membrane_nodes.push_back(node_counter);
			location_indices.push_back(node_counter);
			node_counter++;
		}

		// Placing a single cell on the wall
		
		double x = x_distance;
		double y = y_distance;
		Node<2>* single_node =  new Node<2>(node_counter,  false,  x, y);
		nodes.push_back(single_node);
		transit_nodes.push_back(node_counter);
		location_indices.push_back(node_counter);
		node_counter++;

		if(multiple_cells)
		{
			for(unsigned i=1; i<=n; i++)
			{
				x = x_distance;
				y = y_distance + 2 * i * epithelialPreferredRadius;
				Node<2>* single_node_2 =  new Node<2>(node_counter,  false,  x, y);
				nodes.push_back(single_node_2);
				transit_nodes.push_back(node_counter);
				location_indices.push_back(node_counter);
				node_counter++;
			}
			
		}
		

		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, maxInteractionRadius);

		std::vector<CellPtr> cells;
		std::vector<CellPtr> membrane_cells;

		MAKE_PTR(MembraneCellProliferativeType, p_membrane_type);
		MAKE_PTR(DifferentiatedCellProliferativeType, p_diff_type);
		MAKE_PTR(TransitCellProliferativeType, p_trans_type);
		MAKE_PTR(WildTypeCellMutationState, p_state);
		MAKE_PTR(BoundaryCellProperty, p_boundary);

		//Initialise membrane nodes
		for (unsigned i = 0; i < membrane_nodes.size(); i++)
		{
			NoCellCycleModel* p_cycle_model = new NoCellCycleModel();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_membrane_type);
			
			p_cell->AddCellProperty(p_boundary);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
			membrane_cells.push_back(p_cell);
		}
		
		// Make the single cell

		NoCellCycleModel* p_cycle_model = new NoCellCycleModel();

		CellPtr p_cell(new Cell(p_state, p_cycle_model));
		p_cell->SetCellProliferativeType(p_diff_type);

		cells.push_back(p_cell);
		// Add any additional static cells
		CellPtr p_cell_other;
		if(multiple_cells)
		{
			for(unsigned i=1; i<=n; i++)
			{
				CellPtr p_cell_2(new Cell(p_state, p_cycle_model));
				p_cell_2->SetCellProliferativeType(p_diff_type);

				cells.push_back(p_cell_2);
				p_cell_other = p_cell_2;
			}
		}

		membraneSections.push_back(membrane_cells);

		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);

		OffLatticeSimulation<2> simulator(cell_population);

		std::stringstream out;
        out << "n_" << n << "_MS_" << membrane_spacing << "_EMS_"<< epithelialMembraneStiffness << "_MIR_" << membraneInteractionRadius <<"_MPR_" << membranePreferredRadius;
        out << "_EES_"<< epithelialStiffness << "_EIR_" << epithelialInteractionRadius <<"_EPR_" << epithelialPreferredRadius << "_YF_" << y_force;
        std::string output_directory = "TestMultipleCellDrivingForce/" +  out.str();

		simulator.SetOutputDirectory(output_directory);

		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(LinearSpringForceMembraneCellNodeBased<2>, p_force);
		p_force->SetEpithelialSpringStiffness(epithelialStiffness);
		p_force->SetStromalSpringStiffness(epithelialStiffness);
		p_force->SetMembraneSpringStiffness(membraneStiffness);
		
		p_force->SetEpithelialMembraneSpringStiffness(epithelialMembraneStiffness);
		p_force->SetMembraneStromalSpringStiffness(epithelialMembraneStiffness);
		p_force->SetStromalEpithelialSpringStiffness(epithelialStiffness);

		p_force->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		p_force->SetStromalPreferredRadius(epithelialPreferredRadius);
		p_force->SetMembranePreferredRadius(membranePreferredRadius);

		p_force->SetEpithelialInteractionRadius(epithelialInteractionRadius);
		p_force->SetStromalInteractionRadius(epithelialInteractionRadius);
		p_force->SetMembraneInteractionRadius(membraneInteractionRadius);
		
		p_force->SetMeinekeSpringGrowthDuration(springGrowthDuration);
		p_force->SetMeinekeDivisionRestingSpringLength(0.1);

		p_force->SetDebugMode(debugging);

		simulator.AddForce(p_force);

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		MAKE_PTR(PushForce, p_push_force);
		p_push_force->SetCell(p_cell);
		c_vector<double, 2> force;
		force[0] = x_force;
		force[1] = y_force;
		p_push_force->SetForce(force);
		p_push_force->SetForceOffTime(end_time);
		simulator.AddForce(p_push_force);

		cell_population.AddCellWriter<EpithelialCellForceWriter>();

		Node<2>* p_node =  cell_population.GetNodeCorrespondingToCell(p_cell); // Driving cell
		c_vector<double, 2> driving_cell_position = p_node->rGetLocation();

		Node<2>* p_node_2 =  cell_population.GetNodeCorrespondingToCell(p_cell_other); // Topmost cell
		c_vector<double, 2> top_cell_position = p_node_2->rGetLocation();

		simulator.Solve();


	};
};
