// Standard includes for tests
#include <cxxtest/TestSuite.h>
#include "AbstractCellBasedTestSuite.hpp"
#include "CheckpointArchiveTypes.hpp"
#include "SmartPointers.hpp"
#include "CommandLineArguments.hpp"

#include "SimpleWntContactInhibitionCellCycleModel.hpp"
#include "NodeBasedCellPopulation.hpp"
#include "NodesOnlyMesh.hpp"
#include "OffLatticeSimulation.hpp" //Simulates the evolution of the population
#include "StickToMembraneDivisionRule.hpp"
#include "TransitCellProliferativeType.hpp"
#include "WildTypeCellMutationState.hpp"
#include "WntConcentration.hpp"

// Forces
#include "DividingRotationForce.hpp"
#include "BasicNonLinearSpringForceMultiNodeFix.hpp"

// Cell Cycle Models
#include "SimplifiedPhaseBasedCellCycleModel.hpp"

// Modifiers
#include "VolumeTrackingModifier.hpp"

// Misc
#include "FakePetscSetup.hpp"
#include "Debug.hpp"


class TestForces_CM : public AbstractCellBasedTestSuite
{
	public:
	void xTestDividingRotationForce() throw(Exception)
	{
		
		unsigned n = 10;
		unsigned node_counter = 0;
		std::vector<Node<2>*> nodes;
		std::vector<unsigned> transit_nodes;
		std::vector<unsigned> location_indices;


		// Put down first node which will be a boundary condition node
		Node<2>* single_node =  new Node<2>(node_counter,  false,  0, 0);
		nodes.push_back(single_node);
		transit_nodes.push_back(node_counter);
		location_indices.push_back(node_counter);
		node_counter++;


		for(unsigned i = 1; i <= n; i++)
		{
			double x = 0;
			double y = 2 * i * 0.5;
			if (i == 1 || i == 3)
			{
				x = 0.5;
			}

			Node<2>* single_node_2 =  new Node<2>(node_counter,  false,  x, y);
			nodes.push_back(single_node_2);
			transit_nodes.push_back(node_counter);
			location_indices.push_back(node_counter);
			node_counter++;
		}



		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, 2);

		std::vector<CellPtr> cells;


		MAKE_PTR(TransitCellProliferativeType, p_trans_type);
		MAKE_PTR(WildTypeCellMutationState, p_state);


		for(unsigned i=0; i<=n; i++)
		{
			SimpleWntContactInhibitionCellCycleModel* p_cycle_model = new SimpleWntContactInhibitionCellCycleModel();
			double birth_time = 10 * RandomNumberGenerator::Instance()->ranf();
			p_cycle_model->SetDimension(2);
   			p_cycle_model->SetEquilibriumVolume(0.78);
   			p_cycle_model->SetQuiescentVolumeFraction(0.8);
   			p_cycle_model->SetWntThreshold(0.25);
			p_cycle_model->SetBirthTime(-birth_time);

			if (i == 1 || i ==2)
			{
				p_cycle_model->SetBirthTime(-0.1);

			}
			if (i == 3 || i == 4)
			{
				p_cycle_model->SetBirthTime(-0.3);

			}

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);
			p_cell->GetCellData()->SetItem("parent", i + 3);

