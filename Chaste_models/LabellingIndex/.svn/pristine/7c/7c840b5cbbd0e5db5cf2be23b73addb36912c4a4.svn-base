#ifndef TESTDELTANOTCHLITERATEPAPER_HPP_
#define TESTDELTANOTCHLITERATEPAPER_HPP_


/*
 * = Short-range Signalling Example =
 *
 * On this wiki page we describe in detail the code that is used to run this example from the paper.
 *
 * The easiest way to visualize these simulations is with Paraview.
 * 
 * [[EmbedYoutube(SX2GFOr0Dus)]]
 *
 * == Code overview ==
 *
 * The first thing to do is to include the necessary header files.
 */

#include <cxxtest/TestSuite.h>

// Must be included before other cell_based headers
#include "CellBasedSimulationArchiver.hpp"

#include "AbstractCellBasedWithTimingsTestSuite.hpp"
#include "CellLabel.hpp"
#include "SmartPointers.hpp"
#include "CellsGenerator.hpp"
#include "BernoulliTrialCellCycleModel.hpp"
#include "DeltaNotchSrnModel.hpp"

#include "WildTypeCellMutationState.hpp"
#include "DifferentiatedCellProliferativeType.hpp"
#include "RadialSloughingCellKiller.hpp"
#include "RadialDifferentiationModifier.hpp"

#include "OffLatticeSimulation.hpp"
#include "VertexBasedCellPopulation.hpp"
#include "HoneycombVertexMeshGenerator.hpp"
#include "NagaiHondaDifferentialAdhesionForce.hpp"
#include "SimpleTargetAreaModifier.hpp"

#include "MeshBasedCellPopulationWithGhostNodes.hpp"
#include "HoneycombMeshGenerator.hpp"
#include "DiffusionForce.hpp"
#include "RepulsionForce.hpp"
#include "GeneralisedLinearSpringForce.hpp"

#include "OnLatticeSimulation.hpp"
#include "DeltaNotchTrackingModifier.hpp"
#include "PottsBasedCellPopulation.hpp"
#include "PottsMeshGenerator.hpp"
#include "VolumeConstraintPottsUpdateRule.hpp"

#include "AdhesionPottsUpdateRule.hpp"
#include "SurfaceAreaConstraintPottsUpdateRule.hpp"

#include "ShovingCaBasedDivisionRule.hpp"

#include "CellDeltaNotchWriter.hpp"
#include "CellIdWriter.hpp"
#include "CellAgesWriter.hpp"
#include "CellMutationStatesWriter.hpp"
#include "VoronoiDataWriter.hpp"
#include "CellVolumesWriter.hpp"

#include "PetscSetupAndFinalize.hpp"

/*
 *  This is where you can set parameters to be used in all the simulations.
 */

static const double M_TIME_FOR_SIMULATION = 1000; //100
static const double M_TISSUE_RADIUS = 15; // 15
static const double M_PROLIF_RADIUS = 5; // 5
static const double M_DIVISION_PROBABILITY = 0.1; // 0.1

class TestDeltaNotchLiteratePaper: public AbstractCellBasedWithTimingsTestSuite
{
private:


    /*
     * This is a helper method to generate cells and is used in all simulations.
     */ 
    void GenerateCells(unsigned num_cells, std::vector<CellPtr>& rCells, double divisionProbability)
    {
        boost::shared_ptr<AbstractCellProperty> p_state(CellPropertyRegistry::Instance()->Get<WildTypeCellMutationState>());
        boost::shared_ptr<AbstractCellProperty> p_prolif_type(CellPropertyRegistry::Instance()->Get<TransitCellProliferativeType>());

        for (unsigned i=0; i<num_cells; i++)
        {
            std::vector<double> initial_conditions;
            initial_conditions.push_back(RandomNumberGenerator::Instance()->ranf());
            initial_conditions.push_back(RandomNumberGenerator::Instance()->ranf());

            BernoulliTrialCellCycleModel* p_cc_model = new BernoulliTrialCellCycleModel();
            p_cc_model->SetDimension(2);
            p_cc_model->SetDivisionProbability(divisionProbability);

            DeltaNotchSrnModel* p_srn_model = new DeltaNotchSrnModel();
            p_srn_model->SetInitialConditions(initial_conditions);

            CellPtr p_cell(new Cell(p_state, p_cc_model, p_srn_model));
            p_cell->SetCellProliferativeType(p_prolif_type);

            double birth_time = 0.0;
            p_cell->SetBirthTime(birth_time);

            p_cell->GetCellData()->SetItem("target area", 1.0);
            rCells.push_back(p_cell);
        }
    }

public:

