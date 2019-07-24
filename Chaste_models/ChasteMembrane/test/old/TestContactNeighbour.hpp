// Standard includes for tests
#include <cxxtest/TestSuite.h>
#include "AbstractCellBasedTestSuite.hpp"
#include "CheckpointArchiveTypes.hpp"
#include "SmartPointers.hpp"
#include "CommandLineArguments.hpp"

// Simulators and output
#include "OffLatticeSimulation.hpp" //Simulates the evolution of the population

#include "LinearSpringForceMembraneCellNodeBased.hpp"

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
#include "WntUniformCellCycleModel.hpp"
#include "WntCellCycleModelMembraneCell.hpp"

#include "WildTypeCellMutationState.hpp"

// Boundary conditions
#include "BoundaryCellProperty.hpp"
#include "CryptBoundaryCondition.hpp"

#include "SimpleSloughingCellKiller.hpp"
#include "AnoikisCellKiller.hpp"

//Division Rules
#include "StickToMembraneDivisionRule.hpp"

// Misc
#include "FakePetscSetup.hpp"
#include "Debug.hpp"

class TestContactNeighbour : public AbstractCellBasedTestSuite
{
	public:
	void xTestContactNeighbours2DWithDivision() throw(Exception)
	{
		std::vector<Node<2>*> nodes;

		double dt = 0.05;
		double end_time = 20;
		double sampling_multiple = 1;

		double epithelialStiffness = 2.0; 			// 1.5

		double epithelialPreferredRadius = 0.7;			// 1.0

		double epithelialInteractionRadius = 1.5 * epithelialPreferredRadius; // Epithelial covers stem and transit

		HoneycombMeshGenerator generator(4,4);
        MutableMesh<2,2>* p_generating_mesh = generator.GetMesh();

        NodesOnlyMesh<2> mesh;
        mesh.ConstructNodesWithoutMesh(*p_generating_mesh, 1.5);

        std::vector<CellPtr> cells;
        MAKE_PTR(TransitCellProliferativeType, p_transit_type);
        CellsGenerator<UniformCellCycleModel, 2> cells_generator;
        cells_generator.GenerateBasicRandom(cells, mesh.GetNumNodes(), p_transit_type);

        NodeBasedCellPopulation<2> cell_population(mesh, cells);

        OffLatticeSimulation<2> simulator(cell_population);
        simulator.SetOutputDirectory("TestContactNeighbours2D");
        simulator.SetSamplingTimestepMultiple(sampling_multiple);
        simulator.SetEndTime(end_time);
        simulator.SetDt(dt);

        MAKE_PTR(LinearSpringForceMembraneCellNodeBased<2>, p_force);
		p_force->SetEpithelialSpringStiffness(epithelialStiffness);

		p_force->SetEpithelialPreferredRadius(epithelialPreferredRadius);

		p_force->SetEpithelialInteractionRadius(epithelialInteractionRadius);

		p_force->SetMeinekeSpringGrowthDuration(1);
		p_force->SetMeinekeDivisionRestingSpringLength(0.1);

		p_force->SetDebugMode(true);

        simulator.AddForce(p_force);

        simulator.Solve();
	};

	void xTestContactNeighboursWithMembrane() throw(Exception)
	{

		TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-wh"));
        double wh = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-wh");


		bool debugging = false;

        double epithelialStiffness = 10;
		
        double epithelialMembraneStiffness = 5.0;
		
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> membrane_nodes;
		std::vector<unsigned> location_indices;
		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned node_counter = 0;

		double dt = 0.005;
		double end_time = 20;
		double sampling_multiple = 1;

		// Values that produce a working simulation in the comments
		double membraneStiffness = 5; 			// 5.0

		double epithelialPreferredRadius = 0.75;			// 1.0
		double membranePreferredRadius = 0.2;			// 0.2

		double epithelialInteractionRadius = 1.5 * epithelialPreferredRadius; // Epithelial covers stem and transit
		double membraneInteractionRadius = 7.0 * membranePreferredRadius;
		double maxInteractionRadius = 3.0;

		double minCellCycleDuration = 3;

		double springGrowthDuration = 1.0;


		double membrane_spacing = 0.2;
		double epithelial_spacing = 1.5 * epithelialPreferredRadius;
		double wall_height = wh;
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

		// Drawing the epithelium
		// The transit amplifying cells
		for (double y = wall_bottom; y <= wall_top; y+= epithelial_spacing)
		{
			double x = 0.88; // Note this value is determined from observing simulations//left_side + epithelialPreferredRadius;
			nodes.push_back(new Node<2>(node_counter,  false,  x, y));
			transit_nodes.push_back(node_counter);
			location_indices.push_back(node_counter);
			node_counter++;
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

		// First node is fixed
		{
			NoCellCycleModel* p_cycle_model = new NoCellCycleModel();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);
			p_cell->AddCellProperty(p_boundary);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}
		//Initialise trans nodes
		for (unsigned i = 1; i < transit_nodes.size(); i++)
		{
			UniformCellCycleModel* p_cycle_model = new UniformCellCycleModel();
			double birth_time = minCellCycleDuration * RandomNumberGenerator::Instance()->ranf(); //Randomly set birth time to stop pulsing behaviour
			p_cycle_model->SetBirthTime(-birth_time);
			p_cycle_model->SetMinCellCycleDuration(minCellCycleDuration);

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}

		membraneSections.push_back(membrane_cells);

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

		simulator.SetOutputDirectory("TestContactNeighboursWithMembrane");

		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(LinearSpringForceMembraneCellNodeBased<2>, p_force);
		p_force->SetEpithelialSpringStiffness(epithelialStiffness);
		p_force->SetMembraneSpringStiffness(membraneStiffness);
		p_force->SetEpithelialMembraneSpringStiffness(epithelialMembraneStiffness);

		p_force->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		p_force->SetMembranePreferredRadius(membranePreferredRadius);

		p_force->SetEpithelialInteractionRadius(epithelialInteractionRadius);
		p_force->SetMembraneInteractionRadius(membraneInteractionRadius);
		
		p_force->SetMeinekeSpringGrowthDuration(springGrowthDuration);
		p_force->SetMeinekeDivisionRestingSpringLength(0.1);

		p_force->SetDebugMode(debugging);

		simulator.AddForce(p_force);

		MAKE_PTR_ARGS(AnoikisCellKiller, p_anoikis_killer, (&cell_population));
		simulator.AddCellKiller(p_anoikis_killer);

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		MAKE_PTR_ARGS(SimpleSloughingCellKiller, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer);

		simulator.Solve();

	};


