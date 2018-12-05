// Standard includes for tests
#include <cxxtest/TestSuite.h>
#include "AbstractCellBasedTestSuite.hpp"
#include "CheckpointArchiveTypes.hpp"
#include "SmartPointers.hpp"
#include "CommandLineArguments.hpp"

// Simulators and output
#include "OffLatticeSimulation.hpp" //Simulates the evolution of the population

#include "LinearSpringForcePhaseBased.hpp"
#include "LinearSpringForceMembraneCellNodeBased.hpp"
#include "NormalAdhesionForce.hpp"
#include "NonLinearSpringForceScaled.hpp"

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
#include "TransitCellAnoikisResistantMutationState.hpp"

// Boundary conditions
#include "BoundaryCellProperty.hpp"
#include "CryptBoundaryCondition.hpp"

#include "SimpleSloughingCellKiller.hpp"
#include "AnoikisCellKiller.hpp"

//Division Rules
#include "StickToMembraneDivisionRule.hpp"

// Modifiers
#include "VolumeTrackingModifier.hpp"

//Writers
#include "EpithelialCellPositionWriter.hpp"
#include "EpithelialCellBirthWriter.hpp"
#include "EpithelialCellSPhaseWriter.hpp"
#include "EpithelialCellVelocityWriter.hpp"

// Misc
#include "FakePetscSetup.hpp"
#include "Debug.hpp"

class TestGrowingCellDivision : public AbstractCellBasedTestSuite
{
	public:
	void xTestGrowingDivision() throw(Exception)
	{
		double dt = 0.01;
		double end_time = 20;
		double sampling_multiple = 10;

		double epithelialStiffness = 2.0; 			// 1.5
		double epithelialPreferredRadius = 0.7;			// 1.0
		double epithelialInteractionRadius = 1.5 * epithelialPreferredRadius; // Epithelial covers stem and transit
		double epithelialNewlyDividedRadius = 0.3;

		double stromalStiffness = 2.0; 			// 1.5
		double stromalPreferredRadius = 0.7;			// 1.0
		double stromalInteractionRadius = 1.5 * epithelialPreferredRadius;

		double stromalEpithelialStiffness = 1.0;


		std::vector<Node<2>*> nodes;

		unsigned cells_up = 5;
		unsigned cells_across = 5;
		unsigned node_counter = 0;

		for (unsigned i = 0; i< cells_across; i++)
		{
			for (unsigned j = 0; j< cells_up; j++)
			{
				double x = 0;
				double y = 0;
				if (j == 2* unsigned(j/2))
				{
					x= i;
				} else 
				{
					// stagger for hex mesh
					x = i +0.5;
				}
				y = j * (sqrt(3.0)/2);
				nodes.push_back(new Node<2>(node_counter,  false,  x, y));
				node_counter++;
			}
		}

		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, 3.0);

		std::vector<CellPtr> cells;

		MAKE_PTR(MembraneCellProliferativeType, p_membrane_type);
		MAKE_PTR(DifferentiatedCellProliferativeType, p_diff_type);
		MAKE_PTR(StemCellProliferativeType, p_stem_type);
		MAKE_PTR(TransitCellProliferativeType, p_trans_type);

		MAKE_PTR(WildTypeCellMutationState, p_state);

		for (unsigned i = 0; i < nodes.size(); i++)
		{
			if (i==12 || i==13)
			{
				// Set the middle cell to be proliferating
				GrowingContactInhibitionPhaseBasedCCM* p_cycle_model = new GrowingContactInhibitionPhaseBasedCCM();
				p_cycle_model->SetNewlyDividedRadius(epithelialNewlyDividedRadius);
				p_cycle_model->SetPreferredRadius(epithelialPreferredRadius);
				p_cycle_model->SetInteractionRadius(epithelialInteractionRadius);

				CellPtr p_cell(new Cell(p_state, p_cycle_model));
				p_cell->SetCellProliferativeType(p_trans_type);

				p_cell->InitialiseCellCycleModel();

				cells.push_back(p_cell);
			}
			else
			{
				NoCellCycleModel* p_cycle_model = new NoCellCycleModel();
			
				CellPtr p_cell(new Cell(p_state, p_cycle_model));
				p_cell->SetCellProliferativeType(p_diff_type);
	
				p_cell->InitialiseCellCycleModel();
	
				cells.push_back(p_cell);
			}
		}

        NodeBasedCellPopulation<2> cell_population(mesh, cells);

        OffLatticeSimulation<2> simulator(cell_population);
        simulator.SetOutputDirectory("TestGrowingDivision");
        simulator.SetSamplingTimestepMultiple(sampling_multiple);
        simulator.SetEndTime(end_time);
        simulator.SetDt(dt);

