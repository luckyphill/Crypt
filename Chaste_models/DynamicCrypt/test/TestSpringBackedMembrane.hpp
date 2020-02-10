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
#include "StickToMembraneDivisionRule.hpp"
#include "FixedPlaneBoundaryCondition.hpp"
#include "PlaneBoundaryCondition.hpp"
#include "StopCreepBoundaryCondition.hpp"
#include "SimpleSloughingCellKiller.hpp"

#include "MembraneDetachmentKiller.hpp"

#include "Debug.hpp"

#include "FakePetscSetup.hpp"

class TestSpringBackedMembrane : public AbstractCellBasedTestSuite
{
	
public:


	void TestTheThing() throw(Exception)
	{
		// This test duplicates TestCryptColumn, except it applies a spring backed membrane instead of
		// just the normal force



		// ********************************************************************************************
		// Input parameters in order usually expected, grouped by category
		// ********************************************************************************************



		// ********************************************************************************************
		// Crypt size parameters
		double n = 20;
		if(CommandLineArguments::Instance()->OptionExists("-n"))
		{	
			n = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-n");
			PRINT_VARIABLE(n)

		}

		double n_prolif = n - 10; // Number of proliferative cells, counting up from the bottom
		if(CommandLineArguments::Instance()->OptionExists("-np"))
		{	
			n_prolif = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-np");
			PRINT_VARIABLE(n_prolif)

		}

		double prolifFraction = 0.5; // Proliferative compartment as a fraction of crypt height
		// To make sure this test is still compatible with old data, need to add this check
		bool prolifByFraction = CommandLineArguments::Instance()->OptionExists("-pf");
		if(prolifByFraction)
		{	
			prolifFraction = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-pf");
			PRINT_VARIABLE(prolifFraction)

		}

		
		// ********************************************************************************************

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

		double springBackedStiffness = 50;
		if(CommandLineArguments::Instance()->OptionExists("-sb"))
		{
			springBackedStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-sb");
			PRINT_VARIABLE(springBackedStiffness)
		}

		double stromalStiffness = 50;
		if(CommandLineArguments::Instance()->OptionExists("-ss"))
		{
			stromalStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ss");
			PRINT_VARIABLE(stromalStiffness)
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

		double growthFraction = 0.5; // W phase as a fraction of cellCycleTime
		// To make sure this test is still compatible with old data, need to add this check
		bool growthByFraction = CommandLineArguments::Instance()->OptionExists("-gf");
		if(prolifByFraction)
		{	
			growthFraction = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-gf");
			PRINT_VARIABLE(growthFraction)

		}

		// Should be implemented better, but a quick check to make sure the cell cycle phases
		// aren't set too extreme.
		if (!growthByFraction)
		{
			assert(cellCycleTime - wPhaseLength > 1);
		}
		

		double quiescentVolumeFraction = 0.75;
		if(CommandLineArguments::Instance()->OptionExists("-vf"))
		{	
			quiescentVolumeFraction = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-vf");
			PRINT_VARIABLE(quiescentVolumeFraction)

		}
		// ********************************************************************************************

		// ********************************************************************************************
		// Simulation parameters
		double dt = 0.0005; // The minimum to get covergant simulations for a specific parameter set
		if(CommandLineArguments::Instance()->OptionExists("-dt"))
		{
			dt = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-dt");
			PRINT_VARIABLE(dt)
		}
		
		double burn_in_time = 100; // The time needed to clear the transient behaviour from the initial set up
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
		double sampling_multiple = 10;
		if(CommandLineArguments::Instance()->OptionExists("-sm"))
		{   
			sampling_multiple = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-sm");
			file_output = true;
			TRACE("File output occuring")

		}

		bool java_visualiser = true;
		if(CommandLineArguments::Instance()->OptionExists("-vis"))
		{   
			java_visualiser = true;
			TRACE("Java visualiser ON")

		}
		// ********************************************************************************************


		// ********************************************************************************************
		// Fixed parameters  
		double popUpDistance = 2.5; // The distance from the membrane when cells die
		
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
		std::vector<unsigned> locationIndices;
		std::vector<std::vector<CellPtr>> membraneSections;


		// Column building parameters
		double x_distance = 2.0;
		double y_distance = 0;
		double x = x_distance;
		double y = y_distance;

		// Put down first node which will be a boundary condition node
		Node<2>* single_node =  new Node<2>(node_counter,  false,  x, y);
		single_node->SetRadius(epithelialPreferredRadius);
		nodes.push_back(single_node);
		locationIndices.push_back(node_counter);
		node_counter++;


		// Initialise the crypt nodes
		for(unsigned i = 1; i <= n; i++)
		{
			x = x_distance;
			y = y_distance + 2 * i * epithelialPreferredRadius;
			Node<2>* single_node_2 =  new Node<2>(node_counter,  false,  x, y);
			single_node_2->SetRadius(epithelialPreferredRadius);
			nodes.push_back(single_node_2);
			locationIndices.push_back(node_counter);
			node_counter++;
		}

		// ********************************************************************************************
		// Add the membrane nodes
		x_distance = 1.0;
		y_distance = 0;
		x = x_distance;
		y = y_distance;
		for(unsigned i = 0; i <= n; i++)
		{
			x = x_distance;
			y = y_distance + 2 * i * epithelialPreferredRadius;
			Node<2>* single_node_2 =  new Node<2>(node_counter,  false,  x, y);
			single_node_2->SetRadius(epithelialPreferredRadius);
			nodes.push_back(single_node_2);
			locationIndices.push_back(node_counter);
			node_counter++;
		}
		// ******************************************************************************************** 


		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, maxInteractionRadius);
		// ********************************************************************************************


		// ********************************************************************************************
		// Make the cells
		std::vector<CellPtr> cells;
		std::vector<CellPtr> membraneCells;

		MAKE_PTR(StromalType, pStromal);
		MAKE_PTR(WildTypeCellMutationState, pState);
		MAKE_PTR(MembraneType, pMembraneType);
		MAKE_PTR(BoundaryCellProperty, pBoundary);

		// Give the crypt its cells
		// {
		// 	NoCellCycleModel* pCycleModel = new NoCellCycleModel();

		// 	CellPtr pCell(new Cell(pState, pCycleModel));
		// 	pCell->SetCellProliferativeType(pMembraneType);
		// 	pCell->GetCellData()->SetItem("parent", pCell->GetCellId());
		// 	pCell->InitialiseCellCycleModel();

		// 	cells.push_back(pCell);
		// }
		for(unsigned i=0; i<=n; i++)
		{

			UniformCellCycleModel* pCycleModel = new UniformCellCycleModel();
			double birth_time = cellCycleTime * RandomNumberGenerator::Instance()->ranf();

			pCycleModel->SetBirthTime(-birth_time);

			CellPtr pCell(new Cell(pState, pCycleModel));
			pCell->SetCellProliferativeType(pStromal);
			pCell->InitialiseCellCycleModel();
			pCell->GetCellData()->SetItem("parent", pCell->GetCellId());
			cells.push_back(pCell);
			
		}
		// ********************************************************************************************
		// Add the membrane cells
		
		{
			NoCellCycleModel* pCycleModel = new NoCellCycleModel();

			CellPtr pCell(new Cell(pState, pCycleModel));
			pCell->SetCellProliferativeType(pMembraneType);
			pCell->GetCellData()->SetItem("parent", pCell->GetCellId());
			pCell->AddCellProperty(pBoundary);
			pCell->InitialiseCellCycleModel();
			membraneCells.push_back(pCell);
			cells.push_back(pCell);
		}
		
		for(unsigned i = 1; i <= n; i++)
		{
			NoCellCycleModel* pCycleModel = new NoCellCycleModel();

			CellPtr pCell(new Cell(pState, pCycleModel));
			pCell->SetCellProliferativeType(pMembraneType);
			pCell->InitialiseCellCycleModel();
			pCell->GetCellData()->SetItem("parent", pCell->GetCellId());
			
			pCell->AddCellProperty(pBoundary);

			membraneCells.push_back(pCell);
			cells.push_back(pCell);
		}
		membraneSections.push_back(membraneCells);

		NodeBasedCellPopulation<2> cell_population(mesh, cells, locationIndices);

		c_vector<double, 2> membraneAxis;
		membraneAxis(0) = 0;
		membraneAxis(1) = 1;

		MAKE_PTR(StickToMembraneDivisionRule<2>, pCentreBasedDivisionRule);
		pCentreBasedDivisionRule->SetMembraneAxis(membraneAxis);
		pCentreBasedDivisionRule->SetWiggleDivision(true);
		cell_population.SetCentreBasedDivisionRule(pCentreBasedDivisionRule);

		OffLatticeSimulation<2> simulator(cell_population);

		simulator.SetOutputDirectory("TestSpringBackedMembrane");
		simulator.SetEndTime(simulation_length);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(MembraneInternalForce, pMembrane);
		pMembrane->SetMembraneStiffness(membraneStiffness);
		pMembrane->SetExternalStiffness(externalStiffness);
		pMembrane->SetSpringBackedStiffness(springBackedStiffness);
		pMembrane->SetMembraneSections(membraneSections);
		pMembrane->UseSpringBackedMembrane(true);
		simulator.AddForce(pMembrane);

		MAKE_PTR(StromalInternalForce<2>, pStroma);
		pStroma->SetSpringStiffness(stromalStiffness);
		simulator.AddForce(pStroma);

		MAKE_PTR_ARGS(MembraneDetachmentKiller, pAnoikis, (&cell_population));
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

		point[0] = 0.8;
		point[1] = 0;
		normal[0] = 1;
		normal[1] = 0;

		// boost::shared_ptr<StopCreepBoundaryCondition<StromalType> > pCreepBC(new StopCreepBoundaryCondition<StromalType>(&cell_population, point, -normal));
		// simulator.AddCellPopulationBoundaryCondition(pCreepBC);

		boost::shared_ptr<FixedPlaneBoundaryCondition> pFixedPlaneBC(new FixedPlaneBoundaryCondition(&cell_population, 1));
		simulator.AddCellPopulationBoundaryCondition(pFixedPlaneBC);

		MAKE_PTR_ARGS(SimpleSloughingCellKiller<2>, pKiller, (&cell_population));
		pKiller->SetCryptTop(n);
		simulator.AddCellKiller(pKiller);

		simulator.Solve();

	};

};



