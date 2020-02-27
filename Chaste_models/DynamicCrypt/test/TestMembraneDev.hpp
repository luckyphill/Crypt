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
#include "EpithelialType.hpp"

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
		// Size parameters
		double membraneRadius = 0.5;
		if(CommandLineArguments::Instance()->OptionExists("-mr"))
		{
			membraneRadius = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-mr");
			PRINT_VARIABLE(membraneRadius)
		}

		unsigned width = 20;
		if(CommandLineArguments::Instance()->OptionExists("-w"))
		{
			width = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-w");
			PRINT_VARIABLE(width)
		}

		unsigned height = 5;
		if(CommandLineArguments::Instance()->OptionExists("-h"))
		{
			height = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-h");
			PRINT_VARIABLE(height)
		}
		// ********************************************************************************************

		// Cell cycle parameters
		double cellCycleTime = 15.0;
		if(CommandLineArguments::Instance()->OptionExists("-cct"))
		{
			cellCycleTime = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-cct");
			PRINT_VARIABLE(cellCycleTime)
		}
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
		std::vector<unsigned> membraneIndices;
		std::vector<unsigned> locationIndices;

		std::vector<std::vector<CellPtr>> membraneSections;

		unsigned nodeCounter = 0;


		std::vector<CellPtr> cells;
		std::vector<CellPtr> membraneCells;
	

		MAKE_PTR(DifferentiatedCellProliferativeType, pDiffType);
		MAKE_PTR(MembraneType, pMembraneType);
		MAKE_PTR(StromalType, pStromalType);
		MAKE_PTR(EpithelialType, pEpithelialType);
		MAKE_PTR(WildTypeCellMutationState, pState);


		// Make the stromal under-layer
		
		for (unsigned i = 0; i < width; i++)
		{
			for (unsigned j = 0; j < height; j++)
			{
				double x = i + 0.5 * (j%2);
				double y = j * std::sqrt(3)/2;
				Node<2>* pNode = new Node<2>(nodeCounter,  false,  x, y);
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
		}


		// Put a layer of membrane cells on top of the stroma
		double nMembraneCells = width / (2 * membraneRadius);

		for (unsigned i = 0; i < nMembraneCells; i++)
		{
			double y = (height - 0.5) * std::sqrt(3)/2  +  membraneRadius * std::sqrt(3)/2;
			double x = i * 2 * membraneRadius + 0.5 * (height%2);
			Node<2>* pNode = new Node<2>(nodeCounter,  false,  x, y);
			pNode->SetRadius(membraneRadius);
			nodes.push_back(pNode);

			locationIndices.push_back(nodeCounter);
			membraneIndices.push_back(nodeCounter);
			nodeCounter++;

			NoCellCycleModel* pCycleModel = new NoCellCycleModel();

			CellPtr pCell(new Cell(pState, pCycleModel));
			pCell->SetCellProliferativeType(pMembraneType);
			pCell->InitialiseCellCycleModel();
			membraneCells.push_back(pCell);
			cells.push_back(pCell);
		}

		// Add an epithelial layer
		for (unsigned i = 0; i < width; i++)
		{
			double y = (height - 0.5) * std::sqrt(3)/2  +  (2 * membraneRadius + 0.5) * std::sqrt(3)/2;
			double x = i + 0.5 * ((height+1)%2);
			Node<2>* pNode = new Node<2>(nodeCounter,  false,  x, y);

			nodes.push_back(pNode);

			locationIndices.push_back(nodeCounter);
			nodeCounter++;

			UniformCellCycleModel* pCycleModel = new UniformCellCycleModel();
			double birth_time = cellCycleTime * RandomNumberGenerator::Instance()->ranf();
			pCycleModel->SetBirthTime(-birth_time);
			pCycleModel->SetMinCellCycleDuration(cellCycleTime);

			CellPtr pCell(new Cell(pState, pCycleModel));
			pCell->SetCellProliferativeType(pEpithelialType);
			pCell->InitialiseCellCycleModel();
			pCell->GetCellData()->SetItem("parent", pCell->GetCellId());
			cells.push_back(pCell);
		}

		

		membraneSections.push_back(membraneCells);

		// NodesOnlyMesh<2> mesh;
		// mesh.ConstructNodesWithoutMesh(nodes, maxInteractionRadius);
		// NodeBasedCellPopulation<2> cell_population(mesh, cells, locationIndices);

		Cylindrical2dNodesOnlyMesh* pMesh = new Cylindrical2dNodesOnlyMesh(width);
		pMesh->ConstructNodesWithoutMesh(nodes, maxInteractionRadius);
		NodeBasedCellPopulation<2> cell_population(*pMesh, cells, locationIndices);

		c_vector<double, 2> membraneAxis;
		membraneAxis(0) = 1;
		membraneAxis(1) = 0;

		MAKE_PTR(StickToMembraneDivisionRule<2>, pCentreBasedDivisionRule);
		pCentreBasedDivisionRule->SetMembraneAxis(membraneAxis);
		pCentreBasedDivisionRule->SetWiggleDivision(true);
		cell_population.SetCentreBasedDivisionRule(pCentreBasedDivisionRule);

		OffLatticeSimulation<2> simulator(cell_population);


		simulator.SetOutputDirectory("TestMembraneInternalForce");
		simulator.SetEndTime(simulation_length);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR_ARGS(MembraneInternalForce, p_membrane, (membraneSections, true));
		p_membrane->SetMembraneStiffness(membraneStiffness);
		p_membrane->SetExternalStiffness(externalStiffness);
		simulator.AddForce(p_membrane);

		MAKE_PTR(StromalInternalForce<2>, pStroma);
		pStroma->SetSpringStiffness(stromalStiffness);
		simulator.AddForce(pStroma);

		MAKE_PTR(EpithelialInternalForce<2>, pEpithelial);
		pEpithelial->SetSpringStiffness(epithelialStiffness);
		simulator.AddForce(pEpithelial);

		MAKE_PTR_ARGS(MembraneDetachmentKiller, pAnoikis, (&cell_population));
		pAnoikis->SetCutOffRadius(maxInteractionRadius);
		simulator.AddCellKiller(pAnoikis);

		c_vector<double, 2> point;
		c_vector<double, 2> normal;
		point[0] = 0;
		point[1] = 0;
		normal[0] = 0;
		normal[1] = 1;

		// MAKE_PTR_ARGS(PlaneBoundaryCondition<2,2>, pPlaneBC, (&cell_population, point, normal));
		boost::shared_ptr<PlaneBoundaryCondition<2,2> > pPlaneBC(new PlaneBoundaryCondition<2,2>(&cell_population, point, -normal));
		simulator.AddCellPopulationBoundaryCondition(pPlaneBC);

		simulator.Solve();


	};

};