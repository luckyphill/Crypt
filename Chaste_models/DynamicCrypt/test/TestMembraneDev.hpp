#include <cxxtest/TestSuite.h> //Needed for all test files
#include "CellBasedSimulationArchiver.hpp" //Needed if we would like to save/load simulations
#include "AbstractCellBasedTestSuite.hpp" //Needed for cell-based tests: times simulations, generates random numbers and has cell properties
#include "CheckpointArchiveTypes.hpp" //Needed if we use GetIdentifier() method (which we do)
#include "SmartPointers.hpp" //Enables macros to save typing

/* The next set of classes are needed specifically for the simulation, which can be found in the core code. */

#include "HoneycombMeshGenerator.hpp" //Generates mesh
#include "CylindricalHoneycombMeshGenerator.hpp"
#include "OffLatticeSimulation.hpp" //Simulates the evolution of the population
#include "MeshBasedCellPopulationWithGhostNodes.hpp"
#include "GeneralisedLinearSpringForce.hpp" //give a force to use between cells
#include "WildTypeCellMutationState.hpp"


#include "TorsionalSpringForce.hpp" // A force to restore the membrane to it's preferred shape
#include "MembraneInternalForce.hpp"
#include "NoCellCycleModel.hpp"

// #include "BoundaryCellProperty.hpp"

#include "TransitCellProliferativeType.hpp"
#include "UniformCellCycleModel.hpp"
#include "NodesOnlyMesh.hpp"
#include "NodeBasedCellPopulation.hpp"
#include "CellsGenerator.hpp"
#include "TrianglesMeshWriter.hpp"

#include "DifferentiatedCellProliferativeType.hpp"

#include "Debug.hpp"

#include "FakePetscSetup.hpp"





class TestMembraneDev : public AbstractCellBasedTestSuite
{
	public:
	void TestMembraneTorsionSpring() throw(Exception)
	{

		// ********************************************************************************************
		// Input parameters in order usually expected, grouped by category
		// ********************************************************************************************



		// ********************************************************************************************
		// Membrane parameters
		double n = 20;
		if(CommandLineArguments::Instance()->OptionExists("-n"))
		{	
			n = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-n");
			PRINT_VARIABLE(n)

		}

		double membraneStiffness = 50;
		if(CommandLineArguments::Instance()->OptionExists("-ms"))
		{
			membraneStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ms");
			PRINT_VARIABLE(membraneStiffness)
		}

		double torsionalStiffness = 1;
		if(CommandLineArguments::Instance()->OptionExists("-ts"))
		{
			torsionalStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ts");
			PRINT_VARIABLE(torsionalStiffness)
		}

		double targetCurvature = 0.3;
		if(CommandLineArguments::Instance()->OptionExists("-cv"))
		{
			targetCurvature = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-cv");
			PRINT_VARIABLE(targetCurvature)
		}
		// ********************************************************************************************

		// ********************************************************************************************
		// Simulation parameters
		double dt = 0.005; // The minimum to get covergant simulations for a specific parameter set
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
		double sampling_multiple = 10;
		if(CommandLineArguments::Instance()->OptionExists("-sm"))
		{   
			sampling_multiple = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-sm");
			file_output = true;
			TRACE("File output occurring")

		}

		bool java_visualiser = true;
		if(CommandLineArguments::Instance()->OptionExists("-vis"))
		{   
			java_visualiser = true;
			TRACE("Java visualiser ON")

		}
		// ********************************************************************************************



		std::vector<Node<2>*> nodes;
		std::vector<unsigned> location_indices;

		unsigned node_counter = 0;

		double maxInteractionRadius = 0.8;


		std::vector<CellPtr> cells;


		for (unsigned i = 0; i < n; i++)
		{
			nodes.push_back(new Node<2>(node_counter,  false,  i, 0));
			location_indices.push_back(node_counter);
			node_counter++;
		}

		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, maxInteractionRadius);

		MAKE_PTR(DifferentiatedCellProliferativeType, p_diff_type);
		MAKE_PTR(WildTypeCellMutationState, p_state);

