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
#include "StromalInternalForce.hpp"

#include "NoCellCycleModel.hpp"

// #include "BoundaryCellProperty.hpp"

#include "TransitCellProliferativeType.hpp"
#include "UniformCellCycleModel.hpp"
#include "NodesOnlyMesh.hpp"
#include "NodeBasedCellPopulation.hpp"
#include "NodeBasedCellPopulationWithParticles.hpp"
#include "CellsGenerator.hpp"
#include "TrianglesMeshWriter.hpp"

#include "DifferentiatedCellProliferativeType.hpp"
#include "MembraneType.hpp"
#include "StromalType.hpp"

#include "Debug.hpp"

#include "FakePetscSetup.hpp"





class TestMembraneDev : public AbstractCellBasedTestSuite
{
	public:
	void xTestMembraneTorsionSpring() throw(Exception)
	{
		// DOESNT PRODUCE THE DESIRED BEHAVIOUR
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
		std::vector<unsigned> locationIndices;

		unsigned nodeCounter = 0;

		double maxInteractionRadius = 0.8;


		std::vector<CellPtr> cells;


		for (unsigned i = 0; i < n; i++)
		{
			nodes.push_back(new Node<2>(nodeCounter,  false,  i, 0));
			locationIndices.push_back(nodeCounter);
			nodeCounter++;
		}

		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, maxInteractionRadius);

		MAKE_PTR(DifferentiatedCellProliferativeType, pDiffType);
		MAKE_PTR(WildTypeCellMutationState, pState);

		for (unsigned i = 0; i < n; i++)
		{
			NoCellCycleModel* pCycleModel = new NoCellCycleModel();
			CellPtr pCell(new Cell(pState, pCycleModel));

			pCell->SetCellProliferativeType(pDiffType);
			pCell->InitialiseCellCycleModel();

			cells.push_back(pCell);
		}


		NodeBasedCellPopulation<2> cell_population(mesh, cells, locationIndices);

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

	void TestMembraneInternalForce() throw(Exception)
	{

		// The membrane is a string of cells, that only interact with their immediate neighbour
		// and the crypt cells. Stromal cells fill in the intercrypt space, and the epithelial cells
		// sit on the membrane

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

		double externalStiffness = 50;
		if(CommandLineArguments::Instance()->OptionExists("-ex"))
		{
			externalStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ex");
			PRINT_VARIABLE(externalStiffness)
		}

		double stromalStiffness = 50;
		if(CommandLineArguments::Instance()->OptionExists("-ss"))
		{
			stromalStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ss");
			PRINT_VARIABLE(stromalStiffness)
		}

		double maxInteractionRadius = 0.6;
		if(CommandLineArguments::Instance()->OptionExists("-ir"))
		{
			maxInteractionRadius = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ir");
			PRINT_VARIABLE(maxInteractionRadius)
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


		std::vector<double> membraneX{2.5, 1.5, 0.8, 0.25, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,  0.0,  0.0,  0.0,  0.0, -0.25, -0.8, -1.5, -2.5};
		std::vector<double> membraneY{0.0, 0.25, 0.8, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5, 12.5, 13.5, 14.5, 15.5, 16.2, 16.75, 17};
		

		std::vector<Node<2>*> nodes;
		std::vector<unsigned> membraneIndices;
		std::vector<unsigned> locationIndices;

		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned nodeCounter = 0;


		std::vector<CellPtr> cells;
		std::vector<CellPtr> membraneCells;


		for (unsigned i = 0; i < membraneX.size(); i++)
		{
			Node<2>* pNode = new Node<2>(nodeCounter,  false,  membraneX[i], membraneY[i]);
			pNode->SetRadius(0.5);
			nodes.push_back(pNode);

			locationIndices.push_back(nodeCounter);
			membraneIndices.push_back(nodeCounter);
			nodeCounter++;
		}

		

		MAKE_PTR(DifferentiatedCellProliferativeType, pDiffType);
		MAKE_PTR(MembraneType, pMembraneType);
		MAKE_PTR(StromalType, pStromalType);
		MAKE_PTR(WildTypeCellMutationState, pState);


		for (unsigned i = 0; i < membraneIndices.size(); i++)
		{
			NoCellCycleModel* pCycleModel = new NoCellCycleModel();

			CellPtr pCell(new Cell(pState, pCycleModel));
			pCell->SetCellProliferativeType(pMembraneType);
			pCell->InitialiseCellCycleModel();
			membraneCells.push_back(pCell);
			cells.push_back(pCell);
		}

		membraneSections.push_back(membraneCells);


		// Put in the stromal cells
		std::vector<double> stromaX{ 2.5,  1.5,  0.5, -0.5, -1.5, -2.5,
									 -2.5, -2.5, -2.5, -2.5, -2.5, -2.5, -2.5, -2.5, -2.5, -2.5, -2.5, -2.5, -2.5, -2.5, -2.5, -2.5, -2.5,
									  -1.5, -1.5, -1.5, -1.5, -1.5, -1.5, -1.5, -1.5, -1.5, -1.5, -1.5, -1.5, -1.5, -1.5, -1.5, -1.5, -1.5,
									   -0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -0.5,
									   	 0.5};
		std::vector<double> stromaY{-1.0, -1.0, -1.0, -1.0, -1.0, -1.0,
									  0.0,  1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0,  9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0,
									  	0.0,  1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0,  9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0,
									  	 0.0,  1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0,  9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0,
									  	  0.0};
		
		for (unsigned i = 0; i < stromaX.size(); i++)
		{
			Node<2>* pNode = new Node<2>(nodeCounter,  false,  stromaX[i], stromaY[i]);
			nodes.push_back(pNode);

			locationIndices.push_back(nodeCounter);
			nodeCounter++;

			NoCellCycleModel* pCycleModel = new NoCellCycleModel();

			CellPtr pCell(new Cell(pState, pCycleModel));
			pCell->SetCellProliferativeType(pStromalType);
			pCell->InitialiseCellCycleModel();
			pCell->GetCellData()->SetItem("parent", pCell->GetCellId());
			cells.push_back(pCell);
		}

		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, maxInteractionRadius);

		NodeBasedCellPopulation<2> cell_population(mesh, cells, locationIndices);

		OffLatticeSimulation<2> simulator(cell_population);


		simulator.SetOutputDirectory("TestMembraneInternalForce");
		simulator.SetEndTime(simulation_length);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(MembraneInternalForce, p_membrane);
		p_membrane->SetMembraneStiffness(membraneStiffness);
		p_membrane->SetExternalStiffness(externalStiffness);
		p_membrane->SetMembraneSections(membraneSections);
		simulator.AddForce(p_membrane);

		MAKE_PTR(StromalInternalForce<2>, pStroma);
		pStroma->SetSpringStiffness(stromalStiffness);
		simulator.AddForce(pStroma);

		simulator.Solve();


	};

};