			if (i == 1 || i ==2)
			{
				p_cell->GetCellData()->SetItem("parent", 1);
				
			}
			if (i == 3 || i == 4)
			{
				p_cell->GetCellData()->SetItem("parent", 2);
				
			}
			p_cell->GetCellData()->SetItem("volume", 1);
			cells.push_back(p_cell);


		}

		NodeBasedCellPopulation<2> cell_population(mesh, cells, location_indices);
		cell_population.SetMeinekeDivisionSeparation(0.05); // Set how far apart the cells will be upon division

		WntConcentration<2>::Instance()->SetType(LINEAR);
        WntConcentration<2>::Instance()->SetCellPopulation(cell_population);
        WntConcentration<2>::Instance()->SetCryptLength(n);

        for (std::vector<CellPtr>::iterator cell_iter = cells.begin(); cell_iter != cells.end(); ++cell_iter)
    	{
	        AbstractCellCycleModel* temp_ccm = (*cell_iter)->GetCellCycleModel();
	        SimpleWntContactInhibitionCellCycleModel* p_cycle_model = static_cast<SimpleWntContactInhibitionCellCycleModel*>(temp_ccm);
			p_cycle_model->UpdateCellCyclePhase();
		}

		c_vector<double, 2> membraneAxis;
		membraneAxis(0) = 0;
		membraneAxis(1) = 1;

		MAKE_PTR(StickToMembraneDivisionRule<2>, pCentreBasedDivisionRule);
		pCentreBasedDivisionRule->SetMembraneAxis(membraneAxis);
		cell_population.SetCentreBasedDivisionRule(pCentreBasedDivisionRule);

		//===========================================================================
		// The force we are testing
		//===========================================================================
		DividingRotationForce div_force;
		div_force.SetMembraneAxis(membraneAxis);
		div_force.SetTorsionalStiffness(10.0);

		//===========================================================================
		// Test that it picks the correct nodes
		std::vector<std::pair<Node<2>*, Node<2>*>> node_pairs = div_force.GetNodePairs(cell_population);

		// The first item in the vector should be (1,2)
		std::vector<std::pair<Node<2>*, Node<2>*>>::iterator it1 = node_pairs.begin();
		assert((it1->first)->GetIndex() == 1);
		assert((it1->second)->GetIndex() == 2);
		
		// The second item in the vector should be (3,4)
		++it1;
		assert((it1->first)->GetIndex() == 3);
		assert((it1->second)->GetIndex() == 4);
		
		// There should only be two
		++it1;
		assert(it1 == node_pairs.end());
		//===========================================================================
		// Test that the forces are correct

		TRACE("AddForceContribution starting")
		div_force.AddForceContribution(cell_population);

		it1 = node_pairs.begin();

		TRACE("AddForceContribution done")
		c_vector<double, 2> forceOn1 =  (it1->first)->rGetAppliedForce();
		++it1;
		c_vector<double, 2> forceOn3 =  (it1->first)->rGetAppliedForce();

		PRINT_2_VARIABLES(forceOn1[0], forceOn3[0])

		
		WntConcentration<2>::Instance()->Destroy();

	};

	void TestMultiNodeFix() throw(Exception)
	{
		// This tests the function FindPairsToRemove in BasicNonLinearSpringForceMultiNodeFix
		// The algorithm in the function finds interactions between two cells, and makes sure
		// that a given cell only interacts with one of the internal nodes

		// Make a collection of nodes

		std::vector<Node<2>*> nodes;

		unsigned cells_up = 5;
		unsigned cells_across = 5;
		unsigned node_counter = 0;

		for (unsigned i = 0; i< cells_across; i++)
		{
			for (unsigned j = 0; j< cells_up; j++)
			{
				double x = 0;
				double y = 0;
				if (j == 2* unsigned(j/2))
				{
					x = i;
				} else 
				{
					// stagger for hex mesh
					x = i + 0.5;
				}
				y = j * (sqrt(3.0)/2);

				// Puts two nodes close to each other to represent the nodes in W phase
				if( node_counter == 12)
				{
					nodes.push_back(new Node<2>(node_counter,  false,  x - 0.1, y));
					node_counter++;
					nodes.push_back(new Node<2>(node_counter,  false,  x + 0.1, y));
					node_counter++;
				} else 
				{
					nodes.push_back(new Node<2>(node_counter,  false,  x, y));
					node_counter++;
				}
				
			}
		}

		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, 3.0);

		std::vector<CellPtr> cells;

		MAKE_PTR(DifferentiatedCellProliferativeType, p_diff_type);
		MAKE_PTR(TransitCellProliferativeType, p_trans_type);

		MAKE_PTR(WildTypeCellMutationState, p_state);

		for (unsigned i = 0; i < nodes.size(); i++)
		{

			// Set the middle cell to be proliferating
			SimplifiedPhaseBasedCellCycleModel* p_cycle_model = new SimplifiedPhaseBasedCellCycleModel();

			p_cycle_model->SetWDuration(10);
			p_cycle_model->SetBasePDuration(5);
			p_cycle_model->SetDimension(2);
   			p_cycle_model->SetEquilibriumVolume(2);
   			p_cycle_model->SetQuiescentVolumeFraction(0.8);
   			p_cycle_model->SetWntThreshold(0.5);
			p_cycle_model->SetBirthTime(-12);
			if ( i ==12 || i == 13)
			{
				p_cycle_model->SetBirthTime(-5);
			}

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);
			p_cell->InitialiseCellCycleModel();
			
			if ( i ==12 || i == 13)
			{
				p_cell->GetCellData()->SetItem("parent", 100);
			}

			cells.push_back(p_cell);


		}

        NodeBasedCellPopulation<2> cell_population(mesh, cells);

        OffLatticeSimulation<2> simulator(cell_population);
        simulator.SetOutputDirectory("TestMultiNodeFix");
        simulator.SetSamplingTimestepMultiple(1);
        simulator.SetEndTime(0.001);
        simulator.SetDt(0.001);
        MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

        WntConcentration<2>::Instance()->SetType(LINEAR);
        WntConcentration<2>::Instance()->SetCellPopulation(cell_population);
        WntConcentration<2>::Instance()->SetCryptLength(10);

        simulator.Solve();

        MAKE_PTR(BasicNonLinearSpringForceMultiNodeFix<2>, p_force);

        std::vector<std::pair<Node<2>*, Node<2>* >> node_pairs = p_force->FindPairsToRemove(cell_population);

        for (typename std::vector< std::pair<Node<2>*, Node<2>* > >::iterator iter = node_pairs.begin();
        iter != node_pairs.end();
        iter++)
    	{
    		unsigned node1 = (*iter).first->GetIndex();
    		unsigned node2 = (*iter).second->GetIndex();
    		PRINT_2_VARIABLES(node1, node2)
    	}
	};

};