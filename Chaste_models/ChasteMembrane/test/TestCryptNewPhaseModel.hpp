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
#include "NormalAdhesionForceNewPhaseModel.hpp"
#include "BasicNonLinearSpringForce.hpp"
#include "BasicNonLinearSpringForceNewPhaseModel.hpp"
#include "BasicContactNeighbourSpringForce.hpp"
#include "DividingRotationForce.hpp"
#include "BasicNonLinearSpringForceMultiNodeFix.hpp"

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
#include "UniformContactInhibition.hpp"
#include "WntUniformContactInhibition.hpp"
#include "SimpleWntContactInhibitionCellCycleModel.hpp"
#include "SimplifiedPhaseBasedCellCycleModel.hpp"

#include "WildTypeCellMutationState.hpp"

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

#include "PushForceModifier.hpp"
#include "BasicNonLinearSpringForce.hpp"
#include "NormalAdhesionForce.hpp"

// Wnt Concentration for position tracking
#include "WntConcentration.hpp"

// Writers
#include "EpithelialCellForceWriter.hpp"
#include "EpithelialCellBirthWriter.hpp"
#include "EpithelialCellPositionWriter.hpp"
#include "NewPhaseModelBirthWriter.hpp"
#include "ParentWriter.hpp"

// Misc
#include "FakePetscSetup.hpp"
#include "Debug.hpp"

class TestCryptNewPhaseModel : public AbstractCellBasedTestSuite
{
	
public:

	void TestSimplifiedPhaseBasedModel() throw(Exception)
	{

		// This tests the function of SimplifiedPhaseBasedCellCycleModel
		// Firstly it make sure cells are in their correct phase according to their age

		SimplifiedPhaseBasedCellCycleModel* p_cycle_model = new SimplifiedPhaseBasedCellCycleModel();
 		p_cycle_model->SetBirthTime(0);
 		p_cycle_model->SetDimension(2);

 		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> location_indices;
		std::vector<CellPtr> cells;

		location_indices.push_back(0);
		nodes.push_back(new Node<2>(0,  false,  0, 0));

		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, 1);

		MAKE_PTR(WildTypeCellMutationState, p_healthy_state);
        CellPtr p_cell(new Cell(p_healthy_state, p_cycle_model));

