// Standard includes for tests
#include <cxxtest/TestSuite.h>
#include "AbstractCellBasedTestSuite.hpp"
#include "CheckpointArchiveTypes.hpp"
#include "SmartPointers.hpp"
#include "CommandLineArguments.hpp"

// Simulators
#include "OffLatticeSimulation.hpp"
#include "OffLatticeSimulationWithMutation.hpp"

// Forces
#include "NormalAdhesionForceNewPhaseModel.hpp"
#include "BasicNonLinearSpringForceMultiNodeFix.hpp"

// Mesh
#include "NodesOnlyMesh.hpp"

// Cell Population
#include "NodeBasedCellPopulation.hpp"
#include "MonolayerNodeBasedCellPopulation.hpp"

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
#include "CellBasedSimulationArchiver.hpp"
#include "FakePetscSetup.hpp"
#include "Debug.hpp"

class TestCryptColumnSave : public AbstractCellBasedTestSuite
{
	
public:


	void TestCryptSave() throw(Exception)
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



		// **************************************************************************************************
		// Input parameters in order usually expected, grouped by category
		// **************************************************************************************************



		// **************************************************************************************************
		// Crypt size parameters
		unsigned n = 20;

		unsigned n_prolif = n - 10; // Number of proliferative cells, counting up from the bottom		}
		// **************************************************************************************************

		// **************************************************************************************************
		// Force parameters
		double epithelialStiffness = 20;
		double membraneStiffness = 50;
		double meinekeStiffness = epithelialStiffness; // Newly divided spring stiffness/ **************************************************************************************************

		// **************************************************************************************************
		// Cell cycle parameters
		double cellCycleTime = 15.0;
		double wPhaseLength = 10.0;
		// Should be implemented better, but a quick check to make sure the cell cycle phases
		// aren't set too extreme.
		assert(cellCycleTime - wPhaseLength > 1);

		double quiescentVolumeFraction = 0.75;
		// **************************************************************************************************

		// **************************************************************************************************
		// Simulation parameters
		double dt = 0.002; // The minimum to get covergant simulations for a specific parameter set
		double burn_in_time = 10; // The time needed to clear the transient behaviour from the initial set up		}

		double run_number = 1; // The seed for the RNG, also used to uniquely identify simulations		}
		// **************************************************************************************************

		// **************************************************************************************************
		// Output control
		double sampling_multiple = 100000;
		bool java_visualiser = true;
		// **************************************************************************************************


		// **************************************************************************************************
		// Fixed parameters  
		double popUpDistance = 1.1; // The distance from the membrane when cells die
		
		// To change this, must use SetRadius(epithelialPreferredRadius) and also turn on custom radius
		double epithelialPreferredRadius = 0.5; 

		double equilibriumVolume = M_PI * epithelialPreferredRadius * epithelialPreferredRadius;

		double maxInteractionRadius = 3 * epithelialPreferredRadius;
		
		double growingFinalSpringLength = 1;//(2 * sqrt(2) - 2) * 2 * epithelialPreferredRadius * 1.2; 
		// Modify this to control how large a growing cell is at any time.
		// = 1 means we use the growing line approximation
		// = 2 * sqrt(2) - 2 means we use the growing circle approximation
		// = 2 * pow(2, 1/3) - 2 means we use the growing sphere approximation
		
		double wall_top = n; // The point where sloughing occurs

		unsigned cell_limit = 6 * n; // If the cell count exceeds this, the simulation terminates
		// **************************************************************************************************		



		// **************************************************************************************************
		// Building the simulation
		// **************************************************************************************************



		// **************************************************************************************************
		// Seed the RNG in a "deterministic" way
		RandomNumberGenerator::Instance()->Reseed(run_number * quiescentVolumeFraction * epithelialStiffness);
		// **************************************************************************************************

		// **************************************************************************************************
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
		// **************************************************************************************************


		// **************************************************************************************************
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
			// NoCellCycleModelPhase* p_cycle_model = new NoCellCycleModelPhase();

			// CellPtr p_cell(new Cell(p_state, p_cycle_model));
			// p_cell->SetCellProliferativeType(p_diff_type);
			// p_cell->AddCellProperty(p_boundary);
			// p_cell->GetCellData()->SetItem("parent", p_cell->GetCellId());
			// p_cell->InitialiseCellCycleModel();

			// cells.push_back(p_cell);

			// This doesn't work
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
		// **************************************************************************************************