	void TestContactNeighbours2D() throw(Exception)
	{
		// This test is intended to check that the contact neighbour calculation works correctly
		// The contact neighbours returned should match what is expected
		// This hasn't been implemented completely, since the neighbours returned aren't entirely correct
        double epithelialStiffness = 10;
		
        double epithelialMembraneStiffness = 5.0;

        bool debugging = true;
		
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> location_indices;
		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned node_counter = 0;

		double dt = 0.005;
		double end_time = 0.005;
		double sampling_multiple = 1;

		double epithelialPreferredRadius = 1;			// 1.0

		double epithelialInteractionRadius = 1.2 * epithelialPreferredRadius; // Epithelial covers stem and transit
		double maxInteractionRadius = 1.5;

		double minCellCycleDuration = 3;

		double springGrowthDuration = 1.0;

		// Define an array of points that the contact neighbour method will be applied to
		// This should give a fixed result, regardless of the implementation

		const unsigned n_cells = 18;

		double x [n_cells] = {0,0.7,1,0,-1,-1,0,1.5,0.1,1.5,4,0,0,0,0,0,0,0};
		double y [n_cells] = {0,0.7,0,1,-1,0,-1,0,-1.1,0.9,4,0,0,0,0,0,0,0};

		for (unsigned i = 11; i<n_cells; i++)
		{
			x[i] = x[10] + cos(i*M_PI/(n_cells-10));
			y[i] = y[10] + sin(i*M_PI/(n_cells-10));
		}
		x[13] = x[10] + 1.2 * cos(13*M_PI/(n_cells-10));
		y[13] = y[10] + 1.2 * sin(13*M_PI/(n_cells-10));


		// Drawing the epithelium
		// The transit amplifying cells
		for (unsigned i=0; i < n_cells; i++)
		{
			nodes.push_back(new Node<2>(node_counter,  false,  x[i], y[i]));
			location_indices.push_back(node_counter);
			node_counter++;
		}

		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, maxInteractionRadius);

		std::vector<CellPtr> cells;

		MAKE_PTR(DifferentiatedCellProliferativeType, p_diff_type);
		MAKE_PTR(WildTypeCellMutationState, p_state);

