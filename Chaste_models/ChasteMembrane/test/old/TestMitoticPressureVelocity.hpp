// Standard includes for tests
#include <cxxtest/TestSuite.h>
#include "AbstractCellBasedTestSuite.hpp"
#include "CheckpointArchiveTypes.hpp"
#include "SmartPointers.hpp"
#include "CommandLineArguments.hpp"

// Simulators and output
#include "OffLatticeSimulation.hpp" //Simulates the evolution of the population
#include "OffLatticeSimulationTearOffStoppingEvent.hpp"

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
#include "GrowingContactInhibitionPhaseBasedCCM.hpp"

#include "WildTypeCellMutationState.hpp"

// Boundary conditions
#include "BoundaryCellProperty.hpp"
#include "CryptBoundaryCondition.hpp"

#include "SimpleSloughingCellKiller.hpp"
#include "AnoikisCellKiller.hpp"

//Division Rules
#include "StickToMembraneDivisionRule.hpp"

// Modifiers
#include "VolumeTrackingModifier.hpp"

#include "PushForceModifier.hpp"
#include "BasicNonLinearSpringForce.hpp"

// Writers
#include "EpithelialCellForceWriter.hpp"

// Forces
#include "NormalAdhesionForce.hpp"
#include "LinearSpringForcePhaseBased.hpp"
#include "LinearSpringForceMembraneCellNodeBased.hpp"
#include "PushForce.hpp"
#include "NonLinearSpringForceScaled.hpp"

// Misc
#include "FakePetscSetup.hpp"
#include "Debug.hpp"

class TestMitoticPressureVelocity : public AbstractCellBasedTestSuite
{
	public:
	void xTestMitoticPressureDivision() throw(Exception)
	{
		// This test is to observe the velocity produced purely by cell growth
		// To do this, we use NormalAdhesionForce (i.e. no membrane cells)
		// and force the cells to grow following the same pattern expected in vivo
		// the cells do not divide, but stop growing, then start again following the cycle

        
        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-ems"));
        double epithelialMembraneStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ems"); // The only spring stiffness to worry about

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-ees"));
        double epithelialStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ees");

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-mir"));
        double membraneInteractionRadius = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-mir"); // The furthest that a membrane node can detect the epithelial cell

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-eir"));
        double epithelialInteractionRadius = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-eir");

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-mpr"));
        double membranePreferredRadius = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-mpr");

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-epr"));
        double epithelialPreferredRadius = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-epr");


        double end_time = 5;
        if(CommandLineArguments::Instance()->OptionExists("-t"))
        {	
        	end_time = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-t");

        }
	
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> location_indices;

		unsigned node_counter = 0;

		double dt = 0.0001;
		
		double sampling_multiple = 1;

		double maxInteractionRadius = 4.0;


		double x_distance = 1;

		double x = x_distance;
		double y;
		unsigned n = 20;
		
		for(unsigned i=0; i<=n; i++)
		{
			x = x_distance;
			y = 2 * i * epithelialPreferredRadius;
			Node<2>* single_node_2 =  new Node<2>(node_counter,  false,  x, y);
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

		NoCellCycleModel* p_cycle_model = new NoCellCycleModel();

		CellPtr p_cell(new Cell(p_state, p_cycle_model));
		p_cell->SetCellProliferativeType(p_diff_type);
		p_cell->AddCellProperty(p_boundary);

		cells.push_back(p_cell);
		// Add any additional static cells

		for(unsigned i=1; i<=n; i++)
		{
			UniformCellCycleModel* p_c_uniform = new UniformCellCycleModel();
			double birth_time = 12 * RandomNumberGenerator::Instance()->ranf(); //Randomly set birth time to stop pulsing behaviour
			p_c_uniform->SetBirthTime(-birth_time);

			CellPtr p_cell_2(new Cell(p_state, p_c_uniform));
			p_cell_2->SetCellProliferativeType(p_trans_type);
			// SET CELLS WITH A RANDOM STARTING AGE
			// SET CELLS WITH THE GROWING CELL CYCLE MODEL
			cells.push_back(p_cell_2);

		}


		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);

		OffLatticeSimulation<2> simulator(cell_population);

		std::stringstream out;
        out << "EMS_"<< epithelialMembraneStiffness << "_MIR_" << membraneInteractionRadius <<"_MPR_" << membranePreferredRadius;
        out << "_EES_"<< epithelialStiffness << "_EIR_" << epithelialInteractionRadius <<"_EPR_" << epithelialPreferredRadius;
        std::string output_directory = "TestMitoticPressureVelocity/" +  out.str();

		simulator.SetOutputDirectory(output_directory);

		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(NormalAdhesionForce<2>, p_force);
		// For this force calculator, epithelial means anything not membrane
		p_force->SetMembraneEpithelialSpringStiffness(epithelialMembraneStiffness);

		p_force->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		p_force->SetMembranePreferredRadius(membranePreferredRadius);

		simulator.AddForce(p_force);

		MAKE_PTR(LinearSpringForceMembraneCellNodeBased<2>, p_force_2);
		p_force_2->SetEpithelialSpringStiffness(epithelialStiffness);
		p_force_2->SetStromalSpringStiffness(epithelialStiffness);

		p_force_2->SetStromalEpithelialSpringStiffness(epithelialStiffness);

		p_force_2->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		p_force_2->SetStromalPreferredRadius(epithelialPreferredRadius);
		p_force_2->SetMembranePreferredRadius(membranePreferredRadius);

		p_force_2->SetEpithelialInteractionRadius(epithelialInteractionRadius);
		p_force_2->SetStromalInteractionRadius(epithelialInteractionRadius);
		
		p_force_2->SetMeinekeSpringGrowthDuration(1);
		p_force_2->SetMeinekeDivisionRestingSpringLength(0.1);

		simulator.AddForce(p_force_2);

		{ //Division vector rules
			c_vector<double, 2> membraneAxis;
			membraneAxis(0) = 0;
			membraneAxis(1) = 1;

			MAKE_PTR(StickToMembraneDivisionRule<2>, pCentreBasedDivisionRule);
			pCentreBasedDivisionRule->SetMembraneAxis(membraneAxis);
			cell_population.SetCentreBasedDivisionRule(pCentreBasedDivisionRule);
		}

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		cell_population.AddCellWriter<EpithelialCellForceWriter>();

		simulator.Solve();

	};

