// Standard includes for tests
#include <cxxtest/TestSuite.h>
#include "AbstractCellBasedTestSuite.hpp"
#include "CheckpointArchiveTypes.hpp"
#include "SmartPointers.hpp"
#include "CommandLineArguments.hpp"

// Simulators
#include "OffLatticeSimulationTooManyCells.hpp"

// Forces
#include "BasicNonLinearSpringForceNewPhaseModel.hpp"
#include "NormalAdhesionForceNewPhaseModel.hpp"
#include "BasicNonLinearSpringForceMultiNodeFix.hpp"

// Mesh
#include "NodesOnlyMesh.hpp"

// Cell Population
#include "NodeBasedCellPopulation.hpp"

// Proliferative types
#include "DifferentiatedCellProliferativeType.hpp"
#include "TransitCellProliferativeType.hpp"

//Cell cycle models
#include "NoCellCycleModel.hpp"
#include "NoCellCycleModelPhase.hpp"
#include "SimplifiedPhaseBasedCellCycleModel.hpp"

// Mutation State
#include "WildTypeCellMutationState.hpp"

// Boundary conditions
#include "BoundaryCellProperty.hpp"
#include "CryptBoundaryCondition.hpp"
#include "DividingPopUpBoundaryCondition.hpp"

// Cell killers
#include "SimpleSloughingCellKiller.hpp"
#include "SimpleAnoikisCellKiller.hpp"
#include "IsolatedCellKiller.hpp"
#include "AnoikisCellKillerNewPhaseModel.hpp"
#include "SloughingCellKillerNewPhaseModel.hpp"

//Division Rules
#include "StickToMembraneDivisionRule.hpp"

// Modifiers
#include "VolumeTrackingModifier.hpp"
#include "CryptStateTrackingModifier.hpp"

// Wnt Concentration for position tracking
#include "WntConcentration.hpp"

// Writers
#include "NodePairWriter.hpp"
#include "EpithelialCellForceWriter.hpp"
#include "EpithelialCellPositionWriter.hpp"
#include "NewPhaseModelBirthPositionWriter.hpp"
#include "NewPhaseCountWriter.hpp"

// Misc
#include "FakePetscSetup.hpp"
#include "Debug.hpp"

class TestCryptColumn : public AbstractCellBasedTestSuite
{
	
public:


	void TestCrypt() throw(Exception)
	{
		// This test simulates a column of cells that move in 2 dimensions
		// Growing cells are represented as two nodes throughout the duration of W phase
		// There are three types of interactions:
		// Between cells - this uses the standard non-linear force
		// Between cells and basement membrane - this uses a force normal to the fixed membrane
		// Between nodes of the same cell - this uses a stronger linear force
		// Growing cells have a special boundary condition applied to them to force the division to
		// happen parallel to the membrane, that also, somewhat unnaturally, forces the cells
		// into specific height above the membrane, to prevent "half-cell death"



		// ********************************************************************************************
		// Input parameters in order usually expected, grouped by category
		// ********************************************************************************************



		// ********************************************************************************************
		// Crypt size parameters
		unsigned n = 20;
        if(CommandLineArguments::Instance()->OptionExists("-n"))
        {	
        	n = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-n");
        	PRINT_VARIABLE(n)

        }

        unsigned n_prolif = n - 10; // Number of proliferative cells, counting up from the bottom
        if(CommandLineArguments::Instance()->OptionExists("-np"))
        {	
        	n_prolif = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-np");
        	PRINT_VARIABLE(n_prolif)

        }
        // ********************************************************************************************

        // ********************************************************************************************
        // Force parameters
        double epithelialStiffness = 20;
        if(CommandLineArguments::Instance()->OptionExists("-ees"))
        {
        	epithelialStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ees");
        	PRINT_VARIABLE(epithelialStiffness)
        }

        double membraneStiffness = 50;
        if(CommandLineArguments::Instance()->OptionExists("-ms"))
        {
        	membraneStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ms");
        	PRINT_VARIABLE(membraneStiffness)
        }

        double meinekeStiffness = epithelialStiffness; // Newly divided spring stiffness
        if(CommandLineArguments::Instance()->OptionExists("-nds"))
        {
        	meinekeStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-nds");
        	PRINT_VARIABLE(meinekeStiffness)
        }
        // ********************************************************************************************

        // ********************************************************************************************
        // Cell cycle parameters
        double cellCycleTime = 15.0;
        if(CommandLineArguments::Instance()->OptionExists("-cct"))
        {
        	cellCycleTime = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-cct");
        	PRINT_VARIABLE(cellCycleTime)
        }

        double wPhaseLength = 10.0;
        if(CommandLineArguments::Instance()->OptionExists("-wt"))
        {
        	wPhaseLength =CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-wt");
        	PRINT_VARIABLE(wPhaseLength)
        }

        // Should be implemented better, but a quick check to make sure the cell cycle phases
        // aren't set too extreme.
        assert(cellCycleTime - wPhaseLength > 1);

        double quiescentVolumeFraction = 0.75;
        if(CommandLineArguments::Instance()->OptionExists("-vf"))
        {	
        	quiescentVolumeFraction = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-vf");
        	PRINT_VARIABLE(quiescentVolumeFraction)

        }
        // ********************************************************************************************

        // ********************************************************************************************
        // Simulation parameters
        double dt = 0.002; // The minimum to get covergant simulations for a specific parameter set
		if(CommandLineArguments::Instance()->OptionExists("-dt"))
        {
        	dt = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-dt");
        	PRINT_VARIABLE(dt)
        }
        
        double burn_in_time = 40; // The time needed to clear the transient behaviour from the initial set up
        if(CommandLineArguments::Instance()->OptionExists("-bt"))
        {	
        	burn_in_time = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-bt");
        	PRINT_VARIABLE(burn_in_time)

        }

        double simulation_length = 100;
        if(CommandLineArguments::Instance()->OptionExists("-t"))
        {	
        	simulation_length = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-t");
        	PRINT_VARIABLE(simulation_length)

        }

        double run_number = 1; // For the parameter sweep, must keep track of the run number for saving the output file
        if(CommandLineArguments::Instance()->OptionExists("-run"))
        {	
        	run_number = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-run");
        	PRINT_VARIABLE(run_number)

        }
        // ********************************************************************************************

		// ********************************************************************************************
        // Output control
		bool file_output = false;
        double sampling_multiple = 100000;
        if(CommandLineArguments::Instance()->OptionExists("-sm"))
        {   
            sampling_multiple = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-sm");
            file_output = true;
            TRACE("File output occuring")

        }
        // ********************************************************************************************


        // ********************************************************************************************
        // Fixed parameters  
        double popUpDistance = 1.1; // The distance from the membrane when cells die
        
        double epithelialPreferredRadius = 0.5; // Must have this value due to volume calculation - can't set node radius as SetRadius(epithelialPreferredRadius) doesn't work

        double equilibriumVolume = M_PI * epithelialPreferredRadius * epithelialPreferredRadius;; // Depends on the preferred radius

        double maxInteractionRadius = 3 * epithelialPreferredRadius;
        
        double growingFinalSpringLength = 1;//(2 * sqrt(2) - 2) * 2 * epithelialPreferredRadius * 1.2; 
		// Modify this to control how large a growing cell is at any time.
		// = 1 means we use the growing line approximation
		// = 2 * sqrt(2) - 2 means we use the growing circle approximation
		// = 2 * pow(2, 1/3) - 2 means we use the growing sphere approximation
        
        double wall_top = n; // The point where sloughing occurs

		unsigned cell_limit = 6 * n; // The most cells allowed in a simulation. If the cell count exceeds this, the simulation terminates
		// ********************************************************************************************		



		// ********************************************************************************************
		// Building the simulation
		// ********************************************************************************************



        // ********************************************************************************************
		// Seed the RNG in a "deterministic" way
        RandomNumberGenerator::Instance()->Reseed(run_number * quiescentVolumeFraction * epithelialStiffness);
        // ********************************************************************************************

        // ********************************************************************************************
        // Make the nodes
        unsigned node_counter = 0;

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


		// Initialise the crypt nodes
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
		// ********************************************************************************************


		// ********************************************************************************************
		// Make the cells
		std::vector<CellPtr> cells;

		MAKE_PTR(DifferentiatedCellProliferativeType, p_diff_type);
		MAKE_PTR(TransitCellProliferativeType, p_trans_type);
		MAKE_PTR(WildTypeCellMutationState, p_state);
		MAKE_PTR(BoundaryCellProperty, p_boundary);


		// Give the boundary node its cell and cycle
		{
			NoCellCycleModelPhase* p_cycle_model = new NoCellCycleModelPhase();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_diff_type);
			p_cell->AddCellProperty(p_boundary);
			p_cell->GetCellData()->SetItem("parent", p_cell->GetCellId());
			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}

