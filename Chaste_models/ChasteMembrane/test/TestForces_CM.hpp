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

		
		div_force.AddForceContribution(cell_population);

		it1 = node_pairs.begin();

		
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
		mesh.ConstructNodesWithoutMesh(nodes, 1.5);

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
			if ( i == 12 || i == 13)
			{
				p_cycle_model->SetBirthTime(-5);
			}

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);
			p_cell->InitialiseCellCycleModel();

			cells.push_back(p_cell);


		}

        NodeBasedCellPopulation<2> cell_population(mesh, cells);

        CellPtr cellA = cell_population.GetCellUsingLocationIndex(12);
		CellPtr cellB = cell_population.GetCellUsingLocationIndex(13);
		cellA->GetCellData()->SetItem("parent", 100);
		cellB->GetCellData()->SetItem("parent", 100);

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

        std::vector< std::pair<Node<2>*, Node<2>* >>& all_node_pairs = cell_population.rGetNodePairs();

        std::vector<std::pair<Node<2>*, Node<2>* > > node_pairs = p_force->FindOneInteractionBetweenCellPairs(cell_population, all_node_pairs);

    	assert(all_node_pairs.size() == 194); // Will fail if the simulation is changed at all
    	assert(node_pairs.size() == 57); // Will fail if simulation changes or force calculator changes
    	WntConcentration<2>::Instance()->Destroy();
	};


	void TestMultiNodeFixCrypt() throw(Exception)
	{
		// This tests the function FindPairsToRemove in BasicNonLinearSpringForceMultiNodeFix
		// The algorithm in the function finds interactions between two cells, and makes sure
		// that a given cell only interacts with one of the internal nodes

		// Make a collection of nodes

		std::vector<Node<2>*> nodes;

		
		double x[39] = {0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6};
		double y[39] = {0, 1.40003, 2.08308, 3.59692, 6.32319, 7.02052, 7.71518, 9.23429, 11.8626, 12.6771, 14.3088, 16.0033, 18.6148, 19.5069, 20.4113, 21.329, 22.2611, 23.2087, 24.1729, 25.1546, 11.0925, 12.8551, 2.83952, 15.1519, 4.96266, 17.7341, 4.28318, 0.720704, 8.45481, 10.366, 5.64309, 16.8638, 13.4896, 9.61334, 13.287, 2.63715, 11.6617, 7.95722, 6.33578};
		unsigned parents[39] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 9, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 7, 32, 22, 8, 6, 4};

		unsigned node_counter = 0;
		for (unsigned i = 0; i <39; i++)
		{
			nodes.push_back(new Node<2>(node_counter,  false,  x[i], y[i]));
			node_counter++;
		}

		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, 1.5);

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
			if (i == 22 || i == 4 || i == 6 || i == 7 || i == 9 || i == 8 || i == 21 || i == 32 || i == 33 || i == 34 || i == 35 || i == 36 || i == 37 || i == 38)
			{
				p_cycle_model->SetBirthTime(-5);
			}

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);
			p_cell->InitialiseCellCycleModel();
			p_cell->GetCellData()->SetItem("volume", 0.7);

			cells.push_back(p_cell);


		}

		NodeBasedCellPopulation<2> cell_population(mesh, cells);

		for (unsigned i = 0; i <39; i++)
		{
			CellPtr cellA = cell_population.GetCellUsingLocationIndex(i);
			cellA->GetCellData()->SetItem("parent", parents[i]);
			cellA->GetCellData()->SetItem("volume", 0.7);
		}

        OffLatticeSimulation<2> simulator(cell_population);
        simulator.SetOutputDirectory("TestMultiNodeFixCrypt");
        simulator.SetSamplingTimestepMultiple(1);
        simulator.SetEndTime(0.001);
        simulator.SetDt(0.001);
        MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);

        WntConcentration<2>::Instance()->SetType(LINEAR);
        WntConcentration<2>::Instance()->SetCellPopulation(cell_population);
        WntConcentration<2>::Instance()->SetCryptLength(26);

        simulator.Solve();

        MAKE_PTR(BasicNonLinearSpringForceMultiNodeFix<2>, p_force);

        std::vector< std::pair<Node<2>*, Node<2>* >>& all_node_pairs = cell_population.rGetNodePairs();

        std::vector<std::pair<Node<2>*, Node<2>* > > node_pairs = p_force->FindOneInteractionBetweenCellPairs(cell_population, all_node_pairs);

        

    	assert(all_node_pairs.size() == 117); // Will fail if the simulation is changed at all
    	assert(node_pairs.size() == 38); // Will fail if simulation changes or force calculator changes
    	WntConcentration<2>::Instance()->Destroy();
	};

	void TestMultiNodeFixBeforeSplit() throw(Exception)
	{
		// This tests the function FindPairsToRemove in BasicNonLinearSpringForceMultiNodeFix
		// The algorithm in the function finds interactions between two cells, and makes sure
		// that a given cell only interacts with one of the internal nodes

		// This set of positions appeared immediately before two simulations forked
		// The data is saved in a file in the testing directory for ParameterOptimisation
		unsigned step = 13071;

		std::stringstream nodeA_infile_name;
		nodeA_infile_name << "/Users/phillipbrown/Chaste/projects/ChasteMembrane/processing/ParameterOptimisation/testing/nodesA_"<< step << ".txt";
		std::ifstream nodeA_infile(nodeA_infile_name.str());

		std::list< std::pair<unsigned, unsigned> > nodesA;
		std::string line;
		while (std::getline(nodeA_infile, line))
		{
		    std::istringstream iss(line);
		    unsigned a, b;
		    char c;
		    if (!(iss >> a >> c >> b) || !(c==','))
		    {
		    	break;
		    }
		    nodesA.push_back(std::make_pair(a,b));
		}

		std::stringstream nodeB_infile_name;
		nodeB_infile_name << "/Users/phillipbrown/Chaste/projects/ChasteMembrane/processing/ParameterOptimisation/testing/nodesB_"<< step << ".txt";
		std::ifstream nodeB_infile(nodeB_infile_name.str());

		std::list< std::pair<unsigned, unsigned> > nodesB;

		while (std::getline(nodeB_infile, line))
		{
		    std::istringstream iss(line);
		    unsigned a, b;
		    char c;
		    if (!(iss >> a >> c >> b) || !(c==','))
		    {
		    	break;
		    }

		    nodesB.push_back(std::make_pair(a,b));
		}

		std::stringstream stateA_infile_name;
		stateA_infile_name << "/Users/phillipbrown/Chaste/projects/ChasteMembrane/processing/ParameterOptimisation/testing/stateA_"<< step << ".txt";
		std::ifstream stateA_infile(stateA_infile_name.str());

		// First line is cell IDs
		std::getline( stateA_infile, line );
		std::vector<unsigned> id = GetCsvLineUnsigned(line);


  		// Second line is cell x
		std::getline( stateA_infile, line );
		std::vector<double> x = GetCsvLineDouble(line);

  		// Third line is cell y
		std::getline( stateA_infile, line );
		std::vector<double> y = GetCsvLineDouble(line);

  		// Forth line is cell age
		std::getline( stateA_infile, line );
		std::vector<double> age = GetCsvLineDouble(line);

  		// Fifth line is cell parent
		std::getline( stateA_infile, line );
  		std::vector<unsigned> parent = GetCsvLineUnsigned(line);



		std::vector<Node<2>*> nodes;

		// double x[39] = {0.6, 0.600000000272702, 0.599999995122016, 0.600000064171990, 0.599999999128723, 0.600000000000175, 0.6, 0.6, 0.6, 0.6, 0.599999999898938, 0.6, 0.599999999999988, 0.599999974629623, 0.600000001764502, 0.600000010596402, 0.6, 0.6, 0.6, 0.600000321699527, 0.600000000828741, 0.600000000024627, 0.6, 0.6, 0.599999999997798, 0.599999999944892, 0.600000013186203, 0.600000000000001, 0.599999999409445, 0.6, 0.599999971865908, 0.599999866357506, 0.6, 0.599999974629623, 0.600000000828741, 0.600000000024627, 0.600000000272702, 0.599999999128723, 0.600000321699527};
		// double y[39] = {0, 1.40383294393280, 3.41117552845353, 6.95341038328207, 9.00170365944317, 13.1030846630868, 16.4603878684981, 19.9999497807384, 22.7865999321540, 24.7131882365403, 10.6247851217727, 21.8443593851380, 13.9263761519447, 4.88807393359707, 2.74299596908329, 8.30999698190507, 17.3274883753523, 23.7427480431537, 25.6982636517558, 5.60388475277227, 9.84183256071220, 11.4136311136017, 19.0969529954643, 20.9156157195651, 12.2897101781060, 0.717565947613127, 4.07976585246533, 14.7601113518611, 2.07454595918953, 18.2062453589394, 7.62957845139079, 6.27977432847745, 15.6046818764670, 4.76179408876294, 9.76088631597615, 11.4855685445588, 1.39341922526955, 9.02211187427056, 5.57449777258031};
		
		// Save the parents here. This is what they were from the simulation, but they needed to be adjusted to match the new cell IDs
		// unsigned parents[39] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 31, 32, 33, 34, 35, 36, 37, 38, 39, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 35, 43, 44, 1, 4, 42};
		
		// unsigned ids[39] = 		{0, 1, 2, 3, 4, 5, 6, 7, 8, 31, 32, 33, 34, 35, 36, 37, 38, 39, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61};
		// unsigned parents[39] = 	{0, 1, 2, 3, 4, 5, 6, 7, 8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 13, 20, 21, 1, 4, 19};
		
		// unsigned phases[39] = {0, 2, 1, 1, 2, 0, 0, 0, 0, 0, 1, 0, 0, 2, 1, 1, 0, 0, 0, 2, 2, 2, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 2, 2, 2, 2, 2, 2};
		// double ages[39] = {36.46, 0.592, 14.12, 10.922, 0.288, 15.024, 10.678, 15.56, 22.790, 19.964, 15.744, 15.354, 13.944, 2.976, 12.932, 10.990, 12.106, 22.790, 19.964, 0.082, 1.950, 1.702, 15.560, 15.354, 15.024, 14.838, 14.120, 13.944, 12.932, 12.106, 10.990, 10.922, 10.678, 2.976, 1.950, 1.702, 0.592, 0.288, 0.082};
		
		unsigned node_counter = 0;
		
		for (unsigned i = 0; i < ids.size(); i++)
		{
			nodes.push_back(new Node<2>(node_counter,  false,  x[i], y[i]));
			node_counter++;
		}

		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(nodes, 1.5);

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

			p_cycle_model->SetBirthTime(-age[i]);

			CellPtr p_cell(new Cell(p_state, p_cycle_model));
			p_cell->SetCellProliferativeType(p_trans_type);
			p_cell->InitialiseCellCycleModel();
			p_cell->GetCellData()->SetItem("volume", 0.7);

			cells.push_back(p_cell);


		}
		
		NodeBasedCellPopulation<2> cell_population(mesh, cells);

		for (unsigned i = 0; i <39; i++)
		{
			CellPtr cellA = cell_population.GetCellUsingLocationIndex(i);
			cellA->GetCellData()->SetItem("parent", parent[i]);
			cellA->GetCellData()->SetItem("volume", 0.7);
		}
		
        OffLatticeSimulation<2> simulator(cell_population);
        simulator.SetOutputDirectory("TestMultiNodeFixCrypt");
        simulator.SetSamplingTimestepMultiple(1);
        simulator.SetEndTime(0.002);
        simulator.SetDt(0.002);
        MAKE_PTR(VolumeTrackingModifier<2>, p_mod);
		simulator.AddSimulationModifier(p_mod);
		
        WntConcentration<2>::Instance()->SetType(LINEAR);
        WntConcentration<2>::Instance()->SetCellPopulation(cell_population);
        WntConcentration<2>::Instance()->SetCryptLength(26);

        simulator.Solve();
        
        MAKE_PTR(BasicNonLinearSpringForceMultiNodeFix<2>, p_force);

        std::vector< std::pair<Node<2>*, Node<2>* >>& all_node_pairs = cell_population.rGetNodePairs();

        // Turn each set of cellID pairs into node pairs
        

        std::vector<std::pair<Node<2>*, Node<2>* > > node_pairs = p_force->FindOneInteractionBetweenCellPairs(cell_population, all_node_pairs);

        

    	PRINT_VARIABLE(all_node_pairs.size()); // Will fail if the simulation is changed at all
    	PRINT_VARIABLE(node_pairs.size()); // Will fail if simulation changes or force calculator changes
    	WntConcentration<2>::Instance()->Destroy();
	};

	std::vector<unsigned> GetCsvLineUnsigned(std::string line)
	{
	
		std::istringstream is( line );
		std::vector<unsigned> vec;
		std::string field;
  		while (getline( is, field, ',' ))
  		{
  			std::stringstream fs( field );
		    unsigned f = 0;
		    fs >> f;
		    vec.push_back(f);
  		}
  		return vec;
	}

	std::vector<double> GetCsvLineDouble(std::string line)
	{
	
		std::istringstream is( line );
		std::vector<double> vec;
		std::string field;
  		while (getline( is, field, ',' ))
  		{
  			std::stringstream fs( field );
		    double f = 0.0;  // (default value is 0.0)
		    fs >> f;
		    vec.push_back(f);
  		}
  		return vec;
	}

};