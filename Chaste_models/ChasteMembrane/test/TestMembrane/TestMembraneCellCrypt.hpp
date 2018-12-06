// Standard includes for tests
#include <cxxtest/TestSuite.h>
#include "AbstractCellBasedTestSuite.hpp"
#include "CheckpointArchiveTypes.hpp"
#include "SmartPointers.hpp"
#include "CommandLineArguments.hpp"

// Mesh stuff
#include "MeshBasedCellPopulationWithGhostNodes.hpp"
#include "HoneycombMeshGenerator.hpp" //Generates mesh
#include "CylindricalHoneycombMeshGenerator.hpp"

// Simulators and output
#include "OffLatticeSimulation.hpp" //Simulates the evolution of the population
#include "VoronoiDataWriter.hpp" //Allows us to visualise output in Paraview

// Forces
#include "GeneralisedLinearSpringForce.hpp"
#include "MembraneCellForce.hpp"
#include "MembraneCellForceNodeBased.hpp"
#include "LinearSpringForceMembraneCell.hpp"
#include "LinearSpringForceMembraneCellNodeBased.hpp"

// Proliferative types
#include "MembraneCellProliferativeType.hpp"
#include "DifferentiatedCellProliferativeType.hpp"
#include "TransitCellProliferativeType.hpp"
#include "StemCellProliferativeType.hpp"

// Mutation States
#include "WildTypeCellMutationState.hpp"
#include "TransitCellAnoikisResistantMutationState.hpp"
#include "AnoikisCellTagged.hpp"

// Boundary conditions
#include "BoundaryCellProperty.hpp"
#include "CryptBoundaryCondition.hpp"

//Cell cycle models
#include "NoCellCycleModel.hpp"
#include "UniformCellCycleModel.hpp"
#include "WntUniformCellCycleModel.hpp"
#include "WntCellCycleModelMembraneCell.hpp"

//Cell Killers
#include "AnoikisCellKiller.hpp"
#include "AnoikisCellKillerMembraneCell.hpp"
#include "SimpleSloughingCellKiller.hpp"

//Division Rules
#include "StickToMembraneDivisionRule.hpp"

//Writers
#include "EpithelialCellPositionWriter.hpp"
#include "EpithelialCellBirthWriter.hpp"
#include "NodeVelocityWriter.hpp"

// Wnt concentration
#include "WntConcentrationXSection.hpp"

// Modifiers
#include "VolumeTrackingModifier.hpp"

// Misc
#include "FakePetscSetup.hpp"
#include "Debug.hpp"