		// **************************************************************************************************
		// Make the cell population
		MonolayerNodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);
		// **************************************************************************************************

		// **************************************************************************************************
		//Division vector rules
		c_vector<double, 2> membraneAxis;
		membraneAxis(0) = 0;
		membraneAxis(1) = 1;

		MAKE_PTR(StickToMembraneDivisionRule<2u>, pCentreBasedDivisionRule);
		pCentreBasedDivisionRule->SetMembraneAxis(membraneAxis);
		pCentreBasedDivisionRule->SetWiggleDivision(true);
		cell_population.SetCentreBasedDivisionRule(pCentreBasedDivisionRule);
		// **************************************************************************************************

		// **************************************************************************************************
		// Make the simulation
		OffLatticeSimulationWithMutation simulator(cell_population);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);
		simulator.SetCellLimit(cell_limit);
		// **************************************************************************************************

		// **************************************************************************************************
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
		
		std::string output_directory = "TestCryptColumnSave/" +  simdir.str() + "/"  + rundir.str();

		simulator.SetOutputDirectory(output_directory);
		// **************************************************************************************************

		// **************************************************************************************************
		// Set Wnt parameters and add in the cell population
		WntConcentration<2>::Instance()->SetType(LINEAR);
		WntConcentration<2>::Instance()->SetCellPopulation(cell_population);
		WntConcentration<2>::Instance()->SetCryptLength(n);
		// **************************************************************************************************


		// **************************************************************************************************
		// File outputs
		// Files are only output if the command line argument -sm exists and a sampling multiple is set
		simulator.SetSamplingTimestepMultiple(sampling_multiple);
		// The java visuliser is set separately
		cell_population.SetOutputResultsForChasteVisualizer(java_visualiser);
		// **************************************************************************************************

		// **************************************************************************************************
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

		// **************************************************************************************************

		
		// **************************************************************************************************
		// These two parameters are inately linked - the initial separation of the daughter nodes
		// and the initial resting spring length
		p_force->SetMeinekeDivisionRestingSpringLength( growingFinalSpringLength );
		cell_population.SetMeinekeDivisionSeparation(0.05); // Set how far apart the cells will be upon division
		// **************************************************************************************************

		// **************************************************************************************************
		// Once paramters are set, drop in the force laws
		simulator.AddForce(p_force);
		simulator.AddForce(p_adhesion);
		// **************************************************************************************************

		// **************************************************************************************************
		// Add the boundary conditions
		// Bottom cell locked in place
		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		// Cells in W phase can't pop up
		MAKE_PTR_ARGS(DividingPopUpBoundaryCondition, p_dbc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_dbc);
		// **************************************************************************************************

		// **************************************************************************************************
		// Add in the cell killers
		MAKE_PTR_ARGS(SimpleSloughingCellKiller<2>, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer);

		MAKE_PTR_ARGS(SimpleAnoikisCellKiller, p_anoikis_killer, (&cell_population));
		p_anoikis_killer->SetPopUpDistance(popUpDistance);
		simulator.AddCellKiller(p_anoikis_killer);

		MAKE_PTR_ARGS(IsolatedCellKiller, p_isolated_killer, (&cell_population));
		simulator.AddCellKiller(p_isolated_killer);
		// **************************************************************************************************

		// **************************************************************************************************
		// Modifiers
		MAKE_PTR(VolumeTrackingModifier<2>, p_vmod);
		simulator.AddSimulationModifier(p_vmod);
		// **************************************************************************************************



		// **************************************************************************************************
		// Run the simulation
		// **************************************************************************************************



		// **************************************************************************************************
		// Simulate through the transient behaviour
		simulator.SetEndTime(burn_in_time);

		TRACE("Simulating through transient")
		simulator.Solve();
		// **************************************************************************************************
		std::list<CellPtr> cells1 =  simulator.rGetCellPopulation().rGetCells();
		for (std::list<CellPtr>::iterator it = cells1.begin(); it != cells1.end(); ++it)
		{
			PRINT_VARIABLE((*it)->GetCellId())
		}

		// **************************************************************************************************
		// Post simulation tasks
		// Save the state
		CellBasedSimulationArchiver<2, OffLatticeSimulationWithMutation, 2>::Save(&simulator);
		TRACE("Saved, now loading")
		OffLatticeSimulationWithMutation* p_sim2 = CellBasedSimulationArchiver<2, OffLatticeSimulationWithMutation, 2>::Load(output_directory, burn_in_time);
		p_sim2->SetEndTime(2 * burn_in_time);
		TRACE("Check cells")
		std::list<CellPtr> cells2 =  p_sim2->rGetCellPopulation().rGetCells();

		for (std::list<CellPtr>::iterator it = cells2.begin(); it != cells2.end(); ++it)
		{
			PRINT_VARIABLE((*it)->GetCellId())
		}

		TRACE("Running sim after loading")
		p_sim2->Solve();
		CellBasedSimulationArchiver<2, OffLatticeSimulationWithMutation, 2>::Save(p_sim2);

		// Clean up singletons
		WntConcentration<2>::Instance()->Destroy();
		// **************************************************************************************************

	};




	void TestCryptLoad() throw(Exception)
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



		// **************************************************************************************************
		// Input parameters in order usually expected, grouped by category
		// **************************************************************************************************



		// **************************************************************************************************
		// Crypt size parameters
		unsigned n = 20;

		unsigned n_prolif = n - 10; // Number of proliferative cells, counting up from the bottom		}
		// **************************************************************************************************

		// **************************************************************************************************
		// Force parameters
		double epithelialStiffness = 20;
		double membraneStiffness = 50;
		double meinekeStiffness = epithelialStiffness; // Newly divided spring stiffness/ **************************************************************************************************

		// **************************************************************************************************
		// Cell cycle parameters
		double cellCycleTime = 15.0;
		double wPhaseLength = 10.0;
		// Should be implemented better, but a quick check to make sure the cell cycle phases
		// aren't set too extreme.
		assert(cellCycleTime - wPhaseLength > 1);

		double quiescentVolumeFraction = 0.75;
		// **************************************************************************************************

		// **************************************************************************************************
		// Simulation parameters
		double dt = 0.002; // The minimum to get covergant simulations for a specific parameter set
		double burn_in_time = 20; // The time needed to clear the transient behaviour from the initial set up		}

		double run_number = 1; // The seed for the RNG, also used to uniquely identify simulations		}
		// **************************************************************************************************

		// **************************************************************************************************
		// Output control
		double sampling_multiple = 100000;
		bool java_visualiser = true;
		// **************************************************************************************************


		// **************************************************************************************************
		// Fixed parameters  
		double popUpDistance = 1.1; // The distance from the membrane when cells die
		
		// To change this, must use SetRadius(epithelialPreferredRadius) and also turn on custom radius
		double epithelialPreferredRadius = 0.5; 

		double equilibriumVolume = M_PI * epithelialPreferredRadius * epithelialPreferredRadius;

		double maxInteractionRadius = 3 * epithelialPreferredRadius;
		
		double growingFinalSpringLength = 1;//(2 * sqrt(2) - 2) * 2 * epithelialPreferredRadius * 1.2; 
		// Modify this to control how large a growing cell is at any time.
		// = 1 means we use the growing line approximation
		// = 2 * sqrt(2) - 2 means we use the growing circle approximation
		// = 2 * pow(2, 1/3) - 2 means we use the growing sphere approximation
		
		double wall_top = n; // The point where sloughing occurs

		unsigned cell_limit = 6 * n; // If the cell count exceeds this, the simulation terminates
		// **************************************************************************************************		



		// **************************************************************************************************
		// Building the simulation
		// **************************************************************************************************



		// **************************************************************************************************
		// Seed the RNG in a "deterministic" way
		RandomNumberGenerator::Instance()->Reseed(run_number * quiescentVolumeFraction * epithelialStiffness);
		// **************************************************************************************************

		// **************************************************************************************************
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
		// **************************************************************************************************


		// **************************************************************************************************
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
			// NoCellCycleModelPhase* p_cycle_model = new NoCellCycleModelPhase();

			// CellPtr p_cell(new Cell(p_state, p_cycle_model));
			// p_cell->SetCellProliferativeType(p_diff_type);
			// p_cell->AddCellProperty(p_boundary);
			// p_cell->GetCellData()->SetItem("parent", p_cell->GetCellId());
			// p_cell->InitialiseCellCycleModel();

			// cells.push_back(p_cell);

			// This doesn't work
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
		// **************************************************************************************************

		// **************************************************************************************************
		// Make the cell population
		MonolayerNodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);
		// **************************************************************************************************

		// **************************************************************************************************
		//Division vector rules
		c_vector<double, 2> membraneAxis;
		membraneAxis(0) = 0;
		membraneAxis(1) = 1;

		MAKE_PTR(StickToMembraneDivisionRule<2u>, pCentreBasedDivisionRule);
		pCentreBasedDivisionRule->SetMembraneAxis(membraneAxis);
		pCentreBasedDivisionRule->SetWiggleDivision(true);
		cell_population.SetCentreBasedDivisionRule(pCentreBasedDivisionRule);
		// **************************************************************************************************

		// **************************************************************************************************
		// Make the simulation
		OffLatticeSimulationWithMutation simulator(cell_population);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);
		simulator.SetCellLimit(cell_limit);
		// **************************************************************************************************

		// **************************************************************************************************
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
		
		std::string output_directory = "TestCryptColumnLoad/" +  simdir.str() + "/"  + rundir.str();

		simulator.SetOutputDirectory(output_directory);
		// **************************************************************************************************

		// **************************************************************************************************
		// Set Wnt parameters and add in the cell population
		WntConcentration<2>::Instance()->SetType(LINEAR);
		WntConcentration<2>::Instance()->SetCellPopulation(cell_population);
		WntConcentration<2>::Instance()->SetCryptLength(n);
		// **************************************************************************************************


		// **************************************************************************************************
		// File outputs
		// Files are only output if the command line argument -sm exists and a sampling multiple is set
		simulator.SetSamplingTimestepMultiple(sampling_multiple);
		// The java visuliser is set separately
		cell_population.SetOutputResultsForChasteVisualizer(java_visualiser);
		// **************************************************************************************************

		// **************************************************************************************************
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

		// **************************************************************************************************

		
		// **************************************************************************************************
		// These two parameters are inately linked - the initial separation of the daughter nodes
		// and the initial resting spring length
		p_force->SetMeinekeDivisionRestingSpringLength( growingFinalSpringLength );
		cell_population.SetMeinekeDivisionSeparation(0.05); // Set how far apart the cells will be upon division
		// **************************************************************************************************

		// **************************************************************************************************
		// Once paramters are set, drop in the force laws
		simulator.AddForce(p_force);
		simulator.AddForce(p_adhesion);
		// **************************************************************************************************

		// **************************************************************************************************
		// Add the boundary conditions
		// Bottom cell locked in place
		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		// Cells in W phase can't pop up
		MAKE_PTR_ARGS(DividingPopUpBoundaryCondition, p_dbc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_dbc);
		// **************************************************************************************************

		// **************************************************************************************************
		// Add in the cell killers
		MAKE_PTR_ARGS(SimpleSloughingCellKiller<2>, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer);

		MAKE_PTR_ARGS(SimpleAnoikisCellKiller, p_anoikis_killer, (&cell_population));
		p_anoikis_killer->SetPopUpDistance(popUpDistance);
		simulator.AddCellKiller(p_anoikis_killer);

		MAKE_PTR_ARGS(IsolatedCellKiller, p_isolated_killer, (&cell_population));
		simulator.AddCellKiller(p_isolated_killer);
		// **************************************************************************************************

		// **************************************************************************************************
		// Modifiers
		MAKE_PTR(VolumeTrackingModifier<2>, p_vmod);
		simulator.AddSimulationModifier(p_vmod);
		// **************************************************************************************************



		// **************************************************************************************************
		// Run the simulation
		// **************************************************************************************************



		// **************************************************************************************************
		// Simulate through the transient behaviour
		simulator.SetEndTime(burn_in_time);

		TRACE("Simulating to save point")
		simulator.Solve();
		// **************************************************************************************************


		// **************************************************************************************************
		// Post simulation tasks
		// Save the state
		output_directory = "TestCryptColumnSave/" +  simdir.str() + "/"  + rundir.str();
		OffLatticeSimulationWithMutation* p_sim2 = CellBasedSimulationArchiver<2, OffLatticeSimulationWithMutation, 2>::Load(output_directory, burn_in_time);

		TRACE("Comparing 10:save:load:10 to 20")

		TS_ASSERT(simulator.GetNumBirths() == p_sim2->GetNumBirths() )
		TS_ASSERT(simulator.GetNumDeaths() == p_sim2->GetNumDeaths() )
		TS_ASSERT(  simulator.rGetCellPopulation().GetNode(0)->rGetLocation()[1] == p_sim2->rGetCellPopulation().GetNode(0)->rGetLocation()[1]   )

		TS_ASSERT(  simulator.rGetCellPopulation().GetCellUsingLocationIndex(0)->GetAge() == p_sim2->rGetCellPopulation().GetCellUsingLocationIndex(0)->GetAge()   )

		// Clean up singletons
		WntConcentration<2>::Instance()->Destroy();
		// **************************************************************************************************

	};

};






