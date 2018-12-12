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
#include "WntConcentration.hpp"

// Writers
#include "EpithelialCellBirthWriter.hpp"
#include "EpithelialCellPositionWriter.hpp"

// Misc
#include "FakePetscSetup.hpp"
#include "Debug.hpp"

class TestCrypt1DUniform : public AbstractCellBasedTestSuite
{
	public:
	void xTestCrypt1DNoContactInhibition() throw(Exception)
	{
		// This test simulates a very simple case of a 1D column of cells
		// Each cell has a UniformCellCycleModel and does not experirence contact inhibition

		// The cells stay on a straight line purely due to the division rule. Otherwise, there is
		// no active force keeping them on the straight line


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


		//bool debugging = false;

	
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> location_indices;
		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned node_counter = 0;

		double dt = 0.01;
		
		double sampling_multiple = 1;

		double maxInteractionRadius = 4.0;

		double wall_top = 20;

		double x_distance = 0;
        double y_distance = 0;
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
				UniformCellCycleModel* p_cycle_model_2 = new UniformCellCycleModel();
				double birth_time = 10 * RandomNumberGenerator::Instance()->ranf();
				p_cycle_model_2->SetBirthTime(-birth_time);
				p_cycle_model_2->SetMinCellCycleDuration(10);
				CellPtr p_cell_2(new Cell(p_state, p_cycle_model_2));
				p_cell_2->SetCellProliferativeType(p_trans_type);

				cells.push_back(p_cell_2);
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
        out << "_EES_"<< epithelialStiffness << "_EIR_" << epithelialInteractionRadius <<"_EPR_" << epithelialPreferredRadius;
        std::string output_directory = "TestCrypt1DNoContactInhibition/" +  out.str();

		simulator.SetOutputDirectory(output_directory);

		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		// MAKE_PTR(NormalAdhesionForce<2>, p_force);
		// // For this force calculator, epithelial means anything not membrane
		// p_force->SetMembraneEpithelialSpringStiffness(epithelialMembraneStiffness);

		// p_force->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		// p_force->SetMembranePreferredRadius(membranePreferredRadius);

		// simulator.AddForce(p_force);

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

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		MAKE_PTR_ARGS(SimpleSloughingCellKiller, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer);


		MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

		simulator.Solve();
	};

	void TestCrypt1DWithEndCI() throw(Exception)
	{
		// This test simulates a very simple case of a 1D column of cells
		// Each cell has a UniformContactInhibition cell cycle model
		// This means that if a cell is too compressed when it the end of its CCM, it waits until it is
		// no longer compressed, then divides immediately

		// The cells stay on a straight line purely due to the division rule. Otherwise, there is
		// no active force keeping them on the straight line


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
		WntConcentration<2>* p_wnt = WntConcentration<2>::Instance();
		p_wnt->SetType(LINEAR);
		p_wnt->SetCryptLength(20);
		p_wnt->SetWntConcentrationParameter(20); // Scales the distance to a fraction

	
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> location_indices;
		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned node_counter = 0;

		double dt = 0.001;
		
		double sampling_multiple = 10;

		double maxInteractionRadius = 2.0;

		double wall_top = 20;

		double minimumCycleTime = 10;

		unsigned cell_limit = 100; // At the smallest CI limit, there can be at most 400 cells, but we don't want to get there
		// A maximum of 350 will give at least 350 divisions, probably more, but the simulation won't run the full time
		// so in the end, there should be enough to get a decent plot

		
		double equilibriumVolume = M_PI*epithelialPreferredRadius*epithelialPreferredRadius; // Depends on the preferred radius
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
		//cell_population.SetOutputResultsForChasteVisualizer(false);
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
		WntConcentration<2>::Destroy();
	};