class TestMembraneCellCrypt : public AbstractCellBasedTestSuite
{
	public:
	void xTestCryptNodeBased() throw(Exception)
	{
		// In this we introduce a row of membrane point cells with a small rest length
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> stem_nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> membrane_nodes;
		std::vector<unsigned> location_indices;
		std::vector<unsigned> ghost_nodes;
		std::vector<std::vector<CellPtr>> membraneSections;

		double dt = 0.02;
		double end_time = 50;
		double sampling_multiple = 10;

		unsigned cells_up = 40;
		unsigned cells_across = 40;
		unsigned ghosts = 3;
		unsigned node_counter = 0;
		unsigned num_membrane_nodes = 60;			// 60

		// Values that produce a working simulation in the comments
		double epithelialStiffness = 2.0; 			// 1.5
		double membraneStiffness = 0; 			// 5.0
		double stromalStiffness = 5.0; 				// 2.0

		double epithelialMembraneStiffness = 5.0; 	// 1.0
		double membraneStromalStiffness = 5.0; 		// 5.0
		double stromalEpithelialStiffness = 1.0;	// 1.0

		double epithelialPreferredRadius = 0.75;			// 1.0
		double membranePreferredRadius = 0.2;			// 0.2
		double stromalPreferredRadius = 0.5;			// 1.0

		double epithelialInteractionRadius = 1.5 * epithelialPreferredRadius; // Epithelial covers stem and transit
		double membraneInteractionRadius = 3.0 * membranePreferredRadius;
		double stromalInteractionRadius = 2.0 * stromalPreferredRadius; // Stromal is the differentiated "filler" cells

		double maxInteractionRadius = 1.5;

		double torsional_stiffness = 10;			// 10.0

		double targetCurvatureStemTrans = 0;
		double targetCurvatureTransTrans = 0;

		TRACE("The assertion for non-zero membrane spring force in LinearSpringForceMembraneCellNodeBased has been silenced at line 203 and 294")

		double centre_x = 5.0;
		double centre_y = 15.0;
		double base_radius = 2.0;
		double membrane_spacing = 0.2;
		double wall_height = 30;
		double left_side = centre_x - base_radius;
		double right_side = centre_x + base_radius;
		double wall_top = centre_y + wall_height;
		double wall_bottom = centre_y;

		double targetCurvatureStemStem = 1/base_radius;

		// Drawing the membrane
		// Need to follow this order to ensure membrane nodes are registered in order
		for (double y = wall_top; y >= wall_bottom; y-=membrane_spacing)
		{
			double x = left_side;
			nodes.push_back(new Node<2>(node_counter,  false,  x, y));
			membrane_nodes.push_back(node_counter);
			location_indices.push_back(node_counter);
			node_counter++;
		}

		double acos_arg = (2*pow(base_radius,2) - pow(membrane_spacing,2))/(2*pow(base_radius,2));
		double  d_theta = acos(acos_arg);
		PRINT_VARIABLE(acos_arg)

		for (double theta = d_theta; theta <= M_PI; theta += d_theta)
		{
			double x = centre_x - base_radius * cos(theta);
			double y = centre_y - base_radius * sin(theta);
			nodes.push_back(new Node<2>(node_counter,  false,  x, y));
			membrane_nodes.push_back(node_counter);
			location_indices.push_back(node_counter);
			node_counter++;
		}

		for (double y = wall_bottom; y <= wall_top; y+=membrane_spacing)
		{
			double x = right_side;
			nodes.push_back(new Node<2>(node_counter,  false,  x, y));
			membrane_nodes.push_back(node_counter);
			location_indices.push_back(node_counter);
			node_counter++;
		}

		//Drawing the epithelium
		//Start with the stem cells
		double epithelial_spacing = 1.5 * epithelialPreferredRadius;
		base_radius -= epithelialPreferredRadius;
		acos_arg = (2*pow(base_radius,2) - pow(epithelial_spacing,2))/(2*pow(base_radius,2));
		d_theta = acos(acos_arg);
		PRINT_VARIABLE(acos_arg)

		for (double theta = d_theta; theta <= M_PI; theta += d_theta)
		{
			double x = centre_x - base_radius * cos(theta);
			double y = centre_y - base_radius * sin(theta);
			nodes.push_back(new Node<2>(node_counter,  false,  x, y));
			transit_nodes.push_back(node_counter); // stem_nodes.pushback(node_counter); //ignoring different types to start with
			location_indices.push_back(node_counter);
			node_counter++;
		}
		// Next the transit amplifying cells
		for (double y = wall_bottom; y <= wall_top; y+= epithelial_spacing)
		{
			double x = left_side + epithelialPreferredRadius;
			nodes.push_back(new Node<2>(node_counter,  false,  x, y));
			transit_nodes.push_back(node_counter);
			location_indices.push_back(node_counter);
			node_counter++;

			x = right_side - epithelialPreferredRadius;
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
		MAKE_PTR(StemCellProliferativeType, p_stem_type);
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

		// To get things working, ignore cell types
		//Initialise stem nodes
		// for (unsigned i = 0; i < stem_nodes.size(); i++)
		// {
		// 	UniformCellCycleModel* p_cycle_model = new UniformCellCycleModel();
		// 	double birth_time = 12.0*RandomNumberGenerator::Instance()->ranf(); //Randomly set birth time to stop pulsing behaviour
		// 	p_cycle_model->SetBirthTime(-birth_time);

		// 	CellPtr p_cell(new Cell(p_state, p_cycle_model));
		// 	p_cell->SetCellProliferativeType(p_stem_type);

		// 	p_cell->InitialiseCellCycleModel();

		// 	cells.push_back(p_cell);
		// }

		//Initialise trans nodes
		for (unsigned i = 0; i < transit_nodes.size(); i++)
		{
			UniformCellCycleModel* p_cycle_model = new UniformCellCycleModel();
			double birth_time = 12.0*RandomNumberGenerator::Instance()->ranf(); //Randomly set birth time to stop pulsing behaviour
			p_cycle_model->SetBirthTime(-birth_time);

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}

		membraneSections.push_back(membrane_cells);

		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);

		OffLatticeSimulation<2> simulator(cell_population);
		simulator.SetOutputDirectory("MembraneCellCryptNodeBased");
		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(LinearSpringForceMembraneCellNodeBased<2>, p_force);
		p_force->SetEpithelialSpringStiffness(epithelialStiffness);
		p_force->SetMembraneSpringStiffness(membraneStiffness);
		p_force->SetStromalSpringStiffness(stromalStiffness);
		p_force->SetEpithelialMembraneSpringStiffness(epithelialMembraneStiffness);
		p_force->SetMembraneStromalSpringStiffness(membraneStromalStiffness);
		p_force->SetStromalEpithelialSpringStiffness(stromalEpithelialStiffness);

		p_force->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		p_force->SetMembranePreferredRadius(membranePreferredRadius);
		p_force->SetStromalPreferredRadius(stromalPreferredRadius);

		p_force->SetEpithelialInteractionRadius(epithelialInteractionRadius);
		p_force->SetMembraneInteractionRadius(membraneInteractionRadius);
		p_force->SetStromalInteractionRadius(stromalInteractionRadius);

		simulator.AddForce(p_force);

		MAKE_PTR(MembraneCellForceNodeBased, p_membrane_force);
		p_membrane_force->SetBasementMembraneTorsionalStiffness(torsional_stiffness);
		p_membrane_force->SetTargetCurvatures(targetCurvatureStemStem, targetCurvatureStemTrans, targetCurvatureTransTrans);
		p_membrane_force->SetMembraneSections(membraneSections);
		//p_membrane_force->SetCalculationToTorsion(true);
		//simulator.AddForce(p_membrane_force);

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		MAKE_PTR_ARGS(AnoikisCellKillerMembraneCell, p_anoikis_killer, (&cell_population));
		simulator.AddCellKiller(p_anoikis_killer);

		//SimpleSloughingCellKiller* p_sloughing_killer = new SimpleSloughingCellKiller(&cell_population);
		MAKE_PTR_ARGS(SimpleSloughingCellKiller, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer);

		cell_population.AddCellWriter<EpithelialCellPositionWriter>();
		cell_population.AddCellWriter<EpithelialCellBirthWriter>();

		simulator.Solve();

		simulator.SetEndTime(50);
		simulator.Solve();

	};