		//Initialise membrane nodes
		for (unsigned i = 0; i < location_indices.size(); i++)
		{
			NoCellCycleModel* p_cycle_model = new NoCellCycleModel();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_diff_type);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}


		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);



		OffLatticeSimulation<2> simulator(cell_population);

		simulator.SetOutputDirectory("TestContactNeighbours");

		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(LinearSpringForceMembraneCellNodeBased<2>, p_force);
		p_force->SetEpithelialSpringStiffness(epithelialStiffness);
		p_force->SetEpithelialMembraneSpringStiffness(epithelialMembraneStiffness);

		p_force->SetStromalPreferredRadius(epithelialPreferredRadius);

		p_force->SetStromalInteractionRadius(epithelialInteractionRadius);

		p_force->SetDebugMode(debugging);
		
		

		// p_force->SetMeinekeSpringGrowthDuration(springGrowthDuration);
		// p_force->SetMeinekeDivisionRestingSpringLength(0.1);

		simulator.AddForce(p_force);

		simulator.Solve();

		std::set< std::pair<Node<2>*, Node<2>* > > contact_nodes = p_force->FindContactNeighbourPairs(cell_population);
		TRACE("Here")

		for (typename std::set< std::pair<Node<2>*, Node<2>* > >::iterator iter = contact_nodes.begin();
        iter != contact_nodes.end();
        iter++)
    	{
    		std::pair<Node<2>*, Node<2>* > pair = *iter;
    		unsigned node_a_index = pair.first->GetIndex();
            unsigned node_b_index = pair.second->GetIndex();
            PRINT_2_VARIABLES(node_a_index, node_b_index)
    	}

	};

	void xTestContactNeighbours1D() throw(Exception)
	{
		// This test is intended to check that the contact neighbour calculation works correctly
		// The contact neighbours returned should match what is expected
		// This hasn't been implemented completely, since the neighbours returned aren't entirely correct
        double epithelialStiffness = 10;
		
        double epithelialMembraneStiffness = 5.0;

        bool debugging = true;
		
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> location_indices;
		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned node_counter = 0;

		double dt = 0.005;
		double end_time = 0.01;
		double sampling_multiple = 1;

		double epithelialPreferredRadius = 1;			// 1.0

		double epithelialInteractionRadius = 1.2 * epithelialPreferredRadius; // Epithelial covers stem and transit
		double maxInteractionRadius = 1.5;

		double minCellCycleDuration = 3;

		double springGrowthDuration = 1.0;

		// Define an array of points that the contact neighbour method will be applied to
		// This should give a fixed result, regardless of the implementation

		const unsigned n_cells = 11;

		double x [n_cells] = {0,0,0,0,0,0,0,0,0,0,0};
		double y [n_cells] = {1,2,3,4,4.3,4.35,5,6,8,9,10};
		

		// Drawing the epithelium
		// The transit amplifying cells
		for (unsigned i=0; i < n_cells; i++)
		{
			nodes.push_back(new Node<2>(node_counter,  false,  x[i], y[i]));
			location_indices.push_back(node_counter);
			node_counter++;
		}

		
		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, maxInteractionRadius);
		
		std::vector<CellPtr> cells;

		MAKE_PTR(DifferentiatedCellProliferativeType, p_diff_type);
		MAKE_PTR(WildTypeCellMutationState, p_state);

		//Initialise membrane nodes
		for (unsigned i = 0; i < location_indices.size(); i++)
		{
			NoCellCycleModel* p_cycle_model = new NoCellCycleModel();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_diff_type);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}
		

		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);

		

		OffLatticeSimulation<2> simulator(cell_population);
		
		simulator.SetOutputDirectory("TestContactNeighbours");

		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(LinearSpringForceMembraneCellNodeBased<2>, p_force);
		p_force->SetEpithelialSpringStiffness(epithelialStiffness);
		p_force->SetEpithelialMembraneSpringStiffness(epithelialMembraneStiffness);

		p_force->SetStromalPreferredRadius(epithelialPreferredRadius);

		p_force->SetStromalInteractionRadius(epithelialInteractionRadius);

		p_force->SetDebugMode(false);

		p_force->Set1D(true);
		
		

		// p_force->SetMeinekeSpringGrowthDuration(springGrowthDuration);
		// p_force->SetMeinekeDivisionRestingSpringLength(0.1);

		simulator.AddForce(p_force);
		

		simulator.Solve();
		

		std::set< std::pair<Node<2>*, Node<2>* > > contact_nodes = p_force->FindContactNeighbourPairs(cell_population);
		/*
		node_a_index = 0, node_b_index = 1
		node_a_index = 1, node_b_index = 0
		node_a_index = 1, node_b_index = 2
		node_a_index = 2, node_b_index = 1
		node_a_index = 2, node_b_index = 3
		node_a_index = 3, node_b_index = 2
		node_a_index = 3, node_b_index = 4
		node_a_index = 4, node_b_index = 3
		node_a_index = 4, node_b_index = 5
		node_a_index = 5, node_b_index = 4
		node_a_index = 5, node_b_index = 6
		node_a_index = 6, node_b_index = 5
		node_a_index = 6, node_b_index = 7
		node_a_index = 7, node_b_index = 6
		node_a_index = 8, node_b_index = 9
		node_a_index = 9, node_b_index = 8
		node_a_index = 9, node_b_index = 10
		node_a_index = 10, node_b_index = 9
		// Output should be the same as above, but need to programatically compare with an assert
		*/

		for (typename std::set< std::pair<Node<2>*, Node<2>* > >::iterator iter = contact_nodes.begin();
        iter != contact_nodes.end();
        iter++)
    	{
    		std::pair<Node<2>*, Node<2>* > pair = *iter;
    		unsigned node_a_index = pair.first->GetIndex();
            unsigned node_b_index = pair.second->GetIndex();
            PRINT_2_VARIABLES(node_a_index, node_b_index)
    	}

	};



};