        //MAKE_PTR(LinearSpringForcePhaseBased<2>, p_force);
        MAKE_PTR(LinearSpringForceMembraneCellNodeBased<2>, p_force);
		p_force->SetEpithelialSpringStiffness(epithelialStiffness);
		p_force->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		p_force->SetEpithelialInteractionRadius(epithelialInteractionRadius);

		p_force->SetStromalSpringStiffness(stromalStiffness);
		p_force->SetStromalPreferredRadius(stromalPreferredRadius);
		p_force->SetStromalInteractionRadius(stromalInteractionRadius);

		p_force->SetStromalEpithelialSpringStiffness(stromalEpithelialStiffness);

		p_force->SetMeinekeSpringGrowthDuration(1);
		p_force->SetMeinekeDivisionRestingSpringLength(0.1);

		p_force->SetDebugMode(false);

        simulator.AddForce(p_force);

        MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

        simulator.Solve();
	};

	void xTestGrowingDivisionWithMembrane() throw(Exception)
	{

		//TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-wh"));
        double wh = 21;// CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-wh");


		bool debugging = false;

        double epithelialStiffness = 10.0;
		
        double epithelialMembraneStiffness = 20.0;
		
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> membrane_nodes;
		std::vector<unsigned> location_indices;
		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned node_counter = 0;

		double dt = 0.001;
		double end_time = 10;
		double sampling_multiple = 10;

		// Values that produce a working simulation in the comments
		double membraneStiffness = 5.0; 			// 5.0

		double epithelialPreferredRadius = 0.75;			// 1.0
		double membranePreferredRadius = 0.2;			// 0.2

		double epithelialInteractionRadius = 1.5 * epithelialPreferredRadius; // Epithelial covers stem and transit
		double membraneInteractionRadius = 7.0 * membranePreferredRadius;
		double epithelialNewlyDividedRadius = 0.7 * epithelialPreferredRadius;
		double maxInteractionRadius = 3.0;

		double minCellCycleDuration = 10;

		double mDuration = 1;      // 1.0
		double g1Duration = 5;     // 8.0
		double sDuration = 4.5;    // 7.5
		double g2Duration = 1.5;   // 1.5    These are approximate values for rats/mice taken from the black bible

		double equilibriumVolume = 0.7;
		double volumeFraction = 0.88;


		double springGrowthDuration = 1.0;


		double membrane_spacing = 0.1;
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
			GrowingContactInhibitionPhaseBasedCCM* p_cycle_model = new GrowingContactInhibitionPhaseBasedCCM();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_diff_type);
			p_cell->AddCellProperty(p_boundary);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}
		//Initialise trans nodes
		for (unsigned i = 1; i < transit_nodes.size(); i++)
		{
			GrowingContactInhibitionPhaseBasedCCM* p_cycle_model = new GrowingContactInhibitionPhaseBasedCCM();
			p_cycle_model->SetNewlyDividedRadius(epithelialNewlyDividedRadius);
			p_cycle_model->SetPreferredRadius(epithelialPreferredRadius);
			p_cycle_model->SetInteractionRadius(epithelialInteractionRadius);
			p_cycle_model->SetMDuration(mDuration);
			p_cycle_model->SetSDuration(sDuration);
			p_cycle_model->SetTransitCellG1Duration(g1Duration);
			p_cycle_model->SetG2Duration(g2Duration);
			p_cycle_model->SetEquilibriumVolume(equilibriumVolume);
			p_cycle_model->SetQuiescentVolumeFraction(volumeFraction);

			double birth_time = minCellCycleDuration * RandomNumberGenerator::Instance()->ranf();
			p_cycle_model->SetBirthTime(-birth_time);
			//p_cycle_model->SetMinCellCycleDuration(minCellCycleDuration);

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

		simulator.SetOutputDirectory("TestGrowingDivisionWithMembrane");

		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(LinearSpringForcePhaseBased<2>, p_force);
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

		MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

		cell_population.AddCellWriter<EpithelialCellPositionWriter>();
		cell_population.AddCellWriter<EpithelialCellBirthWriter>();

		simulator.Solve();

	};

	void xTestGrowingDivisionWithMembraneWnt() throw(Exception)
	{

		bool debugging = false;

        double epithelialStiffness = 20.0;
		
        double epithelialMembraneStiffness = 20.0;
		
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> membrane_nodes;
		std::vector<unsigned> location_indices;
		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned node_counter = 0;

		double dt = 0.01;
		double end_time = 50;
		double sampling_multiple = 10;

		double membraneStiffness = 0; 			// 5.0

		double epithelialPreferredRadius = 0.7;			// 1.0
		double membranePreferredRadius = 0.2;			// 0.2

		double epithelialInteractionRadius = 1.5 * epithelialPreferredRadius; // Epithelial covers stem and transit
		double membraneInteractionRadius = 7.0 * membranePreferredRadius;
		double epithelialNewlyDividedRadius = 0.7 * epithelialPreferredRadius;
		double maxInteractionRadius = 3.0;

		double minCellCycleDuration = 10;

		double mDuration = 1;      // 1.0
		double g1Duration = 5;     // 8.0
		double g1ShortDuration = 2;
		double g1LongDuration = 8;
		double sDuration = 4.5;    // 7.5
		double g2Duration = 1.5;   // 1.5    These are approximate values for rats/mice taken from the black bible

		double equilibriumVolume = 0.7;
		double volumeFraction = 0.92;


		double springGrowthDuration = 1.0;


		double membrane_spacing = 0.2;
		double epithelial_spacing = 2.0 * epithelialPreferredRadius;
		double wall_height = 20;
		double left_side = 0;
		double wall_top = wall_height;
		double wall_bottom = 0;

		WntConcentrationXSection<2>* p_wnt = WntConcentrationXSection<2>::Instance();
		p_wnt->SetType(LINEAR);

		p_wnt->SetCryptLength(wall_height);
		p_wnt->SetCryptStart(wall_bottom);
		p_wnt->SetWntThreshold(1);
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
			GrowingContactInhibitionPhaseBasedCCM* p_cycle_model = new GrowingContactInhibitionPhaseBasedCCM();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_diff_type);
			p_cell->AddCellProperty(p_boundary);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}
		//Initialise trans nodes
		for (unsigned i = 1; i < transit_nodes.size(); i++)
		{
			GrowingContactInhibitionPhaseBasedCCM* p_cycle_model = new GrowingContactInhibitionPhaseBasedCCM();
			p_cycle_model->SetNewlyDividedRadius(epithelialNewlyDividedRadius);
			p_cycle_model->SetPreferredRadius(epithelialPreferredRadius);
			p_cycle_model->SetInteractionRadius(epithelialInteractionRadius);
			p_cycle_model->SetMDuration(mDuration);
			p_cycle_model->SetSDuration(sDuration);
			p_cycle_model->SetTransitCellG1Duration(g1Duration);
			p_cycle_model->SetG2Duration(g2Duration);
			p_cycle_model->SetEquilibriumVolume(equilibriumVolume);
			p_cycle_model->SetQuiescentVolumeFraction(volumeFraction);

			p_cycle_model->SetG1LongDuration(g1ShortDuration);
			p_cycle_model->SetG1ShortDuration(g1ShortDuration);
			p_cycle_model->SetNicheLimitConcentration(.66);
			p_cycle_model->SetTransientLimitConcentration(.33);

			p_cycle_model->SetUsingWnt(true);

			double birth_time = minCellCycleDuration * RandomNumberGenerator::Instance()->ranf();
			p_cycle_model->SetBirthTime(-birth_time);
			//p_cycle_model->SetMinCellCycleDuration(minCellCycleDuration);

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}

		membraneSections.push_back(membrane_cells);

		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);
		p_wnt->SetCellPopulation(cell_population);

		{ //Division vector rules
			c_vector<double, 2> membraneAxis;
			membraneAxis(0) = 0;
			membraneAxis(1) = 1;

			MAKE_PTR(StickToMembraneDivisionRule<2>, pCentreBasedDivisionRule);
			pCentreBasedDivisionRule->SetMembraneAxis(membraneAxis);
			cell_population.SetCentreBasedDivisionRule(pCentreBasedDivisionRule);
		}

		OffLatticeSimulation<2> simulator(cell_population);

		simulator.SetOutputDirectory("TestGrowingDivisionWithMembraneWnt");

		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(LinearSpringForcePhaseBased<2>, p_force);
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

		MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

		cell_population.AddCellWriter<EpithelialCellPositionWriter>();
		cell_population.AddCellWriter<EpithelialCellBirthWriter>();
		cell_population.AddCellWriter<EpithelialCellVelocityWriter>();
		cell_population.AddCellWriter<EpithelialCellSPhaseWriter>();

		simulator.Solve();

		WntConcentrationXSection<2>::Destroy();

	};

	void xTestParameterSweep() throw(Exception)
	{

		TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-e"));
        double epithelialStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-e");

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-em"));
        double epithelialMembraneStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-em");

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-g1L"));
        double g1LongDuration = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-g1L");

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-g1S"));
        double g1ShortDuration = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-g1S");


		bool debugging = false;

		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> membrane_nodes;
		std::vector<unsigned> location_indices;
		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned node_counter = 0;

		double dt = 0.01;
		double end_time = 50;
		double sampling_multiple = 10;


		double epithelialPreferredRadius = 0.7;			// 1.0
		double membranePreferredRadius = 0.2;			// 0.2

		double epithelialInteractionRadius = 1.5 * epithelialPreferredRadius; // Epithelial covers stem and transit
		double membraneInteractionRadius = 7.0 * membranePreferredRadius;
		double epithelialNewlyDividedRadius = 0.7 * epithelialPreferredRadius;
		double maxInteractionRadius = 3.0;

		double minCellCycleDuration = 10;

		double mDuration = 1;      // 1.0
		double sDuration = 7.5;    // 7.5
		double g2Duration = 1.5;   // 1.5    These are approximate values for rats/mice taken from the black bible

		double equilibriumVolume = 0.7;
		double volumeFraction = 0.9;


		double springGrowthDuration = 1.0;


		double membrane_spacing = 0.1;
		double epithelial_spacing = 1.5 * epithelialPreferredRadius;
		double wall_height = 25;
		double left_side = 0;
		double wall_top = wall_height;
		double wall_bottom = 0;

		WntConcentrationXSection<2>* p_wnt = WntConcentrationXSection<2>::Instance();
		p_wnt->SetType(LINEAR);

		p_wnt->SetCryptLength(wall_height);
		p_wnt->SetCryptStart(wall_bottom);
		p_wnt->SetWntThreshold(1);
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
			GrowingContactInhibitionPhaseBasedCCM* p_cycle_model = new GrowingContactInhibitionPhaseBasedCCM();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_diff_type);
			p_cell->AddCellProperty(p_boundary);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}
		//Initialise trans nodes
		for (unsigned i = 1; i < transit_nodes.size(); i++)
		{
			GrowingContactInhibitionPhaseBasedCCM* p_cycle_model = new GrowingContactInhibitionPhaseBasedCCM();
			p_cycle_model->SetNewlyDividedRadius(epithelialNewlyDividedRadius);
			p_cycle_model->SetPreferredRadius(epithelialPreferredRadius);
			p_cycle_model->SetInteractionRadius(epithelialInteractionRadius);
			p_cycle_model->SetMDuration(mDuration);
			p_cycle_model->SetSDuration(sDuration);
			//p_cycle_model->SetTransitCellG1Duration(g1Duration);
			p_cycle_model->SetG2Duration(g2Duration);
			p_cycle_model->SetEquilibriumVolume(equilibriumVolume);
			p_cycle_model->SetQuiescentVolumeFraction(volumeFraction);

			p_cycle_model->SetG1LongDuration(g1LongDuration);
			p_cycle_model->SetG1ShortDuration(g1ShortDuration);
			p_cycle_model->SetNicheLimitConcentration(.66);
			p_cycle_model->SetTransientLimitConcentration(.33);

			p_cycle_model->SetUsingWnt(true);

			double birth_time = minCellCycleDuration * RandomNumberGenerator::Instance()->ranf();
			p_cycle_model->SetBirthTime(-birth_time);
			//p_cycle_model->SetMinCellCycleDuration(minCellCycleDuration);

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}

		membraneSections.push_back(membrane_cells);

		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);
		p_wnt->SetCellPopulation(cell_population);

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
        out << "/E_" << epithelialStiffness << "_EM_"<< epithelialMembraneStiffness << "_G1L_" << g1LongDuration << "_G1S_" << g1ShortDuration;

        std::string output_directory = "TestGrowingCellDivisionParameterSweep" +  out.str();
        simulator.SetOutputDirectory(output_directory);

		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(LinearSpringForcePhaseBased<2>, p_force);
		p_force->SetEpithelialSpringStiffness(epithelialStiffness);
		p_force->SetStromalSpringStiffness(epithelialStiffness);
		p_force->SetMembraneSpringStiffness(0);
		
		p_force->SetEpithelialMembraneSpringStiffness(epithelialMembraneStiffness);
		p_force->SetMembraneStromalSpringStiffness(epithelialMembraneStiffness);
		p_force->SetStromalEpithelialSpringStiffness(epithelialStiffness);

		p_force->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		p_force->SetStromalPreferredRadius(epithelialPreferredRadius);
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

		MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

		cell_population.AddCellWriter<EpithelialCellPositionWriter>();
		cell_population.AddCellWriter<EpithelialCellBirthWriter>();
		cell_population.AddCellWriter<EpithelialCellSPhaseWriter>();
		cell_population.AddCellWriter<EpithelialCellVelocityWriter>();


		simulator.Solve();

		WntConcentrationXSection<2>::Destroy();

	};

	void xTestTubeCrypt() throw(Exception)
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
		double epithelialStiffness = 10; 			// 1.5
		double membraneStiffness = 0; 			// 5.0
		double stromalStiffness = 5.0; 				// 2.0

		double epithelialMembraneStiffness = 10; 	// 1.0
		double membraneStromalStiffness = 5.0; 		// 5.0
		double stromalEpithelialStiffness = 1.0;	// 1.0

		double epithelialPreferredRadius = 0.75;			// 1.0
		double membranePreferredRadius = 0.2;			// 0.2
		double stromalPreferredRadius = 0.5;			// 1.0

		double epithelialNewlyDividedRadius = 0.7 * epithelialPreferredRadius;
		double maxInteractionRadius = 3.0;

		double epithelialInteractionRadius = 1.5 * epithelialPreferredRadius; // Epithelial covers stem and transit
		double membraneInteractionRadius = 3.0 * membranePreferredRadius;
		double stromalInteractionRadius = 2.0 * stromalPreferredRadius; // Stromal is the differentiated "filler" cells

        double g1LongDuration = 8;

        double g1ShortDuration = 2;

        double minCellCycleDuration = 10;

		double mDuration = 1;      // 1.0
		double sDuration = 7.5;    // 7.5
		double g2Duration = 1.5;   // 1.5    These are approximate values for rats/mice taken from the black bible

		double equilibriumVolume = 0.7;
		double volumeFraction = 0.9;


		double springGrowthDuration = 1.0;


		double centre_x = 5.0;
		double centre_y = 15.0;
		double base_radius = 2.0;
		double membrane_spacing = 0.2;
		double wall_height = 22;
		double left_side = centre_x - base_radius;
		double right_side = centre_x + base_radius;
		double wall_top = centre_y + wall_height;
		double wall_bottom = centre_y;

		WntConcentrationXSection<2>* p_wnt = WntConcentrationXSection<2>::Instance();
		p_wnt->SetType(LINEAR);

		p_wnt->SetCryptLength(wall_height);
		p_wnt->SetCryptStart(wall_bottom);
		p_wnt->SetWntThreshold(1);
		p_wnt->SetWntConcentrationXSectionParameter(wall_height);

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
		//PRINT_VARIABLE(acos_arg)

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
		//PRINT_VARIABLE(acos_arg)

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

		//Initialise trans nodes
		for (unsigned i = 0; i < transit_nodes.size(); i++)
		{
			GrowingContactInhibitionPhaseBasedCCM* p_cycle_model = new GrowingContactInhibitionPhaseBasedCCM();
			p_cycle_model->SetNewlyDividedRadius(epithelialNewlyDividedRadius);
			p_cycle_model->SetPreferredRadius(epithelialPreferredRadius);
			p_cycle_model->SetInteractionRadius(epithelialInteractionRadius);
			p_cycle_model->SetMDuration(mDuration);
			p_cycle_model->SetSDuration(sDuration);
			//p_cycle_model->SetTransitCellG1Duration(g1Duration);
			p_cycle_model->SetG2Duration(g2Duration);
			p_cycle_model->SetEquilibriumVolume(equilibriumVolume);
			p_cycle_model->SetQuiescentVolumeFraction(volumeFraction);

			p_cycle_model->SetG1LongDuration(g1LongDuration);
			p_cycle_model->SetG1ShortDuration(g1ShortDuration);
			p_cycle_model->SetNicheLimitConcentration(.66);
			p_cycle_model->SetTransientLimitConcentration(.33);

			p_cycle_model->SetUsingWnt(true);

			double birth_time = minCellCycleDuration * RandomNumberGenerator::Instance()->ranf();
			p_cycle_model->SetBirthTime(-birth_time);
			//p_cycle_model->SetMinCellCycleDuration(minCellCycleDuration);

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}

		membraneSections.push_back(membrane_cells);

		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);
		p_wnt->SetCellPopulation(cell_population);

		{ //Division vector rules
			c_vector<double, 2> membraneAxis;
			membraneAxis(0) = 0;
			membraneAxis(1) = 1;

			MAKE_PTR(StickToMembraneDivisionRule<2>, pCentreBasedDivisionRule);
			pCentreBasedDivisionRule->SetMembraneAxis(membraneAxis);
			cell_population.SetCentreBasedDivisionRule(pCentreBasedDivisionRule);
		}

		OffLatticeSimulation<2> simulator(cell_population);
		simulator.SetOutputDirectory("TestTubeCrypt");
		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(LinearSpringForcePhaseBased<2>, p_force);
		p_force->SetEpithelialSpringStiffness(epithelialStiffness);
		p_force->SetStromalSpringStiffness(epithelialStiffness);
		p_force->SetMembraneSpringStiffness(0);
		
		p_force->SetEpithelialMembraneSpringStiffness(epithelialMembraneStiffness);
		p_force->SetMembraneStromalSpringStiffness(epithelialMembraneStiffness);
		p_force->SetStromalEpithelialSpringStiffness(epithelialStiffness);

		p_force->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		p_force->SetStromalPreferredRadius(epithelialPreferredRadius);
		p_force->SetMembranePreferredRadius(membranePreferredRadius);

		p_force->SetEpithelialInteractionRadius(epithelialInteractionRadius);
		p_force->SetMembraneInteractionRadius(membraneInteractionRadius);
		
		p_force->SetMeinekeSpringGrowthDuration(springGrowthDuration);
		p_force->SetMeinekeDivisionRestingSpringLength(0.1);

		simulator.AddForce(p_force);

		MAKE_PTR_ARGS(AnoikisCellKiller, p_anoikis_killer, (&cell_population));
		simulator.AddCellKiller(p_anoikis_killer);

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		MAKE_PTR_ARGS(SimpleSloughingCellKiller, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer);

		MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

		cell_population.AddCellWriter<EpithelialCellPositionWriter>();
		cell_population.AddCellWriter<EpithelialCellBirthWriter>();
		cell_population.AddCellWriter<EpithelialCellSPhaseWriter>();
		cell_population.AddCellWriter<EpithelialCellVelocityWriter>();


		simulator.Solve();

		simulator.SetEndTime(50);
		
		WntConcentrationXSection<2>::Destroy();

	};

	void TestAnoikisResistant() throw(Exception)
	{

		bool debugging = false;

        double epithelialStiffness = 10.0;
		
        double epithelialMembraneStiffness = 12.0;
		
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> membrane_nodes;
		std::vector<unsigned> location_indices;
		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned node_counter = 0;

		double dt = 0.01;
		double end_time = 40;
		double sampling_multiple = 10;

		// Values that produce a working simulation in the comments
		double membraneStiffness = 5.0; 			// 5.0

		double epithelialPreferredRadius = 0.75;			// 1.0
		double membranePreferredRadius = 0.2;			// 0.2

		double epithelialInteractionRadius = 1.5 * epithelialPreferredRadius; // Epithelial covers stem and transit
		double membraneInteractionRadius = 7.0 * membranePreferredRadius;
		double epithelialNewlyDividedRadius = 0.7 * epithelialPreferredRadius;
		double maxInteractionRadius = 3.0;

		double minCellCycleDuration = 10;

		double mDuration = 1;      // 1.0
		double g1Duration = 5;     // 8.0
		double sDuration = 4.5;    // 7.5
		double g2Duration = 1.5;   // 1.5    These are approximate values for rats/mice taken from the black bible

		double equilibriumVolume = 0.7;
		double volumeFraction = 0.88;


		double springGrowthDuration = 1.0;

		double resistantPoppedUpLifeExpectancy = 15;
		double poppedUpLifeExpectancy = 0;


		double membrane_spacing = 0.2;
		double epithelial_spacing = 1.5 * epithelialPreferredRadius;
		double wall_height = 20;
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
		
		MAKE_PTR(TransitCellAnoikisResistantMutationState, p_resist);
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
			GrowingContactInhibitionPhaseBasedCCM* p_cycle_model = new GrowingContactInhibitionPhaseBasedCCM();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_diff_type);
			p_cell->AddCellProperty(p_boundary);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}
		//Initialise trans nodes
		for (unsigned i = 1; i < transit_nodes.size(); i++)
		{
			GrowingContactInhibitionPhaseBasedCCM* p_cycle_model = new GrowingContactInhibitionPhaseBasedCCM();
			p_cycle_model->SetNewlyDividedRadius(epithelialNewlyDividedRadius);
			p_cycle_model->SetPreferredRadius(epithelialPreferredRadius);
			p_cycle_model->SetInteractionRadius(epithelialInteractionRadius);
			p_cycle_model->SetMDuration(mDuration);
			p_cycle_model->SetSDuration(sDuration);
			p_cycle_model->SetTransitCellG1Duration(g1Duration);
			p_cycle_model->SetG2Duration(g2Duration);
			p_cycle_model->SetEquilibriumVolume(equilibriumVolume);
			p_cycle_model->SetQuiescentVolumeFraction(volumeFraction);

			double birth_time = minCellCycleDuration * RandomNumberGenerator::Instance()->ranf();
			p_cycle_model->SetBirthTime(-birth_time);
			//p_cycle_model->SetMinCellCycleDuration(minCellCycleDuration);

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);

			p_cell->InitialiseCellCycleModel();

			// if (i==6)
			// {
			// 	TRACE("Cell set as mutant")
			// 	p_cell->SetMutationState(p_resist);
			// }

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

		simulator.SetOutputDirectory("TestAnoikisResistant");

		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(LinearSpringForcePhaseBased<2>, p_force);
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
		p_force->SetMembraneInteractionRadius(membraneInteractionRadius);
		
		p_force->SetMeinekeSpringGrowthDuration(springGrowthDuration);
		p_force->SetMeinekeDivisionRestingSpringLength(0.1);

		p_force->SetDebugMode(debugging);

		simulator.AddForce(p_force);

		MAKE_PTR_ARGS(AnoikisCellKiller, p_anoikis_killer, (&cell_population));
		p_anoikis_killer->SetPoppedUpLifeExpectancy(poppedUpLifeExpectancy);
		p_anoikis_killer->SetResistantPoppedUpLifeExpectancy(resistantPoppedUpLifeExpectancy);
		simulator.AddCellKiller(p_anoikis_killer);

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		MAKE_PTR_ARGS(SimpleSloughingCellKiller, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer);

		MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

		cell_population.AddCellWriter<EpithelialCellPositionWriter>();
		cell_population.AddCellWriter<EpithelialCellBirthWriter>();
		TRACE("About to solve")
		simulator.Solve();

	};

	void xTestGrowingDivisionNormalAdhesion() throw(Exception)
	{

		//TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-wh"));
        double wh = 21;// CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-wh");


		bool debugging = false;

        double epithelialStiffness = 15.0;
		
        double epithelialMembraneStiffness = 10.0;
		
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> location_indices;
		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned node_counter = 0;

		double dt = 0.001;
		double end_time = 100;
		double sampling_multiple = 10;

		// Values that produce a working simulation in the comments
		double membraneStiffness = 5.0; 			// 5.0

		double epithelialPreferredRadius = 0.75;			// 1.0
		double membranePreferredRadius = 0.2;			// 0.2

		double epithelialInteractionRadius = 1.5 * epithelialPreferredRadius; // Epithelial covers stem and transit
		double membraneInteractionRadius = 7.0 * membranePreferredRadius;
		double epithelialNewlyDividedRadius = 0.7 * epithelialPreferredRadius;
		double maxInteractionRadius = 3.0;

		double minCellCycleDuration = 10;

		double mDuration = 1;      // 1.0
		double g1Duration = 5;     // 8.0
		double sDuration = 4.5;    // 7.5
		double g2Duration = 1.5;   // 1.5    These are approximate values for rats/mice taken from the black bible

		double equilibriumVolume = 0.7;
		double volumeFraction = 0.88;


		double springGrowthDuration = 3.0;


		double epithelial_spacing = 1.5 * epithelialPreferredRadius;
		double wall_height = wh;
		double left_side = 0;
		double wall_top = wall_height;
		double wall_bottom = 0;


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


		// First node is fixed
		{
			GrowingContactInhibitionPhaseBasedCCM* p_cycle_model = new GrowingContactInhibitionPhaseBasedCCM();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_diff_type);
			p_cell->AddCellProperty(p_boundary);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}
		//Initialise trans nodes
		for (unsigned i = 1; i < transit_nodes.size(); i++)
		{
			GrowingContactInhibitionPhaseBasedCCM* p_cycle_model = new GrowingContactInhibitionPhaseBasedCCM();
			p_cycle_model->SetNewlyDividedRadius(epithelialNewlyDividedRadius);
			p_cycle_model->SetPreferredRadius(epithelialPreferredRadius);
			p_cycle_model->SetInteractionRadius(epithelialInteractionRadius);

			double wiggle = 0.5 * RandomNumberGenerator::Instance()->ranf() - 0.25;
			p_cycle_model->SetMDuration(mDuration + wiggle);
			
			wiggle = 2 * RandomNumberGenerator::Instance()->ranf() - 1;
			p_cycle_model->SetSDuration(sDuration + wiggle);

			wiggle = RandomNumberGenerator::Instance()->ranf() - 0.5;
			p_cycle_model->SetTransitCellG1Duration(g1Duration + wiggle);

			wiggle = 0.25 * RandomNumberGenerator::Instance()->ranf() - 0.125;
			p_cycle_model->SetG2Duration(g2Duration + wiggle);

			p_cycle_model->SetEquilibriumVolume(equilibriumVolume);
			p_cycle_model->SetQuiescentVolumeFraction(volumeFraction);

			double birth_time = minCellCycleDuration * RandomNumberGenerator::Instance()->ranf();
			p_cycle_model->SetBirthTime(-birth_time);
			//p_cycle_model->SetMinCellCycleDuration(minCellCycleDuration);

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
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

		simulator.SetOutputDirectory("TestGrowingDivisionNormalAdhesion");

		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(NormalAdhesionForce<2>, p_force_2);
		// For this force calculator, epithelial means anything not membrane
		p_force_2->SetMembraneEpithelialSpringStiffness(epithelialMembraneStiffness);

		p_force_2->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		p_force_2->SetMembranePreferredRadius(membranePreferredRadius);

		MAKE_PTR(NonLinearSpringForceScaled<2>, p_force);
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
		p_force->SetMembraneInteractionRadius(membraneInteractionRadius);
		
		p_force->SetMeinekeSpringGrowthDuration(springGrowthDuration);
		p_force->SetMeinekeDivisionRestingSpringLength(0.1);

		p_force->SetDebugMode(debugging);

		p_force->SetCryptTop(wall_top);

		simulator.AddForce(p_force);

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		MAKE_PTR_ARGS(SimpleSloughingCellKiller, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer);

		MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

		cell_population.AddCellWriter<EpithelialCellPositionWriter>();
		cell_population.AddCellWriter<EpithelialCellBirthWriter>();

		simulator.Solve();

	};

	void xTestAdjacentCellsDivideSimulataneously() throw(Exception)
	{
		double dt = 0.001;
		double end_time = 20;
		double sampling_multiple = 1;

		double epithelialStiffness = 2.0; 			// 1.5
		double epithelialPreferredRadius = 0.7;			// 1.0
		double epithelialInteractionRadius = 1.5 * epithelialPreferredRadius; // Epithelial covers stem and transit
		double epithelialNewlyDividedRadius = 0.3;

		double stromalStiffness = 2.0; 			// 1.5
		double stromalPreferredRadius = 0.7;			// 1.0
		double stromalInteractionRadius = 1.5 * epithelialPreferredRadius;

		double stromalEpithelialStiffness = 1.0;


		std::vector<Node<2>*> nodes;

		nodes.push_back(new Node<2>(0,  false,  0, 0));
		nodes.push_back(new Node<2>(1,  false,  0, 1.4 * epithelialPreferredRadius));

		unsigned node_counter = 2;

		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, 3.0);

		std::vector<CellPtr> cells;

		MAKE_PTR(MembraneCellProliferativeType, p_membrane_type);
		MAKE_PTR(DifferentiatedCellProliferativeType, p_diff_type);
		MAKE_PTR(StemCellProliferativeType, p_stem_type);
		MAKE_PTR(TransitCellProliferativeType, p_trans_type);

		MAKE_PTR(WildTypeCellMutationState, p_state);

		for (unsigned i = 0; i < nodes.size(); i++)
		{

			GrowingContactInhibitionPhaseBasedCCM* p_cycle_model = new GrowingContactInhibitionPhaseBasedCCM();
			p_cycle_model->SetNewlyDividedRadius(epithelialNewlyDividedRadius);
			p_cycle_model->SetPreferredRadius(epithelialPreferredRadius);
			p_cycle_model->SetInteractionRadius(epithelialInteractionRadius);

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);

		}

        NodeBasedCellPopulation<2> cell_population(mesh, cells);

        OffLatticeSimulation<2> simulator(cell_population);
        simulator.SetOutputDirectory("TestAdjacentCellsDivideSimulataneously");
        simulator.SetSamplingTimestepMultiple(sampling_multiple);
        simulator.SetEndTime(end_time);
        simulator.SetDt(dt);

        MAKE_PTR(LinearSpringForcePhaseBased<2>, p_force);
        //MAKE_PTR(LinearSpringForceMembraneCellNodeBased<2>, p_force);
		p_force->SetEpithelialSpringStiffness(epithelialStiffness);
		p_force->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		p_force->SetEpithelialInteractionRadius(epithelialInteractionRadius);

		p_force->SetStromalSpringStiffness(stromalStiffness);
		p_force->SetStromalPreferredRadius(stromalPreferredRadius);
		p_force->SetStromalInteractionRadius(stromalInteractionRadius);

		p_force->SetStromalEpithelialSpringStiffness(stromalEpithelialStiffness);

		p_force->SetMeinekeSpringGrowthDuration(1);
		p_force->SetMeinekeDivisionRestingSpringLength(0.1);

		p_force->SetDebugMode(false);

        simulator.AddForce(p_force);

        MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

        simulator.Solve();
	};
};