	void TestWntCryptNodeBased() throw(Exception)
	{
		// In this we introduce a row of membrane point cells with a small rest length
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> stem_nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> membrane_nodes;
		std::vector<unsigned> location_indices;
		std::vector<unsigned> ghost_nodes;
		std::vector<std::vector<CellPtr>> membraneSections;


		WntConcentrationXSection<2>* p_wnt = WntConcentrationXSection<2>::Instance();
		p_wnt->SetType(LINEAR);
		double dt = 0.01;
		double end_time = 50;
		double sampling_multiple = 10;

		unsigned cells_up = 40;
		unsigned cells_across = 40;
		unsigned ghosts = 3;
		unsigned node_counter = 0;
		unsigned num_membrane_nodes = 60;			// 60

		// Values that produce a working simulation in the comments
		double epithelialStiffness = 5.0; 			// 1.5
		double membraneStiffness = 0; 			// 5.0
		double stromalStiffness = 5.0; 				// 2.0

		double epithelialMembraneStiffness = 10.0; 	// 1.0
		double membraneStromalStiffness = 5.0; 		// 5.0
		double stromalEpithelialStiffness = 1.0;	// 1.0

		double epithelialPreferredRadius = 0.75;			// 1.0
		double membranePreferredRadius = 0.2;			// 0.2
		double stromalPreferredRadius = 0.5;			// 1.0

		double epithelialInteractionRadius = 1.5 * epithelialPreferredRadius; // Epithelial covers stem and transit
		double membraneInteractionRadius = 3.0 * membranePreferredRadius;
		double stromalInteractionRadius = 2.0 * stromalPreferredRadius; // Stromal is the differentiated "filler" cells

		double maxInteractionRadius = 1.5;

		double torsional_stiffness = 10;			// 10.0

		double targetCurvatureStemTrans = 0;
		double targetCurvatureTransTrans = 0;

		double minCellCycleDuration = 12;

		TRACE("The assertion for non-zero membrane spring force in LinearSpringForceMembraneCellNodeBased has been silenced at line 203 and 294")

		double centre_x = 5.0;
		double centre_y = 15.0;
		double base_radius = 2.0;
		double membrane_spacing = 0.2;
		double wall_height = 10;
		double left_side = centre_x - base_radius;
		double right_side = centre_x + base_radius;
		double wall_top = centre_y + wall_height;
		double wall_bottom = centre_y;

		double targetCurvatureStemStem = 1/base_radius;

		p_wnt->SetCryptLength(wall_height + base_radius);
		p_wnt->SetCryptStart(centre_y - base_radius);
		p_wnt->SetWntThreshold(.2);
		p_wnt->SetWntConcentrationXSectionParameter(wall_height + base_radius);

		// Drawing the membrane
		// Need to follow this order to ensure membrane nodes are registered in order
		for (double y = wall_top; y >= wall_bottom; y-=membrane_spacing)
		{
			double x = left_side;
			nodes.push_back(new Node<2>(node_counter,  false,  x, y));
			membrane_nodes.push_back(node_counter);
			location_indices.push_back(node_counter);
			node_counter++;
		}

		double acos_arg = (2*pow(base_radius,2) - pow(membrane_spacing,2))/(2*pow(base_radius,2));
		double  d_theta = acos(acos_arg);
		PRINT_VARIABLE(acos_arg)

		for (double theta = d_theta; theta <= M_PI; theta += d_theta)
		{
			double x = centre_x - base_radius * cos(theta);
			double y = centre_y - base_radius * sin(theta);
			nodes.push_back(new Node<2>(node_counter,  false,  x, y));
			membrane_nodes.push_back(node_counter);
			location_indices.push_back(node_counter);
			node_counter++;
		}

		for (double y = wall_bottom; y <= wall_top; y+=membrane_spacing)
		{
			double x = right_side;
			nodes.push_back(new Node<2>(node_counter,  false,  x, y));
			membrane_nodes.push_back(node_counter);
			location_indices.push_back(node_counter);
			node_counter++;
		}

		//Drawing the epithelium
		//Start with the stem cells
		double epithelial_spacing = 1.5 * epithelialPreferredRadius;
		base_radius -= epithelialPreferredRadius;
		acos_arg = (2*pow(base_radius,2) - pow(epithelial_spacing,2))/(2*pow(base_radius,2));
		d_theta = acos(acos_arg);
		PRINT_VARIABLE(acos_arg)

		for (double theta = d_theta; theta <= M_PI; theta += d_theta)
		{
			double x = centre_x - base_radius * cos(theta);
			double y = centre_y - base_radius * sin(theta);
			nodes.push_back(new Node<2>(node_counter,  false,  x, y));
			transit_nodes.push_back(node_counter); // stem_nodes.pushback(node_counter); //ignoring different types to start with
			location_indices.push_back(node_counter);
			node_counter++;
		}
		// Next the transit amplifying cells
		for (double y = wall_bottom; y <= wall_top; y+= epithelial_spacing)
		{
			double x = left_side + epithelialPreferredRadius;
			nodes.push_back(new Node<2>(node_counter,  false,  x, y));
			transit_nodes.push_back(node_counter);
			location_indices.push_back(node_counter);
			node_counter++;

			x = right_side - epithelialPreferredRadius;
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
		MAKE_PTR(StemCellProliferativeType, p_stem_type);
		MAKE_PTR(TransitCellProliferativeType, p_trans_type);

		MAKE_PTR(WildTypeCellMutationState, p_state);
		MAKE_PTR(TransitCellAnoikisResistantMutationState, p_resist);
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

		//Initialise trans nodes
		for (unsigned i = 0; i < transit_nodes.size(); i++)
		{
			WntUniformCellCycleModel* p_cycle_model = new WntUniformCellCycleModel();
			double birth_time = 12.0*RandomNumberGenerator::Instance()->ranf(); //Randomly set birth time to stop pulsing behaviour
			p_cycle_model->SetBirthTime(-birth_time);
			p_cycle_model->SetMinCellCycleDuration(minCellCycleDuration);

			// Pick a cell to be mutant
			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			// if (i==30)
			// {
			// 	TRACE("Mutation set")
			// 	p_cell->SetMutationState(p_resist);
			// }

			p_cell->SetCellProliferativeType(p_trans_type);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}

		membraneSections.push_back(membrane_cells);

		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);

		p_wnt->SetCellPopulation(cell_population);

		OffLatticeSimulation<2> simulator(cell_population);
		simulator.SetOutputDirectory("MembraneCellWntCryptNodeBased");
		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(LinearSpringForceMembraneCellNodeBased<2>, p_force);
		p_force->SetEpithelialSpringStiffness(epithelialStiffness);
		p_force->SetMembraneSpringStiffness(membraneStiffness);
		p_force->SetStromalSpringStiffness(stromalStiffness);
		p_force->SetEpithelialMembraneSpringStiffness(epithelialMembraneStiffness);
		p_force->SetMembraneStromalSpringStiffness(membraneStromalStiffness);
		p_force->SetStromalEpithelialSpringStiffness(stromalEpithelialStiffness);

		p_force->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		p_force->SetMembranePreferredRadius(membranePreferredRadius);
		p_force->SetStromalPreferredRadius(stromalPreferredRadius);

		p_force->SetEpithelialInteractionRadius(epithelialInteractionRadius);
		p_force->SetMembraneInteractionRadius(membraneInteractionRadius);
		p_force->SetStromalInteractionRadius(stromalInteractionRadius);

		simulator.AddForce(p_force);

		MAKE_PTR(MembraneCellForceNodeBased, p_membrane_force);
		p_membrane_force->SetBasementMembraneTorsionalStiffness(torsional_stiffness);
		p_membrane_force->SetTargetCurvatures(targetCurvatureStemStem, targetCurvatureStemTrans, targetCurvatureTransTrans);
		p_membrane_force->SetMembraneSections(membraneSections);
		//p_membrane_force->SetCalculationToTorsion(true);
		//simulator.AddForce(p_membrane_force);

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		MAKE_PTR_ARGS(AnoikisCellKiller, p_anoikis_killer, (&cell_population));
		simulator.AddCellKiller(p_anoikis_killer);

		//SimpleSloughingCellKiller* p_sloughing_killer = new SimpleSloughingCellKiller(&cell_population);
		MAKE_PTR_ARGS(SimpleSloughingCellKiller, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer);

		cell_population.AddCellWriter<EpithelialCellPositionWriter>();
		cell_population.AddCellWriter<EpithelialCellBirthWriter>();

		simulator.Solve();

		WntConcentrationXSection<2>::Destroy();

	};


