#include <cxxtest/TestSuite.h>
#include "CheckpointArchiveTypes.hpp"
#include "AbstractCellBasedTestSuite.hpp"

#include "CellsGenerator.hpp"
#include "OffLatticeSimulation.hpp"
#include "TransitCellProliferativeType.hpp"
#include "SmartPointers.hpp"

#include "NoCellCycleModel.hpp"
#include "UniformCellCycleModel.hpp"

#include "StromalType.hpp"
#include "StemType.hpp"
#include "EpithelialType.hpp"

#include "FixedVertexBasedDivisionRule.hpp"

#include "AnoikisCellKillerVertex.hpp"

#include "HoneycombVertexMeshGenerator.hpp"
#include "CylindricalHoneycombVertexMeshGenerator.hpp"
#include "VertexBasedCellPopulation.hpp"
#include "NagaiHondaForce.hpp"
#include "SimpleTargetAreaModifier.hpp"
#include "PlaneBoundaryCondition.hpp"
#include "PlaneBasedCellKiller.hpp"

#include "FakePetscSetup.hpp"

#include "Debug.hpp"

class TestEpithelialLayer : public AbstractCellBasedTestSuite
{
public:

    void TestPeriodicMonolayer()
    {

    	unsigned width = 10;
		if(CommandLineArguments::Instance()->OptionExists("-w"))
		{
			width = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-w");
			PRINT_VARIABLE(width)
		}

		unsigned height = 6;
		if(CommandLineArguments::Instance()->OptionExists("-h"))
		{
			height = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-h");
			PRINT_VARIABLE(height)
		}

		double anoikisDistance = 1.5;
		if(CommandLineArguments::Instance()->OptionExists("-ad"))
		{
			anoikisDistance = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-ad");
			PRINT_VARIABLE(anoikisDistance)
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

        CylindricalHoneycombVertexMeshGenerator generator(width, height, true);    // Parameters are: cells across, cells up
        Cylindrical2dVertexMesh* pMesh = generator.GetCylindricalMesh();

        std::vector<CellPtr> cells;

		MAKE_PTR(StromalType, pStromalType);
		MAKE_PTR(StemType, pStemType);
		MAKE_PTR(EpithelialType, pEpithelialType);
		MAKE_PTR(WildTypeCellMutationState, pState);

		unsigned numCells = pMesh->GetNumElements();
		PRINT_VARIABLE(numCells)
		cells.clear();

	    cells.reserve(numCells);

	    // Create cells
	    for (unsigned i=0; i < width * (height - 1); i++)
	    {
	        NoCellCycleModel* pCCM = new NoCellCycleModel;
	        pCCM->SetDimension(2);

	        CellPtr pCell(new Cell(pState, pCCM));
	        pCell->SetCellProliferativeType(pStromalType);
	        pCell->SetBirthTime(-cellCycleTime);

	        cells.push_back(pCell);
	    }

	    for (unsigned i=0; i < width ; i++)
	    {
	        UniformCellCycleModel* pCCM = new UniformCellCycleModel;
	        pCCM->SetDimension(2);

	        CellPtr pCell(new Cell(pState, pCCM));
	        pCell->SetCellProliferativeType(pEpithelialType);


	        double birth = -cellCycleTime*RandomNumberGenerator::Instance()->ranf();

	        pCell->SetBirthTime(birth);
	        cells.push_back(pCell);
	    }
	    PRINT_VARIABLE(cells.size())

        VertexBasedCellPopulation<2> cellPopulation(*pMesh, cells);

        c_vector<double,2> point = zero_vector<double>(2);
        c_vector<double,2> normal = zero_vector<double>(2);
        normal(1) = 1.0;

        MAKE_PTR_ARGS(FixedVertexBasedDivisionRule<2>, pDivision, (normal));
        cellPopulation.SetVertexBasedDivisionRule(pDivision);

        OffLatticeSimulation<2> simulator(cellPopulation);
        simulator.SetOutputDirectory("VertexBasedPeriodicMonolayer");
        simulator.SetEndTime(simulation_length);
		simulator.SetDt(dt);
		simulator.SetSamplingTimestepMultiple(sampling_multiple);

        MAKE_PTR(NagaiHondaForce<2>, p_force);
        simulator.AddForce(p_force);

        MAKE_PTR(SimpleTargetAreaModifier<2>, p_growth_modifier);
        p_growth_modifier->SetGrowthDuration(cellCycleTime * 0.5);
        simulator.AddSimulationModifier(p_growth_modifier);

        normal(1) = -1.0;
        MAKE_PTR_ARGS(PlaneBoundaryCondition<2>, p_bc, (&cellPopulation, point, normal));
        simulator.AddCellPopulationBoundaryCondition(p_bc);


        MAKE_PTR_ARGS(AnoikisCellKillerVertex<2>, pAnoikis, (&cellPopulation));
        simulator.AddCellKiller(pAnoikis);



        simulator.Solve();


    }
};