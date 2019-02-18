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
#include "DividingRotationForce.hpp"
#include "BasicContactNeighbourSpringForce.hpp"

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
#include "SimpleWntWithAnoikisResistantMitosisArrest.hpp"

// Mutation state
#include "WildTypeCellMutationState.hpp"
#include "TransitCellAnoikisResistantMutationState.hpp"
#include "WeakenedMembraneAdhesion.hpp"

// Boundary conditions
#include "BoundaryCellProperty.hpp"
#include "CryptBoundaryCondition.hpp"

// Cell killers
#include "SimpleSloughingCellKiller.hpp"
#include "TopAndBottomSloughing.hpp"
#include "SimpleAnoikisCellKiller.hpp"

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

class TestAnoikisResistance : public AbstractCellBasedTestSuite
{
	public:

	void xTestCryptAnoikisResistant() throw(Exception)
	{
		// This test runs a healthy crypt and introduces a single anoikis resistant cell
		// The resistant cell position is specified as a cell position (1 to 15)
		// The legnth of resistance can also be specified. If it is not, resistance is assumed permanent


		double popUpDistance = 1.1;
		if(CommandLineArguments::Instance()->OptionExists("-pu"))
        {
        	popUpDistance = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-pu");
        }

        double adhesionForceLawParameter = 5.0;
        if(CommandLineArguments::Instance()->OptionExists("-aap"))
        {
        	adhesionForceLawParameter = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-aap");
        }

        double attractionParameter = 5.0; // epithelial attraction parameter
        if(CommandLineArguments::Instance()->OptionExists("-eap"))
        {
        	attractionParameter = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-eap");
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

        unsigned n_prolif = 15; // Number of proliferative cells, counting up from the bottom
        if(CommandLineArguments::Instance()->OptionExists("-np"))
        {	
        	n_prolif = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-np");

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

        double cellCycleTime = 2.0;
        bool customCellCycleTime = false;
        if(CommandLineArguments::Instance()->OptionExists("-cct"))
        {
        	customCellCycleTime = true;
        	cellCycleTime = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-cct");
        }

        double resistantPoppedUpLifeExpectancy = end_time;
        if(CommandLineArguments::Instance()->OptionExists("-rple"))
        {
        	resistantPoppedUpLifeExpectancy = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-rple");
        }

        unsigned resistantPosition = 1;
        if(CommandLineArguments::Instance()->OptionExists("-rpos"))
        {	
        	resistantPosition = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-rpos");

        }

        double epithelialPreferredRadius = 0.5; // Must have this value due to volume calculation - can't set node radius as SetRadius(epithelialPreferredRadius) doesn't work

        double equilibriumVolume = M_PI*epithelialPreferredRadius*epithelialPreferredRadius;; // Depends on the preferred radius

        bool multiple_cells = true;
        unsigned n = 20;

        unsigned node_counter = 0;

		double dt = 0.001;

		double maxInteractionRadius = 2.0;

		double wall_top = 20;

		double minimumCycleTime = 10;

		unsigned cell_limit = 200; // At the smallest CI limit, there can be at most 400 cells, but we don't want to get there
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

		if(multiple_cells)
		{
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
			
		}


		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, maxInteractionRadius);

		std::vector<CellPtr> cells;

		MAKE_PTR(DifferentiatedCellProliferativeType, p_diff_type);
		MAKE_PTR(TransitCellProliferativeType, p_trans_type);
		MAKE_PTR(WildTypeCellMutationState, p_state);
		MAKE_PTR(BoundaryCellProperty, p_boundary);

		MAKE_PTR(TransitCellAnoikisResistantMutationState, p_resistant);

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

		if(multiple_cells)
		{
			for(unsigned i=1; i<=n; i++)
			{

				SimpleWntContactInhibitionCellCycleModel* p_cycle_model = new SimpleWntContactInhibitionCellCycleModel();
				double birth_time = (minimumCycleTime + cellCycleTime - 2) * RandomNumberGenerator::Instance()->ranf();
				if (customCellCycleTime)
				{
					p_cycle_model->SetTransitCellG1Duration(cellCycleTime);
				}
				p_cycle_model->SetDimension(2);
	   			p_cycle_model->SetEquilibriumVolume(equilibriumVolume);
	   			p_cycle_model->SetQuiescentVolumeFraction(quiescentVolumeFraction);
	   			p_cycle_model->SetWntThreshold(1 - (double)n_prolif/n);
				p_cycle_model->SetBirthTime(-birth_time);

				CellPtr p_cell(new Cell(p_state, p_cycle_model));
				p_cell->SetCellProliferativeType(p_trans_type);
				p_cell->InitialiseCellCycleModel();

				if (i == resistantPosition)
				{
					p_cell->SetMutationState(p_resistant);
				}

				cells.push_back(p_cell);

				
			}
		}


		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);


		{ //Division vector rules
			c_vector<double, 2> membraneAxis;
			membraneAxis(0) = 0;
			membraneAxis(1) = 1;

			MAKE_PTR(StickToMembraneDivisionRule<2>, pCentreBasedDivisionRule);
			pCentreBasedDivisionRule->SetMembraneAxis(membraneAxis);
			pCentreBasedDivisionRule->SetWiggleDivision(wiggle);
			cell_population.SetCentreBasedDivisionRule(pCentreBasedDivisionRule);
		}


		// A simulator with a stopping even when there are too many cells
		OffLatticeSimulationTooManyCells simulator(cell_population);


		// Building the directory name
		std::stringstream out;
        out << "n_" << n;
        out << "_EES_"<< epithelialStiffness << "_VF_" << quiescentVolumeFraction << "_MS_" << membraneEpithelialSpringStiffness << "_CCT_" << int(cellCycleTime);
        if(CommandLineArguments::Instance()->OptionExists("-run"))
        {
        	out << "_run_" << run_number;
        }
        std::string output_directory = "TestCryptAnoikisResistant/" +  out.str();

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
		MAKE_PTR(BasicNonLinearSpringForce<2>, p_force);
		// MAKE_PTR(BasicContactNeighbourSpringForce<2>, p_force);
		p_force->SetSpringStiffness(epithelialStiffness);
		p_force->SetRestLength(2 * epithelialPreferredRadius);
		p_force->SetCutOffLength(3 * epithelialPreferredRadius);
		
		p_force->SetMeinekeSpringStiffness(meinekeStiffness);
		p_force->SetMeinekeSpringGrowthDuration(1);

		p_force->SetAttractionParameter(attractionParameter);

		MAKE_PTR(NormalAdhesionForce<2>, p_adhesion);
        p_adhesion->SetMembraneEpithelialSpringStiffness(membraneEpithelialSpringStiffness);
        p_adhesion->SetAdhesionForceLawParameter(adhesionForceLawParameter);
		
		// ********************************************************************************************
		// These two parameters are inately linked - the initial separation of the daughter nodes
		// and the initial resting spring length
		p_force->SetMeinekeDivisionRestingSpringLength(0.05);
		cell_population.SetMeinekeDivisionSeparation(0.05); // Set how far apart the cells will be upon division
		// ********************************************************************************************

        // ********************************************************************************************
        // Once paramters are set, drop in the force laws
		simulator.AddForce(p_force);
		simulator.AddForce(p_adhesion);
		// ********************************************************************************************

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		// ********************************************************************************************
		// Add in the cell killers
		MAKE_PTR_ARGS(SimpleSloughingCellKiller<2>, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer);

		MAKE_PTR_ARGS(SimpleAnoikisCellKiller, p_anoikis_killer, (&cell_population));
		p_anoikis_killer->SetPopUpDistance(popUpDistance);
		p_anoikis_killer->SetResistantPoppedUpLifeExpectancy(resistantPoppedUpLifeExpectancy); // resistant cells don't die from anoikis immediately
		simulator.AddCellKiller(p_anoikis_killer);
		// ********************************************************************************************


		MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

		simulator.SetOutputDivisionLocations(true);
		PRINT_VARIABLE(simulator.GetOutputDivisionLocations())

		simulator.Solve();
		WntConcentration<2>::Instance()->Destroy();

		// ********************************************************************************************
		// Post simulation processing
		// Probably best implemented as a 'writer', but have to work out how to di that first
		// Get the highest cell ID, which should indicate the total number of cells made in the simulation
		MeshBasedCellPopulation<2,2>* p_tissue = static_cast<MeshBasedCellPopulation<2,2>*>(&simulator.rGetCellPopulation());
		std::list<CellPtr> pos_cells =  p_tissue->rGetCells();

		unsigned cellId = 0;

        for (std::list<CellPtr>::iterator cell_iter = pos_cells.begin(); cell_iter != pos_cells.end(); ++cell_iter)
        {
        	
        	if ((*cell_iter)->GetCellId() > cellId)
        	{
        		cellId = (*cell_iter)->GetCellId();
        	}
            
        }

        std::stringstream kill_count_file_name;
        // Uni Mac path
        kill_count_file_name << "/Users/phillipbrown/Research/Crypt/Data/Chaste/CellKillCount/kill_count_" << "n_" << n << "_EES_"<< epithelialStiffness;
        // Macbook path
        // kill_count_file_name << "/Users/phillip/Research/Crypt/Data/Chaste/CellKillCount/kill_count_" << "n_" << n << "_EES_"<< epithelialStiffness;
        // Phoenix path
        // kill_count_file_name << "data/CellKillCount/kill_count_" << "n_" << n << "_EES_"<< epithelialStiffness;
        kill_count_file_name << "_MS_" << membraneEpithelialSpringStiffness << "_VF_" << int(100 * quiescentVolumeFraction) << "_CCT_" << int(cellCycleTime) << ".txt";
        // VF and PU don't change here
        //  << "_PU_" << popUpDistance <<

        ofstream kill_count_file;
        kill_count_file.open(kill_count_file_name.str());

        kill_count_file << "Total cells, killed sloughing, killed anoikis\n";

        kill_count_file << cellId << "," << p_sloughing_killer->GetCellKillCount() << "," << p_anoikis_killer->GetCellKillCount();

        kill_count_file.close();

        // ********************************************************************************************

        PRINT_VARIABLE(p_sloughing_killer->GetCellKillCount())
		PRINT_VARIABLE(p_anoikis_killer->GetCellKillCount())
		PRINT_VARIABLE(cellId)
	};

