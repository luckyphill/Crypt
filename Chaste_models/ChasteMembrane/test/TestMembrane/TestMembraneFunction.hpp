// Standard includes for tests
#include <cxxtest/TestSuite.h>
#include "AbstractCellBasedTestSuite.hpp"
#include "CheckpointArchiveTypes.hpp"
#include "SmartPointers.hpp"

// Mesh stuff
#include "MeshBasedCellPopulationWithGhostNodes.hpp"
#include "HoneycombMeshGenerator.hpp" //Generates mesh
#include "CylindricalHoneycombMeshGenerator.hpp"

// Simulators and output
#include "OffLatticeSimulation.hpp" //Simulates the evolution of the population
#include "VoronoiDataWriter.hpp" //Allows us to visualise output in Paraview

// Forces and BCs
#include "GeneralisedLinearSpringForce.hpp"
#include "MembraneCellForce.hpp"
#include "MembraneCellForceNodeBased.hpp"
#include "CryptBoundaryCondition.hpp"
#include "LinearSpringForceMembraneCell.hpp"
#include "LinearSpringForceMembraneCellNodeBased.hpp"

// Cell details
#include "MembraneCellProliferativeType.hpp"
#include "DifferentiatedCellProliferativeType.hpp"
#include "BoundaryCellProperty.hpp"

#include "WildTypeCellMutationState.hpp"

#include "NoCellCycleModel.hpp"

// Misc
#include "FakePetscSetup.hpp"
#include "Debug.hpp"


class TestMembraneFunction : public AbstractCellBasedTestSuite
{
	public:
	void xTestMembraneCurvatureForce() throw(Exception)
	{
		// Tests the membrane curvature force on a string of membrane cells
		// Should curl up like a snail
		unsigned cells_up = 10;
		unsigned cells_across = 30;
		unsigned space_to_end = 12;

		double dt = 0.02;
		double end_time = 10;
		double sampling_multiple = 100;

		//Set all the spring stiffness variables
		double epithelialStiffness = 15.0; //Epithelial-epithelial spring connections
		double membraneStiffness = 3.0; //Stiffness of membrane to membrane spring connections
		double stromalStiffness = 15.0;

		double epithelialMembraneStiffness = 15.0; //Epithelial-non-epithelial spring connections
		double membraneStromalStiffness = 5.0; //Non-epithelial-non-epithelial spring connections
		double stromalEpithelialStiffness = 10.0;

		double torsional_stiffness = 0.10;

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

		simulator.SetOutputDirectory("TestMembraneCurvatureForce");
		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(LinearSpringForceMembraneCell<2>, p_spring_force);
		p_spring_force->SetCutOffLength(1.5);
		//Set the spring stiffnesses
		p_spring_force->SetEpithelialSpringStiffness(epithelialStiffness);
		p_spring_force->SetMembraneSpringStiffness(membraneStiffness);
		p_spring_force->SetStromalSpringStiffness(stromalStiffness);
		p_spring_force->SetEpithelialMembraneSpringStiffness(epithelialMembraneStiffness);
		p_spring_force->SetMembraneStromalSpringStiffness(membraneStromalStiffness);
		p_spring_force->SetStromalEpithelialSpringStiffness(stromalEpithelialStiffness);

		simulator.AddForce(p_spring_force);

		MAKE_PTR(MembraneCellForce, p_membrane_force);
		p_membrane_force->SetBasementMembraneTorsionalStiffness(torsional_stiffness);
		p_membrane_force->SetTargetCurvatures(targetCurvatureStemStem, targetCurvatureStemTrans, targetCurvatureTransTrans);
		p_membrane_force->SetCalculationToTorsion(true);
		simulator.AddForce(p_membrane_force);

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		simulator.Solve();

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
		double end_time = 100;
		double sampling_multiple = 50;

		unsigned cells_up = 6;
		unsigned cells_across = 6;
		unsigned ghosts = 3;
		unsigned node_counter = 0;
		unsigned num_membrane_nodes = 15;			// 60

		// Values that produce a working simulation in the comments
		double epithelialStiffness = 1.50; 			// 1.5
		double membraneStiffness = 5.0; 			// 5.0
		double stromalStiffness = 2.0; 				// 2.0

		double epithelialMembraneStiffness = 1.0; 	// 1.0
		double membraneStromalStiffness = 3.0; 		// 5.0
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

		double torsional_stiffness = 8.0;			// 10.0

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
		MAKE_PTR(BoundaryCellProperty, p_boundary);

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

		for (unsigned i = 0; i < stromal_nodes.size(); i++)
		{

			Node<2>* p_node = cell_population.GetNode(i);

			double y = p_node->rGetLocation()[1];

			CellPtr p_cell = cell_population.GetCellUsingLocationIndex(i);
			if (y > 7)
			{
				p_cell->AddCellProperty(p_boundary);
			}
		}

		OffLatticeSimulation<2> simulator(cell_population);
		simulator.SetOutputDirectory("SmallMembraneCells");
		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(LinearSpringForceMembraneCell<2>, p_force);
		p_force->SetEpithelialSpringStiffness(epithelialStiffness);
		p_force->SetMembraneSpringStiffness(membraneStiffness);
		p_force->SetStromalSpringStiffness(stromalStiffness);
		p_force->SetEpithelialMembraneSpringStiffness(epithelialMembraneStiffness);
		p_force->SetMembraneStromalSpringStiffness(membraneStromalStiffness);
		p_force->SetStromalEpithelialSpringStiffness(stromalEpithelialStiffness);

		p_force->SetEpithelialRestLength(epithelialRestLength);
		p_force->SetMembraneRestLength(membraneRestLength);
		p_force->SetStromalRestLength(stromalRestLength);
		p_force->SetEpithelialMembraneRestLength(epithelialMembraneRestLength);
		p_force->SetMembraneStromalRestLength(membraneStromalRestLength);
		p_force->SetStromalEpithelialRestLength(stromalEpithelialRestLength);

		p_force->SetMembraneStromalCutOffLength(membraneStromalCutOffLength);
		simulator.AddForce(p_force);

		MAKE_PTR(MembraneCellForce, p_membrane_force);
		p_membrane_force->SetBasementMembraneTorsionalStiffness(torsional_stiffness);
		p_membrane_force->SetTargetCurvatures(targetCurvatureStemStem, targetCurvatureStemTrans, targetCurvatureTransTrans);
		simulator.AddForce(p_membrane_force);

		MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		simulator.AddCellPopulationBoundaryCondition(p_bc);

		simulator.Solve();
	}

