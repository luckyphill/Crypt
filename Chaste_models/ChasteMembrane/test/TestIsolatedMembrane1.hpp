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
#include "VoronoiDataWriter.hpp" //Allows us to visualise output in Paraview
#include "GeneralisedLinearSpringForce.hpp" //give a force to use between cells
#include "MembraneCellProliferativeType.hpp"
#include "WildTypeCellMutationState.hpp"

//#include "EpithelialLayerBasementMembraneForce.hpp"
//#include "EpithelialLayerBasementMembraneForceModified.hpp"
//#include "EpithelialLayerLinearSpringForce.hpp"

//#include "CryptBoundaryCondition.hpp"

#include "MembraneCellForce.hpp" // A force to restore the membrane to it's preferred shape

#include "NoCellCycleModel.hpp"

#include "BoundaryCellProperty.hpp"

#include "TransitCellProliferativeType.hpp"
#include "UniformCellCycleModel.hpp"
#include "NodesOnlyMesh.hpp"
#include "NodeBasedCellPopulation.hpp"
#include "CellsGenerator.hpp"
#include "TrianglesMeshWriter.hpp"


#include "DifferentiatedCellProliferativeType.hpp"

//#include "LinearSpringForceMembraneCell.hpp"
//#include "LinearSpringSmallMembraneCell.hpp"
//#include "ForceTest.hpp"
#include "Debug.hpp"

#include "FakePetscSetup.hpp"





class TestIsolatedMembrane : public AbstractCellBasedTestSuite
{
	public:
	void xTestIsolatedFlatMembrane() throw(Exception)
	{
		unsigned cells_up = 10;
		unsigned cells_across = 30;
		unsigned space_to_end = 12;

		double dt = 0.02;
		double end_time = 1000;
		double sampling_multiple = 100;

		//Set all the spring stiffness variables
		double epithelialStiffness = 15.0; //Epithelial-epithelial spring connections
		double membraneStiffness = 3.0; //Stiffness of membrane to membrane spring connections
		double stromalStiffness = 15.0;

		double epithelialMembraneStiffness = 15.0; //Epithelial-non-epithelial spring connections
		double membraneStromalStiffness = 5.0; //Non-epithelial-non-epithelial spring connections
		double stromalEpithelialStiffness = 10.0;

		double torsional_stiffness = 0.10;
		double stiffness_ratio = 4.5; // For paneth cells

		double targetCurvatureStemStem = 1/10.0;
		double targetCurvatureStemTrans = 0; // Not implemented properly, so keep it the same as TransTrans for now
		double targetCurvatureTransTrans = 0;


		HoneycombMeshGenerator generator(cells_across, cells_up);
		MutableMesh<2,2>* p_mesh = generator.GetMesh();

		std::vector<unsigned> initial_real_indices = generator.GetCellLocationIndices();
		std::vector<unsigned> real_indices;

		for (unsigned i = 0; i < initial_real_indices.size(); i++)
		{
			unsigned cell_index = initial_real_indices[i];
			double x = p_mesh->GetNode(cell_index)->rGetLocation()[0];
			double y = p_mesh->GetNode(cell_index)->rGetLocation()[1];

			if ( y > int(cells_up/2) && y < int(cells_up/2 + 1) && x <cells_across - space_to_end && x >space_to_end)
			{
				real_indices.push_back(cell_index);
			}
		}

		boost::shared_ptr<AbstractCellProperty> p_membrane = CellPropertyRegistry::Instance()->Get<MembraneCellProliferativeType>();
		boost::shared_ptr<AbstractCellProperty> p_state = CellPropertyRegistry::Instance()->Get<WildTypeCellMutationState>();
		MAKE_PTR(BoundaryCellProperty, p_boundary);

		std::vector<CellPtr> cells;

		for (unsigned i = 0; i<real_indices.size(); i++)
		{
			NoCellCycleModel* p_cycle_model = new NoCellCycleModel();
			CellPtr p_cell(new Cell(p_state, p_cycle_model));

			p_cell->SetCellProliferativeType(p_membrane);

			p_cell->InitialiseCellCycleModel();

			if (i==0 || i ==1)
			{
				// Fix the first two cells in space
				p_cell->AddCellProperty(p_boundary);
			}

			cells.push_back(p_cell); 
		}

		MeshBasedCellPopulationWithGhostNodes<2> cell_population(*p_mesh, cells, real_indices);

		cell_population.AddPopulationWriter<VoronoiDataWriter>();

		OffLatticeSimulation<2> simulator(cell_population);

		simulator.SetOutputDirectory("TestIsolatedFlatMembrane");
		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		// MAKE_PTR(LinearSpringForceMembraneCell<2>, p_spring_force);
		// p_spring_force->SetCutOffLength(1.5);
		// //Set the spring stiffnesses
		// p_spring_force->SetEpithelialSpringStiffness(epithelialStiffness);
		// p_spring_force->SetMembraneSpringStiffness(membraneStiffness);
		// p_spring_force->SetStromalSpringStiffness(stromalStiffness);
		// p_spring_force->SetEpithelialMembraneSpringStiffness(epithelialMembraneStiffness);
		// p_spring_force->SetMembraneStromalSpringStiffness(membraneStromalStiffness);
		// p_spring_force->SetStromalEpithelialSpringStiffness(stromalEpithelialStiffness);

		// p_spring_force->SetPanethCellStiffnessRatio(stiffness_ratio);
		// simulator.AddForce(p_spring_force);

		MAKE_PTR(MembraneCellForce, p_membrane_force);
		p_membrane_force->SetBasementMembraneTorsionalStiffness(torsional_stiffness);
		p_membrane_force->SetTargetCurvatures(targetCurvatureStemStem, targetCurvatureStemTrans, targetCurvatureTransTrans);
		simulator.AddForce(p_membrane_force);

		// MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		// simulator.AddCellPopulationBoundaryCondition(p_bc);

		simulator.Solve();

	}

