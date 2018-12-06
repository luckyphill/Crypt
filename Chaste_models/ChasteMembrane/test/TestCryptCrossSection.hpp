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
#include "UniformContactInhibition.hpp"
#include "WntUniformContactInhibition.hpp"

#include "WildTypeCellMutationState.hpp"

// Boundary conditions
#include "BoundaryCellProperty.hpp"
#include "CryptBoundaryCondition.hpp"

// Cell killers
#include "SimpleSloughingCellKiller.hpp"
#include "TopAndBottomSloughing.hpp"
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

// Wnt Concentration for position tracking
#include "WntConcentrationXSection.hpp"

// Writers
#include "EpithelialCellBirthWriter.hpp"
#include "EpithelialCellPositionWriter.hpp"

// Misc
#include "FakePetscSetup.hpp"
#include "Debug.hpp"

class TestCryptCrossSection : public AbstractCellBasedTestSuite
{
	public:

	void TestCryptCI() throw(Exception)
	{
		// This test simulates a column of cells that can now move in 2 dimensions
		// In order to retain the cells in a column, an etherial force needs to be added
		// to approximate the role of the basement membrane
		// But, since there is no 'physical' membrane causing forces perpendicular to the column
		// a minor element of randomness needs to be added to the division direction nudge
		// the column out of it's unstable equilibrium.

		// 1: add division nudge
		// 2: add BM force to pull back into column
		// 3: determine BM force and range needed to get varying amounts of popping up
		// 4: make sure contact neighbours is correct
		// 5: use phase based and contact inhibition CCM
		// 6: use e-e force determined from experiments, and CI percentage


        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-ees"));
        double epithelialStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ees");

        double epithelialInteractionRadius = 1; //Not considered since it's 1D

        double membranePreferredRadius = 0.5; // Meaningless

        double epithelialPreferredRadius = 0.5; // Must have this value due to volume calculation - can't set node radius as SetRadius(epithelialPreferredRadius) doesn't work


        bool multiple_cells = true;
        unsigned n = 20;

        double end_time = 100;
        if(CommandLineArguments::Instance()->OptionExists("-t"))
        {	
        	end_time = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-t");

        }

        double quiescentVolumeFraction = 0.88; // Set by the user
        if(CommandLineArguments::Instance()->OptionExists("-vf"))
        {	
        	quiescentVolumeFraction = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-vf");

        }

        double run_number = 1; // For the parameter sweep, must keep track of the run number for saving the output file
        if(CommandLineArguments::Instance()->OptionExists("-run"))
        {	
        	run_number = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-run");

        }

        // First things first - need to seed the rng to make sure each simulation is different
        RandomNumberGenerator::Instance()->Reseed(run_number * quiescentVolumeFraction * epithelialStiffness);
		//bool debugging = false;

		// Make the Wnt concentration for tracking cell position so division can be turned off
		WntConcentrationXSection<2>* p_wnt = WntConcentrationXSection<2>::Instance();
		p_wnt->SetType(LINEAR);
		p_wnt->SetCryptLength(20);
		p_wnt->SetCryptStart(0);
		p_wnt->SetWntThreshold(.75);
		p_wnt->SetWntConcentrationXSectionParameter(20); // Scales the distance to a fraction

	
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> location_indices;
		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned node_counter = 0;

		double dt = 0.001;
		
		double sampling_multiple = 1000000;

		double maxInteractionRadius = 2.0;

		double wall_top = 20;

		double minimumCycleTime = 10;

		unsigned cell_limit = 100; // At the smallest CI limit, there can be at most 400 cells, but we don't want to get there
		// A maximum of 350 will give at least 350 divisions, probably more, but the simulation won't run the full time
		// so in the end, there should be enough to get a decent plot

		
		double equilibriumVolume = M_PI*epithelialPreferredRadius*epithelialPreferredRadius;; // Depends on the preferred radius
		PRINT_VARIABLE(equilibriumVolume)
		PRINT_VARIABLE(quiescentVolumeFraction);

		double x_distance = 0;
        double y_distance = 0;
		double x = x_distance;
		double y = y_distance;

		// Put down first node which will be a boundary condition node
		Node<2>* single_node =  new Node<2>(node_counter,  false,  x, y);
		single_node->SetRadius(epithelialPreferredRadius);
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
				single_node_2->SetRadius(epithelialPreferredRadius);
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

		{
			NoCellCycleModel* p_cycle_model = new NoCellCycleModel();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_diff_type);
			p_cell->AddCellProperty(p_boundary);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}

