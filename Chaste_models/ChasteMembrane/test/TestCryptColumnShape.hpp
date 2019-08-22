// Standard includes for tests
#include <cxxtest/TestSuite.h>
#include "AbstractCellBasedTestSuite.hpp"
#include "CheckpointArchiveTypes.hpp"
#include "SmartPointers.hpp"
#include "CommandLineArguments.hpp"

// Simulators
#include "OffLatticeSimulation.hpp"

// Forces
#include "ConstantForce.hpp"

// Boundary Conditions
#include "NoForcePeriodicBoundaryCondition.hpp"

// Mesh
#include "NodesOnlyMesh.hpp"

// Cell Population
#include "NodeBasedCellPopulation.hpp"

// Proliferative types
#include "DifferentiatedCellProliferativeType.hpp"
#include "TransitCellProliferativeType.hpp"

//Cell cycle models
#include "NoCellCycleModel.hpp"

// Mutation State
#include "WildTypeCellMutationState.hpp"

// Misc
#include "FakePetscSetup.hpp"
#include "Debug.hpp"

class TestCryptColumnShape : public AbstractCellBasedTestSuite
{
	
public:


	void xTestCryptSine() throw(Exception)
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
		unsigned n = 40;
		if(CommandLineArguments::Instance()->OptionExists("-n"))
		{	
			n = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-n");
			PRINT_VARIABLE(n)

		}

		unsigned waves = 2;
		if(CommandLineArguments::Instance()->OptionExists("-w"))
		{	
			waves = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-w");
			PRINT_VARIABLE(waves)

		}

		double speed = 1; // The minimum to get covergant simulations for a specific parameter set
		if(CommandLineArguments::Instance()->OptionExists("-sp"))
		{
			speed = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-sp");
			PRINT_VARIABLE(speed)
		}

		// ********************************************************************************************
		// Simulation parameters
		double dt = 0.002; // The minimum to get covergant simulations for a specific parameter set
		if(CommandLineArguments::Instance()->OptionExists("-dt"))
		{
			dt = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-dt");
			PRINT_VARIABLE(dt)
		}
		

		double simulation_length = 100;
		if(CommandLineArguments::Instance()->OptionExists("-t"))
		{	
			simulation_length = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-t");
			PRINT_VARIABLE(simulation_length)

		}

		// ********************************************************************************************

		// ********************************************************************************************
		// Output control
		bool file_output = true;
		double sampling_multiple = 100;
		file_output = true;
		TRACE("File output occuring")

		bool java_visualiser = true;
		TRACE("Java visulaiser ON")
		// ********************************************************************************************


		// ********************************************************************************************
		// Building the simulation
		// ********************************************************************************************

		// ********************************************************************************************
		// Make the nodes
		unsigned node_counter = 0;

		std::vector<Node<2>*> nodes;
		std::vector<unsigned> location_indices;


		// Column building parameters
		double x_distance = 0;
		double y_distance = 0;
		double x = x_distance;
		double y = y_distance;

		unsigned x_layer = 1; // Thickness of non-oscilating part
		unsigned x_height = 6; // Maximum stack height

		

