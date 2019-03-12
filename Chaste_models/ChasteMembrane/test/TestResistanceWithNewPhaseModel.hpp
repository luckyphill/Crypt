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
#include "NormalAdhesionForce.hpp"
#include "BasicNonLinearSpringForce.hpp"
#include "NormalAdhesionForceNewPhaseModel.hpp"
#include "BasicNonLinearSpringForceNewPhaseModel.hpp"
#include "DividingRotationForce.hpp"
#include "BasicContactNeighbourSpringForce.hpp"

// Mesh
#include "HoneycombMeshGenerator.hpp" //Generates mesh
#include "NodesOnlyMesh.hpp"
#include "CellsGenerator.hpp"

// Cell Populations
#include "NodeBasedCellPopulation.hpp"
#include "MonolayerNodeBasedCellPopulation.hpp"

// Proliferative types
#include "MembraneCellProliferativeType.hpp"
#include "DifferentiatedCellProliferativeType.hpp"
#include "TransitCellProliferativeType.hpp"
#include "StemCellProliferativeType.hpp"

//Cell cycle models
#include "NoCellCycleModel.hpp"
#include "UniformCellCycleModel.hpp"
#include "UniformContactInhibition.hpp"
#include "WntUniformContactInhibition.hpp"
#include "SimpleWntContactInhibitionCellCycleModel.hpp"
#include "SimpleWntWithAnoikisResistanceAndSenescence.hpp"

// Mutation state
#include "WildTypeCellMutationState.hpp"
#include "TransitCellAnoikisResistantMutationState.hpp"
#include "WeakenedMembraneAdhesion.hpp"

// Boundary conditions
#include "BoundaryCellProperty.hpp"
#include "CryptBoundaryCondition.hpp"
#include "DividingBoundaryCondition.hpp"
#include "DividingPopUpBoundaryCondition.hpp"

// Cell killers
#include "SimpleSloughingCellKiller.hpp"
#include "TopAndBottomSloughing.hpp"
#include "SimpleAnoikisCellKiller.hpp"
#include "IsolatedCellKiller.hpp"

//Division Rules
#include "StickToMembraneDivisionRule.hpp"

// Modifiers
#include "VolumeTrackingModifier.hpp"

//Division Rules
#include "StickToMembraneDivisionRule.hpp"

// Wnt Concentration for position tracking
#include "WntConcentration.hpp"

// Writers
#include "EpithelialCellBirthWriter.hpp"
#include "EpithelialCellPositionWriter.hpp"

// Misc
#include "FakePetscSetup.hpp"
#include "Debug.hpp"

class TestAnoikisResistanceWithNewPhaseModel : public AbstractCellBasedTestSuite
{
	// Most up to date test: TestResistantAndWeakenedDivisionBC
	// Running any other test may not produce output in the expected format
	// for further processing

	public:

	void TestResistanceWithNewPhaseModel() throw(Exception)
	{
		// This test runs a healthy crypt and introduces a single anoikis resistant cell
		// The resistant cell position is specified as a cell position
		// The position of both the anoikis resistance and adhesion weakening can be specified
		// If adhesion weakening position not specified, assumed to be the same cell as
		// anoikis resistance

		// The simulation runs for a set amount of time before mutations are introduced, which is
		// specified by the flag -bt (burn-in time). The flag -t specifies the length of simulation
		// after burn-in


		double popUpDistance = 1.1;
		if(CommandLineArguments::Instance()->OptionExists("-pu"))
        {
        	popUpDistance = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-pu");
        }

        double membraneEpithelialSpringStiffness = 50;
        if(CommandLineArguments::Instance()->OptionExists("-ms"))
        {
        	membraneEpithelialSpringStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ms");
        }

		double epithelialStiffness = 20;
        if(CommandLineArguments::Instance()->OptionExists("-ees"))
        {
        	epithelialStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ees");
        }

        double meinekeStiffness = epithelialStiffness; // Newly divided spring stiffness
        if(CommandLineArguments::Instance()->OptionExists("-nds"))
        {
        	meinekeStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-nds");
        }

        // The length of time to allow the simulation to reach "dynamic equilibrium"
        double burn_in_time = 100;
        if(CommandLineArguments::Instance()->OptionExists("-bt"))
        {	
        	burn_in_time = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-bt");

        }

        // The length of time after burn-in
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


        bool wiggle = true; // Default to "2D"
        if(CommandLineArguments::Instance()->OptionExists("-oned"))
        {	
        	wiggle = false;
        }

        bool java_visualiser = false;
        double sampling_multiple = 100000;
        if(CommandLineArguments::Instance()->OptionExists("-sm"))
        {   
            sampling_multiple = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-sm");
            java_visualiser = true;

        }

        double cellCycleTime = 15.0;
        if(CommandLineArguments::Instance()->OptionExists("-cct"))
        {
        	cellCycleTime = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-cct");
        }

        double wPhaseLength = 10.0;
        if(CommandLineArguments::Instance()->OptionExists("-wt"))
        {
        	wPhaseLength =CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-wt");
        }

        assert(cellCycleTime - wPhaseLength > 1);

        double resistantPoppedUpLifeExpectancy = DBL_MAX; // By default, popped up cells won't die within the simulation
        if(CommandLineArguments::Instance()->OptionExists("-rple"))
        {
        	resistantPoppedUpLifeExpectancy = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-rple");
        }

        unsigned resistantPosition = 1;
        if(CommandLineArguments::Instance()->OptionExists("-rpos"))
        {	
        	resistantPosition = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-rpos");

        }

        double resistantCellCycleTime = 2.0;
        if(CommandLineArguments::Instance()->OptionExists("-rcct"))
        {
        	resistantCellCycleTime = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-rcct");
        }

        unsigned weakenedPosition = resistantPosition;
        if(CommandLineArguments::Instance()->OptionExists("-wpos"))
        {	
        	weakenedPosition = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-wpos");

        }

        double weakeningFraction = 1.0; // Default is no weakening
        if(CommandLineArguments::Instance()->OptionExists("-wf"))
        {
        	weakeningFraction = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-wf");
        }



        double epithelialPreferredRadius = 0.5; // Must have this value due to volume calculation - can't set node radius as SetRadius(epithelialPreferredRadius) doesn't work

        double equilibriumVolume = M_PI*epithelialPreferredRadius*epithelialPreferredRadius;; // Depends on the preferred radius

        bool multiple_cells = true;
        
        unsigned n = 20;
        if(CommandLineArguments::Instance()->OptionExists("-n"))
        {	
        	n = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-n");

        }

        unsigned n_prolif = n - 10; // Number of proliferative cells, counting up from the bottom
        if(CommandLineArguments::Instance()->OptionExists("-np"))
        {	
        	n_prolif = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-np");

        }

        unsigned node_counter = 0;

		double dt = 0.002; // The minimum to get covergant simulations for a specific parameter set
		if(CommandLineArguments::Instance()->OptionExists("-dt"))
        {
        	dt = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-dt");
        }

		double maxInteractionRadius = 2.0;

		double wall_top = n;

		double minimumCycleTime = 10;

		unsigned cell_limit = 5 * n; // At the smallest CI limit, there can be at most 400 cells, but we don't want to get there
		// A maximum of 350 will give at least 350 divisions, probably more, but the simulation won't run the full time
		// so in the end, there should be enough to get a decent plot
        

        // First things first - need to seed the rng to make sure each simulation is different
        RandomNumberGenerator::Instance()->Reseed(run_number * quiescentVolumeFraction * epithelialStiffness);
		//bool debugging = false;

		// Make the Wnt concentration for tracking cell position so division can be turned off
		// Create an instance of a Wnt concentration
        	
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> location_indices;


		// Column building parameters
		double x_distance = 0.6;
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

		for(unsigned i = 1; i <= n; i++)
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



		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, maxInteractionRadius);