		if(multiple_cells)
		{
			for(unsigned i=1; i<=n; i++)
			{
				WntUniformContactInhibition* p_cycle_model = new WntUniformContactInhibition();
				double birth_time = minimumCycleTime * RandomNumberGenerator::Instance()->ranf();
				p_cycle_model->SetBirthTime(-birth_time);
				p_cycle_model->SetMinCellCycleDuration(minimumCycleTime);
				p_cycle_model->SetQuiescentVolumeFraction(quiescentVolumeFraction);
				p_cycle_model->SetEquilibriumVolume(equilibriumVolume);
				p_cycle_model->SetProliferativeRegion(0.25); // 0.25 will occur 3/4 up the crypt


				CellPtr p_cell(new Cell(p_state, p_cycle_model));
				p_cell->SetCellProliferativeType(p_trans_type);

				cells.push_back(p_cell);
			}
		}


		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);
		p_wnt->SetCellPopulation(cell_population);
		cell_population.SetOutputResultsForChasteVisualizer(false);
		cell_population.SetMeinekeDivisionSeparation(0.05); // Set how far apart the cells will be upon division



		{ //Division vector rules
			c_vector<double, 2> membraneAxis;
			membraneAxis(0) = 0;
			membraneAxis(1) = 1;

			MAKE_PTR(StickToMembraneDivisionRule<2>, pCentreBasedDivisionRule);
			pCentreBasedDivisionRule->SetMembraneAxis(membraneAxis);
			cell_population.SetCentreBasedDivisionRule(pCentreBasedDivisionRule);
		}



		OffLatticeSimulationTooManyCells simulator(cell_population);



		std::stringstream out;
        out << "n_" << n;
        out << "_EES_"<< epithelialStiffness << "_VF_" << quiescentVolumeFraction;
        if(CommandLineArguments::Instance()->OptionExists("-run"))
        {
        	out << "_run_" << run_number;
        }
        std::string output_directory = "TestCrypt1DWithEndCI/" +  out.str();

		simulator.SetOutputDirectory(output_directory);

		PRINT_VARIABLE(end_time)
		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);
		simulator.SetCellLimit(cell_limit);

		// Use the generalised spring force
		// MAKE_PTR(GeneralisedLinearSpringForce<2>, p_gen_force);
		// simulator.AddForce(p_gen_force);

		// Use the specialised spring force
		MAKE_PTR(LinearSpringForceMembraneCellNodeBased<2>, p_force);
		p_force->SetEpithelialSpringStiffness(epithelialStiffness);
		p_force->SetStromalSpringStiffness(epithelialStiffness);

		p_force->SetStromalEpithelialSpringStiffness(epithelialStiffness);

		p_force->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		p_force->SetStromalPreferredRadius(epithelialPreferredRadius);
		p_force->SetMembranePreferredRadius(membranePreferredRadius);

		p_force->SetEpithelialInteractionRadius(epithelialInteractionRadius);
		p_force->SetStromalInteractionRadius(epithelialInteractionRadius);
		
		p_force->SetMeinekeSpringGrowthDuration(1);
		p_force->SetMeinekeDivisionRestingSpringLength(0.05);

		p_force->Set1D(true);

		simulator.AddForce(p_force);

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		MAKE_PTR_ARGS(TopAndBottomSloughing, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer);


		//cell_population.AddCellWriter<EpithelialCellBirthWriter>();
		//cell_population.AddCellWriter<EpithelialCellPositionWriter>();

		MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

		simulator.SetOutputDivisionLocations(true);
		PRINT_VARIABLE(simulator.GetOutputDivisionLocations())

		simulator.Solve();
		WntConcentrationXSection<2>::Destroy();
	};

	
};