	void xTestIsolatedFlatMembraneNodeBased() throw(Exception)
	{
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> membraneCellIds;
		std::vector<unsigned> real_indices;
		std::vector<std::vector<CellPtr>> membraneSections;

		double dt = 0.001;
		double end_time = 10;
		double sampling_multiple = 10;

		unsigned cells_up = 10;
		unsigned cells_across = 30;
		unsigned space_to_end = 12;
		unsigned ghosts = 3;
		unsigned node_counter = 0;
		unsigned num_membrane_nodes = 60;			// 60

		// Values that produce a working simulation in the comments
		double epithelialStiffness = 1.50; 			// 1.5
		double membraneStiffness = 5.0; 			// 5.0
		double stromalStiffness = 2.0; 				// 2.0

		double epithelialMembraneStiffness = 1.0; 	// 1.0
		double membraneStromalStiffness = 1.0; 		// 5.0
		double stromalEpithelialStiffness = 1.0;	// 1.0

		double epithelialPreferredRadius = 1.0;			// 1.0
		double membranePreferredRadius = 0.11;			// 0.2
		double stromalPreferredRadius = 0.5;			// 1.0

		double epithelialInteractionRadius = 1.5 * epithelialPreferredRadius; // Epithelial covers stem and transit
		double membraneInteractionRadius = 2.0 * membranePreferredRadius;
		double stromalInteractionRadius = 1.5 * stromalPreferredRadius; // Stromal is the differentiated "filler" cells

		double maxInteractionRadius = 3.0;

		double torsional_stiffness = 1;			// 10.0

		double targetCurvatureStemStem = 0.3;		// not used in this test, see MembraneCellForce.cpp lines 186 - 190
		double targetCurvatureStemTrans = 0;
		double targetCurvatureTransTrans = 0;



		std::vector<CellPtr> cells;
		std::vector<CellPtr> membrane_cells;
		MAKE_PTR(MembraneCellProliferativeType, p_membrane_type);

		for (unsigned i = 0; i < cells_across; i++)
		{
			nodes.push_back(new Node<2>(node_counter,  false,  0.1 * i, 0));
			real_indices.push_back(node_counter);
			node_counter++;
		}

		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, maxInteractionRadius);