		std::vector<CellPtr> cells;

		MAKE_PTR(DifferentiatedCellProliferativeType, p_diff_type);
		MAKE_PTR(TransitCellProliferativeType, p_trans_type);
		MAKE_PTR(WildTypeCellMutationState, p_state);
		MAKE_PTR(BoundaryCellProperty, p_boundary);

		MAKE_PTR(TransitCellAnoikisResistantMutationState, p_resistant);
		MAKE_PTR(WeakenedMembraneAdhesion, p_weakened);

		// Make the single cell

		{
			NoCellCycleModel* p_cycle_model = new NoCellCycleModel();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_diff_type);
			p_cell->AddCellProperty(p_boundary);
			p_cell->GetCellData()->SetItem("parent", p_cell->GetCellId());
			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}




		for(unsigned i=1; i<=n; i++)
		{

			SimplifiedPhaseBasedCellCycleModel* p_cycle_model = new SimplifiedPhaseBasedCellCycleModel();
			double birth_time = cellCycleTime * RandomNumberGenerator::Instance()->ranf();

			p_cycle_model->SetWDuration(wPhaseLength);
			p_cycle_model->SetBasePDuration(cellCycleTime - wPhaseLength);
			p_cycle_model->SetDimension(2);
   			p_cycle_model->SetEquilibriumVolume(equilibriumVolume);
   			p_cycle_model->SetQuiescentVolumeFraction(quiescentVolumeFraction);
   			p_cycle_model->SetWntThreshold(1 - (double)n_prolif/n);
			p_cycle_model->SetBirthTime(-birth_time);
			// if(CommandLineArguments::Instance()->OptionExists("-rcct"))
			// {
			// 	p_cycle_model->SetPoppedUpG1Duration(resistantCellCycleTime);
			// }

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);
			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);

			
		}


		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);


		//Division vector rules
		c_vector<double, 2> membraneAxis;
		membraneAxis(0) = 0;
		membraneAxis(1) = 1;

		MAKE_PTR(StickToMembraneDivisionRule<2>, pCentreBasedDivisionRule);
		pCentreBasedDivisionRule->SetMembraneAxis(membraneAxis);
		pCentreBasedDivisionRule->SetWiggleDivision(wiggle);
		cell_population.SetCentreBasedDivisionRule(pCentreBasedDivisionRule);
		


		// A simulator with a stopping even when there are too many cells
		OffLatticeSimulationTooManyCells simulator(cell_population);


		// Building the directory name
		std::stringstream out;
        out << "n_" << n;
        out << "_EES_"<< epithelialStiffness << "_VF_" << quiescentVolumeFraction << "_MS_" << membraneEpithelialSpringStiffness << "_CCT_" << int(cellCycleTime);
        out << "_run_" << run_number;
        std::string output_directory = "TestCryptResistantNewPhaseModel/" +  out.str();

		simulator.SetOutputDirectory(output_directory);

		// ********************************************************************************************
		// Set Wnt parameters and add in the cell population
		WntConcentration<2>::Instance()->SetType(LINEAR);
        WntConcentration<2>::Instance()->SetCellPopulation(cell_population);
        WntConcentration<2>::Instance()->SetCryptLength(n);
        // ********************************************************************************************


		// ********************************************************************************************
        // File outputs
        // Files are only output if the command line argument -sm exists and a sampling multiple is set
        simulator.SetSamplingTimestepMultiple(sampling_multiple);
        cell_population.SetOutputResultsForChasteVisualizer(java_visualiser);
        // ********************************************************************************************

		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);
		simulator.SetCellLimit(cell_limit);

		// ********************************************************************************************
		// Set force parameters
		MAKE_PTR(BasicNonLinearSpringForceNewPhaseModel<2>, p_force);
		// MAKE_PTR(BasicContactNeighbourSpringForce<2>, p_force);
		p_force->SetSpringStiffness(epithelialStiffness);
		p_force->SetRestLength(2 * epithelialPreferredRadius);
		p_force->SetCutOffLength(3 * epithelialPreferredRadius);
		
		p_force->SetMeinekeSpringStiffness(meinekeStiffness);
		p_force->SetMeinekeSpringGrowthDuration(wPhaseLength);


		MAKE_PTR(NormalAdhesionForceNewPhaseModel<2>, p_adhesion);
        p_adhesion->SetMembraneEpithelialSpringStiffness(membraneEpithelialSpringStiffness);
        p_adhesion->SetWeakeningFraction(weakeningFraction);
		
		// ********************************************************************************************
		// These two parameters are inately linked - the initial separation of the daughter nodes
		// and the initial resting spring length

		double growingFinalSpringLength = (2 * sqrt(2) - 2) * 2 * epithelialPreferredRadius; // This is the maximum spring length between two nodes of a growing cell
		// Modify this to control how large a growing cell is at any time.
		// = 2 * sqrt(2) - 2 means we use the growing circle approximation
		// = 2 * pow(2, 1/3) - 2 means we use the growing sphere approximation

		p_force->SetMeinekeDivisionRestingSpringLength( growingFinalSpringLength );
		cell_population.SetMeinekeDivisionSeparation(0.01);
		// ********************************************************************************************

        // ********************************************************************************************
        // Once paramters are set, drop in the force laws
		simulator.AddForce(p_force);
		simulator.AddForce(p_adhesion);
		// ********************************************************************************************
		// Add the boundary conditions

		// Bottom cell locked in place
		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		// Cells in W phase can't pop up
		MAKE_PTR_ARGS(DividingPopUpBoundaryCondition, p_dbc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_dbc);

		// ********************************************************************************************
		// Add in the cell killers
		MAKE_PTR_ARGS(SimpleSloughingCellKiller<2>, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer);

		MAKE_PTR_ARGS(SimpleAnoikisCellKiller, p_anoikis_killer, (&cell_population));
		p_anoikis_killer->SetPopUpDistance(popUpDistance);
		p_anoikis_killer->SetResistantPoppedUpLifeExpectancy(resistantPoppedUpLifeExpectancy); // resistant cells don't die from anoikis immediately
		simulator.AddCellKiller(p_anoikis_killer);

		MAKE_PTR_ARGS(IsolatedCellKiller<2>, p_isolated_killer, (&cell_population));
		simulator.AddCellKiller(p_isolated_killer);
		// ********************************************************************************************


		MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

		simulator.SetOutputDivisionLocations(true);
		simulator.SetEndTime(burn_in_time);
		simulator.Solve();
		TRACE("Burn-in complete")


		// ********************************************************************************************
		// Post simulation processing
		// Probably best implemented as a 'writer', but have to work out how to do that first
		// Get the highest cell ID, which should indicate the total number of cells made in the simulation
		MeshBasedCellPopulation<2,2>* p_tissue = static_cast<MeshBasedCellPopulation<2,2>*>(&simulator.rGetCellPopulation());
		std::list<CellPtr> pos_cells =  p_tissue->rGetCells();


		// Sort the cells in order of height
		// If errors occur with useless error messages, this might be the cause
		pos_cells.sort(
			[p_tissue](CellPtr A, CellPtr B)
		{
				Node<2>* node_A = p_tissue->GetNodeCorrespondingToCell(A);
				Node<2>* node_B = p_tissue->GetNodeCorrespondingToCell(B);
				return (node_A->rGetLocation()[1] < node_B->rGetLocation()[1]);
		});

		std::list<CellPtr>::iterator it = pos_cells.begin();
		std::advance(it, resistantPosition);

		(*it)->SetMutationState(p_resistant);

		it = pos_cells.begin();
		std::advance(it, weakenedPosition);

		(*it)->AddCellProperty(p_weakened);

		simulator.SetEndTime(burn_in_time + end_time);
		simulator.Solve();

		WntConcentration<2>::Instance()->Destroy();


	};


};
