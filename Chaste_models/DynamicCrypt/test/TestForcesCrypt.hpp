#include <cxxtest/TestSuite.h> //Needed for all test files
#include "CellBasedSimulationArchiver.hpp" //Needed if we would like to save/load simulations
#include "AbstractCellBasedTestSuite.hpp" //Needed for cell-based tests: times simulations, generates random numbers and has cell properties
#include "CheckpointArchiveTypes.hpp" //Needed if we use GetIdentifier() method (which we do)
#include "SmartPointers.hpp" //Enables macros to save typing

/* The next set of classes are needed specifically for the simulation, which can be found in the core code. */

#include "OffLatticeSimulation.hpp" //Simulates the evolution of the population
#include "MeshBasedCellPopulationWithGhostNodes.hpp"
#include "GeneralisedLinearSpringForce.hpp" //give a force to use between cells
#include "WildTypeCellMutationState.hpp"


#include "TorsionalSpringForce.hpp" // A force to restore the membrane to it's preferred shape
#include "MembraneInternalForce.hpp"
#include "StromalInternalForce.hpp"
#include "EpithelialInternalForce.hpp"

#include "StickToMembraneDivisionRule.hpp"

#include "MembraneDetachmentKiller.hpp"

#include "NoCellCycleModel.hpp"

#include "PlaneBoundaryCondition.hpp"

// #include "BoundaryCellProperty.hpp"

#include "TransitCellProliferativeType.hpp"
#include "UniformCellCycleModel.hpp"
#include "NodesOnlyMesh.hpp"
#include "Cylindrical2dNodesOnlyMesh.hpp"
#include "NodeBasedCellPopulation.hpp"
#include "NodeBasedCellPopulationWithParticles.hpp"
#include "CellsGenerator.hpp"
#include "TrianglesMeshWriter.hpp"

#include "DifferentiatedCellProliferativeType.hpp"
#include "MembraneType.hpp"
#include "StromalType.hpp"
#include "StemType.hpp"
#include "EpithelialType.hpp"

#include "Debug.hpp"

#include "FakePetscSetup.hpp"





class TestForcesCrypt : public AbstractCellBasedTestSuite
{
	public:

	void TestForceParameter() throw(Exception)
	{

		// The membrane is a string of cells, that only interact with their immediate neighbour
		// and the crypt cells. Stromal cells fill in the intercrypt space, and the epithelial cells
		// sit on the membrane

		// ********************************************************************************************
		// Input parameters in order usually expected, grouped by category
		// ********************************************************************************************


		// ********************************************************************************************
		// Force parameters
		double epithelialStiffness = 20;
		if(CommandLineArguments::Instance()->OptionExists("-ees"))
		{
			epithelialStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ees");
			PRINT_VARIABLE(epithelialStiffness)
		}

		double separation = 2;
		if(CommandLineArguments::Instance()->OptionExists("-sep"))
		{
			separation = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-sep");
			PRINT_VARIABLE(separation)
		}

		double maxInteractionRadius = 1.5;
		if(CommandLineArguments::Instance()->OptionExists("-ir"))
		{
			maxInteractionRadius = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ir");
			PRINT_VARIABLE(maxInteractionRadius)
		}

		double alpha = 5;
		if(CommandLineArguments::Instance()->OptionExists("-a"))
		{
			alpha = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-a");
			PRINT_VARIABLE(alpha)
		}

		double cutOff = 2;
		if(CommandLineArguments::Instance()->OptionExists("-co"))
		{
			cutOff = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-co");
			PRINT_VARIABLE(cutOff)
		}

		// Simulation parameters
		double dt = 0.005; // The minimum to get covergant simulations for a specific parameter set
		if(CommandLineArguments::Instance()->OptionExists("-dt"))
		{
			dt = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-dt");
			PRINT_VARIABLE(dt)
		}

		double simulation_length = 10;
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
		std::vector<unsigned> membraneIndices;
		std::vector<unsigned> locationIndices;


		unsigned nodeCounter = 0;


		std::vector<CellPtr> cells;
		std::vector<CellPtr> membraneCells;
	

		MAKE_PTR(DifferentiatedCellProliferativeType, pDiffType);
		MAKE_PTR(MembraneType, pMembraneType);
		MAKE_PTR(StromalType, pStromalType);
		MAKE_PTR(StemType, pStemType);
		MAKE_PTR(EpithelialType, pEpithelialType);
		MAKE_PTR(WildTypeCellMutationState, pState);


		// Add two cells
		
		{
			Node<2>* pNode = new Node<2>(nodeCounter,  false,  2, 2);
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

		{
			Node<2>* pNode = new Node<2>(nodeCounter,  false,  2, 2 + separation);
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


		simulator.SetOutputDirectory("TestForceParameter");
		simulator.SetEndTime(simulation_length);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(StromalInternalForce<2>, pStroma);
		pStroma->SetSpringStiffness(epithelialStiffness);
		pStroma->SetAttractionParameter(alpha);
		pStroma->SetCutOffLength(cutOff);
		simulator.AddForce(pStroma);

		simulator.Solve();


	};

};