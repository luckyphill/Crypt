

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
// Wnt Concentration for position tracking
#include "WntConcentration.hpp"

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
// Cell properties
#include "BoundaryCellProperty.hpp"
#include "TransitCellAnoikisResistantMutationState.hpp"
#include "WeakenedMembraneAdhesion.hpp"
#include "WeakenedCellCellAdhesion.hpp"
// Division Rules
#include "StickToMembraneDivisionRule.hpp"
// Forces
#include "NormalAdhesionForceNewPhaseModel.hpp"
#include "BasicNonLinearSpringForceMultiNodeFix.hpp"
// Cell cycle models
#include "NoCellCycleModelPhase.hpp"
#include "SimplifiedPhaseBasedCellCycleModel.hpp"

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

	void TestArchivingAnoikisCellKillerNewPhaseModel()
	{
		// Set up
		OutputFileHandler handler("archive", false);    // don't erase contents of folder
		std::string archive_filename = handler.GetOutputDirectoryFullPath() + "AnoikisCellKillerNewPhaseModel.arch";
		{
			// Create an output archive
			AnoikisCellKillerNewPhaseModel cell_killer(NULL);

			std::ofstream ofs(archive_filename.c_str());
			boost::archive::text_oarchive output_arch(ofs);

			// Serialize via pointer
			AnoikisCellKillerNewPhaseModel* const p_cell_killer = &cell_killer;
			
			p_cell_killer->SetSlowDeath(true);
			p_cell_killer->SetPoppedUpLifeExpectancy(11);
			p_cell_killer->SetResistantPoppedUpLifeExpectancy(12);
			p_cell_killer->SetPopUpDistance(1.2);

			output_arch << p_cell_killer;
	   }

	   {
			// Create an input archive
			std::ifstream ifs(archive_filename.c_str(), std::ios::binary);
			boost::archive::text_iarchive input_arch(ifs);

			AnoikisCellKillerNewPhaseModel* p_cell_killer;

			// Restore from the archive
			input_arch >> p_cell_killer;

			TS_ASSERT(p_cell_killer != NULL);
			TS_ASSERT(p_cell_killer->GetCellKillCount() == 0);
			TS_ASSERT(p_cell_killer->mSlowDeath);
			TS_ASSERT(p_cell_killer->mPoppedUpLifeExpectancy == 11);
			TS_ASSERT(p_cell_killer->mResistantPoppedUpLifeExpectancy ==12);
			TS_ASSERT(p_cell_killer->mPopUpDistance == 1.2);

			// Tidy up
			delete p_cell_killer;
		}
	}

	void TestArchivingSloughingCellKillerNewPhaseModel()
	{
		// Set up
		OutputFileHandler handler("archive", false);    // don't erase contents of folder
		std::string archive_filename = handler.GetOutputDirectoryFullPath() + "SloughingCellKillerNewPhaseModel.arch";
		{
			// Create an output archive
			SloughingCellKillerNewPhaseModel cell_killer(NULL);
			cell_killer.SetCryptTop(20);

			std::ofstream ofs(archive_filename.c_str());
			boost::archive::text_oarchive output_arch(ofs);

			// Serialize via pointer
			SloughingCellKillerNewPhaseModel* const p_cell_killer = &cell_killer;

			output_arch << p_cell_killer;
	   }

	   {
			// Create an input archive
			std::ifstream ifs(archive_filename.c_str(), std::ios::binary);
			boost::archive::text_iarchive input_arch(ifs);

			SloughingCellKillerNewPhaseModel* p_cell_killer;

			// Restore from the archive
			input_arch >> p_cell_killer;

			TS_ASSERT(p_cell_killer != NULL);
			TS_ASSERT(p_cell_killer->mCryptTop == 20);
			TS_ASSERT(p_cell_killer->GetCellKillCount() == 0);

			// Tidy up
			delete p_cell_killer;
		}
	}

	void TestArchivingBoundaryCellProperty()
	{
		// Set up
		OutputFileHandler handler("archive", false);    // don't erase contents of folder
		std::string archive_filename = handler.GetOutputDirectoryFullPath() + "BoundaryCellProperty.arch";
		{
			// Create an output archive
			BoundaryCellProperty* bcp = new BoundaryCellProperty();

			std::ofstream ofs(archive_filename.c_str());
			boost::archive::text_oarchive output_arch(ofs);

			// Serialize via pointer
			BoundaryCellProperty* const p_bcp = bcp;

			output_arch << p_bcp;
	   }

	   {
			// Create an input archive
			std::ifstream ifs(archive_filename.c_str(), std::ios::binary);
			boost::archive::text_iarchive input_arch(ifs);

			BoundaryCellProperty* p_bcp;

			// Restore from the archive
			input_arch >> p_bcp;

			TS_ASSERT(p_bcp != NULL);
			TS_ASSERT(p_bcp->GetColour() == 5);

			// Tidy up
			delete p_bcp;
		}
	}

	void TestArchivingTransitCellAnoikisResistantMutationState()
	{
		// Set up
		OutputFileHandler handler("archive", false);    // don't erase contents of folder
		std::string archive_filename = handler.GetOutputDirectoryFullPath() + "TransitCellAnoikisResistantMutationState.arch";
		{
			// Create an output archive
			TransitCellAnoikisResistantMutationState* bcp = new TransitCellAnoikisResistantMutationState();

			std::ofstream ofs(archive_filename.c_str());
			boost::archive::text_oarchive output_arch(ofs);

			// Serialize via pointer
			TransitCellAnoikisResistantMutationState* const p_bcp = bcp;

			output_arch << p_bcp;
	   }

	   {
			// Create an input archive
			std::ifstream ifs(archive_filename.c_str(), std::ios::binary);
			boost::archive::text_iarchive input_arch(ifs);

			TransitCellAnoikisResistantMutationState* p_bcp;

			// Restore from the archive
			input_arch >> p_bcp;

			TS_ASSERT(p_bcp != NULL);
			TS_ASSERT(p_bcp->GetColour() == 4);

			// Tidy up
			delete p_bcp;
		}
	}

	void TestArchivingWeakenedMembraneAdhesion()
	{
		// Set up
		OutputFileHandler handler("archive", false);    // don't erase contents of folder
		std::string archive_filename = handler.GetOutputDirectoryFullPath() + "WeakenedMembraneAdhesion.arch";
		{
			// Create an output archive
			WeakenedMembraneAdhesion* bcp = new WeakenedMembraneAdhesion();

			std::ofstream ofs(archive_filename.c_str());
			boost::archive::text_oarchive output_arch(ofs);

			// Serialize via pointer
			WeakenedMembraneAdhesion* const p_bcp = bcp;

			output_arch << p_bcp;
	   }

	   {
			// Create an input archive
			std::ifstream ifs(archive_filename.c_str(), std::ios::binary);
			boost::archive::text_iarchive input_arch(ifs);

			WeakenedMembraneAdhesion* p_bcp;

			// Restore from the archive
			input_arch >> p_bcp;

			TS_ASSERT(p_bcp != NULL);
			TS_ASSERT(p_bcp->GetColour() == 5);

			// Tidy up
			delete p_bcp;
		}
	}

	void TestArchivingWeakenedCellCellAdhesion()
	{
		// Set up
		OutputFileHandler handler("archive", false);    // don't erase contents of folder
		std::string archive_filename = handler.GetOutputDirectoryFullPath() + "WeakenedCellCellAdhesion.arch";
		{
			// Create an output archive
			WeakenedCellCellAdhesion* bcp = new WeakenedCellCellAdhesion();

			std::ofstream ofs(archive_filename.c_str());
			boost::archive::text_oarchive output_arch(ofs);

			// Serialize via pointer
			WeakenedCellCellAdhesion* const p_bcp = bcp;

			output_arch << p_bcp;
	   }

	   {
			// Create an input archive
			std::ifstream ifs(archive_filename.c_str(), std::ios::binary);
			boost::archive::text_iarchive input_arch(ifs);

			WeakenedCellCellAdhesion* p_bcp;

			// Restore from the archive
			input_arch >> p_bcp;

			TS_ASSERT(p_bcp != NULL);
			TS_ASSERT(p_bcp->GetColour() == 5);

			// Tidy up
			delete p_bcp;
		}
	}

	void TestArchiveStickToMembraneDivisionRule()
	{
		FileFinder archive_dir("archive", RelativeTo::ChasteTestOutput);
		std::string archive_file = "StickToMembraneDivisionRule.arch";

		{
			boost::shared_ptr<StickToMembraneDivisionRule<2> > p_division_rule(new StickToMembraneDivisionRule<2>());
			c_vector<double, 2> membraneAxis;
			membraneAxis[0] = 1;
			membraneAxis[1] = 2;
			p_division_rule->SetMembraneAxis(membraneAxis);
			p_division_rule->SetWiggleDivision(true);
			p_division_rule->SetMaxAngle(0.2);

			// Setting the membrane axis converts the vector to a unit vector
			TS_ASSERT_DELTA(p_division_rule->rGetDivisionVector()[0], 0.4472135, 1e-6);
			TS_ASSERT_DELTA(p_division_rule->rGetDivisionVector()[1], 0.8944271, 1e-6);

			ArchiveOpener<boost::archive::text_oarchive, std::ofstream> arch_opener(archive_dir, archive_file);
			boost::archive::text_oarchive* p_arch = arch_opener.GetCommonArchive();

			(*p_arch) << p_division_rule;
		}

		{
			boost::shared_ptr<StickToMembraneDivisionRule<2> > p_division_rule;

			ArchiveOpener<boost::archive::text_iarchive, std::ifstream> arch_opener(archive_dir, archive_file);
			boost::archive::text_iarchive* p_arch = arch_opener.GetCommonArchive();

			(*p_arch) >> p_division_rule;

			c_vector<double, 2> membraneAxis = p_division_rule->rGetDivisionVector();
			// TS_ASSERT(membraneAxis[0] == 1);
			// TS_ASSERT(membraneAxis[1] == 2);
			TS_ASSERT_DELTA(membraneAxis[0], 0.4472135, 1e-6);
			TS_ASSERT_DELTA(membraneAxis[1], 0.8944271, 1e-6);
			TS_ASSERT(p_division_rule->mWiggle);
			TS_ASSERT(p_division_rule->mMaxAngle == 0.2);

		}
	}

	void TestArchiveNormalAdhesionForceNewPhaseModel()
	{
		EXIT_IF_PARALLEL;
		OutputFileHandler handler("archive", false);
		std::string archive_filename = handler.GetOutputDirectoryFullPath() + "NormalAdhesionForceNewPhaseModel.arch";

		{
			NormalAdhesionForceNewPhaseModel<2> force;

			std::ofstream ofs(archive_filename.c_str());
			boost::archive::text_oarchive output_arch(ofs);

			// Set member variables
			force.SetMembraneSpringStiffness(101);
			force.SetMembranePreferredRadius(0.2);
			force.SetEpithelialPreferredRadius(0.9); // Epithelial is the differentiated "filler" cells
			force.SetAdhesionForceLawParameter(2.0);
			force.SetWeakeningFraction(0.5);

			// Serialize via pointer to most abstract class possible
			AbstractForce<2>* const p_force = &force;

			output_arch << p_force;
		}

		{
			AbstractForce<2>* p_force;

			// Create an input archive
			std::ifstream ifs(archive_filename.c_str(), std::ios::binary);
			boost::archive::text_iarchive input_arch(ifs);

			// Restore from the archive
			input_arch >> p_force;
			NormalAdhesionForceNewPhaseModel<2>* p_nforce = static_cast<NormalAdhesionForceNewPhaseModel<2>*>(p_force);
			// Check member variables have been correctly archived
			TS_ASSERT_DELTA(p_nforce->mMembraneEpithelialSpringStiffness, 101, 1e-6);
			TS_ASSERT_DELTA(p_nforce->mMembranePreferredRadius, 0.2, 1e-6);
			TS_ASSERT_DELTA(p_nforce->mEpithelialPreferredRadius, 0.9, 1e-6);
			TS_ASSERT_DELTA(p_nforce->mAdhesionForceLawParameter, 2.0, 1e-6);
			TS_ASSERT_DELTA(p_nforce->mWeakeningFraction, 0.5, 1e-6);

			// Tidy up
			delete p_force;
		}
	}

	void TestArchiveBasicNonLinearSpringForceMultiNodeFix()
	{
		EXIT_IF_PARALLEL;
		OutputFileHandler handler("archive", false);
		std::string archive_filename = handler.GetOutputDirectoryFullPath() + "BasicNonLinearSpringForceMultiNodeFix.arch";

		{
			BasicNonLinearSpringForceMultiNodeFix<2> force;

			std::ofstream ofs(archive_filename.c_str());
			boost::archive::text_oarchive output_arch(ofs);

			force.SetSpringStiffness(101);
			force.SetRestLength(2);
			force.SetCutOffLength(3);
			force.SetAttractionParameter(4);
			force.SetMeinekeSpringStiffness(5);
			force.SetMeinekeDivisionRestingSpringLength(0.6);
			force.SetMeinekeSpringGrowthDuration(7);
			force.SetModifierFraction(0.2);

			// Serialize via pointer to most abstract class possible
			AbstractForce<2>* const p_force = &force;

			output_arch << p_force;
		}

		{
			AbstractForce<2>* p_force;

			// Create an input archive
			std::ifstream ifs(archive_filename.c_str(), std::ios::binary);
			boost::archive::text_iarchive input_arch(ifs);

			// Restore from the archive
			input_arch >> p_force;
			BasicNonLinearSpringForceMultiNodeFix<2>* p_nforce = static_cast<BasicNonLinearSpringForceMultiNodeFix<2>*>(p_force);
			// Check member variables have been correctly archived
			TS_ASSERT_DELTA(p_nforce->mSpringStiffness, 101, 1e-6);
			TS_ASSERT_DELTA(p_nforce->mRestLength, 2, 1e-6);
			TS_ASSERT_DELTA(p_nforce->mCutOffLength, 3, 1e-6);
			TS_ASSERT_DELTA(p_nforce->mAttractionParameter, 4, 1e-6);
			TS_ASSERT_DELTA(p_nforce->mMeinekeSpringStiffness, 5, 1e-6);
			TS_ASSERT_DELTA(p_nforce->mMeinekeDivisionRestingSpringLength,0.6, 1e-6);
			TS_ASSERT_DELTA(p_nforce->mMeinekeSpringGrowthDuration, 7, 1e-6);
			TS_ASSERT_DELTA(p_nforce->mModifierFraction, 0.2, 1e-6);

			// Tidy up
			delete p_force;
		}
	}

	void TestArchiveNoCellCycleModelPhase()
    {
        OutputFileHandler handler("archive", false);
        std::string archive_filename = handler.GetOutputDirectoryFullPath() + "NoCellCycleModelPhase.arch";

        {
            // We must set up SimulationTime to avoid memory leaks
            SimulationTime::Instance()->SetEndTimeAndNumberOfTimeSteps(1.0, 1);

            // As usual, we archive via a pointer to the most abstract class possible
            AbstractCellCycleModel* const p_model = new NoCellCycleModelPhase;

            p_model->SetDimension(2);
            p_model->SetBirthTime(-1.0);

            std::ofstream ofs(archive_filename.c_str());
            boost::archive::text_oarchive output_arch(ofs);

            output_arch << p_model;

            delete p_model;
            SimulationTime::Destroy();
        }

        {
            // We must set SimulationTime::mStartTime here to avoid tripping an assertion
            SimulationTime::Instance()->SetStartTime(0.0);

            AbstractCellCycleModel* p_model2;

            std::ifstream ifs(archive_filename.c_str(), std::ios::binary);
            boost::archive::text_iarchive input_arch(ifs);

            input_arch >> p_model2;

            // Check private data has been restored correctly
            TS_ASSERT_DELTA(p_model2->GetBirthTime(), -1.0, 1e-12);
            TS_ASSERT_DELTA(p_model2->GetAge(), 1.0, 1e-12);
            TS_ASSERT_EQUALS(p_model2->GetDimension(), 2u);
            TS_ASSERT_EQUALS(p_model2->ReadyToDivide(), false);

            // Avoid memory leaks
            delete p_model2;
        }
    }


    void TestArchiveSimplifiedPhaseBasedCellCycleModel()
    {
        OutputFileHandler handler("archive", false);
        std::string archive_filename = handler.GetOutputDirectoryFullPath() + "SimplifiedPhaseBasedCellCycleModel.arch";

        {
            // We must set up SimulationTime to avoid memory leaks
            SimulationTime::Instance()->SetEndTimeAndNumberOfTimeSteps(1.0, 1);
            // The RNG will produce random P phase lengths, so seed it to a fixed values
            // to get a deterministic P phase length
            RandomNumberGenerator::Instance()->Reseed(10);

            // As usual, we archive via a pointer to the most abstract class possible
            SimplifiedPhaseBasedCellCycleModel* const p_model = new SimplifiedPhaseBasedCellCycleModel();


            p_model->SetDimension(1);
            p_model->SetBirthTime(-1.5);

            p_model->SetWDuration(5);
			p_model->SetBasePDuration(5);
			p_model->SetDimension(2);
			p_model->SetEquilibriumVolume(0.7);
			p_model->SetQuiescentVolumeFraction(0.6);
			p_model->SetWntThreshold(0.5);
			p_model->SetBirthTime(2.5);
			p_model->SetPopUpDivision(true);
			p_model->SetMinimumPDuration(2);

			MAKE_PTR(TransitCellProliferativeType, p_trans_type);
			MAKE_PTR(WildTypeCellMutationState, p_state);

			CellPtr p_cell(new Cell(p_state, p_model));
			p_cell->SetCellProliferativeType(p_trans_type);
			p_cell->InitialiseCellCycleModel();

			TS_ASSERT_DELTA(p_model->GetPDuration(), 6.16196, 1e-5);

			TRACE("-H")
            std::ofstream ofs(archive_filename.c_str());
            boost::archive::text_oarchive output_arch(ofs);
            TRACE("-G")
            output_arch << dynamic_cast<AbstractCellCycleModel*>(p_model);
            TRACE("-F")
            p_cell->~Cell();
            // delete p_model;
            TRACE("-E")
            SimulationTime::Destroy();
            RandomNumberGenerator::Destroy();
            WntConcentration<2>::Destroy();
            TRACE("-D")
        }
        TRACE("-C")
        {
            // We must set SimulationTime::mStartTime here to avoid tripping an assertion
            TRACE("-B")
            SimulationTime::Instance()->SetStartTime(0.0);
            TRACE("-A")
            AbstractCellCycleModel* p_model2;
            TRACE("A")
            std::ifstream ifs(archive_filename.c_str(), std::ios::binary);
            boost::archive::text_iarchive input_arch(ifs);
            TRACE("B")
            input_arch >> p_model2;
            TRACE("C")
            TS_ASSERT_EQUALS(p_model2->GetDimension(), 1u);
            TS_ASSERT_DELTA(p_model2->GetBirthTime(), -1.5, 1e-12);
            TS_ASSERT_DELTA(p_model2->GetAge(), 1.5, 1e-12);
            TRACE("D")
            TS_ASSERT_EQUALS(static_cast<AbstractPhaseBasedCellCycleModel*>(p_model2)->GetCurrentCellCyclePhase(), M_PHASE);
            TS_ASSERT_DELTA(static_cast<SimplifiedPhaseBasedCellCycleModel*>(p_model2)->GetQuiescentVolumeFraction(), 0.5, 1e-6);
            TS_ASSERT_DELTA(static_cast<SimplifiedPhaseBasedCellCycleModel*>(p_model2)->GetEquilibriumVolume(), 1.0, 1e-6);

            // Avoid memory leaks
            delete p_model2;
        }
    }

};

#endif /*TestArchivingSrc_HPP_*/