	void xTestManuallyGenerateMesh() throw(Exception)
	{
		std::vector<Node<2>*> nodes;

		unsigned cells_up = 10;
		unsigned cells_across = 10;
		unsigned node_counter = 0;

		for (unsigned i = 0; i< cells_across; i++)
		{
			for (unsigned j = 0; j< cells_up; j++)
			{
				double x = 0;
				double y = 0;
				if (j == 2* unsigned(j/2))
				{
					x= i;
				} else 
				{
					// stagger for hex mesh
					x = i +0.5;
				}
				y = j * (sqrt(3.0)/2);
				nodes.push_back(new Node<2>(node_counter,  false,  x, y));
				node_counter++;
			}
		}

		MutableMesh<2,2> mesh(nodes);

		TrianglesMeshWriter<2,2> mesh_writer("WriteTest", "mesh", false);
		mesh_writer.WriteFilesUsingMesh(mesh);

		// NodesOnlyMesh<2> mesh;
		// mesh.ConstructNodesWithoutMesh(nodes, 1.5);

		std::vector<CellPtr> cells;
		MAKE_PTR(TransitCellProliferativeType, p_transit_type);
		CellsGenerator<UniformCellCycleModel, 2> cells_generator;
		cells_generator.GenerateBasicRandom(cells, mesh.GetNumNodes(), p_transit_type);

		MeshBasedCellPopulation<2> cell_population(mesh, cells);
		cell_population.AddPopulationWriter<VoronoiDataWriter>();

		OffLatticeSimulation<2> simulator(cell_population);
		simulator.SetOutputDirectory("ManuallyPlaceNodes");
		simulator.SetSamplingTimestepMultiple(12);
		simulator.SetEndTime(10.0);

		MAKE_PTR(GeneralisedLinearSpringForce<2>, p_force);
		simulator.AddForce(p_force);

		simulator.Solve();

		//TS_ASSERT_DELTA(SimulationTime::Instance()->GetTime(), 10.0, 1e-10);

	}

