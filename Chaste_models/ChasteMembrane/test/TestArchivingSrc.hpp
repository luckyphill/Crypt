

#ifndef TestArchivingSrc_HPP_
#define TestArchivingSrc_HPP_

#include <cxxtest/TestSuite.h>

#include <boost/archive/text_oarchive.hpp>
#include <boost/archive/text_iarchive.hpp>

#include <fstream>
#include <iostream>

#include "OutputFileHandler.hpp"
#include "AbstractCellBasedTestSuite.hpp"
#include "SmartPointers.hpp"
#include "ReplicatableVector.hpp"
#include "ArchiveOpener.hpp"
#include "ArchiveLocationInfo.hpp"
#include "FixedG1GenerationalCellCycleModel.hpp"
#include "CellsGenerator.hpp"
//This test is always run sequentially (never in parallel)
#include "FakePetscSetup.hpp"
#include "Debug.hpp"

// Things to be tested
#include "NodesOnlyMesh.hpp"
#include "MonolayerNodeBasedCellPopulation.hpp"
#include "NoCellCycleModel.hpp"
#include "WildTypeCellMutationState.hpp"
// Cell killers
#include "SimpleSloughingCellKiller.hpp"
#include "SimpleAnoikisCellKiller.hpp"
#include "IsolatedCellKiller.hpp"
#include "AnoikisCellKillerNewPhaseModel.hpp"
#include "SloughingCellKillerNewPhaseModel.hpp"
// Boundary Conditions
#include "CryptBoundaryCondition.hpp"
#include "DividingPopUpBoundaryCondition.hpp"

class TestArchivingSrc: public AbstractCellBasedTestSuite
{
public:


	void TestArchivingMonolayerNodeBasedCellPopulation()
	{
		EXIT_IF_PARALLEL;    // Population archiving doesn't work in parallel yet.

		FileFinder archive_dir("archive", RelativeTo::ChasteTestOutput);
		std::string archive_file = "MonolayerNodeBasedCellPopulation.arch";
		ArchiveLocationInfo::SetMeshFilename("MonolayerNodeBasedCellPopulation_mesh");

		{
			// I just copied all this from the test for NodeBaseCellPopulation.
			// It's mostly unecessary, but I'm not touching it because it works

			// Create a simple mesh
			TrianglesMeshReader<2,2> mesh_reader("mesh/test/data/square_4_elements");
			TetrahedralMesh<2,2> generating_mesh;
			generating_mesh.ConstructFromMeshReader(mesh_reader);

			// Convert this to a NodesOnlyMesh
			NodesOnlyMesh<2> mesh;
			mesh.ConstructNodesWithoutMesh(generating_mesh, 1.5);

			// Create cells
			std::vector<CellPtr> cells;
			CellsGenerator<FixedG1GenerationalCellCycleModel, 2> cells_generator;
			cells_generator.GenerateBasic(cells, mesh.GetNumNodes());

			// Create a cell population
			MonolayerNodeBasedCellPopulation<2>* const p_cell_population = new MonolayerNodeBasedCellPopulation<2>(mesh, cells);
			p_cell_population->SetDampingConstantPoppedUp(0.5);
			// Cells have been given birth times of 0, -1, -2, -3, -4.
			// loop over them to run to time 0.0;
			for (AbstractCellPopulation<2>::Iterator cell_iter = p_cell_population->Begin();
				cell_iter != p_cell_population->End();
				++cell_iter)
			{
				cell_iter->ReadyToDivide();
			}


			// Create an output archive
			ArchiveOpener<boost::archive::text_oarchive, std::ofstream> arch_opener(archive_dir, archive_file);
			boost::archive::text_oarchive* p_arch = arch_opener.GetCommonArchive();

			// Write the cell population to the archive
			(*p_arch) << p_cell_population;

			// Avoid memory leak
			SimulationTime::Destroy();
			delete p_cell_population;
		}

		{
			// Need to set up time
			unsigned num_steps = 10;

			SimulationTime* p_simulation_time = SimulationTime::Instance();
			p_simulation_time->SetStartTime(0.0);
			p_simulation_time->SetEndTimeAndNumberOfTimeSteps(1.0, num_steps+1);
			p_simulation_time->IncrementTimeOneStep();

			MonolayerNodeBasedCellPopulation<2>* p_cell_population;

			// Restore the cell population
			ArchiveOpener<boost::archive::text_iarchive, std::ifstream> arch_opener(archive_dir, archive_file);
			boost::archive::text_iarchive* p_arch = arch_opener.GetCommonArchive();

			(*p_arch) >> p_cell_population;

			TS_ASSERT(p_cell_population != NULL);
			TS_ASSERT_DELTA(p_cell_population->GetDampingConstantPoppedUp(), 0.5, 1e-9);

			// Tidy up
			SimulationTime::Destroy();
			delete p_cell_population;
		}
	}