	void TestMitoticPressureScaledStiffness() throw(Exception)
	{
		// This test is to observe the velocity produced purely by cell growth
		// To do this, we use NormalAdhesionForce (i.e. no membrane cells)
		// and force the cells to grow following the same pattern expected in vivo
		// the cells do not divide, but stop growing, then start again following the cycle

        
        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-ems"));
        double epithelialMembraneStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ems"); // The only spring stiffness to worry about

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-ees"));
        double epithelialStiffness = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ees");

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-mir"));
        double membraneInteractionRadius = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-mir"); // The furthest that a membrane node can detect the epithelial cell

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-eir"));
        double epithelialInteractionRadius = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-eir");

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-mpr"));
        double membranePreferredRadius = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-mpr");

        TS_ASSERT(CommandLineArguments::Instance()->OptionExists("-epr"));
        double epithelialPreferredRadius = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-epr");


        double end_time = 5;
        if(CommandLineArguments::Instance()->OptionExists("-t"))
        {	
        	end_time = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-t");

        }

		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> location_indices;

		unsigned node_counter = 0;

		double dt = 0.001;
		
		double sampling_multiple = 1;

		double maxInteractionRadius = 4.0;

		double wall_top = 21;

		double x_distance = 1;

		double x = x_distance;
		double y;
		unsigned n = 20;
		
		for(unsigned i=0; i<=n; i++)
		{
			x = x_distance;
			y = 2 * i * epithelialPreferredRadius;
			Node<2>* single_node_2 =  new Node<2>(node_counter,  false,  x, y);
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

		NoCellCycleModel* p_cycle_model = new NoCellCycleModel();

		CellPtr p_cell(new Cell(p_state, p_cycle_model));
		p_cell->SetCellProliferativeType(p_diff_type);
		p_cell->AddCellProperty(p_boundary);

		cells.push_back(p_cell);
		// Add any additional static cells

		for(unsigned i=1; i<=n; i++)
		{
			UniformCellCycleModel* p_c_uniform = new UniformCellCycleModel();
			double birth_time = 12 * RandomNumberGenerator::Instance()->ranf(); //Randomly set birth time to stop pulsing behaviour
			p_c_uniform->SetBirthTime(-birth_time);

			CellPtr p_cell_2(new Cell(p_state, p_c_uniform));
			p_cell_2->SetCellProliferativeType(p_trans_type);

			cells.push_back(p_cell_2);

		}


		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);

		OffLatticeSimulation<2> simulator(cell_population);

		std::stringstream out;
        out << "EMS_"<< epithelialMembraneStiffness << "_MIR_" << membraneInteractionRadius <<"_MPR_" << membranePreferredRadius;
        out << "_EES_"<< epithelialStiffness << "_EIR_" << epithelialInteractionRadius <<"_EPR_" << epithelialPreferredRadius;
        std::string output_directory = "TestMitoticPressureVelocity/" +  out.str();

		simulator.SetOutputDirectory(output_directory);

		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(NormalAdhesionForce<2>, p_force);
		// For this force calculator, epithelial means anything not membrane
		p_force->SetMembraneEpithelialSpringStiffness(epithelialMembraneStiffness);

		p_force->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		p_force->SetMembranePreferredRadius(membranePreferredRadius);

		simulator.AddForce(p_force);

		MAKE_PTR(NonLinearSpringForceScaled<2>, p_force_2);
		p_force_2->SetEpithelialSpringStiffness(epithelialStiffness);
		p_force_2->SetStromalSpringStiffness(epithelialStiffness);

		p_force_2->SetStromalEpithelialSpringStiffness(epithelialStiffness);

		p_force_2->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		p_force_2->SetStromalPreferredRadius(epithelialPreferredRadius);
		p_force_2->SetMembranePreferredRadius(membranePreferredRadius);

		p_force_2->SetEpithelialInteractionRadius(epithelialInteractionRadius);
		p_force_2->SetStromalInteractionRadius(epithelialInteractionRadius);
		
		p_force_2->SetMeinekeSpringGrowthDuration(1);
		p_force_2->SetMeinekeDivisionRestingSpringLength(0.1);

		p_force_2->SetCryptTop(wall_top);

		simulator.AddForce(p_force_2);

		{ //Division vector rules
			c_vector<double, 2> membraneAxis;
			membraneAxis(0) = 0;
			membraneAxis(1) = 1;

			MAKE_PTR(StickToMembraneDivisionRule<2>, pCentreBasedDivisionRule);
			pCentreBasedDivisionRule->SetMembraneAxis(membraneAxis);
			cell_population.SetCentreBasedDivisionRule(pCentreBasedDivisionRule);
		}

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		MAKE_PTR_ARGS(SimpleSloughingCellKiller, p_sloughing_killer, (&cell_population));
		p_sloughing_killer->SetCryptTop(wall_top);
		simulator.AddCellKiller(p_sloughing_killer);

		cell_population.AddCellWriter<EpithelialCellForceWriter>();

		simulator.Solve();

	};
	
};
