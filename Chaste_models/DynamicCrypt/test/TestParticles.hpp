#include <cxxtest/TestSuite.h>

#include <boost/archive/text_oarchive.hpp>
#include <boost/archive/text_iarchive.hpp>

#include "ArchiveOpener.hpp"
#include "NodeBasedCellPopulationWithParticles.hpp"
#include "CellsGenerator.hpp"
#include "FixedG1GenerationalCellCycleModel.hpp"
#include "TrianglesMeshReader.hpp"
#include "HoneycombMeshGenerator.hpp"
#include "TetrahedralMesh.hpp"
#include "AbstractCellBasedTestSuite.hpp"
#include "WildTypeCellMutationState.hpp"
#include "CellLabel.hpp"
#include "CellId.hpp"
#include "CellPropertyRegistry.hpp"
#include "SmartPointers.hpp"
#include "FileComparison.hpp"
#include "DifferentiatedCellProliferativeType.hpp"
#include "ApoptoticCellProperty.hpp"

// Cell writers
#include "CellAgesWriter.hpp"
#include "CellAncestorWriter.hpp"
#include "CellVolumesWriter.hpp"
#include "CellProliferativePhasesWriter.hpp"

// Cell population writers
#include "CellPopulationAreaWriter.hpp"
#include "CellMutationStatesCountWriter.hpp"
#include "CellProliferativePhasesCountWriter.hpp"
#include "CellProliferativeTypesCountWriter.hpp"

#include "PetscSetupAndFinalize.hpp"

#include "OffLatticeSimulation.hpp"

class TestParticles : public AbstractCellBasedTestSuite
{
    public:
    void TestWithParticles()
    {

        unsigned num_cells_depth = 11;
        unsigned num_cells_width = 6;
        HoneycombMeshGenerator generator(num_cells_width, num_cells_depth, 2);
        TetrahedralMesh<2,2>* p_generating_mesh = generator.GetMesh();

        // Convert this to a NodesOnlyMesh
        NodesOnlyMesh<2> mesh;
        mesh.ConstructNodesWithoutMesh(*p_generating_mesh, 1.5);

        std::vector<unsigned> location_indices = generator.GetCellLocationIndices();

        // Set up cells
        std::vector<CellPtr> cells;
        CellsGenerator<FixedG1GenerationalCellCycleModel,2> cells_generator;
        cells_generator.GenerateGivenLocationIndices(cells, location_indices);

        // Create a cell population
        NodeBasedCellPopulationWithParticles<2> cell_population(mesh, cells, location_indices);

        // Create a set of node indices corresponding to particles
        std::set<unsigned> node_indices;
        std::set<unsigned> location_indices_set;
        std::set<unsigned> particle_indices;

        for (unsigned i=0; i<mesh.GetNumNodes(); i++)
        {
            node_indices.insert(mesh.GetNode(i)->GetIndex());
        }
        for (unsigned i=0; i<location_indices.size(); i++)
        {
            location_indices_set.insert(location_indices[i]);
        }

        std::set_difference(node_indices.begin(), node_indices.end(),
                            location_indices_set.begin(), location_indices_set.end(),
                            std::inserter(particle_indices, particle_indices.begin()));

        OffLatticeSimulation<2> simulator(cell_population);
        simulator.SetOutputDirectory("WithParticles");
        simulator.SetEndTime(1);
        simulator.SetDt(0.01);
        simulator.SetSamplingTimestepMultiple(1);

        simulator.Solve();


    };

};