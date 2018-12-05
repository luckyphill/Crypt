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

//Division Rules
#include "StickToMembraneDivisionRule.hpp"

#include "PushForceModifier.hpp"
#include "BasicNonLinearSpringForce.hpp"
#include "NormalAdhesionForce.hpp"

// Writers
#include "EpithelialCellDragForceWriter.hpp"
#include "EpithelialCellForceWriter.hpp"

// Misc
#include "FakePetscSetup.hpp"
#include "Debug.hpp"

class TestDrivingForceNormalAdhesion : public AbstractCellBasedTestSuite
{
	public:
	void xTestDrivingForceNormalAdhesionTest() throw(Exception)
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


		bool debugging = false;

	
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> location_indices;
		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned node_counter = 0;

		double dt = 0.001;
		
		double sampling_multiple = 1;

		double maxInteractionRadius = 4.0;


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

		MAKE_PTR(DifferentiatedCellProliferativeType, p_diff_type);
		MAKE_PTR(TransitCellProliferativeType, p_trans_type);
		MAKE_PTR(WildTypeCellMutationState, p_state);
		MAKE_PTR(BoundaryCellProperty, p_boundary);

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

		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);

		OffLatticeSimulation<2> simulator(cell_population);

		std::stringstream out;
        out << "n_" << n << "_EMS_"<< epithelialMembraneStiffness << "_MIR_" << membraneInteractionRadius <<"_MPR_" << membranePreferredRadius;
        out << "_EES_"<< epithelialStiffness << "_EIR_" << epithelialInteractionRadius <<"_EPR_" << epithelialPreferredRadius << "_YF_" << y_force;
        std::string output_directory = "TestDrivingForceNormalAdhesion/" +  out.str();

		simulator.SetOutputDirectory(output_directory);

		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(NormalAdhesionForce<2>, p_force);
		// For this force calculator, epithelial means anything not membrane
		p_force->SetMembraneEpithelialSpringStiffness(epithelialMembraneStiffness);

		p_force->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		p_force->SetMembranePreferredRadius(membranePreferredRadius);

		simulator.AddForce(p_force);

		MAKE_PTR(LinearSpringForceMembraneCellNodeBased<2>, p_force_2);
		p_force_2->SetEpithelialSpringStiffness(epithelialStiffness);
		p_force_2->SetStromalSpringStiffness(epithelialStiffness);

		p_force_2->SetStromalEpithelialSpringStiffness(epithelialStiffness);

		p_force_2->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		p_force_2->SetStromalPreferredRadius(epithelialPreferredRadius);
		p_force_2->SetMembranePreferredRadius(membranePreferredRadius);

		p_force_2->SetEpithelialInteractionRadius(epithelialInteractionRadius);
		p_force_2->SetStromalInteractionRadius(epithelialInteractionRadius);
		
		p_force_2->SetMeinekeSpringGrowthDuration(1);
		p_force_2->SetMeinekeDivisionRestingSpringLength(0.1);

		simulator.AddForce(p_force_2);


		MAKE_PTR(PushForce, p_push_force);
		p_push_force->SetCell(p_cell);
		c_vector<double, 2> force;
		force[0] = x_force;
		force[1] = y_force;
		p_push_force->SetForce(force);
		p_push_force->SetForceOffTime(end_time);
		simulator.AddForce(p_push_force);

		cell_population.AddCellWriter<EpithelialCellForceWriter>();

		simulator.Solve();

		Node<2>* p_node =  cell_population.GetNodeCorrespondingToCell(p_cell); // Driving cell
		c_vector<double, 2> driving_cell_position = p_node->rGetLocation();

		//PRINT_VARIABLE(driving_cell_position[1])


	};


	void TestDrivingForceDivision() throw(Exception)
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


		bool debugging = false;

	
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> location_indices;
		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned node_counter = 0;

		double dt = 0.001;
		
		double sampling_multiple = 1;

		double maxInteractionRadius = 4.0;


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

		MAKE_PTR(DifferentiatedCellProliferativeType, p_diff_type);
		MAKE_PTR(TransitCellProliferativeType, p_trans_type);
		MAKE_PTR(WildTypeCellMutationState, p_state);
		MAKE_PTR(BoundaryCellProperty, p_boundary);

		// Make the single cell

		UniformCellCycleModel* p_cycle_model = new UniformCellCycleModel();

		CellPtr p_cell(new Cell(p_state, p_cycle_model));
		p_cell->SetCellProliferativeType(p_diff_type);

		cells.push_back(p_cell);
		// Add any additional static cells
		CellPtr p_cell_other;
		if(multiple_cells)
		{
			for(unsigned i=1; i<=n; i++)
			{
				UniformCellCycleModel* p_cycle_model_2 = new UniformCellCycleModel();
				double birth_time = 10 * RandomNumberGenerator::Instance()->ranf();
				p_cycle_model_2->SetBirthTime(-birth_time);
				p_cycle_model_2->SetMinCellCycleDuration(10);
				CellPtr p_cell_2(new Cell(p_state, p_cycle_model_2));
				p_cell_2->SetCellProliferativeType(p_trans_type);

				cells.push_back(p_cell_2);
				p_cell_other = p_cell_2;
			}
		}

		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);

		{ //Division vector rules
			c_vector<double, 2> membraneAxis;
			membraneAxis(0) = 0;
			membraneAxis(1) = 1;

			MAKE_PTR(StickToMembraneDivisionRule<2>, pCentreBasedDivisionRule);
			pCentreBasedDivisionRule->SetMembraneAxis(membraneAxis);
			cell_population.SetCentreBasedDivisionRule(pCentreBasedDivisionRule);
		}

		OffLatticeSimulation<2> simulator(cell_population);

		std::stringstream out;
        out << "n_" << n << "_EMS_"<< epithelialMembraneStiffness << "_MIR_" << membraneInteractionRadius <<"_MPR_" << membranePreferredRadius;
        out << "_EES_"<< epithelialStiffness << "_EIR_" << epithelialInteractionRadius <<"_EPR_" << epithelialPreferredRadius << "_YF_" << y_force;
        std::string output_directory = "TestDrivingForceNormalAdhesion/" +  out.str();

		simulator.SetOutputDirectory(output_directory);

		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(NormalAdhesionForce<2>, p_force);
		// For this force calculator, epithelial means anything not membrane
		p_force->SetMembraneEpithelialSpringStiffness(epithelialMembraneStiffness);

		p_force->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		p_force->SetMembranePreferredRadius(membranePreferredRadius);

		simulator.AddForce(p_force);

		MAKE_PTR(LinearSpringForceMembraneCellNodeBased<2>, p_force_2);
		p_force_2->SetEpithelialSpringStiffness(epithelialStiffness);
		p_force_2->SetStromalSpringStiffness(epithelialStiffness);

		p_force_2->SetStromalEpithelialSpringStiffness(epithelialStiffness);

		p_force_2->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		p_force_2->SetStromalPreferredRadius(epithelialPreferredRadius);
		p_force_2->SetMembranePreferredRadius(membranePreferredRadius);

		p_force_2->SetEpithelialInteractionRadius(epithelialInteractionRadius);
		p_force_2->SetStromalInteractionRadius(epithelialInteractionRadius);
		
		p_force_2->SetMeinekeSpringGrowthDuration(1);
		p_force_2->SetMeinekeDivisionRestingSpringLength(0.1);

		simulator.AddForce(p_force_2);


		MAKE_PTR(PushForce, p_push_force);
		p_push_force->SetCell(p_cell);
		c_vector<double, 2> force;
		force[0] = x_force;
		force[1] = y_force;
		p_push_force->SetForce(force);
		p_push_force->SetForceOffTime(end_time);
		simulator.AddForce(p_push_force);

		cell_population.AddCellWriter<EpithelialCellForceWriter>();

		simulator.Solve();

		Node<2>* p_node =  cell_population.GetNodeCorrespondingToCell(p_cell); // Driving cell
		c_vector<double, 2> driving_cell_position = p_node->rGetLocation();

		//PRINT_VARIABLE(driving_cell_position[1])


	};
};