		// Give the crypt its cells
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

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);
			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
			
		}
		// ********************************************************************************************

		// ********************************************************************************************
		// Make the cell population
		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);
		// ********************************************************************************************

		// ********************************************************************************************
		//Division vector rules
		c_vector<double, 2> membraneAxis;
		membraneAxis(0) = 0;
		membraneAxis(1) = 1;

		MAKE_PTR(StickToMembraneDivisionRule<2>, pCentreBasedDivisionRule);
		pCentreBasedDivisionRule->SetMembraneAxis(membraneAxis);
		pCentreBasedDivisionRule->SetWiggleDivision(true);
		cell_population.SetCentreBasedDivisionRule(pCentreBasedDivisionRule);
		// ********************************************************************************************

		// ********************************************************************************************
		// Make the simulation
		OffLatticeSimulationTooManyCells simulator(cell_population);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);
		simulator.SetCellLimit(cell_limit);
		// ********************************************************************************************

		// ********************************************************************************************
		// Building the directory name
		std::stringstream simdir;
        simdir << "n_" << n;
        simdir << "_np_" << n_prolif;
        simdir << "_EES_"<< epithelialStiffness;
        simdir << "_MS_" << membraneStiffness;
        simdir << "_CCT_" << cellCycleTime;
		simdir << "_WT_" << wPhaseLength;
        simdir << "_VF_" << quiescentVolumeFraction;
        simdir << "_run_" << run_number;
        
        std::stringstream rundir;
        rundir << "run_" << run_number;
        
        std::string output_directory = "TestCryptColumn/" +  simdir.str() + "/"  + rundir.str();

		simulator.SetOutputDirectory(output_directory);
		// ********************************************************************************************

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
        cell_population.SetOutputResultsForChasteVisualizer(file_output);
        // ********************************************************************************************

		// ********************************************************************************************
		// Add forces
		// MAKE_PTR(BasicNonLinearSpringForce<2>, p_force);
		MAKE_PTR(BasicNonLinearSpringForceMultiNodeFix<2>, p_force);
		p_force->SetSpringStiffness(epithelialStiffness);
		p_force->SetRestLength(2 * epithelialPreferredRadius);
		p_force->SetCutOffLength(3 * epithelialPreferredRadius);
		
		p_force->SetMeinekeSpringStiffness(meinekeStiffness);
		p_force->SetMeinekeSpringGrowthDuration(wPhaseLength);

		MAKE_PTR(NormalAdhesionForceNewPhaseModel<2>, p_adhesion);
        p_adhesion->SetMembraneSpringStiffness(membraneStiffness);

        // ********************************************************************************************

		
		// ********************************************************************************************
		// These two parameters are inately linked - the initial separation of the daughter nodes
		// and the initial resting spring length
		p_force->SetMeinekeDivisionRestingSpringLength( growingFinalSpringLength );
		cell_population.SetMeinekeDivisionSeparation(0.05); // Set how far apart the cells will be upon division
		// ********************************************************************************************

        // ********************************************************************************************
        // Once paramters are set, drop in the force laws
		simulator.AddForce(p_force);
		simulator.AddForce(p_adhesion);
		// ********************************************************************************************

		// ********************************************************************************************
		// Add the boundary conditions
		// Bottom cell locked in place
		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		// Cells in W phase can't pop up
		MAKE_PTR_ARGS(DividingPopUpBoundaryCondition, p_dbc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_dbc);
		// ********************************************************************************************

		// ********************************************************************************************
		// Add in the cell killers
		MAKE_PTR_ARGS(SimpleSloughingCellKiller<2>, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer);

		MAKE_PTR_ARGS(SimpleAnoikisCellKiller, p_anoikis_killer, (&cell_population));
		p_anoikis_killer->SetPopUpDistance(popUpDistance);
		simulator.AddCellKiller(p_anoikis_killer);

		MAKE_PTR_ARGS(IsolatedCellKiller<2>, p_isolated_killer, (&cell_population));
		simulator.AddCellKiller(p_isolated_killer);
		// ********************************************************************************************

		// ********************************************************************************************
		// Modifiers
		MAKE_PTR(VolumeTrackingModifier<2>, p_vmod);
		simulator.AddSimulationModifier(p_vmod);
		// ********************************************************************************************



		// ********************************************************************************************
		// Run the simulation
		// ********************************************************************************************



		// ********************************************************************************************
		// Simulate through the transient behaviour
		simulator.SetEndTime(burn_in_time);

		TRACE("Simulating through transient")
		simulator.Solve();
		// ********************************************************************************************


		// ********************************************************************************************
		// Prepare for proper simulation
		// ********************************************************************************************

		// ********************************************************************************************
		// Capture the number of cell births during the transient time
		unsigned transient_births = simulator.GetNumBirths();
		// ********************************************************************************************


		// ********************************************************************************************
		// Reset the cell killers
		simulator.RemoveAllCellKillers();
		MAKE_PTR_ARGS(SloughingCellKillerNewPhaseModel, p_sloughing_killer_2, (&cell_population));
		p_sloughing_killer_2->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer_2);

		MAKE_PTR_ARGS(AnoikisCellKillerNewPhaseModel, p_anoikis_killer_2, (&cell_population));
		p_anoikis_killer_2->SetPopUpDistance(popUpDistance);
		simulator.AddCellKiller(p_anoikis_killer_2);

		simulator.AddCellKiller(p_isolated_killer);
		// ********************************************************************************************

		// ********************************************************************************************
		// Modifier to track the crypt statistics
		MAKE_PTR(CryptStateTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);
		// ********************************************************************************************

		// ********************************************************************************************
		// Reset the end time
		simulator.SetEndTime(burn_in_time + simulation_length);
		// ********************************************************************************************


		// ********************************************************************************************
        // Add cell population writers if they are requested
        if (file_output)
        {
        	MeshBasedCellPopulation<2,2>* p_tissue = static_cast<MeshBasedCellPopulation<2,2>*>(&simulator.rGetCellPopulation());
            p_tissue->AddCellWriter<EpithelialCellPositionWriter>();
        }
        // ********************************************************************************************



		// ********************************************************************************************
		// Run the simulation to be observed
		TRACE("Starting simulation proper")
		simulator.Solve();
		// ********************************************************************************************



		// ********************************************************************************************
		// Post simulation tasks
		WntConcentration<2>::Instance()->Destroy();
		// ********************************************************************************************

		// ********************************************************************************************
		// Collate simulation data
		// This number will not match the cell births from CryptStateTrackingModifier
		// The Chaste Division event is connected to the actual division event, so there will
		// always be a 1-1 ratio, however, some Chaste divisions happen just before the burn in
		// time finishes, while their paired actual divisions happen after, thus the Chaste divisions
		// won't be counted, but the actual divisions will.
		// The reverse happens when the simulation stops, some Chaste divisions will be counted, but
		// the paired actual divisions won't have happened before the simulation ends
		// The numbers will actually be close because those Chaste divisions missed before the start
		// will be roughly the same as the actual divisions missed after the end.
		// The modifier division count will be the "correct" division count for the model
		unsigned simulation_births = simulator.GetNumBirths() - transient_births;
 		simulation_births *= 1; // Literally just to keep the compiler on phoenix happy

		// ********************************************************************************************
		// Simulation characteristic data output
		// ********************************************************************************************
		double 		anoikis 			= double(p_anoikis_killer_2->GetCellKillCount())/simulation_length;
		double 		averageCellCount 	= p_mod->GetAverageCount() - 1;
		double 		birthRate 			= double(p_mod->GetBirthCount())/simulation_length;
		unsigned 	maxBirthPosition 	= p_mod->GetMaxBirthPosition();

        // ********************************************************************************************
        // Output data to the command line
		TRACE("START")
		PRINT_VARIABLE(anoikis)   				// Anoikis rate
		PRINT_VARIABLE(averageCellCount) 		// Expected total number of cells in the crypt
		PRINT_VARIABLE(birthRate)				// Birth rate
		PRINT_VARIABLE(maxBirthPosition)		// Highest cell position where cell division happens
		TRACE("END")
		// ********************************************************************************************

	};

};