	void xTestResistantAndWeakened() throw(Exception)
	{
		// This test runs a healthy crypt and introduces a single anoikis resistant cell
		// The resistant cell position is specified as a cell position (1 to 15)
		// The legnth of resistance can also be specified. If it is not, resistance is assumed permanent


		double popUpDistance = 1.1;
		if(CommandLineArguments::Instance()->OptionExists("-pu"))
        {
        	popUpDistance = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-pu");
        }

        double adhesionForceLawParameter = 5.0;
        if(CommandLineArguments::Instance()->OptionExists("-aap"))
        {
        	adhesionForceLawParameter = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-aap");
        }

        double attractionParameter = 5.0; // epithelial attraction parameter
        if(CommandLineArguments::Instance()->OptionExists("-eap"))
        {
        	attractionParameter = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-eap");
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

        double cellCycleTime = 2.0;
        bool customCellCycleTime = false;
        if(CommandLineArguments::Instance()->OptionExists("-cct"))
        {
        	customCellCycleTime = true;
        	cellCycleTime = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-cct");
        }

        double resistantPoppedUpLifeExpectancy = end_time;
        if(CommandLineArguments::Instance()->OptionExists("-rple"))
        {
        	resistantPoppedUpLifeExpectancy = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-rple");
        }

        unsigned resistantPosition = 1;
        if(CommandLineArguments::Instance()->OptionExists("-rpos"))
        {	
        	resistantPosition = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-rpos");

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

		unsigned cell_limit = 3 * n; // At the smallest CI limit, there can be at most 400 cells, but we don't want to get there
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

		if(multiple_cells)
		{
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

		if(multiple_cells)
		{
			for(unsigned i=1; i<=n; i++)
			{

				SimpleWntWithAnoikisResistantMitosisArrest* p_cycle_model = new SimpleWntWithAnoikisResistantMitosisArrest();
				double birth_time = (minimumCycleTime + cellCycleTime - 2) * RandomNumberGenerator::Instance()->ranf();
				if (customCellCycleTime)
				{
					p_cycle_model->SetTransitCellG1Duration(cellCycleTime);
				}
				p_cycle_model->SetDimension(2);
	   			p_cycle_model->SetEquilibriumVolume(equilibriumVolume);
	   			p_cycle_model->SetQuiescentVolumeFraction(quiescentVolumeFraction);
	   			p_cycle_model->SetWntThreshold(1 - (double)n_prolif/n);
				p_cycle_model->SetBirthTime(-birth_time);
				p_cycle_model->SetPopUpDivision(false);

				CellPtr p_cell(new Cell(p_state, p_cycle_model));
				p_cell->SetCellProliferativeType(p_trans_type);
				p_cell->InitialiseCellCycleModel();

				if (i == resistantPosition)
				{
					p_cell->SetMutationState(p_resistant);
				}

				if (i == weakenedPosition)
				{
					p_cell->AddCellProperty(p_weakened);
				}

				cells.push_back(p_cell);

				
			}
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
        if(CommandLineArguments::Instance()->OptionExists("-run"))
        {
        	out << "_run_" << run_number;
        }
        std::string output_directory = "TestCryptAnoikisResistant/" +  out.str();

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
		MAKE_PTR(BasicNonLinearSpringForce<2>, p_force);
		// MAKE_PTR(BasicContactNeighbourSpringForce<2>, p_force);
		p_force->SetSpringStiffness(epithelialStiffness);
		p_force->SetRestLength(2 * epithelialPreferredRadius);
		p_force->SetCutOffLength(3 * epithelialPreferredRadius);
		
		p_force->SetMeinekeSpringStiffness(meinekeStiffness);
		p_force->SetMeinekeSpringGrowthDuration(1);

		p_force->SetAttractionParameter(attractionParameter);

		MAKE_PTR(NormalAdhesionForce<2>, p_adhesion);
        p_adhesion->SetMembraneEpithelialSpringStiffness(membraneEpithelialSpringStiffness);
        p_adhesion->SetAdhesionForceLawParameter(adhesionForceLawParameter);
        p_adhesion->SetWeakeningFraction(weakeningFraction);
		
		// ********************************************************************************************
		// These two parameters are inately linked - the initial separation of the daughter nodes
		// and the initial resting spring length
		p_force->SetMeinekeDivisionRestingSpringLength(0.05);
		cell_population.SetMeinekeDivisionSeparation(0.05); // Set how far apart the cells will be upon division
		// ********************************************************************************************

        // ********************************************************************************************
        // Once paramters are set, drop in the force laws
		simulator.AddForce(p_force);
		simulator.AddForce(p_adhesion);
		// ********************************************************************************************

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		// ********************************************************************************************
		// Add in the cell killers
		MAKE_PTR_ARGS(SimpleSloughingCellKiller<2>, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer);

		MAKE_PTR_ARGS(SimpleAnoikisCellKiller, p_anoikis_killer, (&cell_population));
		p_anoikis_killer->SetPopUpDistance(popUpDistance);
		p_anoikis_killer->SetResistantPoppedUpLifeExpectancy(resistantPoppedUpLifeExpectancy); // resistant cells don't die from anoikis immediately
		simulator.AddCellKiller(p_anoikis_killer);
		// ********************************************************************************************


		MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

		simulator.SetOutputDivisionLocations(true);
		PRINT_VARIABLE(simulator.GetOutputDivisionLocations())

		simulator.Solve();
		WntConcentration<2>::Instance()->Destroy();

		// ********************************************************************************************
		// Post simulation processing
		// Probably best implemented as a 'writer', but have to work out how to di that first
		// Get the highest cell ID, which should indicate the total number of cells made in the simulation
		MeshBasedCellPopulation<2,2>* p_tissue = static_cast<MeshBasedCellPopulation<2,2>*>(&simulator.rGetCellPopulation());
		std::list<CellPtr> pos_cells =  p_tissue->rGetCells();

		unsigned cellId = 0;

        for (std::list<CellPtr>::iterator cell_iter = pos_cells.begin(); cell_iter != pos_cells.end(); ++cell_iter)
        {
        	
        	if ((*cell_iter)->GetCellId() > cellId)
        	{
        		cellId = (*cell_iter)->GetCellId();
        	}
            
        }

	};

	void TestResistantAndWeakenedDivisionRotation() throw(Exception)
	{
		// This test runs a healthy crypt and introduces a single anoikis resistant cell
		// The resistant cell position is specified as a cell position (1 to 15)
		// The legnth of resistance can also be specified. If it is not, resistance is assumed permanent


		double popUpDistance = 1.1;
		if(CommandLineArguments::Instance()->OptionExists("-pu"))
        {
        	popUpDistance = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-pu");
        }

        double adhesionForceLawParameter = 5.0;
        if(CommandLineArguments::Instance()->OptionExists("-aap"))
        {
        	adhesionForceLawParameter = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-aap");
        }

        double attractionParameter = 5.0; // epithelial attraction parameter
        if(CommandLineArguments::Instance()->OptionExists("-eap"))
        {
        	attractionParameter = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-eap");
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

        // Time to run the simulation after burn in
        double end_time = 100;
        if(CommandLineArguments::Instance()->OptionExists("-t"))
        {	
        	end_time = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-t");

        }

        // Time to run the simulation before adding in the mutations
        double burn_in_time = 100;
        if(CommandLineArguments::Instance()->OptionExists("-bt"))
        {	
        	burn_in_time = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-bt");

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

        double cellCycleTime = 2.0;
        bool customCellCycleTime = false;
        if(CommandLineArguments::Instance()->OptionExists("-cct"))
        {
        	customCellCycleTime = true;
        	cellCycleTime = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-cct");
        }

        double resistantPoppedUpLifeExpectancy = end_time;
        if(CommandLineArguments::Instance()->OptionExists("-rple"))
        {
        	resistantPoppedUpLifeExpectancy = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-rple");
        }

        unsigned resistantPosition = 1;
        if(CommandLineArguments::Instance()->OptionExists("-rpos"))
        {	
        	resistantPosition = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-rpos");

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

		unsigned cell_limit = 3 * n; // At the smallest CI limit, there can be at most 400 cells, but we don't want to get there
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

		if(multiple_cells)
		{
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

		if(multiple_cells)
		{
			for(unsigned i=1; i<=n; i++)
			{

				SimpleWntWithAnoikisResistantMitosisArrest* p_cycle_model = new SimpleWntWithAnoikisResistantMitosisArrest();
				double birth_time = (minimumCycleTime + cellCycleTime - 2) * RandomNumberGenerator::Instance()->ranf();
				if (customCellCycleTime)
				{
					p_cycle_model->SetTransitCellG1Duration(cellCycleTime);
				}
				p_cycle_model->SetDimension(2);
	   			p_cycle_model->SetEquilibriumVolume(equilibriumVolume);
	   			p_cycle_model->SetQuiescentVolumeFraction(quiescentVolumeFraction);
	   			p_cycle_model->SetWntThreshold(1 - (double)n_prolif/n);
				p_cycle_model->SetBirthTime(-birth_time);
				p_cycle_model->SetPopUpDivision(false);

				CellPtr p_cell(new Cell(p_state, p_cycle_model));
				p_cell->SetCellProliferativeType(p_trans_type);
				p_cell->InitialiseCellCycleModel();

				cells.push_back(p_cell);

				
			}
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
        if(CommandLineArguments::Instance()->OptionExists("-run"))
        {
        	out << "_run_" << run_number;
        }
        std::string output_directory = "TestCryptResistantAndWeakened/" +  out.str();

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
		simulator.SetEndTime(burn_in_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);
		simulator.SetCellLimit(cell_limit);

		// ********************************************************************************************
		// Set force parameters
		MAKE_PTR(BasicNonLinearSpringForce<2>, p_force);
		p_force->SetSpringStiffness(epithelialStiffness);
		p_force->SetRestLength(2 * epithelialPreferredRadius);
		p_force->SetCutOffLength(3 * epithelialPreferredRadius);
		
		p_force->SetMeinekeSpringStiffness(meinekeStiffness);
		p_force->SetMeinekeSpringGrowthDuration(1);

		p_force->SetAttractionParameter(attractionParameter);

		MAKE_PTR(NormalAdhesionForce<2>, p_adhesion);
        p_adhesion->SetMembraneEpithelialSpringStiffness(membraneEpithelialSpringStiffness);
        p_adhesion->SetAdhesionForceLawParameter(adhesionForceLawParameter);
        p_adhesion->SetWeakeningFraction(weakeningFraction);
		
		MAKE_PTR(DividingRotationForce, p_rotation);
        p_rotation->SetTorsionalStiffness(20.0);
        p_rotation->SetMembraneAxis(membraneAxis);
		
		// ********************************************************************************************
		// These two parameters are inately linked - the initial separation of the daughter nodes
		// and the initial resting spring length
		p_force->SetMeinekeDivisionRestingSpringLength(0.05);
		cell_population.SetMeinekeDivisionSeparation(0.05); // Set how far apart the cells will be upon division
		// ********************************************************************************************

        // ********************************************************************************************
        // Once paramters are set, drop in the force laws
		simulator.AddForce(p_force);
		simulator.AddForce(p_adhesion);
		simulator.AddForce(p_rotation);
		// ********************************************************************************************

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		// ********************************************************************************************
		// Add in the cell killers
		MAKE_PTR_ARGS(SimpleSloughingCellKiller<2>, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer);

		MAKE_PTR_ARGS(SimpleAnoikisCellKiller, p_anoikis_killer, (&cell_population));
		p_anoikis_killer->SetPopUpDistance(popUpDistance);
		p_anoikis_killer->SetResistantPoppedUpLifeExpectancy(resistantPoppedUpLifeExpectancy); // resistant cells don't die from anoikis immediately
		simulator.AddCellKiller(p_anoikis_killer);
		// ********************************************************************************************


		MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

		simulator.SetOutputDivisionLocations(true);
		PRINT_VARIABLE(simulator.GetOutputDivisionLocations())

		simulator.Solve();

		simulator.SetEndTime(burn_in_time + end_time);

		// ********************************************************************************************
		// After running the simulation to homeostasis, we introduce a mutation to the cell n_pos from the bottom
		MeshBasedCellPopulation<2,2>* p_tissue = static_cast<MeshBasedCellPopulation<2,2>*>(&simulator.rGetCellPopulation());
		std::list<CellPtr> pos_cells =  p_tissue->rGetCells();
		std::sort(pos_cells.begin(), pos_cells.end(), 
			[p_tissue](CellPtr A, CellPtr B)
		{ 
		    Node<2>* node_A =  p_tissue->GetNodeCorrespondingToCell(A);
			Node<2>* node_B =  p_tissue->GetNodeCorrespondingToCell(B);
		    return (node_A->rGetLocation()[1] < node_B->rGetLocation()[1]); 
		});

		std::list<CellPtr>::iterator it = pos_cells.begin();
    	std::advance(it, resistantPosition);
		
		(*it)->SetMutationState(p_resistant);

		it = pos_cells.begin();
    	std::advance(it, weakenedPosition);
		
		(*it)->AddCellProperty(p_weakened);

		simulator.Solve();

		WntConcentration<2>::Instance()->Destroy();

		// ********************************************************************************************
		// Post simulation processing
		// Probably best implemented as a 'writer', but have to work out how to do that first
		// Get the highest cell ID, which should indicate the total number of cells made in the simulation
		p_tissue = static_cast<MeshBasedCellPopulation<2,2>*>(&simulator.rGetCellPopulation());
		pos_cells =  p_tissue->rGetCells();

		unsigned cellId = 0;
		unsigned differentiated = 0;
		unsigned proliferative = 0;

        for (std::list<CellPtr>::iterator cell_iter = pos_cells.begin(); cell_iter != pos_cells.end(); ++cell_iter)
        {
        	
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
            
        }

        unsigned total_cells = proliferative + differentiated;

        PRINT_VARIABLE(p_sloughing_killer->GetCellKillCount())
		PRINT_VARIABLE(p_anoikis_killer->GetCellKillCount())
		PRINT_VARIABLE(proliferative)
		PRINT_VARIABLE(differentiated)
		PRINT_VARIABLE(total_cells)
		PRINT_VARIABLE(cellId)

	};

	void xTestCryptDivisionRotation() throw(Exception)
	{
		// This test simulates a column of cells that can now move in 2 dimensions
		// In order to retain the cells in a column, an etherial force needs to be added
		// to approximate the role of the basement membrane
		// 
		// Additionally, this tests a 'division-rotation' force. This is designed to act like
		// a torsion spring for cells undergoing mitosis, to stop them from popping up before
		// they have finished dividing

		// 1: add division nudge - done
		// 2: add BM force to pull back into column - done 
		// 3: determine BM force and range needed to get varying amounts of popping up - sort of done
		// 4: make sure contact neighbours is correct
		// 5: use phase based and contact inhibition CCM
		// 6: use e-e force determined from experiments, and CI percentage


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

        double cellCycleTime = 5;
        if(CommandLineArguments::Instance()->OptionExists("-cct"))
        {
        	cellCycleTime = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-cct");
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

        unsigned n_prolif = 15; // Number of proliferative cells, counting up from the bottom
        if(CommandLineArguments::Instance()->OptionExists("-np"))
        {	
        	n_prolif = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-np");

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

        double epithelialPreferredRadius = 0.5; // Must have this value due to volume calculation - can't set node radius as SetRadius(epithelialPreferredRadius) doesn't work

        double equilibriumVolume = M_PI*epithelialPreferredRadius*epithelialPreferredRadius; // Depends on the preferred radius

        bool multiple_cells = true;
        unsigned n = 20;

        unsigned node_counter = 0;

		double dt = 0.001;

		double maxInteractionRadius = 2.0;

		double wall_top = 20;

		double minimumCycleTime = 10;

		unsigned cell_limit = 200; // At the smallest CI limit, there can be at most 400 cells, but we don't want to get there
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

		if(multiple_cells)
		{
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

		if(multiple_cells)
		{
			for(unsigned i=1; i<=n; i++)
			{

				SimpleWntContactInhibitionCellCycleModel* p_cycle_model = new SimpleWntContactInhibitionCellCycleModel();
				double birth_time = (minimumCycleTime + cellCycleTime) * RandomNumberGenerator::Instance()->ranf();
				p_cycle_model->SetTransitCellG1Duration(cellCycleTime);
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
		}


		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);

		// ********************************************************************************************
		//Division vector rules
		c_vector<double, 2> membraneAxis;
		membraneAxis(0) = 0;
		membraneAxis(1) = 1;

		MAKE_PTR(StickToMembraneDivisionRule<2>, pCentreBasedDivisionRule);
		pCentreBasedDivisionRule->SetMembraneAxis(membraneAxis);
		pCentreBasedDivisionRule->SetWiggleDivision(wiggle);
		cell_population.SetCentreBasedDivisionRule(pCentreBasedDivisionRule);
		// ********************************************************************************************


		// A simulator with a stopping even when there are too many cells
		OffLatticeSimulationTooManyCells simulator(cell_population);


		// Building the directory name
		std::stringstream out;
        out << "n_" << n;
        out << "_EES_"<< epithelialStiffness << "_VF_" << quiescentVolumeFraction;
        if(CommandLineArguments::Instance()->OptionExists("-run"))
        {
        	out << "_run_" << run_number;
        }
        std::string output_directory = "TestCryptDivisionRotation/" +  out.str();

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
		MAKE_PTR(BasicNonLinearSpringForce<2>, p_force);
		p_force->SetSpringStiffness(epithelialStiffness);
		p_force->SetRestLength(2 * epithelialPreferredRadius);
		p_force->SetCutOffLength(3 * epithelialPreferredRadius);
		
		p_force->SetMeinekeSpringStiffness(meinekeStiffness);
		p_force->SetMeinekeSpringGrowthDuration(1);

		MAKE_PTR(NormalAdhesionForce<2>, p_adhesion);
        p_adhesion->SetMembraneEpithelialSpringStiffness(membraneEpithelialSpringStiffness);

        MAKE_PTR(DividingRotationForce, p_rotation);
        p_rotation->SetTorsionalStiffness(20.0);
        p_rotation->SetMembraneAxis(membraneAxis);
		
		// ********************************************************************************************
		// These two parameters are inately linked - the initial separation of the daughter nodes
		// and the initial resting spring length
		p_force->SetMeinekeDivisionRestingSpringLength(0.05);
		cell_population.SetMeinekeDivisionSeparation(0.05); // Set how far apart the cells will be upon division
		// ********************************************************************************************

        // ********************************************************************************************
        // Once paramters are set, drop in the force laws
		simulator.AddForce(p_force);
		simulator.AddForce(p_adhesion);
		simulator.AddForce(p_rotation);
		// ********************************************************************************************

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		// ********************************************************************************************
		// Add in the cell killers
		MAKE_PTR_ARGS(SimpleSloughingCellKiller<2>, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer);

		MAKE_PTR_ARGS(SimpleAnoikisCellKiller, p_anoikis_killer, (&cell_population));
		p_anoikis_killer->SetPopUpDistance(popUpDistance);
		simulator.AddCellKiller(p_anoikis_killer);
		// ********************************************************************************************


		MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

		simulator.SetOutputDivisionLocations(true);
		PRINT_VARIABLE(simulator.GetOutputDivisionLocations())

		simulator.Solve();
		WntConcentration<2>::Instance()->Destroy();

		// ********************************************************************************************
		// Post simulation processing
		// Probably best implemented as a 'writer', but have to work out how to di that first
		// Get the highest cell ID, which should indicate the total number of cells made in the simulation
		MeshBasedCellPopulation<2,2>* p_tissue = static_cast<MeshBasedCellPopulation<2,2>*>(&simulator.rGetCellPopulation());
		std::list<CellPtr> pos_cells =  p_tissue->rGetCells();

		unsigned cellId = 0;

        for (std::list<CellPtr>::iterator cell_iter = pos_cells.begin(); cell_iter != pos_cells.end(); ++cell_iter)
        {
        	
        	if ((*cell_iter)->GetCellId() > cellId)
        	{
        		cellId = (*cell_iter)->GetCellId();
        	}
            
        }

        // ********************************************************************************************

        PRINT_VARIABLE(p_sloughing_killer->GetCellKillCount())
		PRINT_VARIABLE(p_anoikis_killer->GetCellKillCount())
		PRINT_VARIABLE(cellId)
	};


	// bool sort_height(CellPtr A, CellPtr B)
	// { 
	// 	Node<2>* node_A =  p_tissue->GetNodeCorrespondingToCell(A);
	// 	Node<2>* node_B =  p_tissue->GetNodeCorrespondingToCell(B);
 //        c_vector<double, 2> node_location = p_node->rGetLocation();
	//     return (node_A->rGetLocation()[1] < node_B->rGetlocation()[1]); 
	// };

};