	void TestArchivingCryptBoundaryCondition()
	{
		EXIT_IF_PARALLEL;    // We cannot archive parallel cell based simulations yet.
		// Set up singleton classes
		TrianglesMeshReader<2,2> mesh_reader("mesh/test/data/square_4_elements");
		TetrahedralMesh<2,2> generating_mesh;
		generating_mesh.ConstructFromMeshReader(mesh_reader);

		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(generating_mesh, 1.5);

		std::vector<CellPtr> cells;
		CellsGenerator<FixedG1GenerationalCellCycleModel, 2> cells_generator;
		cells_generator.GenerateBasic(cells, mesh.GetNumNodes());

		NodeBasedCellPopulation<2> population(mesh, cells);

		FileFinder archive_dir("archive", RelativeTo::ChasteTestOutput);
		std::string archive_file = "CryptBoundaryCondition.arch";
		ArchiveLocationInfo::SetMeshFilename("CryptBoundaryCondition");

		{
			// Create an output archive
			CryptBoundaryCondition boundary_condition(&population);

			// Create an output archive
			ArchiveOpener<boost::archive::text_oarchive, std::ofstream> arch_opener(archive_dir, archive_file);
			boost::archive::text_oarchive* p_arch = arch_opener.GetCommonArchive();

			// Serialize via pointer
			AbstractCellPopulationBoundaryCondition<2>* const p_boundary_condition = &boundary_condition;
			(*p_arch) << p_boundary_condition;

		}

		{
			// Create an input archive
			ArchiveOpener<boost::archive::text_iarchive, std::ifstream> arch_opener(archive_dir, archive_file);
			boost::archive::text_iarchive* p_arch = arch_opener.GetCommonArchive();
			AbstractCellPopulationBoundaryCondition<2,2>* p_boundary_condition;
			// Restore from the archive
			(*p_arch) >> p_boundary_condition;

			TS_ASSERT(p_boundary_condition != NULL);
			TS_ASSERT(p_boundary_condition->VerifyBoundaryCondition())
			// Tidy up
			delete p_boundary_condition;

		}
	}

	void TestArchivingDividingPopUpBoundaryCondition()
	{
		EXIT_IF_PARALLEL;    // We cannot archive parallel cell based simulations yet.
		// Set up singleton classes
		TrianglesMeshReader<2,2> mesh_reader("mesh/test/data/square_4_elements");
		TetrahedralMesh<2,2> generating_mesh;
		generating_mesh.ConstructFromMeshReader(mesh_reader);

		NodesOnlyMesh<2> mesh;
		mesh.ConstructNodesWithoutMesh(generating_mesh, 1.5);

		std::vector<CellPtr> cells;
		CellsGenerator<FixedG1GenerationalCellCycleModel, 2> cells_generator;
		cells_generator.GenerateBasic(cells, mesh.GetNumNodes());

		NodeBasedCellPopulation<2> population(mesh, cells);

		FileFinder archive_dir("archive", RelativeTo::ChasteTestOutput);
		std::string archive_file = "DividingPopUpBoundaryCondition.arch";
		ArchiveLocationInfo::SetMeshFilename("DividingPopUpBoundaryCondition");

		{
			// Create an output archive
			DividingPopUpBoundaryCondition boundary_condition(&population);

			// Create an output archive
			ArchiveOpener<boost::archive::text_oarchive, std::ofstream> arch_opener(archive_dir, archive_file);
			boost::archive::text_oarchive* p_arch = arch_opener.GetCommonArchive();

			// Serialize via pointer
			AbstractCellPopulationBoundaryCondition<2>* const p_boundary_condition = &boundary_condition;
			(*p_arch) << p_boundary_condition;

		}

		{
			// Create an input archive
			ArchiveOpener<boost::archive::text_iarchive, std::ifstream> arch_opener(archive_dir, archive_file);
			boost::archive::text_iarchive* p_arch = arch_opener.GetCommonArchive();
			AbstractCellPopulationBoundaryCondition<2,2>* p_boundary_condition;
			// Restore from the archive
			(*p_arch) >> p_boundary_condition;

			TS_ASSERT(p_boundary_condition != NULL);
			TS_ASSERT(p_boundary_condition->VerifyBoundaryCondition())
			// Tidy up
			delete p_boundary_condition;

		}
	}