		for (unsigned i = 0; i < n; i++)
		{
			NoCellCycleModel* p_cycle_model = new NoCellCycleModel();
			CellPtr p_cell(new Cell(p_state, p_cycle_model));

			p_cell->SetCellProliferativeType(p_diff_type);
			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}


		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);

		OffLatticeSimulation<2> simulator(cell_population);

		simulator.SetOutputDirectory("TestMembraneTorsionSpring");
		simulator.SetEndTime(simulation_length);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(GeneralisedLinearSpringForce<2>, p_force);
		p_force->SetMeinekeSpringStiffness(membraneStiffness);
		simulator.AddForce(p_force);

		MAKE_PTR(TorsionalSpringForce, p_torsional_force);
		p_torsional_force->SetTorsionalStiffness(torsionalStiffness);
		p_torsional_force->SetTargetCurvature(targetCurvature);
		p_torsional_force->SetDt(dt);
		p_torsional_force->SetDampingConstant(1);

		simulator.AddForce(p_torsional_force);

		TRACE("All set up")
		simulator.Solve();

	};

	void TestMembraneBulkStroma() throw(Exception)
	{

		// The membrane is a string of cells, that only interact with their immediate neighbour
		// and the crypt cells. The effect of the stromal cells is replaced with a bulk property
		// force

		// ********************************************************************************************
		// Input parameters in order usually expected, grouped by category
		// ********************************************************************************************

		// ********************************************************************************************
		// Input parameter to choose position file
		unsigned type = 1;
		if(CommandLineArguments::Instance()->OptionExists("-type"))
		{
			type = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-type");
			PRINT_VARIABLE(type)
		}


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
		// ********************************************************************************************

		// ********************************************************************************************
		// Simulation parameters
		double dt = 0.005; // The minimum to get covergant simulations for a specific parameter set
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
		double sampling_multiple = 10;
		if(CommandLineArguments::Instance()->OptionExists("-sm"))
		{   
			sampling_multiple = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-sm");
			file_output = true;
			TRACE("File output occurring")

		}

		bool java_visualiser = true;
		if(CommandLineArguments::Instance()->OptionExists("-vis"))
		{   
			java_visualiser = true;
			TRACE("Java visualiser ON")

		}
		// ********************************************************************************************


		std::vector<double> membraneX{2.5, 1.5, 0.8, 0.25, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,  0.0,  0.0,  0.0,  0.0};
		std::vector<double> membraneY{0.0, 0.25, 0.8, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5, 12.5, 13.5, 14.5};
		

		std::vector<Node<2>*> nodes;
		std::vector<unsigned> membrane_nodes;
		std::vector<unsigned> location_indices;

		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned node_counter = 0;

		double maxInteractionRadius = 2;


		std::vector<CellPtr> cells;
		std::vector<CellPtr> membrane_cells;


		for (unsigned i = 0; i < membraneX.size(); i++)
		{
			nodes.push_back(new Node<2>(node_counter,  false,  membraneX[i], membraneY[i]));
			location_indices.push_back(node_counter);
			membrane_nodes.push_back(node_counter);
			node_counter++;
		}

		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, maxInteractionRadius);

		MAKE_PTR(DifferentiatedCellProliferativeType, p_diff_type);
		MAKE_PTR(WildTypeCellMutationState, p_state);


		for (unsigned i = 0; i < membrane_nodes.size(); i++)
		{
			NoCellCycleModel* p_cycle_model = new NoCellCycleModel();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_diff_type);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
			membrane_cells.push_back(p_cell);
		}

		membraneSections.push_back(membrane_cells);


		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);

		OffLatticeSimulation<2> simulator(cell_population);

		simulator.SetOutputDirectory("TestMembraneBulkStroma");
		simulator.SetEndTime(simulation_length);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(MembraneInternalForce, p_membrane);
		p_membrane->SetMembraneStiffness(membraneStiffness);
		p_membrane->SetMembraneSections(membraneSections);
		simulator.AddForce(p_membrane);

		simulator.Solve();

	}

};