    /*
     * == CA ==
     *
     * Simulate juxtacrine signalling in a population of cells in the
     * Cellular Automaton model.
     */
   void TestCaBasedDeltaNotch() throw (Exception)
   {
        // Create a simple 2D PottsMesh
        unsigned domain_wide = 3*M_TISSUE_RADIUS;
        PottsMeshGenerator<2> generator(domain_wide, 0, 0, domain_wide, 0, 0);
        PottsMesh<2>* p_mesh = generator.GetMesh();

        p_mesh->Translate(-(double)domain_wide*0.5 + 0.5,-(double)domain_wide*0.5 + 0.5);

        // Specify where cells lie
        std::vector<unsigned> location_indices;
        for (unsigned i=0; i<domain_wide; i++)
        {
          for (unsigned j=0; j<domain_wide; j++)
          {
              location_indices.push_back(j + i * domain_wide );
          }
        }

        // Create cells
        std::vector<CellPtr> cells;
        GenerateCells(location_indices.size(),cells,M_DIVISION_PROBABILITY);

        // Create cell population
        CaBasedCellPopulation<2> cell_population(*p_mesh, cells, location_indices);

        // Set population to output all data to results files
        cell_population.AddCellWriter<CellIdWriter>();
        cell_population.AddCellWriter<CellAgesWriter>();
        cell_population.AddCellWriter<CellMutationStatesWriter>();
        cell_population.AddCellWriter<CellDeltaNotchWriter>();

        OnLatticeSimulation<2> simulator(cell_population);
        simulator.SetOutputDirectory("DeltaNotch/Ca");
        simulator.SetOutputDivisionLocations(true);

        simulator.SetDt(0.01);
        simulator.SetSamplingTimestepMultiple(100);
        simulator.SetEndTime(M_TIME_FOR_SIMULATION);

        // Add Division Rule
        boost::shared_ptr<AbstractCaBasedDivisionRule<2> > p_division_rule(new ShovingCaBasedDivisionRule<2>());
        cell_population.SetCaBasedDivisionRule(p_division_rule);

        // Add DeltaNotch modifier
        MAKE_PTR(DeltaNotchTrackingModifier<2>, p_modifier);
        simulator.AddSimulationModifier(p_modifier);


        // Add RadialDifferentiationModifier modifier
        MAKE_PTR(RadialDifferentiationModifier<2>, p_differentiation_modifier);
        p_differentiation_modifier->SetRadius(M_PROLIF_RADIUS);
        simulator.AddSimulationModifier(p_differentiation_modifier);

        // Add a cell killer
        MAKE_PTR_ARGS(RadialSloughingCellKiller, p_killer, (&cell_population, zero_vector<double>(2), M_TISSUE_RADIUS));
        simulator.AddCellKiller(p_killer);

        simulator.Solve();
    }

