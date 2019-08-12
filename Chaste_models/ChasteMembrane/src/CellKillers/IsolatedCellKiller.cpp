/*
 * This finds cell clusters that are not attached to the monolayer and kills them
 */

#include "IsolatedCellKiller.hpp"
#include "AbstractCellKiller.hpp"
#include "AbstractCellProperty.hpp"
#include "MeshBasedCellPopulation.hpp"
#include "NodeBasedCellPopulation.hpp"
#include "AnoikisCellTagged.hpp"
#include "Debug.hpp"




IsolatedCellKiller::IsolatedCellKiller(AbstractCellPopulation<2>* pCellPopulation)
	: AbstractCellKiller<2>(pCellPopulation)
{

}


IsolatedCellKiller::~IsolatedCellKiller()
{

}



void IsolatedCellKiller::CheckAndLabelCellsForApoptosisOrDeath()
{
	
	NodeBasedCellPopulation<2>* p_tissue = static_cast<NodeBasedCellPopulation<2>*> (this->mpCellPopulation);

	// This code may be useful, so don't delete just yet
	// In fact this class doesn't alter it's function if only this code is here, so
	// keep it for the time being in case this brake
	for (typename AbstractCellPopulation<2>::Iterator cell_iter = p_tissue->Begin();
			cell_iter != p_tissue->End();
			++cell_iter)
	{
		unsigned nodeIndex = this->mpCellPopulation->GetLocationIndexUsingCell(*cell_iter);
		// unsigned nodeIndex = p_tissue->GetNodeCorrespondingToCell(cell_iter->GetIndex());
			c_vector<double,2> cell_location = p_tissue->GetNode(nodeIndex)->rGetLocation();

			std::set<unsigned> neighbours;
			double radius = 1.5; // Distance to check for neighbours

			neighbours = p_tissue->GetNodesWithinNeighbourhoodRadius(nodeIndex, radius);

			if( (*cell_iter)->template HasCellProperty<AnoikisCellTagged>() )
			{
				if ( neighbours.empty() )
				{
					cell_iter->Kill();
					mCellKillCount++;
				}
				else
				{
					// Search for a neighbour that is closer to the membrane
					// if one does not exist, then it cannot be attached to the membrane
					c_vector<double,2> n_location;
					bool lower_found = false;
					for (std::set<unsigned>::iterator nit = neighbours.begin(); nit != neighbours.end(); ++nit)
					{
						n_location = p_tissue->GetNode(*nit)->rGetLocation();
						if (n_location[0] < cell_location[0])
						{
							lower_found = true;
							break;
						}
					}

					if (!lower_found)
					{
						cell_iter->Kill();
						mCellKillCount++;
					}

				}

			}


	}
	// std::vector<std::set<unsigned>> looseClusters = FindLooseClusters();

	// for (std::vector<std::set<unsigned>>::iterator it = looseClusters.begin(); it != looseClusters.end(); ++it)
	// {
	// 	std::set<unsigned> cluster = (*it);
	// 	for (std::set<unsigned>::iterator ind = cluster.begin(); ind !=cluster.end(); ++ind)
	// 	{
	// 		// Get the cell from the index, kill the cell
	// 		CellPtr cell = p_tissue->GetCellUsingLocationIndex(*ind);
	// 		cell->Kill();
	// 		mCellKillCount++;
	// 	}
	// }

}


std::vector<std::set<unsigned>> IsolatedCellKiller::FindLooseClusters()
{
	// Loop through the cells and build a list of clusters
	// Then, for each cluster that doesn't contain at least one 
	// monolayer cell, add the cells to the list of cells to be killed
	NodeBasedCellPopulation<2>* p_tissue = static_cast<NodeBasedCellPopulation<2>*> (this->mpCellPopulation);

	std::vector<std::set<unsigned>> regions;

	std::set<unsigned> visited;

	double radius = 1.3; // Distance to check for neighbours

	for (typename AbstractCellPopulation<2>::Iterator cell_iter = p_tissue->Begin();
			cell_iter != p_tissue->End();
			++cell_iter)
	{
		std::set<unsigned> thisRegion;

		bool isLoose = true;       

		unsigned nodeIndex = this->mpCellPopulation->GetLocationIndexUsingCell(*cell_iter);
		
		if (visited.find(nodeIndex) == visited.end())
		{
			visited.insert(nodeIndex);
			thisRegion.insert(nodeIndex);

			// Check if the cell we are looking at is in the monolayer
			// If it is, then change isLoose = false;
			// Even if it is not loose, we still need to complete the algorithm
			// to identify the entire lump and the cells that get to stay
			if (!(*cell_iter)->template HasCellProperty<AnoikisCellTagged>()) 
			{
				isLoose = false;
			}

			std::set<unsigned> neighbours;
			neighbours = p_tissue->GetNodesWithinNeighbourhoodRadius(nodeIndex, radius);

			RecursiveFindClusters(p_tissue, neighbours, &thisRegion, &visited, &isLoose);

			if (isLoose)
			{
				regions.push_back(thisRegion); 
			}
		}
	}

	return regions;
}


void IsolatedCellKiller::RecursiveFindClusters(NodeBasedCellPopulation<2>* p_tissue, std::set<unsigned> neighbours, std::set<unsigned>* thisRegion, std::set<unsigned>* visited, bool* isLoose)
{
	// Loop through each neighbour, and if the neighbour hasn't been visited yet, add it to the region
	double radius = 1.3; // Distance to check for neighbours
	for (std::set<unsigned>::iterator nit = neighbours.begin(); nit != neighbours.end(); ++nit)
	{
		if (visited->find(*nit) == visited->end())
		{
			visited->insert(*nit);
			thisRegion->insert(*nit);

			// Check if the cell we are looking at is in the monolayer
			// If it is, then change isLoose = false;
			// Even if it is not loose, we still need to complete the algorithm
			// to identify the entire lump and the cells that get to stay
			if (!p_tissue->GetCellUsingLocationIndex(*nit)->template HasCellProperty<AnoikisCellTagged>())
			{
				*isLoose = false;
			}

			std::set<unsigned> next_neighbours;
			next_neighbours = p_tissue->GetNodesWithinNeighbourhoodRadius(*nit, radius);
			RecursiveFindClusters(p_tissue, next_neighbours, thisRegion, visited, isLoose);
		}
	}
}
	


unsigned IsolatedCellKiller::GetCellKillCount()
{
	return mCellKillCount;
}


void IsolatedCellKiller::OutputCellKillerParameters(out_stream& rParamsFile)
{
	*rParamsFile << "\t\t\t<CellsRemovedBySloughing>" << 1 << "</CellsRemovedBySloughing> \n";

	// Call direct parent class
	AbstractCellKiller<2>::OutputCellKillerParameters(rParamsFile);
}



#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(IsolatedCellKiller)