	void TestInsertCloseMembrane() throw(Exception)
	{
		// In this we introduce a row of membrane point cells with a small rest length
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> stromal_nodes;
		std::vector<unsigned> membrane_nodes;
		std::vector<unsigned> location_indices;
		std::vector<unsigned> ghost_nodes;

		double dt = 0.01;
		double end_time = 10;
		double sampling_multiple = 10;

		unsigned cells_up = 10;
		unsigned cells_across = 10;
		unsigned ghosts = 3;
		unsigned node_counter = 0;
		unsigned num_membrane_nodes = 60;			// 60

		// Values that produce a working simulation in the comments
		double epithelialStiffness = 1.50; 			// 1.5
		double membraneStiffness = 5.0; 			// 5.0
		double stromalStiffness = 2.0; 				// 2.0

		double epithelialMembraneStiffness = 1.0; 	// 1.0
		double membraneStromalStiffness = 5.0; 		// 5.0
		double stromalEpithelialStiffness = 1.0;	// 1.0

		double epithelialRestLength = 1.0;			// 1.0
		double membraneRestLength = 0.2;			// 0.2
		double stromalRestLength = 1.0;				// 1.0

		double epithelialMembraneRestLength = 1.0;	// 1.0
		double membraneStromalRestLength = 0.4;		// 0.4
		double stromalEpithelialRestLength = 1.0;	// 1.0

		double mEpithelialCutOffLength; // Epithelial covers stem and transit
		double mMembraneCutOffLength;
		double mStromalCutOffLength; // Stromal is the differentiated "filler" cells

		double mEpithelialMembraneCutOffLength;
		double membraneStromalCutOffLength = 0.6;	// 0.6 If this is too small the stromal cells never attach to the membrane cells
		double mStromalEpithelialCutOffLength;

		double torsional_stiffness = 0.020;			// 10.0

		double targetCurvatureStemStem = 0.3;		// not used in this test, see MembraneCellForce.cpp lines 186 - 190
		double targetCurvatureStemTrans = 0;
		double targetCurvatureTransTrans = 0;

		for (unsigned i = 0; i < cells_across; i++)
		{
			for (unsigned j = 0; j < cells_up; j++)
			{
				double x = 0;
				double y = 0;
				if (j == 2* unsigned(j/2))
				{
					x = i;
				} else 
				{
					// stagger for hex mesh
					x = i +0.5;
				}
				y = j * (sqrt(3.0)/2);
				nodes.push_back(new Node<2>(node_counter,  false,  x, y));
				stromal_nodes.push_back(node_counter);
				location_indices.push_back(node_counter);
				node_counter++;
			}
		}

		double membrane_spacing = double(cells_across -0.5)/num_membrane_nodes;

		for (double x = 0.0; x < cells_across -0.5; x += membrane_spacing)
		{
			double y = 5*(sqrt(3.0)/4);
			nodes.push_back(new Node<2>(node_counter,  false,  x, y));
			membrane_nodes.push_back(node_counter);
			location_indices.push_back(node_counter);
			node_counter++;
		}

		// make a ghost node halo
		for (int i = -ghosts; i < int(cells_across + ghosts); i++)
		{
			for (int j = -ghosts; j < int(cells_up + ghosts); j++)
			{
				double x = 0;
				double y = j * (sqrt(3.0)/2);
				if (j == 2* int(j/2))
				{
					x = i;
					if (x < 0 || x >=cells_across || y < 0 || j >= int(cells_up))
					{
						nodes.push_back(new Node<2>(node_counter,  false,  x, y));
						ghost_nodes.push_back(node_counter);
						node_counter++;
					}
				} else 
				{
					// stagger for hex mesh
					x = i +0.5;
					if (x < 0.5 || x >=cells_across + 0.5 || y < 0 || j >= int(cells_up))
					{
						nodes.push_back(new Node<2>(node_counter,  false,  x, y));
						ghost_nodes.push_back(node_counter);
						node_counter++;
					}

				}
			}
		}

		// Add in ghost node halo

		MutableMesh<2,2> mesh(nodes);

		TrianglesMeshWriter<2,2> mesh_writer("WriteTest", "mesh", false);
		mesh_writer.WriteFilesUsingMesh(mesh);

		std::vector<CellPtr> cells;
		MAKE_PTR(MembraneCellProliferativeType, p_membrane_type);
		MAKE_PTR(DifferentiatedCellProliferativeType, p_diff_type);
		MAKE_PTR(WildTypeCellMutationState, p_state);

		// Note: At no point does the for loop reference the node index stored in stromal_nodes
		// By chance the order of the nodes matches in the mesh is the same as those in the node vector
		// It works, but I'm not sure if this will work 100% of the time
		for (unsigned i = 0; i < stromal_nodes.size(); i++)
		{
			NoCellCycleModel* p_cycle_model = new NoCellCycleModel();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_diff_type);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}

		for (unsigned i = 0; i < membrane_nodes.size(); i++)
		{
			NoCellCycleModel* p_cycle_model = new NoCellCycleModel();

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_membrane_type);

			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);
		}


		MeshBasedCellPopulationWithGhostNodes<2> cell_population(mesh, cells, location_indices);
		cell_population.AddPopulationWriter<VoronoiDataWriter>();

		OffLatticeSimulation<2> simulator(cell_population);
		simulator.SetOutputDirectory("SmallMembraneCells");
		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(GeneralisedLinearSpringForce<2>, p_force);
		// p_force->SetEpithelialSpringStiffness(epithelialStiffness);
		// p_force->SetMembraneSpringStiffness(membraneStiffness);
		// p_force->SetStromalSpringStiffness(stromalStiffness);
		// p_force->SetEpithelialMembraneSpringStiffness(epithelialMembraneStiffness);
		// p_force->SetMembraneStromalSpringStiffness(membraneStromalStiffness);
		// p_force->SetStromalEpithelialSpringStiffness(stromalEpithelialStiffness);

		// p_force->SetEpithelialRestLength(epithelialRestLength);
		// p_force->SetMembraneRestLength(membraneRestLength);
		// p_force->SetStromalRestLength(stromalRestLength);
		// p_force->SetEpithelialMembraneRestLength(epithelialMembraneRestLength);
		// p_force->SetMembraneStromalRestLength(membraneStromalRestLength);
		// p_force->SetStromalEpithelialRestLength(stromalEpithelialRestLength);

		// p_force->SetMembraneStromalCutOffLength(membraneStromalCutOffLength);
		simulator.AddForce(p_force);

		MAKE_PTR(MembraneCellForce, p_membrane_force);
		p_membrane_force->SetBasementMembraneTorsionalStiffness(torsional_stiffness);
		p_membrane_force->SetTargetCurvatures(targetCurvatureStemStem, targetCurvatureStemTrans, targetCurvatureTransTrans);
		//simulator.AddForce(p_membrane_force);
		TRACE("Setup works")
		simulator.Solve();
	}

};