		boost::shared_ptr<AbstractCellProperty> p_membrane = CellPropertyRegistry::Instance()->Get<MembraneCellProliferativeType>();
		boost::shared_ptr<AbstractCellProperty> p_state = CellPropertyRegistry::Instance()->Get<WildTypeCellMutationState>();
		MAKE_PTR(BoundaryCellProperty, p_boundary);

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
			membrane_cells.push_back(p_cell);
			membraneCellIds.push_back(p_cell->GetCellId());
		}

		membraneSections.push_back(membrane_cells);

		NodeBasedCellPopulation<2> cell_population(mesh, cells, real_indices);

		OffLatticeSimulation<2> simulator(cell_population);

		simulator.SetOutputDirectory("TestIsolatedFlatMembraneNodeBased");
		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(LinearSpringForceMembraneCellNodeBased<2>, p_force);
		p_force->SetMembraneSpringStiffness(membraneStiffness);
		p_force->SetMembranePreferredRadius(membranePreferredRadius);
		p_force->SetMembraneInteractionRadius(membraneInteractionRadius);

		simulator.AddForce(p_force);

		MAKE_PTR(MembraneCellForceNodeBased, p_membrane_force);
		p_membrane_force->SetBasementMembraneTorsionalStiffness(torsional_stiffness);
		p_membrane_force->SetTargetCurvatures(targetCurvatureStemStem, targetCurvatureStemTrans, targetCurvatureTransTrans);
		p_membrane_force->SetMembraneSections(membraneSections);
		//p_membrane_force->SetCalculationToTorsion(true);

		simulator.AddForce(p_membrane_force);

		// MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		// simulator.AddCellPopulationBoundaryCondition(p_bc);
		TRACE("All set up")
		simulator.Solve();

	}

	void xTestInsertCloseMembraneNodeBased() throw(Exception)
	{
		// In this we introduce a row of membrane point cells with a small rest length
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> stromal_nodes;
		std::vector<unsigned> membrane_nodes;
		std::vector<unsigned> location_indices;
		std::vector<unsigned> ghost_nodes;
		std::vector<std::vector<CellPtr>> membraneSections;

		double dt = 0.001;
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
		double stromalStiffness = 5.0; 				// 2.0

		double epithelialMembraneStiffness = 1.0; 	// 1.0
		double membraneStromalStiffness = 10.0; 		// 5.0
		double stromalEpithelialStiffness = 1.0;	// 1.0

		double epithelialPreferredRadius = 1.0;			// 1.0
		double membranePreferredRadius = 0.2;			// 0.2
		double stromalPreferredRadius = 0.6;			// 1.0

		double epithelialInteractionRadius = 3.0 * epithelialPreferredRadius; // Epithelial covers stem and transit
		double membraneInteractionRadius = 1.5 * membranePreferredRadius;
		double stromalInteractionRadius = 2.0 * stromalPreferredRadius; // Stromal is the differentiated "filler" cells

		double maxInteractionRadius = 1.5;

		double torsional_stiffness = 10;			// 10.0

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


		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, maxInteractionRadius);

		std::vector<CellPtr> cells;
		std::vector<CellPtr> membrane_cells;

		MAKE_PTR(MembraneCellProliferativeType, p_membrane_type);
		MAKE_PTR(DifferentiatedCellProliferativeType, p_diff_type);
		MAKE_PTR(WildTypeCellMutationState, p_state);
		MAKE_PTR(BoundaryCellProperty, p_boundary);

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
			membrane_cells.push_back(p_cell);
		}

		membraneSections.push_back(membrane_cells);

		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);

		// for (unsigned i = 0; i < stromal_nodes.size(); i++)
		// {

		// 	Node<2>* p_node = cell_population.GetNode(i);

		// 	double x = p_node->rGetLocation()[0];

		// 	CellPtr p_cell = cell_population.GetCellUsingLocationIndex(i);
		// 	if (x==0)
		// 	{
		// 		p_cell->AddCellProperty(p_boundary);
		// 	}
		// }

		OffLatticeSimulation<2> simulator(cell_population);
		simulator.SetOutputDirectory("SmallMembraneCells");
		simulator.SetEndTime(end_time);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

		MAKE_PTR(LinearSpringForceMembraneCellNodeBased<2>, p_force);
		p_force->SetEpithelialSpringStiffness(epithelialStiffness);
		p_force->SetMembraneSpringStiffness(membraneStiffness);
		p_force->SetStromalSpringStiffness(stromalStiffness);
		p_force->SetEpithelialMembraneSpringStiffness(epithelialMembraneStiffness);
		p_force->SetMembraneStromalSpringStiffness(membraneStromalStiffness);
		p_force->SetStromalEpithelialSpringStiffness(stromalEpithelialStiffness);

		p_force->SetEpithelialPreferredRadius(epithelialPreferredRadius);
		p_force->SetMembranePreferredRadius(membranePreferredRadius);
		p_force->SetStromalPreferredRadius(stromalPreferredRadius);

		p_force->SetEpithelialInteractionRadius(epithelialInteractionRadius);
		p_force->SetMembraneInteractionRadius(membraneInteractionRadius);
		p_force->SetStromalInteractionRadius(stromalInteractionRadius);

		simulator.AddForce(p_force);

		MAKE_PTR(MembraneCellForceNodeBased, p_membrane_force);
		p_membrane_force->SetBasementMembraneTorsionalStiffness(torsional_stiffness);
		p_membrane_force->SetTargetCurvatures(targetCurvatureStemStem, targetCurvatureStemTrans, targetCurvatureTransTrans);
		p_membrane_force->SetMembraneSections(membraneSections);
		//p_membrane_force->SetCalculationToTorsion(true);
		simulator.AddForce(p_membrane_force);

		// MAKE_PTR_ARGS(CryptBoundaryCondition, p_bc, (&cell_population));
		// simulator.AddCellPopulationBoundaryCondition(p_bc);
		simulator.Solve();
	};

};