    /*
     * == CP ==
     *
     * Simulate juxtacrine signalling in a population of cells in the
     * Cellular Potts model.
     */
    void TestPottsBasedDeltaNotch() throw (Exception)
    {
        // Create a simple 2D PottsMesh
        unsigned element_size = 4;
        unsigned domain_size = (unsigned) (2.5*M_TISSUE_RADIUS * element_size); // larger than the circle.
        PottsMeshGenerator<2> generator(domain_size, 2*M_TISSUE_RADIUS, element_size, domain_size, 2*M_TISSUE_RADIUS, element_size);
        PottsMesh<2>* p_mesh = generator.GetMesh();
        p_mesh->Translate(-0.5*(double)domain_size,-0.5*(double)domain_size);

        // Create cells
        std::vector<CellPtr> cells;
        GenerateCells(p_mesh->GetNumElements(),cells,M_DIVISION_PROBABILITY);

        // Create cell population
        PottsBasedCellPopulation<2> cell_population(*p_mesh, cells);
        cell_population.AddCellWriter<CellIdWriter>();
        cell_population.AddCellWriter<CellAgesWriter>();
        cell_population.AddCellWriter<CellDeltaNotchWriter>();
        cell_population.SetNumSweepsPerTimestep(1);

        // Set the Temperature
        cell_population.SetTemperature(0.1); //Default is 0.1

        // Set up cell-based simulation
        OnLatticeSimulation<2> simulator(cell_population);
        simulator.SetOutputDirectory("DeltaNotch/Potts");
        simulator.SetOutputDivisionLocations(true);

        // Set time step and end time for simulation
        simulator.SetDt(0.01); // This is the default value
        simulator.SetSamplingTimestepMultiple(100);
        simulator.SetEndTime(M_TIME_FOR_SIMULATION);

        // Add DeltaNotch modifier
        MAKE_PTR(DeltaNotchTrackingModifier<2>, p_modifier);
        simulator.AddSimulationModifier(p_modifier);

        // Add RadialDifferentiationModifier modifier
        MAKE_PTR(RadialDifferentiationModifier<2>, p_differentiation_modifier);
        p_differentiation_modifier->SetRadius(element_size*M_PROLIF_RADIUS);
        simulator.AddSimulationModifier(p_differentiation_modifier);


        // Create update rules and pass to the simulation
        MAKE_PTR(VolumeConstraintPottsUpdateRule<2>, p_volume_constraint_update_rule);
        p_volume_constraint_update_rule->SetMatureCellTargetVolume(16); // i.e 4x4 cells
        p_volume_constraint_update_rule->SetDeformationEnergyParameter(0.1);
        simulator.AddUpdateRule(p_volume_constraint_update_rule);

        MAKE_PTR(SurfaceAreaConstraintPottsUpdateRule<2>, p_surface_constraint_update_rule);
        p_surface_constraint_update_rule->SetMatureCellTargetSurfaceArea(16); // i.e 4x4 cells
        p_surface_constraint_update_rule->SetDeformationEnergyParameter(0.01);
        simulator.AddUpdateRule(p_surface_constraint_update_rule);

        MAKE_PTR(AdhesionPottsUpdateRule<2>, p_adhesion_update_rule);
        p_adhesion_update_rule->SetCellCellAdhesionEnergyParameter(0.1);
        p_adhesion_update_rule->SetCellBoundaryAdhesionEnergyParameter(0.2);
        simulator.AddUpdateRule(p_adhesion_update_rule);

        // Add a cell killer
        MAKE_PTR_ARGS(RadialSloughingCellKiller, p_killer, (&cell_population, zero_vector<double>(2), element_size*M_TISSUE_RADIUS));
        simulator.AddCellKiller(p_killer);

        // Run simulation
        simulator.Solve();
    }