	void TestArchivingSimpleSloughingCellKiller()
	{
		// Set up
		OutputFileHandler handler("archive", false);    // don't erase contents of folder
		std::string archive_filename = handler.GetOutputDirectoryFullPath() + "SimpleSloughingCellKiller.arch";
		{
			// Create an output archive
			SimpleSloughingCellKiller<2> cell_killer(NULL);
			cell_killer.SetCryptTop(20);

			std::ofstream ofs(archive_filename.c_str());
			boost::archive::text_oarchive output_arch(ofs);

			// Serialize via pointer
			SimpleSloughingCellKiller<2>* const p_cell_killer = &cell_killer;

			output_arch << p_cell_killer;
	   }

	   {
			// Create an input archive
			std::ifstream ifs(archive_filename.c_str(), std::ios::binary);
			boost::archive::text_iarchive input_arch(ifs);

			SimpleSloughingCellKiller<2>* p_cell_killer;

			// Restore from the archive
			input_arch >> p_cell_killer;

			TS_ASSERT(p_cell_killer != NULL);
			TS_ASSERT(p_cell_killer->mCryptTop == 20);
			TS_ASSERT(p_cell_killer->GetCellKillCount() == 0);

			// Tidy up
			delete p_cell_killer;
		}
	}

	void TestArchivingSimpleAnoikisCellKiller()
	{
		// Set up
		OutputFileHandler handler("archive", false);    // don't erase contents of folder
		std::string archive_filename = handler.GetOutputDirectoryFullPath() + "SimpleAnoikisCellKiller.arch";
		{
			// Create an output archive
			SimpleAnoikisCellKiller cell_killer(NULL);
			cell_killer.SetSlowDeath(true);
			cell_killer.SetPoppedUpLifeExpectancy(11);
			cell_killer.SetResistantPoppedUpLifeExpectancy(15);
			cell_killer.SetPopUpDistance(3);

			std::ofstream ofs(archive_filename.c_str());
			boost::archive::text_oarchive output_arch(ofs);

			// Serialize via pointer
			SimpleAnoikisCellKiller* const p_cell_killer = &cell_killer;

			output_arch << p_cell_killer;
	   }

	   {
			// Create an input archive
			std::ifstream ifs(archive_filename.c_str(), std::ios::binary);
			boost::archive::text_iarchive input_arch(ifs);

			SimpleAnoikisCellKiller* p_cell_killer;

			// Restore from the archive
			input_arch >> p_cell_killer;

			TS_ASSERT(p_cell_killer != NULL);
			TS_ASSERT(p_cell_killer->GetPoppedUpLifeExpectancy()==11);
			TS_ASSERT(p_cell_killer->GetResistantPoppedUpLifeExpectancy()==15);
			TS_ASSERT(p_cell_killer->GetPopUpDistance()==3);
			TS_ASSERT(p_cell_killer->GetCellKillCount() == 0);

			// Tidy up
			delete p_cell_killer;
		}
	}

	void TestArchivingIsolatedCellKiller()
	{
		// Set up
		OutputFileHandler handler("archive", false);    // don't erase contents of folder
		std::string archive_filename = handler.GetOutputDirectoryFullPath() + "IsolatedCellKiller.arch";
		{
			// Create an output archive
			IsolatedCellKiller cell_killer(NULL);

			std::ofstream ofs(archive_filename.c_str());
			boost::archive::text_oarchive output_arch(ofs);

			// Serialize via pointer
			IsolatedCellKiller* const p_cell_killer = &cell_killer;

			output_arch << p_cell_killer;
	   }

	   {
			// Create an input archive
			std::ifstream ifs(archive_filename.c_str(), std::ios::binary);
			boost::archive::text_iarchive input_arch(ifs);

			IsolatedCellKiller* p_cell_killer;

			// Restore from the archive
			input_arch >> p_cell_killer;

			TS_ASSERT(p_cell_killer != NULL);
			TS_ASSERT(p_cell_killer->GetCellKillCount() == 0);

			// Tidy up
			delete p_cell_killer;
		}
	}


};

#endif /*TestArchivingSrc_HPP_*/