	void xTestForceCalculator() throw(Exception)
	{

		
        double epithelialStiffness = 20;


        double epithelialInteractionRadius = 1; //Not considered since it's 1D

        double membranePreferredRadius = 0.5; // Meaningless

        double epithelialPreferredRadius = 0.5; // Must have this value due to volume calculation - can't set node radius as SetRadius(epithelialPreferredRadius) doesn't work

        double end_time = 0.005;

	
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> location_indices;

		unsigned node_counter = 0;

		double dt = 0.01;
		
		double sampling_multiple = 1;

		double maxInteractionRadius = 2.0;

		//double wall_top = 20;

		const unsigned n_cells = 7;

		double x [n_cells] = {0,0,0,0,0,0,0};
		double y [n_cells] = {0, 0.5, 0.9, 1.6, 2.0, 2.7, 3.2};
		

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
		MAKE_PTR(BoundaryCellProperty, p_boundary);

		for(unsigned i=1; i<=n_cells; i++)
		{
			NoCellCycleModel* p_cycle_model = new NoCellCycleModel();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_diff_type);
			if (i==1)
			{
				p_cell->AddCellProperty(p_boundary);
			}

			cells.push_back(p_cell);
		}
		// Make the single cell


		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);


		OffLatticeSimulationTooManyCells simulator(cell_population);


		simulator.SetOutputDirectory("TestForceCalculator");

		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);


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
		p_force->SetMeinekeDivisionRestingSpringLength(0.01);

		p_force->Set1D(true);

		simulator.AddForce(p_force);

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		simulator.Solve();

		MeshBasedCellPopulation<2,2>* p_tissue = static_cast<MeshBasedCellPopulation<2,2>*>(&simulator.rGetCellPopulation());
		// MeshBasedCellPopulation<2,2>* p_tissue = &CellPopulation);

		std::list<CellPtr> pos_cells =  p_tissue->rGetCells();



	    for (std::list<CellPtr>::iterator cell_iter = pos_cells.begin(); cell_iter != pos_cells.end(); ++cell_iter)
	    {
	        Node<2>* p_node =  p_tissue->GetNodeCorrespondingToCell(*cell_iter);
	        c_vector<double, 2> pos;
	        pos = p_node->rGetLocation();
	        PRINT_3_VARIABLES(p_node->GetIndex() , pos[0],pos[1])
	    }
	};

	void xTestDivision() throw(Exception)
	{
		double epithelialStiffness = 20;


        double epithelialInteractionRadius = 1; //Not considered since it's 1D

        double membranePreferredRadius = 0.5; // Meaningless

        double epithelialPreferredRadius = 0.5; // Must have this value due to volume calculation - can't set node radius as SetRadius(epithelialPreferredRadius) doesn't work

        double end_time = 0.005;

	
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> location_indices;

		unsigned node_counter = 0;

		double dt = 0.01;
		
		double sampling_multiple = 1;

		double maxInteractionRadius = 2.0;

		//double wall_top = 20;

		const unsigned n_cells = 7;

		double x [n_cells] = {0,0,0,0,0,0,0};
		double y [n_cells] = {0, 0.5, 0.9, 1.6, 2.0, 2.7, 3.2};
		

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
		MAKE_PTR(TransitCellProliferativeType, p_trans_type);
		MAKE_PTR(WildTypeCellMutationState, p_state);
		MAKE_PTR(BoundaryCellProperty, p_boundary);

		for(unsigned i=1; i<=n_cells; i++)
		{
			NoCellCycleModel* p_cycle_model = new NoCellCycleModel();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_diff_type);
			if (i==1)
			{
				p_cell->AddCellProperty(p_boundary);
			}

			cells.push_back(p_cell);
		}

		UniformCellCycleModel* p_cycle_model = new UniformCellCycleModel();
		p_cycle_model->SetBirthTime(-15);
		cells[3]->SetCellProliferativeType(p_trans_type);
		cells[3]->SetCellCycleModel(p_cycle_model);


		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);

		{ //Division vector rules
			c_vector<double, 2> membraneAxis;
			membraneAxis(0) = 0;
			membraneAxis(1) = 1;

			MAKE_PTR(StickToMembraneDivisionRule<2>, pCentreBasedDivisionRule);
			pCentreBasedDivisionRule->SetMembraneAxis(membraneAxis);
			cell_population.SetCentreBasedDivisionRule(pCentreBasedDivisionRule);
		}


		OffLatticeSimulationTooManyCells simulator(cell_population);


		simulator.SetOutputDirectory("TestDivision");

		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);


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
		p_force_2->SetMeinekeDivisionRestingSpringLength(0.01);

		p_force_2->Set1D(true);

		simulator.AddForce(p_force_2);

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		simulator.Solve();

		MeshBasedCellPopulation<2,2>* p_tissue = static_cast<MeshBasedCellPopulation<2,2>*>(&simulator.rGetCellPopulation());
		// MeshBasedCellPopulation<2,2>* p_tissue = &CellPopulation);

		std::list<CellPtr> pos_cells =  p_tissue->rGetCells();



	    for (std::list<CellPtr>::iterator cell_iter = pos_cells.begin(); cell_iter != pos_cells.end(); ++cell_iter)
	    {
	        Node<2>* p_node =  p_tissue->GetNodeCorrespondingToCell(*cell_iter);
	        c_vector<double, 2> pos;
	        pos = p_node->rGetLocation();
	        PRINT_3_VARIABLES(p_node->GetIndex() , pos[0],pos[1])
	    }
	};


};