    /*
     * == OS ==
     *
     * Simulate juxtacrine signalling in a population of cells in the
     * Overlapping Spheres model.
     */
    void TestNodeBasedDeltaNotch() throw (Exception)
    {

        // Create a simple mesh
        unsigned num_ghosts = 0;
        HoneycombMeshGenerator generator(2*M_TISSUE_RADIUS, 2.5*M_TISSUE_RADIUS, num_ghosts);
        MutableMesh<2,2>* p_generating_mesh = generator.GetMesh();
        p_generating_mesh->Translate(-M_TISSUE_RADIUS,-M_TISSUE_RADIUS);

        double cut_off_length = 1.0;

        // Convert this to a NodesOnlyMesh
        NodesOnlyMesh<2> mesh;
        mesh.ConstructNodesWithoutMesh(*p_generating_mesh, cut_off_length);

        // Set up cells, one for each Node
        std::vector<CellPtr> cells;
        GenerateCells(mesh.GetNumNodes(),cells,M_DIVISION_PROBABILITY);

        // Create cell population
        NodeBasedCellPopulation<2> cell_population(mesh, cells);

        // Set population to output all data to results files
        cell_population.AddCellWriter<CellIdWriter>();
        cell_population.AddCellWriter<CellAgesWriter>();
        cell_population.AddCellWriter<CellDeltaNotchWriter>();

        // Set up cell-based simulation and output directory
        OffLatticeSimulation<2> simulator(cell_population);
        simulator.SetOutputDirectory("DeltaNotch/Node");
        simulator.SetOutputDivisionLocations(true);

        // Set time step and end time for simulation
        simulator.SetDt(1.0/200.0);
        simulator.SetSamplingTimestepMultiple(200);
        simulator.SetEndTime(M_TIME_FOR_SIMULATION);

        // Add DeltaNotch modifier
        MAKE_PTR(DeltaNotchTrackingModifier<2>, p_modifier);
        simulator.AddSimulationModifier(p_modifier);

        // Add RadialDifferentiationModifier modifier
        MAKE_PTR(RadialDifferentiationModifier<2>, p_differentiation_modifier);
        p_differentiation_modifier->SetRadius(M_PROLIF_RADIUS);
        simulator.AddSimulationModifier(p_differentiation_modifier);

        // Create a force law and pass it to the simulation
        MAKE_PTR(GeneralisedLinearSpringForce<2>, p_linear_force);
        p_linear_force->SetMeinekeSpringStiffness(50.0);
        p_linear_force->SetCutOffLength(cut_off_length);
        simulator.AddForce(p_linear_force);

        // Add a cell killer
        MAKE_PTR_ARGS(RadialSloughingCellKiller, p_killer, (&cell_population, zero_vector<double>(2), M_TISSUE_RADIUS));
        simulator.AddCellKiller(p_killer);

        // Run simulation
        simulator.Solve();
   }


    /*
     * == VT ==
     *
     * Simulate juxtacrine signalling in a population of cells in the
     * Voronoi Tesselation model.
     */
    void TestMeshBasedDeltaNotch() throw (Exception)
    {
        // Create a simple mesh
        unsigned num_ghosts = 0;
        HoneycombMeshGenerator generator(2*M_TISSUE_RADIUS, 2.5*M_TISSUE_RADIUS, num_ghosts);
        MutableMesh<2,2>* p_mesh = generator.GetMesh();
        p_mesh->Translate(-M_TISSUE_RADIUS,-M_TISSUE_RADIUS);

        // Set up cells, one for each non ghost Node
        std::vector<unsigned> location_indices = generator.GetCellLocationIndices();//**Changed**//
        std::vector<CellPtr> cells;
        GenerateCells(location_indices.size(),cells,M_DIVISION_PROBABILITY);

        // Create cell population
        MeshBasedCellPopulationWithGhostNodes<2> cell_population(*p_mesh, cells, location_indices);

        // Set population to output all data to results files
        cell_population.AddCellWriter<CellIdWriter>();
        cell_population.AddCellWriter<CellAgesWriter>();
        cell_population.AddCellWriter<CellDeltaNotchWriter>();

        cell_population.SetWriteVtkAsPoints(false);
        cell_population.AddPopulationWriter<VoronoiDataWriter>();

        // Set up cell-based simulation and output directory
        OffLatticeSimulation<2> simulator(cell_population);
        simulator.SetOutputDirectory("DeltaNotch/Mesh");
        simulator.SetOutputDivisionLocations(true);

        // Set time step and end time for simulation
        simulator.SetDt(1.0/200.0);
        simulator.SetSamplingTimestepMultiple(200);
        simulator.SetEndTime(M_TIME_FOR_SIMULATION);

        // Add DeltaNotch modifier
        MAKE_PTR(DeltaNotchTrackingModifier<2>, p_modifier);
        simulator.AddSimulationModifier(p_modifier);

        // Add RadialDifferentiationModifier modifier
        MAKE_PTR(RadialDifferentiationModifier<2>, p_differentiation_modifier);
        p_differentiation_modifier->SetRadius(M_PROLIF_RADIUS);
        simulator.AddSimulationModifier(p_differentiation_modifier);

        // Create a force law and pass it to the simulation
        MAKE_PTR(GeneralisedLinearSpringForce<2>, p_linear_force);
        p_linear_force->SetMeinekeSpringStiffness(50.0);
        p_linear_force->SetCutOffLength(1.5);
        simulator.AddForce(p_linear_force);

        // Add a cell killer
        MAKE_PTR_ARGS(RadialSloughingCellKiller, p_killer, (&cell_population, zero_vector<double>(2), M_TISSUE_RADIUS));
        simulator.AddCellKiller(p_killer);

          // Run simulation
        simulator.Solve();
    }