	void xTestWntWallNodeBased() throw(Exception)
	{
		// Start off by setting the CLA parameters
		// This test has a niche cell cycle time and a transient cell cycle time
		// Transient is given as the argument
		// Niche is twice transient
		// Both have a uniform distribution which is -0 +2 of the value minCellCycleDuration

		TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-e"));
        double epithelialStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-e");
		
		TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-em"));
        double epithelialMembraneStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-em");
		
		TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-ct"));
        double minCellCycleDuration = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ct");

		double poppedUpLifeExpectancy = 0;
		if (CommandLineArguments::Instance()->OptionExists("-le"))
		{
			poppedUpLifeExpectancy = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-le");
		}

		double resistantPoppedUpLifeExpectancy = 10;
		if (CommandLineArguments::Instance()->OptionExists("-rle"))
		{
			resistantPoppedUpLifeExpectancy = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-rle");
		}

        bool slowDeath = false;

		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> membrane_nodes;
		std::vector<unsigned> location_indices;
		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned node_counter = 0;

		WntConcentrationXSection<2>* p_wnt = WntConcentrationXSection<2>::Instance();
		p_wnt->SetType(LINEAR);
		double dt = 0.01;
		double end_time = 50;
		double sampling_multiple = 1;

		// Values that produce a working simulation in the comments
		double membraneStiffness = 5; 			// 5.0

		double epithelialPreferredRadius = 0.75;			// 1.0
		double membranePreferredRadius = 0.2;			// 0.2
		double stromalPreferredRadius = 0.5;			// 1.0

		double epithelialInteractionRadius = 1.5 * epithelialPreferredRadius; // Epithelial covers stem and transit
		double membraneInteractionRadius = 5.0 * membranePreferredRadius;
		double maxInteractionRadius = 1.5;

		double wntThreshold = 0.25;  //point where Wnt no longer allows mitosis

		TRACE("The assertion for non-zero membrane spring force in LinearSpringForceMembraneCellNodeBased has been silenced at line 203 and 294")

		double membrane_spacing = 0.2;
		double epithelial_spacing = 1.5 * epithelialPreferredRadius;
		double wall_height = 20;
		double left_side = 0;
		double wall_top = wall_height;
		double wall_bottom = 0;

		p_wnt->SetCryptLength(wall_height);
		p_wnt->SetCryptStart(wall_bottom);
		p_wnt->SetWntThreshold(wntThreshold);
		p_wnt->SetWntConcentrationXSectionParameter(wall_height);

		// Drawing the membrane
		for (double y = wall_bottom; y <= wall_top; y+=membrane_spacing)
		{
			double x = left_side;
			nodes.push_back(new Node<2>(node_counter,  false,  x, y));
			membrane_nodes.push_back(node_counter);
			location_indices.push_back(node_counter);
			node_counter++;
		}

		//Drawing the epithelium
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
		MAKE_PTR(StemCellProliferativeType, p_stem_type);
		MAKE_PTR(TransitCellProliferativeType, p_trans_type);

		MAKE_PTR(TransitCellAnoikisResistantMutationState, p_resist);
		MAKE_PTR(WildTypeCellMutationState, p_state);
		MAKE_PTR(BoundaryCellProperty, p_boundary);

		unsigned number_of_fixed_membrane_nodes = 5;
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
			WntCellCycleModelMembraneCell* p_cycle_model = new WntCellCycleModelMembraneCell();
			double birth_time = minCellCycleDuration * RandomNumberGenerator::Instance()->ranf(); //Randomly set birth time to stop pulsing behaviour
			p_cycle_model->SetBirthTime(-birth_time);
			p_cycle_model->SetNicheCellCycleTime(2 * minCellCycleDuration);
			p_cycle_model->SetTransientCellCycleTime(minCellCycleDuration);

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);
			p_cell->SetApoptosisTime(2.0);
			if (i==13)
			{
				TRACE("Cell set as mutant")
				p_cell->SetMutationState(p_resist);
			}

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