        cells.push_back(p_cell);

 		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);
 		

 		// Needs a Wnt concentration
 		WntConcentration<2>::Instance()->SetType(LINEAR);
        WntConcentration<2>::Instance()->SetCellPopulation(cell_population);
        WntConcentration<2>::Instance()->SetCryptLength(10);

		

        SimulationTime* p_simulation_time = SimulationTime::Instance();
        p_simulation_time->SetEndTimeAndNumberOfTimeSteps(20.0, 10);

        p_cell->GetCellData()->SetItem("volume", 0.9);

        p_cycle_model->Initialise();
        TS_ASSERT_EQUALS(p_cell->GetCellData()->GetItem("parent"), 0);

        // Cell is currently aged 0, so should still be in the T phase
        TS_ASSERT_EQUALS(p_cycle_model->GetCurrentCellCyclePhase(), W_PHASE);



        for (unsigned i = 0; i < 5; i++)
        {
            p_simulation_time->IncrementTimeOneStep();
            TS_ASSERT_EQUALS(p_cell->ReadyToDivide(), false);
        }

        // At 12 hours after increment
        p_simulation_time->IncrementTimeOneStep();
        TS_ASSERT_EQUALS(p_cell->ReadyToDivide(), false);
        TS_ASSERT_EQUALS(p_cycle_model->GetCurrentCellCyclePhase(), P_PHASE);

        p_simulation_time->IncrementTimeOneStep();
        p_simulation_time->IncrementTimeOneStep();
        p_simulation_time->IncrementTimeOneStep();
        TS_ASSERT_EQUALS(p_cell->ReadyToDivide(), true);

        CellPtr p_new_cell = p_cell->Divide();

        cell_population.AddCell(p_new_cell, p_cell);

        SimplifiedPhaseBasedCellCycleModel* p_ccm = static_cast<SimplifiedPhaseBasedCellCycleModel*>(p_cell->GetCellCycleModel());
        SimplifiedPhaseBasedCellCycleModel* p_new_ccm = static_cast<SimplifiedPhaseBasedCellCycleModel*>(p_new_cell->GetCellCycleModel());
        
        TS_ASSERT_EQUALS(p_ccm->GetCurrentCellCyclePhase(), W_PHASE)
        TS_ASSERT_EQUALS(p_new_ccm->GetCurrentCellCyclePhase(), W_PHASE)

        TS_ASSERT_EQUALS(p_new_cell->GetCellData()->GetItem("parent"), 0);
        TS_ASSERT_EQUALS(p_cell->GetCellData()->GetItem("parent"), p_new_cell->GetCellData()->GetItem("parent"))

        WntConcentration<2>::Instance()->Destroy();



	}
	// This is the most up-to-date test.
	// Any output format found in here may not be found in previous tests
	void TestCryptAlternatePhaseLengths() throw(Exception)
	{
		// This test simulates a column of cells that can now move in 2 dimensions
		// In order to retain the cells in a column, an etherial force needs to be added
		// to approximate the role of the basement membrane
		// But, since there is no 'physical' membrane causing forces perpendicular to the column
		// a minor element of randomness needs to be added to the division direction nudge
		// the column out of it's unstable equilibrium.

		// IT IMPLEMENTS A BOUNDARY CONDITION METHOD TO STOP CELLS IN MITOSIS POPPING UP

		// The cell cycle model times are changed to make growth happen over a longer period



		double popUpDistance = 1.1;
		if(CommandLineArguments::Instance()->OptionExists("-pu"))
        {
        	popUpDistance = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-pu");
        }

        double adhesionForceLawParameter = 5.0; // adhesion atraction parameter

        double attractionParameter = 5.0; // epithelial attraction parameter

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

        double epithelialPreferredRadius = 0.5; // Must have this value due to volume calculation - can't set node radius as SetRadius(epithelialPreferredRadius) doesn't work

        double equilibriumVolume = M_PI * epithelialPreferredRadius * epithelialPreferredRadius;; // Depends on the preferred radius

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

		double maxInteractionRadius = 3 * epithelialPreferredRadius;

		double wall_top = n;

		double minimumCycleTime = 10;

		unsigned cell_limit = 3 * n; // At the smallest CI limit, there can be at most 400 cells, but we don't want to get there
		// A maximum of 350 will give at least 350 divisions, probably more, but the simulation won't run the full time
		// so in the end, there should be enough to get a decent plot

		double growingFinalSpringLength = (2 * sqrt(2) - 2) * 2 * epithelialPreferredRadius; // This is the maximum spring length between two nodes of a growing cell
		// Modify this to control how large a growing cell is at any time.
		// = 2 * sqrt(2) - 2 means we use the growing circle approximation
		// = 2 * pow(2, 1/3) - 2 means we use the growing sphere approximation
        

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
        
        std::string output_directory = "TestCryptAlternatePhaseLengths/" +  out.str();

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

		PRINT_VARIABLE(end_time)
		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);
		simulator.SetCellLimit(cell_limit);

		// ********************************************************************************************
		// Set force parameters
		MAKE_PTR(BasicNonLinearSpringForceMultiNodeFix<2>, p_force);
		// MAKE_PTR(BasicNonLinearSpringForceNewPhaseModel<2>, p_force);
		// MAKE_PTR(BasicContactNeighbourSpringForce<2>, p_force);
		p_force->SetSpringStiffness(epithelialStiffness);
		p_force->SetRestLength(2 * epithelialPreferredRadius);
		p_force->SetCutOffLength(3 * epithelialPreferredRadius);
		
		p_force->SetMeinekeSpringStiffness(meinekeStiffness);
		p_force->SetMeinekeSpringGrowthDuration(wPhaseLength);

		p_force->SetAttractionParameter(attractionParameter);

		MAKE_PTR(NormalAdhesionForceNewPhaseModel<2>, p_adhesion);
        p_adhesion->SetMembraneEpithelialSpringStiffness(membraneEpithelialSpringStiffness);
        p_adhesion->SetAdhesionForceLawParameter(adhesionForceLawParameter);

		
		// ********************************************************************************************
		// These two parameters are inately linked - the initial separation of the daughter nodes
		// and the initial resting spring length
		p_force->SetMeinekeDivisionRestingSpringLength( growingFinalSpringLength );
		cell_population.SetMeinekeDivisionSeparation(0.01); // Set how far apart the cells will be upon division
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
		simulator.AddCellKiller(p_anoikis_killer);

		MAKE_PTR_ARGS(IsolatedCellKiller<2>, p_isolated_killer, (&cell_population));
		simulator.AddCellKiller(p_isolated_killer);
		// ********************************************************************************************


		MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

		simulator.SetOutputDivisionLocations(true);
		PRINT_VARIABLE(simulator.GetOutputDivisionLocations())

		cell_population.AddCellWriter<EpithelialCellForceWriter>();
		boost::shared_ptr<NewPhaseModelBirthWriter<2,2> > p_writer{new NewPhaseModelBirthWriter<2,2>};
		
		p_writer->SetSamplingMultiple(sampling_multiple);
		cell_population.AddCellWriter(p_writer);

		cell_population.AddCellWriter<ParentWriter>();
		


		simulator.Solve();
		
		// ********************************************************************************************
		// Post simulation processing
		// Probably best implemented as a 'writer', but have to work out how to do that first
		// Get the highest cell ID, which should indicate the total number of cells made in the simulation
		MeshBasedCellPopulation<2,2>* p_tissue = static_cast<MeshBasedCellPopulation<2,2>*>(&simulator.rGetCellPopulation());
		std::list<CellPtr> pos_cells =  p_tissue->rGetCells();

		unsigned cellId = 0;
		unsigned proliferative = 0;
		unsigned differentiated = 0;

		unsigned Wcells = 0;
		unsigned Pcells = 0;

        for (std::list<CellPtr>::iterator cell_iter = pos_cells.begin(); cell_iter != pos_cells.end(); ++cell_iter)
        {
        	SimplifiedPhaseBasedCellCycleModel* p_ccm = static_cast<SimplifiedPhaseBasedCellCycleModel*>((*cell_iter)->GetCellCycleModel());

        	if ((*cell_iter)->GetCellId() > cellId)
        	{
        		cellId = (*cell_iter)->GetCellId();
        	}
        	if ((*cell_iter)->GetCellProliferativeType()->IsType<DifferentiatedCellProliferativeType>() && (*cell_iter)->GetCellId() != 0)
        	{
        		differentiated++;
        	}
        	if ((*cell_iter)->GetCellProliferativeType()->IsType<TransitCellProliferativeType>())
        	{
        		proliferative++;
        	}
        	if (p_ccm->GetCurrentCellCyclePhase() == W_PHASE)
        	{
        		Wcells++;
        	}
        	if (p_ccm->GetCurrentCellCyclePhase() == P_PHASE)
        	{
        		Pcells++;
        	}
            
        }

        unsigned total_cells = proliferative + differentiated;


        WntConcentration<2>::Instance()->Destroy();

        std::stringstream kill_count_file_name;
        // Uni Mac path
        // kill_count_file_name << "/Users/phillipbrown/Research/Crypt/Data/Chaste/ParameterSearch/parameter_statistics_" << "n_" << n << "_EES_"<< epithelialStiffness;
        // Macbook path
        kill_count_file_name << "/Users/phillip/Research/Crypt/Data/Chaste/ParameterSearch/parameter_statistics_" << "n_" << n << "_EES_"<< epithelialStiffness;
        // Phoenix path
        // kill_count_file_name << "data/ParameterSearch/parameter_statistics_" << "n_" << n << "_EES_"<< epithelialStiffness;
        
        kill_count_file_name << "_MS_" << membraneEpithelialSpringStiffness << "_VF_" << int(100 * quiescentVolumeFraction) << "_CCT_" << int(cellCycleTime);
        kill_count_file_name << "_run_" << run_number << ".txt";
        // VF and PU don't change here
        //  << "_PU_" << popUpDistance <<

        ofstream kill_count_file;
        kill_count_file.open(kill_count_file_name.str());

        kill_count_file << "Total cells, killed sloughing, killed anoikis, final proliferative, final differentiated, final total\n";

        kill_count_file << cellId << "," << p_sloughing_killer->GetCellKillCount() << "," << p_anoikis_killer->GetCellKillCount();
        kill_count_file << "," << proliferative << "," << differentiated << "," << total_cells; 

        kill_count_file.close();

        // ********************************************************************************************

        PRINT_VARIABLE(p_sloughing_killer->GetCellKillCount())
		PRINT_VARIABLE(p_anoikis_killer->GetCellKillCount())
		PRINT_VARIABLE(proliferative)
		PRINT_VARIABLE(differentiated)
		PRINT_VARIABLE(total_cells)
		PRINT_VARIABLE(cellId)
		PRINT_VARIABLE(Wcells)
		PRINT_VARIABLE(Pcells)

		ofstream deathAge;
        deathAge.open("deathAge.txt");

        std::vector<double> deathAges = p_anoikis_killer->GetAgesAtDeath();

        std::vector<double>::iterator it;

        for (it = deathAges.begin(); it != deathAges.end(); ++it)
        {
        	deathAge << (*it) << "\n";
        }

        deathAge.close();
	};

};