    /*
     * == VM ==
     *
     * Simulate juxtacrine signalling in a population of cells
     * Cell Vertex model.
     */
    void TestVertexBasedDeltaNotch() throw (Exception)
    {
        // Create a simple 2D MutableVertexMesh
        HoneycombVertexMeshGenerator generator(2*M_TISSUE_RADIUS,2.5*M_TISSUE_RADIUS);
        MutableVertexMesh<2,2>* p_mesh = generator.GetMesh();
        p_mesh->SetCellRearrangementThreshold(0.1);
        p_mesh->Translate(-M_TISSUE_RADIUS,-M_TISSUE_RADIUS);

        // Slows things down but can use a larger timestep and diffusion forces.
        //p_mesh->SetCheckForInternalIntersections(true);

        // Associate each cell with a cell-cycle model that incorporates a Delta-Notch ODE system
        std::vector<CellPtr> cells;
        GenerateCells(p_mesh->GetNumElements(),cells,M_DIVISION_PROBABILITY);

        // Create cell population
        VertexBasedCellPopulation<2> cell_population(*p_mesh, cells);

        // Set population to output all data to results files
        cell_population.AddCellWriter<CellIdWriter>();
        cell_population.AddCellWriter<CellAgesWriter>();
        cell_population.AddCellWriter<CellDeltaNotchWriter>();

        // Set up cell-based simulation and output directory
        OffLatticeSimulation<2> simulator(cell_population);
        simulator.SetOutputDirectory("DeltaNotch/Vertex");
        simulator.SetOutputDivisionLocations(true);

        // Set time step and end time for simulation
        simulator.SetDt(1.0/200.0);
        simulator.SetSamplingTimestepMultiple(200);
        simulator.SetEndTime(M_TIME_FOR_SIMULATION);

        // Add DeltaNotch modifier
        MAKE_PTR(DeltaNotchTrackingModifier<2>, p_modifier);
        simulator.AddSimulationModifier(p_modifier);

        // Add RadialDifferentiationModifier modifier
        MAKE_PTR(RadialDifferentiationModifier<2>, p_differentiation_modifier);
        p_differentiation_modifier->SetRadius(M_PROLIF_RADIUS);
        simulator.AddSimulationModifier(p_differentiation_modifier);


        // Create Forces and pass to simulation NOTE : these are not the default ones and chosen to give a stable growing monolayer
        MAKE_PTR(NagaiHondaForce<2>, p_force);
        p_force->SetNagaiHondaDeformationEnergyParameter(50.0);
        p_force->SetNagaiHondaMembraneSurfaceEnergyParameter(1.0);
        p_force->SetNagaiHondaCellCellAdhesionEnergyParameter(1.0);
        p_force->SetNagaiHondaCellBoundaryAdhesionEnergyParameter(10.0);
        simulator.AddForce(p_force);

        // Add a cell killer
        MAKE_PTR_ARGS(RadialSloughingCellKiller, p_killer, (&cell_population, zero_vector<double>(2), M_TISSUE_RADIUS));
        simulator.AddCellKiller(p_killer);

        // Run simulation
        simulator.Solve();
   }
};

#endif /* TESTDELTANOTCHLITERATEPAPER_HPP_ */