		p_wnt->SetCellPopulation(cell_population);

		OffLatticeSimulation<2> simulator(cell_population);

		std::stringstream out;
        out << "/E_" << epithelialStiffness << "EM_"<< epithelialMembraneStiffness << "CCT_" << minCellCycleDuration;
        if (CommandLineArguments::Instance()->OptionExists("-le"))
        {
        	out << "PLE_" << poppedUpLifeExpectancy;
        }
        std::string output_directory = "WntWallTests-TwoProliferationRegions" +  out.str();
        simulator.SetOutputDirectory(output_directory);

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
		p_force->SetMeinekeSpringGrowthDuration(1);
		p_force->SetMeinekeDivisionRestingSpringLength(0.1);

		simulator.AddForce(p_force);

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		MAKE_PTR_ARGS(AnoikisCellKiller, p_anoikis_killer, (&cell_population));
		p_anoikis_killer->SetSlowDeath(slowDeath);
		p_anoikis_killer->SetPoppedUpLifeExpectancy(poppedUpLifeExpectancy);
		p_anoikis_killer->SetResistantPoppedUpLifeExpectancy(resistantPoppedUpLifeExpectancy);
		simulator.AddCellKiller(p_anoikis_killer);

		MAKE_PTR_ARGS(SimpleSloughingCellKiller, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer);

		MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

		cell_population.AddCellWriter<EpithelialCellPositionWriter>();
		cell_population.AddCellWriter<EpithelialCellBirthWriter>();
		// cell_population.AddPopulationWriter<NodeVelocityWriter<2,2>>();

		simulator.Solve();

		WntConcentrationXSection<2>::Destroy();

	};

	void xTestWntWallStretchyMembrane() throw(Exception)
	{
		// Start off by setting the CLA parameters
		// This test has a niche cell cycle time and a transient cell cycle time
		// Transient is given as the argument
		// Niche is twice transient
		// Both have a uniform distribution which is -0 +2 of the value minCellCycleDuration

		TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-e"));
        double epithelialStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-e");
		
		TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-em"));
        double epithelialMembraneStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-em");
		
		TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-ct"));
        double minCellCycleDuration = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ct");

		double poppedUpLifeExpectancy = 0;
		if (CommandLineArguments::Instance()->OptionExists("-le"))
		{
			poppedUpLifeExpectancy = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-le");
		}

		double resistantPoppedUpLifeExpectancy = 10;
        bool slowDeath = false;

		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> membrane_nodes;
		std::vector<unsigned> location_indices;
		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned node_counter = 0;

		WntConcentrationXSection<2>* p_wnt = WntConcentrationXSection<2>::Instance();
		p_wnt->SetType(LINEAR);
		double dt = 0.005;
		double end_time = 100;
		double sampling_multiple = 10;

		// Values that produce a working simulation in the comments
		double membraneStiffness = 10; 			// 5.0

		double epithelialPreferredRadius = 0.75;			// 1.0
		double membranePreferredRadius = 0.2;			// 0.2
		double stromalPreferredRadius = 0.5;			// 1.0

		double epithelialInteractionRadius = 1.5 * epithelialPreferredRadius; // Epithelial covers stem and transit
		double membraneInteractionRadius = 3.0 * membranePreferredRadius;
		double maxInteractionRadius = 1.5;

		double wntThreshold = 0.2;  //point where Wnt no longer allows mitosis

		TRACE("The assertion for non-zero membrane spring force in LinearSpringForceMembraneCellNodeBased has been silenced at line 203 and 294")

		double membrane_spacing = 0.3;
		double epithelial_spacing = 1.5 * epithelialPreferredRadius;
		double wall_height = 30;
		double left_side = 0;
		double wall_top = wall_height;
		double wall_bottom = 0;

		p_wnt->SetCryptLength(wall_height);
		p_wnt->SetCryptStart(wall_bottom);
		p_wnt->SetWntThreshold(wntThreshold);
		p_wnt->SetWntConcentrationXSectionParameter(wall_height);

		// Drawing the membrane
		for (double y = wall_bottom; y <= wall_top; y+=membrane_spacing)
		{
			double x = left_side;
			nodes.push_back(new Node<2>(node_counter,  false,  x, y));
			membrane_nodes.push_back(node_counter);
			location_indices.push_back(node_counter);
			node_counter++;
		}

		//Drawing the epithelium
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
		MAKE_PTR(StemCellProliferativeType, p_stem_type);
		MAKE_PTR(TransitCellProliferativeType, p_trans_type);

		MAKE_PTR(TransitCellAnoikisResistantMutationState, p_resist);
		MAKE_PTR(WildTypeCellMutationState, p_state);
		MAKE_PTR(BoundaryCellProperty, p_boundary);

		unsigned number_of_fixed_membrane_nodes = 5;
		//Initialise membrane nodes
		for (unsigned i = 0; i < membrane_nodes.size(); i++)
		{
			NoCellCycleModel* p_cycle_model = new NoCellCycleModel();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_membrane_type);
			
			if (i < number_of_fixed_membrane_nodes)
			{
				p_cell->AddCellProperty(p_boundary);
			}

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
			WntCellCycleModelMembraneCell* p_cycle_model = new WntCellCycleModelMembraneCell();
			double birth_time = minCellCycleDuration * RandomNumberGenerator::Instance()->ranf(); //Randomly set birth time to stop pulsing behaviour
			p_cycle_model->SetBirthTime(-birth_time);
			p_cycle_model->SetNicheCellCycleTime(2 * minCellCycleDuration);
			p_cycle_model->SetTransientCellCycleTime(minCellCycleDuration);

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);
			p_cell->SetApoptosisTime(2.0);
			// if (i==13)
			// {
			// 	TRACE("Cell set as mutant")
			// 	p_cell->SetMutationState(p_resist);
			// }

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

		p_wnt->SetCellPopulation(cell_population);

		OffLatticeSimulation<2> simulator(cell_population);

		std::stringstream out;
        out << "/Stretchy_Membrane_E_" << epithelialStiffness << "EM_"<< epithelialMembraneStiffness << "CCT_" << minCellCycleDuration;
        if (CommandLineArguments::Instance()->OptionExists("-le"))
        {
        	out << "PLE_" << poppedUpLifeExpectancy;
        }
        std::string output_directory = "WntWallTests-TwoProliferationRegions" +  out.str();
        simulator.SetOutputDirectory(output_directory);

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

		simulator.AddForce(p_force);

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		MAKE_PTR_ARGS(AnoikisCellKiller, p_anoikis_killer, (&cell_population));
		p_anoikis_killer->SetSlowDeath(slowDeath);
		p_anoikis_killer->SetPoppedUpLifeExpectancy(poppedUpLifeExpectancy);
		p_anoikis_killer->SetResistantPoppedUpLifeExpectancy(resistantPoppedUpLifeExpectancy);
		simulator.AddCellKiller(p_anoikis_killer);

		MAKE_PTR_ARGS(SimpleSloughingCellKiller, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer);

		cell_population.AddCellWriter<EpithelialCellPositionWriter>();
		cell_population.AddCellWriter<EpithelialCellBirthWriter>();

		simulator.Solve();

		WntConcentrationXSection<2>::Destroy();

	};

	void xTestSingleCellOnWall() throw(Exception)
	{
		// Start off by setting the CLA parameters
		// This test has a niche cell cycle time and a transient cell cycle time
		// Transient is given as the argument
		// Niche is twice transient
		// Both have a uniform distribution which is -0 +2 of the value minCellCycleDuration

		TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-e"));
        double epithelialStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-e");
		
		TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-em"));
        double epithelialMembraneStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-em");
		
		TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-ct"));
        double minCellCycleDuration = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ct");

        bool slowDeath = false;

		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> membrane_nodes;
		std::vector<unsigned> location_indices;
		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned node_counter = 0;

		WntConcentrationXSection<2>* p_wnt = WntConcentrationXSection<2>::Instance();
		p_wnt->SetType(LINEAR);
		double dt = 0.005;
		double end_time = 100;
		double sampling_multiple = 10;

		// Values that produce a working simulation in the comments
		double membraneStiffness = 5; 			// 5.0

		double epithelialPreferredRadius = 0.75;			// 1.0
		double membranePreferredRadius = 0.2;			// 0.2
		double stromalPreferredRadius = 0.5;			// 1.0

		double epithelialInteractionRadius = 1.5 * epithelialPreferredRadius; // Epithelial covers stem and transit
		double membraneInteractionRadius = 5.0 * membranePreferredRadius;
		double maxInteractionRadius = 1.5;

		double wntThreshold = 0.2;  //point where Wnt no longer allows mitosis

		TRACE("The assertion for non-zero membrane spring force in LinearSpringForceMembraneCellNodeBased has been silenced at line 203 and 294")

		double membrane_spacing = 0.2;
		double epithelial_spacing = 1.5 * epithelialPreferredRadius;
		double wall_height = 30;
		double left_side = 0;
		double wall_top = wall_height;
		double wall_bottom = 0;

		p_wnt->SetCryptLength(wall_height);
		p_wnt->SetCryptStart(wall_bottom);
		p_wnt->SetWntThreshold(wntThreshold);
		p_wnt->SetWntConcentrationXSectionParameter(wall_height);

		// Drawing the membrane
		for (double y = wall_bottom; y <= wall_top; y+=membrane_spacing)
		{
			double x = left_side;
			nodes.push_back(new Node<2>(node_counter,  false,  x, y));
			membrane_nodes.push_back(node_counter);
			location_indices.push_back(node_counter);
			node_counter++;
		}

		// Putting a single cell on the wall
		{
			double y = wall_bottom +10.0;
			double x = 1.0; // Note this value is determined from observing simulations//left_side + epithelialPreferredRadius;
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
		MAKE_PTR(StemCellProliferativeType, p_stem_type);
		MAKE_PTR(TransitCellProliferativeType, p_trans_type);

		MAKE_PTR(TransitCellAnoikisResistantMutationState, p_resist);
		MAKE_PTR(WildTypeCellMutationState, p_state);
		MAKE_PTR(BoundaryCellProperty, p_boundary);

		unsigned number_of_fixed_membrane_nodes = 5;
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

		membraneSections.push_back(membrane_cells);

		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);

		p_wnt->SetCellPopulation(cell_population);

		OffLatticeSimulation<2> simulator(cell_population);

		std::stringstream out;
        out << "/Single_Cell_Test_E_" << epithelialStiffness << "EM_"<< epithelialMembraneStiffness << "CCT_" << minCellCycleDuration;

        std::string output_directory = "Single_Cell_Test" +  out.str();
        simulator.SetOutputDirectory(output_directory);

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

		simulator.AddForce(p_force);

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);


		simulator.Solve();

		WntConcentrationXSection<2>::Destroy();

	};

};