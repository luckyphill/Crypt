    
#ifndef TestPhaseLabellingIndex_HPP_
#define TestPhaseLabellingIndex_HPP_


#include <cxxtest/TestSuite.h>

// Must be included before any other cell_based headers
#include "CellBasedSimulationArchiver.hpp"

#include "SmartPointers.hpp"

#include "CylindricalHoneycombMeshGenerator.hpp"
#include "Cylindrical2dNodesOnlyMesh.hpp"

#include "CellsGenerator.hpp"

#include "SimpleWntContactInhibitionCellCycleModel.hpp"
#include "WntConcentration.hpp"

#include "MeshBasedCellPopulationWithGhostNodes.hpp"

#include "CellProliferativeTypesCountWriter.hpp"
#include "CellIdWriter.hpp"
#include "CellVolumesWriter.hpp"
#include "CellAncestorWriter.hpp"

#include "OffLatticeSimulation.hpp"

#include "RepulsionForce.hpp"

#include "SimpleTargetAreaModifier.hpp"
#include "VolumeTrackingModifier.hpp"

#include "PlaneBasedCellKiller.hpp"

#include "PlaneBoundaryCondition.hpp"

#include "CryptStatistics.hpp"

#include "AbstractCellBasedWithTimingsTestSuite.hpp"
#include "PetscSetupAndFinalize.hpp"
#include "Warnings.hpp"
#include "Debug.hpp"

/*
 *  This is where you can set parameters toi be used in all the simulations.
 */

static const double M_END_STEADY_STATE = 200; //100
static const double M_END_TIME = 1100; //1100
static const double M_CRYPT_DIAMETER = 16;
static const double M_CRYPT_LENGTH = 12;
static const double M_CONTACT_INHIBITION_LEVEL = 0.8;

class TestPhaseLabellingIndex : public AbstractCellBasedWithTimingsTestSuite
{
    private:


    void GenerateCells(unsigned num_cells, std::vector<CellPtr>& rCells, double equilibriumVolume, double quiescentVolumeFraction, double s_length)
    {
        double typical_cell_cycle_duration = 7.0 + s_length;
        double sDuration = s_length;//1.0; //Normally 5.0, Same length as M phase for test  

        boost::shared_ptr<AbstractCellProperty> p_state(CellPropertyRegistry::Instance()->Get<WildTypeCellMutationState>());
        boost::shared_ptr<AbstractCellProperty> p_cell_type(CellPropertyRegistry::Instance()->Get<TransitCellProliferativeType>());

        for (unsigned i=0; i<num_cells; i++)
        {
            SimpleWntContactInhibitionCellCycleModel* p_model = new SimpleWntContactInhibitionCellCycleModel();
            p_model->SetDimension(2);
            p_model->SetEquilibriumVolume(equilibriumVolume);
            p_model->SetQuiescentVolumeFraction(quiescentVolumeFraction);
            p_model->SetWntThreshold(0.5);
            p_model->SetSDuration(sDuration);


            CellPtr p_cell(new Cell(p_state, p_model));
            p_cell->SetCellProliferativeType(p_cell_type);
            double birth_time = - RandomNumberGenerator::Instance()->ranf() * typical_cell_cycle_duration;
            p_cell->SetBirthTime(birth_time);

            rCells.push_back(p_cell);
        }
    }

    public:


    void TestMeshBasedCrypt() throw (Exception)
    {

        // Seed the RNG
        double run_number = 1; // For the parameter sweep, must keep track of the run number for saving the output file
        if(CommandLineArguments::Instance()->OptionExists("-run"))
        {   
            run_number = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-run");

        }

        double s_length = 5; // default length of S Phase
        if(CommandLineArguments::Instance()->OptionExists("-S"))
        {   
            s_length = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-S");

        }

        double end_time = 200;
        if(CommandLineArguments::Instance()->OptionExists("-t"))
        {   
            end_time = CommandLineArguments::Instance()->GetUnsignedCorrespondingToOption("-t");

        }

        bool java_visualiser = false;
        double sampling_multiple = 100000;
        if(CommandLineArguments::Instance()->OptionExists("-sm"))
        {   
            sampling_multiple = CommandLineArguments::Instance()->GetDoubleCorrespondingToOption("-sm");
            java_visualiser = true;

        }
        PRINT_VARIABLE(run_number)
        PRINT_VARIABLE(s_length)
        PRINT_VARIABLE(end_time)
        PRINT_VARIABLE(sampling_multiple)
        PRINT_VARIABLE(java_visualiser)
        
        RandomNumberGenerator::Instance()->Reseed(run_number);
        

        // Create mesh
        unsigned thickness_of_ghost_layer = 2;

        CylindricalHoneycombMeshGenerator generator(M_CRYPT_DIAMETER, M_CRYPT_LENGTH, thickness_of_ghost_layer);
        Cylindrical2dMesh* p_mesh = generator.GetCylindricalMesh();

        // Get location indices corresponding to real cells
        std::vector<unsigned> location_indices = generator.GetCellLocationIndices();

        // Create cells
        std::vector<CellPtr> cells;
        GenerateCells(location_indices.size(),cells,sqrt(3.0)/2.0,M_CONTACT_INHIBITION_LEVEL, s_length);  //mature_volume = sqrt(3.0)/2.0

        // Create tissue
        MeshBasedCellPopulationWithGhostNodes<2> cell_population(*p_mesh, cells, location_indices);
        cell_population.AddCellPopulationCountWriter<CellProliferativeTypesCountWriter>();
        cell_population.AddCellWriter<CellVolumesWriter>();
        cell_population.AddCellWriter<CellIdWriter>();
        cell_population.AddCellWriter<CellAncestorWriter>();
        

        // Create an instance of a Wnt concentration
        WntConcentration<2>::Instance()->SetType(LINEAR);
        WntConcentration<2>::Instance()->SetCellPopulation(cell_population);
        WntConcentration<2>::Instance()->SetCryptLength(M_CRYPT_LENGTH);

        // Create simulation from cell population
        OffLatticeSimulation<2> simulator(cell_population);
        simulator.SetDt(1.0/200.0);
        simulator.SetEndTime(end_time);
        std::stringstream file_path;
        file_path << "TestPhaseLabellingIndex/s" << s_length << "run" << run_number;
        simulator.SetOutputDirectory(file_path.str());
        simulator.SetOutputDivisionLocations(true);
        simulator.SetOutputCellVelocities(true);

        // ********************************************************************************************
        // File outputs
        // Files are only output if the command line argument -sm exists and a sampling multiple is set
        simulator.SetSamplingTimestepMultiple(sampling_multiple);
        cell_population.SetOutputResultsForChasteVisualizer(java_visualiser);
        // ********************************************************************************************


        // Add volume tracking Modifier
        MAKE_PTR(VolumeTrackingModifier<2>, p_modifier);
        simulator.AddSimulationModifier(p_modifier);

        // Create a force law and pass it to the simulation
        MAKE_PTR(GeneralisedLinearSpringForce<2>, p_linear_force);
        p_linear_force->SetMeinekeSpringStiffness(50.0);
        simulator.AddForce(p_linear_force);

        // Solid base boundary condition
        MAKE_PTR_ARGS(PlaneBoundaryCondition<2>, p_bcs, (&cell_population, zero_vector<double>(2), -unit_vector<double>(2,1)));
        p_bcs->SetUseJiggledNodesOnPlane(true);
        simulator.AddCellPopulationBoundaryCondition(p_bcs);

        // Sloughing killer
        MAKE_PTR_ARGS(PlaneBasedCellKiller<2>, p_killer, (&cell_population, (M_CRYPT_LENGTH-0.5)*unit_vector<double>(2,1), unit_vector<double>(2,1)));
        simulator.AddCellKiller(p_killer);

        // Run simulation
        simulator.Solve();

        // Mark Ancestors
        // simulator.SetEndTime(M_END_TIME);
        // simulator.rGetCellPopulation().SetCellAncestorsToLocationIndices();

        // // Run simulation to new end time
        // simulator.Solve();

        // Clear singletons
        WntConcentration<2>::Instance()->Destroy();


        MeshBasedCellPopulation<2,2>* p_tissue = static_cast<MeshBasedCellPopulation<2,2>*>(&simulator.rGetCellPopulation());

        CryptStatistics stats(*p_tissue);
        double xBottom = RandomNumberGenerator::Instance()->ranf()*(M_CRYPT_DIAMETER/2);
        double xTop = RandomNumberGenerator::Instance()->ranf()*(M_CRYPT_DIAMETER/2);
        PRINT_2_VARIABLES(xBottom,xTop)

        std::vector<CellPtr> section = stats.GetCryptSectionPeriodic(M_CRYPT_LENGTH, xBottom, xTop);

        std::stringstream wholecryptfilename;
        wholecryptfilename << "short_s_data/whole_crypt_s" << s_length << "run_" << run_number << ".txt";
        std::stringstream sphasefilename;
        sphasefilename << "short_s_data/sphase_s" << s_length << "run_" << run_number << ".txt";
        std::stringstream mphasefilename;
        mphasefilename << "short_s_data/mphase_s" << s_length << "run_" << run_number << ".txt";

        ofstream wholecryptfile;
        wholecryptfile.open(wholecryptfilename.str());
        ofstream sphasefile;
        sphasefile.open(sphasefilename.str());
        ofstream mphasefile;
        mphasefile.open(mphasefilename.str());

        sphasefile << xBottom << "," << xTop << "\n";
        mphasefile << xBottom << "," << xTop << "\n";

        for (std::size_t i = 0; i != section.size(); ++i)
        {
            Node<2>* p_node =  p_tissue->GetNodeCorrespondingToCell(section[i]);

            SimpleWntContactInhibitionCellCycleModel* p_ccm = static_cast<SimpleWntContactInhibitionCellCycleModel*>(section[i]->GetCellCycleModel());

            if (p_ccm->GetCurrentCellCyclePhase() == S_PHASE)
            { 
                sphasefile << i << "," << p_node->rGetLocation()[0] << "," << p_node->rGetLocation()[1] <<"\n";
            }

            if (p_ccm->GetCurrentCellCyclePhase() == M_PHASE)
            {
                mphasefile << i << "," << p_node->rGetLocation()[0] << "," << p_node->rGetLocation()[1] << "\n";
            }
            
        }


        // Output all cells
        std::list<CellPtr> pos_cells =  p_tissue->rGetCells();

        for (std::list<CellPtr>::iterator cell_iter = pos_cells.begin(); cell_iter != pos_cells.end(); ++cell_iter)
        {
            Node<2>* p_node =  p_tissue->GetNodeCorrespondingToCell(*cell_iter);
            SimpleWntContactInhibitionCellCycleModel* p_ccm = static_cast<SimpleWntContactInhibitionCellCycleModel*>((*cell_iter)->GetCellCycleModel());
            wholecryptfile << (*cell_iter)->GetCellId() << "," <<  p_ccm->GetCurrentCellCyclePhase()  << "," << p_node->rGetLocation()[0] << "," << p_node->rGetLocation()[1] << "\n";
        }

        sphasefile.close();
        mphasefile.close();
        wholecryptfile.close();


    };

};

#endif /* TestPhaseLabellingIndex_HPP_ */