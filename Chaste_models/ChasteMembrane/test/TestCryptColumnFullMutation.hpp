// Standard includes for tests
#include <cxxtest/TestSuite.h>
#include "AbstractCellBasedTestSuite.hpp"
#include "CheckpointArchiveTypes.hpp"
#include "SmartPointers.hpp"
#include "CommandLineArguments.hpp"

// Simulators
#include "OffLatticeSimulation.hpp"

// Forces
#include "NormalAdhesionForceNewPhaseModel.hpp"
#include "BasicNonLinearSpringForceMultiNodeFix.hpp"

// Mesh
#include "NodesOnlyMesh.hpp"

// Cell Population
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
#include "TransitCellAnoikisResistantMutationState.hpp"
#include "WeakenedMembraneAdhesion.hpp"
#include "WeakenedCellCellAdhesion.hpp"

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
#include "EpithelialCellPositionWriter.hpp"
#include "PopUpLocationWriter.hpp"

// Misc
#include "FakePetscSetup.hpp"
#include "Debug.hpp"


class TestCryptColumnFullMutation : public AbstractCellBasedTestSuite
{
	
public:


	void TestCryptMutation() throw(Exception)
	{
		// Here we apply mutations to the entire crypt after a period of
		// time to clear the transient behaviour

		// This test assumes that we already know the optimal parameters for a range of
		// crypts. These crypt types are hard coded, but the actual parameters are stored
		// externally. The crypt type is specified by the -crypt flag with a number
		//corresponding to the type required:
		// 1. MouseColonDesc
		// 2. MouseColonAsc
		// 3. MouseColonTrans
		// 4. MouseColonCaecum
		// 5. RatColonDesc
		// 6. RatColonAsc
		// 7. RatColonTrans
		// 8. RatColonCaecum
		// 9. HumanColon

		// ********************************************************************************************
		// Specify crypt type and parameters
		unsigned type = 1u;
		if(CommandLineArguments::Instance()->OptionExists("-crypt"))
		{	
			type = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-crypt");
			if (type > 9)
			{
				EXCEPTION("Crypt type must be between 1 and 9");
			}
		}

		std::stringstream input_file;
		input_file << std::getenv("HOME");
		input_file << "/Research/Crypt/Chaste_models/ChasteMembrane/test/params/";
		std::stringstream cryptType;
		switch(type)
		{
			case 1u:
			{
				cryptType << "MouseColonDesc";
				TRACE("Simulating with MouseColonDesc crypt")
				break;
			}
			case 2u:
			{
				cryptType << "MouseColonAsc";
				TRACE("Simulating with MouseColonAsc crypt")
				break;
			}
			case 3u:
			{
				cryptType << "MouseColonTrans";
				TRACE("Simulating with MouseColonTrans crypt")
				break;
			}
			case 4u:
			{
				cryptType << "MouseColonCaecum";
				TRACE("Simulating with MouseColonCaecum crypt")
				break;
			}
			case 5u:
			{
				cryptType << "RatColonDesc";
				TRACE("Simulating with RatColonDesc crypt")
				break;
			}
			case 6u:
			{
				cryptType << "RatColonAsc";
				TRACE("Simulating with RatColonAsc crypt")
				break;
			}
			case 7u:
			{
				cryptType << "RatColonTrans";
				TRACE("Simulating with RatColonTrans crypt")
				break;
			}
			case 8u:
			{
				cryptType << "RatColonCaecum";
				TRACE("Simulating with RatColonCaecum crypt")
				break;
			}
			case 9u:
			{
				cryptType << "HumanColon";
				TRACE("Simulating with HumanColon crypt")
				break;
			}
			default:
				NEVER_REACHED;
		}

		input_file << cryptType.str() << ".txt";

		std::ifstream inputParams;
		inputParams.open (input_file.str(), std::ios::in);
		double readParams[7];
		std::string line;
		if (inputParams.is_open())
		{
			unsigned i = 0;
			while (inputParams >> readParams[i])
			{
				i++;
			}
			inputParams.close();
		}

		// ********************************************************************************************
		// Crypt size parameters
		unsigned n = unsigned(readParams[0]);
		unsigned n_prolif = unsigned(readParams[1]);
		// ********************************************************************************************

		// ********************************************************************************************
		// Force parameters
		double epithelialStiffness = readParams[2];
		double membraneStiffness = readParams[3];
		double meinekeStiffness = epithelialStiffness; // Newly divided spring stiffness
		// ********************************************************************************************
		// Cell cycle parameters
		double cellCycleTime = readParams[5];
		double wPhaseLength = readParams[6];
		double quiescentVolumeFraction = readParams[4];
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
		// Mutation input parameters
		// ********************************************************************************************
		TRACE("Mutation parameters")

		// ******************************************************************************************** 
		// Crypt height - strictly speaking this should be emergent, but in this type of model it has
		// to be manually controlled 
		unsigned mutantN = n; // Number of proliferative cells, counting up from the bottom
		if(CommandLineArguments::Instance()->OptionExists("-Mn"))
		{   
			mutantN = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-Mn");
			PRINT_VARIABLE(mutantN)

		}
		// ********************************************************************************************



		// ******************************************************************************************** 
		// Differentiation position 
		unsigned mutantProliferativeCompartment = n_prolif; // Number of proliferative cells, counting up from the bottom
		if(CommandLineArguments::Instance()->OptionExists("-Mnp"))
		{   
			mutantProliferativeCompartment = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-Mnp");
			PRINT_VARIABLE(mutantProliferativeCompartment)

		}
		// ******************************************************************************************** 


		// ********************************************************************************************
		// Anoikis resistance
		double resistantPoppedUpLifeExpectancy = DBL_MAX;
		if(CommandLineArguments::Instance()->OptionExists("-rple"))
		{
			resistantPoppedUpLifeExpectancy = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-rple");
			PRINT_VARIABLE(resistantPoppedUpLifeExpectancy)
		}

		// Poppped up cells continue cycle (on/off)
		bool setPopUpDivision = false;
		if(CommandLineArguments::Instance()->OptionExists("-rdiv"))
		{	
			setPopUpDivision = true;
		}
		PRINT_VARIABLE(setPopUpDivision)


		double resistantCellCycleTime = cellCycleTime;
		if(setPopUpDivision && CommandLineArguments::Instance()->OptionExists("-rcct"))
		{
			resistantCellCycleTime = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-rcct");
			PRINT_VARIABLE(resistantCellCycleTime)
		}
		if(!setPopUpDivision && CommandLineArguments::Instance()->OptionExists("-rcct"))
		{
			TRACE("Popped up cell cycle time not set")
		}
		// ********************************************************************************************


		// ********************************************************************************************
		// Adhesion weakening
		double msModifier = 1.0; // Default is no weakening
		if(CommandLineArguments::Instance()->OptionExists("-msM"))
		{
			msModifier = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-msM");
			PRINT_VARIABLE(msModifier)
		}
		// ********************************************************************************************


		// ********************************************************************************************
		// Cell-cell interaction modifier
		double eesModifier = 1.0; // Default is no weakening
		if(CommandLineArguments::Instance()->OptionExists("-eesM"))
		{
			eesModifier = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-eesM");
			PRINT_VARIABLE(eesModifier)
		}

		// ********************************************************************************************


		// ********************************************************************************************
		// Cell cycle modifier
		double cctModifier = 1.0;
		if(CommandLineArguments::Instance()->OptionExists("-cctM"))
		{
			cctModifier = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-cctM");
			PRINT_VARIABLE(cctModifier)
		}

		double wtModifier = 1.0;
		if(CommandLineArguments::Instance()->OptionExists("-wtM"))
		{
			wtModifier = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-wtM");
			PRINT_VARIABLE(wtModifier)
		}

		// ********************************************************************************************

		// ********************************************************************************************
		// Mutant Contact inhibition fraction
		double mutantQuiescentVolumeFraction = quiescentVolumeFraction;
		if(CommandLineArguments::Instance()->OptionExists("-Mvf"))
		{   
			mutantQuiescentVolumeFraction = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-Mvf");
			PRINT_VARIABLE(mutantQuiescentVolumeFraction)

		}
		// ********************************************************************************************     


		// ********************************************************************************************
		// Damping constant for popped up cells
		// ********************************************************************************************


		// ******************************************************************************************** 
		// The damping constant
		// This has been qualitatively chosen to be 0.2, so that popped up cell experience 20% of the 
		// damping (drag) force of cells on the basement membrane. While this is fixed as default,
		// it is still not clear (21/06/2019) what an appropriate value is, so the ability to modify it
		// is being retained.
		double dampingConstant = 0.2;
		if(CommandLineArguments::Instance()->OptionExists("-D"))
		{
			dampingConstant = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-D");
			PRINT_VARIABLE(dampingConstant)
		}
		// ********************************************************************************************


		// ********************************************************************************************
		// Output control
		// ********************************************************************************************



		// ********************************************************************************************
		bool file_output = false;
		double sampling_multiple = 100000;
		if(CommandLineArguments::Instance()->OptionExists("-sm"))
		{   
			sampling_multiple = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-sm");
			file_output = true;
			TRACE("File output occuring")

		}

		// Output popup location data
		bool outputPopUpLocation = false;
		if(CommandLineArguments::Instance()->OptionExists("-Pul"))
		{   
			outputPopUpLocation = true;
			TRACE("Pop up location data output")
		}
		// ********************************************************************************************




		// ********************************************************************************************
		// Fixed parameters  
		// ********************************************************************************************



		// ********************************************************************************************
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

		unsigned cell_limit = 10 * n; // The most cells allowed in a simulation. If the cell count exceeds this, the simulation terminates
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
			p_cycle_model->SetPopUpDivision(setPopUpDivision);

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);
			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
			
		}
		// ********************************************************************************************

		// ********************************************************************************************
		// Make the cell population
		MonolayerNodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);
		cell_population.SetDampingConstantPoppedUp(dampingConstant);
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
		OffLatticeSimulation<2> simulator(cell_population);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);
		// ********************************************************************************************

		// ********************************************************************************************
		// Building the directory name
		std::stringstream mutdir;

		mutdir << "Mnp_" << mutantProliferativeCompartment;
		mutdir << "_eesM_" << eesModifier;
		mutdir << "_msM_" << msModifier;
		mutdir << "_cctM_" << cctModifier;
		mutdir << "_wtM_" << wtModifier;
		mutdir << "_Mvf_" << mutantQuiescentVolumeFraction;
		if (resistantPoppedUpLifeExpectancy != DBL_MAX)
		{
			mutdir << "_rple_" << resistantPoppedUpLifeExpectancy;
		}


		if (setPopUpDivision)
		{
			mutdir << "_rdiv_" << setPopUpDivision;

			mutdir << "_rcct_" << resistantCellCycleTime;	
		}

		std::stringstream rundir;
		rundir << "run_" << run_number;
		
		std::string output_directory = "TestCryptColumnFullMutation/" +  cryptType.str() + "/" + mutdir.str() + "/" + rundir.str();

		simulator.SetOutputDirectory(output_directory);
		OutputFileHandler output_file_handler(output_directory+"/", true);
		std::string directory = output_file_handler.GetOutputDirectoryFullPath();
		PRINT_VARIABLE(directory)
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

		p_force->SetModifierFraction(eesModifier);

		MAKE_PTR(NormalAdhesionForceNewPhaseModel<2>, p_adhesion);
		p_adhesion->SetMembraneSpringStiffness(membraneStiffness);
		p_adhesion->SetWeakeningFraction(msModifier);

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
		// Reset the cell killers
		simulator.RemoveAllCellKillers();
		MAKE_PTR_ARGS(SloughingCellKillerNewPhaseModel, p_sloughing_killer_2, (&cell_population));
		p_sloughing_killer_2->SetCryptTop(mutantN);
		simulator.AddCellKiller(p_sloughing_killer_2);

		MAKE_PTR_ARGS(AnoikisCellKillerNewPhaseModel, p_anoikis_killer_2, (&cell_population));
		p_anoikis_killer_2->SetPopUpDistance(popUpDistance);
		p_anoikis_killer_2->SetResistantPoppedUpLifeExpectancy(resistantPoppedUpLifeExpectancy);
		simulator.AddCellKiller(p_anoikis_killer_2);

		MAKE_PTR_ARGS(IsolatedCellKiller, p_isolated_killer, (&cell_population));
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
		// Add in the mutations
		// ********************************************************************************************



		// ********************************************************************************************
		// Set all of the cells to mutant cells
		MeshBasedCellPopulation<2,2>* p_tissue = static_cast<MeshBasedCellPopulation<2,2>*>(&simulator.rGetCellPopulation());
		std::list<CellPtr> pos_cells =  p_tissue->rGetCells();

		MAKE_PTR(TransitCellAnoikisResistantMutationState, p_resistant);
		MAKE_PTR(WeakenedMembraneAdhesion, p_Mweakened);
		MAKE_PTR(WeakenedCellCellAdhesion, p_Eweakened);

		for (std::list<CellPtr>::iterator it = pos_cells.begin(); it != pos_cells.end(); ++it)
		{
			unsigned index = p_tissue->GetLocationIndexUsingCell((*it));
			// Make sure we don't do anything to the fixed node at the bottom
			if (index != 0)
			{
				(*it)->SetMutationState(p_resistant);
				(*it)->AddCellProperty(p_Mweakened);
				(*it)->AddCellProperty(p_Eweakened);

				SimplifiedPhaseBasedCellCycleModel* p_ccm = static_cast<SimplifiedPhaseBasedCellCycleModel*>((*it)->GetCellCycleModel());
				
				p_ccm->SetWDuration( wtModifier * wPhaseLength);
				p_ccm->SetBasePDuration(cctModifier * cellCycleTime - wtModifier * wPhaseLength);
				p_ccm->SetQuiescentVolumeFraction(mutantQuiescentVolumeFraction);
				p_ccm->SetWntThreshold(1 - (double)mutantProliferativeCompartment/n);
			}
		}
		// ********************************************************************************************
		

		// ********************************************************************************************
		// Add cell population writers if they are requested	
		if (outputPopUpLocation)
		{
			p_tissue->AddPopulationWriter<PopUpLocationWriter>();
		}
		// ********************************************************************************************


		// ********************************************************************************************
		// Run the simulation to be observed
		TRACE("Starting simulation proper")
		TRACE("START")
		simulator.Solve();
		
		// Here be statistics
		TRACE("END")
		// ********************************************************************************************


		// ********************************************************************************************
		// Post simulation tasks
		WntConcentration<2>::Instance()->Destroy();
		// ********************************************************************************************

	};

};