		// Initialise the crypt nodes
		for(unsigned i = 0; i < n; i++)
		{
			for(unsigned j = 0; j <= x_height; j++)
			{
				x = j;
				y = y_distance + i;
				if (   x <= x_layer + (x_height + 0.1) * ( 1+ cos(2* 3.1415 * waves * y / n)  )/2   )
				{
					Node<2>* single_node =  new Node<2>(node_counter,  false,  x, y);
					nodes.push_back(single_node);
					location_indices.push_back(node_counter);
					node_counter++;
				}
			}
		}


		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, 1);
		// ********************************************************************************************


		// ********************************************************************************************
		// Make the cells
		std::vector<CellPtr> cells;
		MAKE_PTR(WildTypeCellMutationState, p_state);
		// Give the crypt its cells
		for(unsigned i=0; i< node_counter; i++)
		{

			NoCellCycleModel* p_cycle_model = new NoCellCycleModel();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));

			cells.push_back(p_cell);
			
		}
		// ********************************************************************************************

		// ********************************************************************************************
		// Make the cell population
		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);
		// ********************************************************************************************

		// ********************************************************************************************
		// Make the simulation
		OffLatticeSimulation<2> simulator(cell_population);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);
		// ********************************************************************************************

		// ********************************************************************************************
		// Building the directory name
		std::stringstream simdir;
		simdir << "n_" << n;
		simdir << "_waves_" << waves;
		
		std::string output_directory = "TestCryptColumnShape/Sine/" +  simdir.str() + "/";

		simulator.SetOutputDirectory(output_directory);
		// ********************************************************************************************


		// ********************************************************************************************
		// File outputs
		// Files are only output if the command line argument -sm exists and a sampling multiple is set
		simulator.SetSamplingTimestepMultiple(sampling_multiple);
		// The java visuliser is set separately
		cell_population.SetOutputResultsForChasteVisualizer(java_visualiser);
		// ********************************************************************************************

		// ********************************************************************************************
		// Add forces
		// Need to add a constant up force on everything
		MAKE_PTR(ConstantForce<2>, p_force);
		p_force->SetForce(speed);
		p_force->SetAxis(2);
		simulator.AddForce(p_force);

		// ********************************************************************************************

		// ********************************************************************************************
		// Add the boundary conditions
		// Bottom cell locked in place

		MAKE_PTR_ARGS(NoForcePeriodicBoundaryCondition<2>, p_bc, (&cell_population));
		p_bc->SetTopBoundary((double)n);
		p_bc->SetBottomBoundary(0);
		p_bc->SetAxis(2);
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		// ********************************************************************************************

		// ********************************************************************************************
		// Run the simulation
		// ********************************************************************************************



		// ********************************************************************************************
		// Simulate through the transient behaviour
		simulator.SetEndTime(simulation_length);

		TRACE("Simulating waves")
		simulator.Solve();
		// ********************************************************************************************


	};



	void TestCryptPulse() throw(Exception)
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
		unsigned n = 40;
		if(CommandLineArguments::Instance()->OptionExists("-n"))
		{	
			n = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-n");
			PRINT_VARIABLE(n)

		}

		unsigned waves = 4;
		if(CommandLineArguments::Instance()->OptionExists("-w"))
		{	
			waves = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-w");
			PRINT_VARIABLE(waves)

		}

		double speed = 1; // The minimum to get covergant simulations for a specific parameter set
		if(CommandLineArguments::Instance()->OptionExists("-sp"))
		{
			speed = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-sp");
			PRINT_VARIABLE(speed)
		}

		// ********************************************************************************************
		// Simulation parameters
		double dt = 0.002; // The minimum to get covergant simulations for a specific parameter set
		if(CommandLineArguments::Instance()->OptionExists("-dt"))
		{
			dt = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-dt");
			PRINT_VARIABLE(dt)
		}
		

		double simulation_length = 100;
		if(CommandLineArguments::Instance()->OptionExists("-t"))
		{	
			simulation_length = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-t");
			PRINT_VARIABLE(simulation_length)

		}

		// ********************************************************************************************

		// ********************************************************************************************
		// Output control
		bool file_output = true;
		double sampling_multiple = 100;
		file_output = true;
		TRACE("File output occuring")

		bool java_visualiser = true;
		TRACE("Java visulaiser ON")
		// ********************************************************************************************


		// ********************************************************************************************
		// Building the simulation
		// ********************************************************************************************

		// ********************************************************************************************
		// Make the nodes
		unsigned node_counter = 0;

		std::vector<Node<2>*> nodes;
		std::vector<unsigned> location_indices;


		// Column building parameters
		double x_distance = 0;
		double y_distance = 0;
		double x = x_distance;
		double y = y_distance;

		unsigned x_layer = 1; // Thickness of non-oscilating part
		unsigned x_height = 6; // Maximum stack height

		

		// Initialise the crypt nodes
		for(unsigned i = 0; i < n; i++)
		{
			for(unsigned j = 0; j <= x_height; j++)
			{
				x = j;
				y = y_distance + i;
				if (   x <= x_layer + (x_height + 0.1) * std::exp(  -std::pow( (y - (double)n/2) / waves, 2 )  )    )
				{
					Node<2>* single_node =  new Node<2>(node_counter,  false,  x, y);
					nodes.push_back(single_node);
					location_indices.push_back(node_counter);
					node_counter++;
				}
			}
		}


		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, 1);
		// ********************************************************************************************


		// ********************************************************************************************
		// Make the cells
		std::vector<CellPtr> cells;
		MAKE_PTR(WildTypeCellMutationState, p_state);
		// Give the crypt its cells
		for(unsigned i=0; i< node_counter; i++)
		{

			NoCellCycleModel* p_cycle_model = new NoCellCycleModel();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));

			cells.push_back(p_cell);
			
		}
		// ********************************************************************************************

		// ********************************************************************************************
		// Make the cell population
		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);
		// ********************************************************************************************

		// ********************************************************************************************
		// Make the simulation
		OffLatticeSimulation<2> simulator(cell_population);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);
		// ********************************************************************************************

		// ********************************************************************************************
		// Building the directory name
		std::stringstream simdir;
		simdir << "n_" << n;
		simdir << "_size_" << waves;
		
		std::string output_directory = "TestCryptColumnShape/Pulse/" +  simdir.str() + "/";

		simulator.SetOutputDirectory(output_directory);
		// ********************************************************************************************


		// ********************************************************************************************
		// File outputs
		// Files are only output if the command line argument -sm exists and a sampling multiple is set
		simulator.SetSamplingTimestepMultiple(sampling_multiple);
		// The java visuliser is set separately
		cell_population.SetOutputResultsForChasteVisualizer(java_visualiser);
		// ********************************************************************************************

		// ********************************************************************************************
		// Add forces
		// Need to add a constant up force on everything
		MAKE_PTR(ConstantForce<2>, p_force);
		p_force->SetForce(speed);
		p_force->SetAxis(2);
		simulator.AddForce(p_force);

		// ********************************************************************************************

		// ********************************************************************************************
		// Add the boundary conditions
		// Bottom cell locked in place

		MAKE_PTR_ARGS(NoForcePeriodicBoundaryCondition<2>, p_bc, (&cell_population));
		p_bc->SetTopBoundary((double)n);
		p_bc->SetBottomBoundary(0);
		p_bc->SetAxis(2);
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		// ********************************************************************************************

		// ********************************************************************************************
		// Run the simulation
		// ********************************************************************************************



		// ********************************************************************************************
		// Simulate through the transient behaviour
		simulator.SetEndTime(simulation_length);

		TRACE("Simulating pulse")
		simulator.Solve();
		// ********************************************************************************************


	};

};



