#include "MembraneInternalForce.hpp"
#include "AbstractCellProperty.hpp"
#include "MembraneType.hpp"
#include "StemType.hpp"
#include "Debug.hpp"

#include "MutableMesh.hpp"

/*
 * Created by: PHILLIP BROWN, 27/10/2017
 * Initial Structure borrows heavily from "EpithelialLayerBasementMembraneForce.cpp"
 * as found in the Chaste Paper Tutorials for the CryptFissionPlos2016 project
 */

/**
 * To avoid warnings on some compilers, C++ style initialization of member
 * variables should be done in the order they are defined in the header file.
 */
MembraneInternalForce::MembraneInternalForce()
   :  AbstractForce<2>(),
   mMembraneStiffness(50)
{
}

MembraneInternalForce::MembraneInternalForce(std::vector<std::vector<CellPtr>> membraneSections)
   :  AbstractForce<2>(),
   mMembraneStiffness(50),
   mMembraneSections(membraneSections)
{
}

MembraneInternalForce::MembraneInternalForce(std::vector<std::vector<CellPtr>> membraneSections, bool isPeriodic)
   :  AbstractForce<2>(),
   mIsPeriodic(isPeriodic),
   mMembraneSections(membraneSections)
   
   
{
	if (mIsPeriodic)
	{
		// If the simulation is periodic and the membrane loops around
		// left to right, then the membrane section must be connected
		// Need to add the forst two elements to the end in order for
		// the curvature force to work properly
		for (std::vector<std::vector<CellPtr>>::iterator iter = mMembraneSections.begin(); iter != mMembraneSections.end(); ++iter)
		{
			std::vector<CellPtr> membraneCells = *iter;
			if (membraneCells[1] != (*iter).back())
			{
				(*iter).push_back(membraneCells[0]);
				(*iter).push_back(membraneCells[1]);
			}
		}
	}
}

MembraneInternalForce::~MembraneInternalForce()
{

}

void MembraneInternalForce::SetMembraneStiffness(double membraneStiffness)
{
	mMembraneStiffness = membraneStiffness;
}

void MembraneInternalForce::SetMembraneRestoringRate(double membraneRestoringRate)
{
	mMembraneRestoringRate = membraneRestoringRate;
}

void MembraneInternalForce::SetTargetCurvatureStem(double targetCurvatureStem)
{
	mTargetCurvatureStem = targetCurvatureStem;
}

void MembraneInternalForce::SetExternalStiffness(double externalStiffness)
{
	mExternalStiffness = externalStiffness;
}

void MembraneInternalForce::SetIsPeriodic(bool isPeriodic)
{
	mIsPeriodic = isPeriodic;
}


//Method overriding the virtual method for AbstractForce. The crux of what really needs to be done.
void MembraneInternalForce::AddForceContribution(AbstractCellPopulation<2>& rCellPopulation)
{

	AddTensionForceContribution(rCellPopulation);

	AddExternalForceContribution(rCellPopulation);

	AddCurvatureForceContribution(rCellPopulation);



}

void MembraneInternalForce::AddTensionForceContribution(AbstractCellPopulation<2>& rCellPopulation)
{
	MeshBasedCellPopulation<2>* pTissue = static_cast<MeshBasedCellPopulation<2>*>(&rCellPopulation);


	for (std::vector<std::vector<CellPtr>>::iterator iter = mMembraneSections.begin(); iter != mMembraneSections.end(); ++iter)
	{
		std::vector<CellPtr> membraneCells = *iter;

		// If periodic, then the first two entries are repeated at the end for the sake of the
		// restoring force, so need to avoid them
		unsigned itLimit = membraneCells.size();
		if (mIsPeriodic)
		{
			itLimit -= 1;
		}
		// We loop through the membrane sections to set the restoring forces
		for (unsigned i = 0; i < itLimit - 1; i++)
		{
			CellPtr cellA = membraneCells[i];
			CellPtr cellB = membraneCells[i+1];

			Node<2>* nodeA = pTissue->GetNode(pTissue->GetLocationIndexUsingCell(cellA));
			Node<2>* nodeB = pTissue->GetNode(pTissue->GetLocationIndexUsingCell(cellB));

			double radiusA = nodeA->GetRadius();
			double radiusB = nodeB->GetRadius();

			double restLength = radiusA + radiusB;

						
			c_vector<double, 2> locationA = pTissue->GetLocationOfCellCentre(cellA);
			c_vector<double, 2> locationB = pTissue->GetLocationOfCellCentre(cellB);

			c_vector<double, 2> vectorAB = rCellPopulation.rGetMesh().GetVectorFromAtoB(locationA, locationB);

			double lengthAB = norm_2(vectorAB);

			double dx = lengthAB - restLength;

			double forceMagnitude = mMembraneStiffness * dx;
			c_vector<double, 2> forceVector = forceMagnitude * vectorAB / lengthAB;

			nodeA->AddAppliedForceContribution(forceVector);
			nodeB->AddAppliedForceContribution(-forceVector);

		}
	}
}

void MembraneInternalForce::AddExternalForceContribution(AbstractCellPopulation<2>& rCellPopulation)
{

	MeshBasedCellPopulation<2>* pTissue = static_cast<MeshBasedCellPopulation<2>*>(&rCellPopulation);

	for (std::vector<std::vector<CellPtr>>::iterator iter = mMembraneSections.begin(); iter != mMembraneSections.end(); ++iter)
	{
		std::vector<CellPtr> membraneCells = *iter;
		// We loop through the membrane sections to set the extrenal forces
		unsigned itLimit = membraneCells.size();
		if (mIsPeriodic)
		{
			itLimit -=2;
		}

		for (unsigned i = 0; i < itLimit; i++)
		{
			CellPtr cellA = membraneCells[i];

			Node<2>* pMembraneNode = pTissue->GetNode(pTissue->GetLocationIndexUsingCell(cellA));			

			std::vector<unsigned>& neighbours = pMembraneNode->rGetNeighbours();
			for (std::vector<unsigned>::iterator it = neighbours.begin(); it != neighbours.end(); it++)
			{
				Node<2>* pNeighbour =  pTissue->GetNode(*it);
				CellPtr pCell = pTissue->GetCellUsingLocationIndex(*it);
				if (!pCell->GetCellProliferativeType()->IsType<MembraneType>())
				{
					double radiusA = pMembraneNode->GetRadius();
					double radiusB = pNeighbour->GetRadius();

					double restLength = radiusA + radiusB;
								
					c_vector<double, 2> locationA = pMembraneNode->rGetLocation();
					c_vector<double, 2> locationB = pNeighbour->rGetLocation();

					c_vector<double, 2> vectorAB = rCellPopulation.rGetMesh().GetVectorFromAtoB(locationA, locationB);
					// c_vector<double, 2> vectorAB = locationB - locationA;

					double lengthAB = norm_2(vectorAB);

					double dx = lengthAB - restLength;

					c_vector<double, 2> forceVector;

					if (dx <= 0) //overlap is negative
					{
						// log(x+1) is undefined for x<=-1
						assert(dx > -restLength);
						forceVector = mExternalStiffness * vectorAB * restLength * log(1.0 + dx/restLength);
					}
					else
					{
						double alpha = 5.0;
						forceVector = mExternalStiffness * vectorAB * dx * exp(-alpha * dx/restLength);
					}

					pMembraneNode->AddAppliedForceContribution(forceVector);
					pNeighbour->AddAppliedForceContribution(-forceVector);
				}
			}
		}
	}

}



double MembraneInternalForce::FindParametricCurvature(AbstractCellPopulation<2>& rCellPopulation,
															c_vector<double, 2> leftLocation,
															c_vector<double, 2> centreLocation,
															c_vector<double, 2> rightLocation)
{
	//Get the relevant vectors (all possible differences)
	c_vector<double, 2> vectorLC = rCellPopulation.rGetMesh().GetVectorFromAtoB(leftLocation, centreLocation);
	c_vector<double, 2> vectorCR = rCellPopulation.rGetMesh().GetVectorFromAtoB(centreLocation, rightLocation);
	c_vector<double, 2> vectorLR = rCellPopulation.rGetMesh().GetVectorFromAtoB(leftLocation, rightLocation);

	// Firstly find the parametric intervals
	double leftS = sqrt(pow(vectorLC[0],2) + pow(vectorLC[1],2));
	double rightS = sqrt(pow(vectorCR[0],2) + pow(vectorCR[1],2));

	double sumIntervals = leftS + rightS;

	//Calculate finite difference of first derivatives
	double xPrime = (vectorLR[0]) / sumIntervals;
	double yPrime = (vectorLR[1]) / sumIntervals;

	//Calculate finite difference of second derivatives
	double xPrimePrime = 2 * (leftS * vectorCR[0] - rightS * vectorLC[0]) / (leftS * rightS * sumIntervals);
	double yPrimePrime = 2 * (leftS * vectorCR[1] - rightS * vectorLC[1]) / (leftS * rightS * sumIntervals);

	//Calculate curvature using formula
	double curvature = (xPrime * yPrimePrime - yPrime * xPrimePrime) / pow((pow(xPrime,2) + pow(yPrime,2)),3/2);

	return curvature;
}



double MembraneInternalForce::GetTargetCurvature(AbstractCellPopulation<2>& rCellPopulation, CellPtr centreCell,
																		c_vector<double, 2> leftLocation,
																		c_vector<double, 2> centreLocation,
																		c_vector<double, 2> rightLocation)
{
	// Returns the angle that we're aiming for
	// At the moment, it doesn't handle membrane cells with both types separately, but treats them like  they're attached to transit cells
	MeshBasedCellPopulation<2>* pTissue = static_cast<MeshBasedCellPopulation<2>*>(&rCellPopulation);

	bool contactWithStem = false;
	unsigned centreIndex = pTissue->GetLocationIndexUsingCell(centreCell);
	std::set<unsigned> neighbourIndices = rCellPopulation.GetNeighbouringNodeIndices(centreIndex);

	for (std::set<unsigned>::iterator iter = neighbourIndices.begin();
	         			iter != neighbourIndices.end();
	         				++iter)
	{

		CellPtr neighbour = pTissue->GetCellUsingLocationIndex(*iter);
		if (!neighbour->IsDead())
		{

			if (neighbour->GetCellProliferativeType()->IsType<StemType>())
			{
				return mTargetCurvatureStem;
			}
		}
	}


	return 0;
}


void MembraneInternalForce::AddCurvatureForceContribution(AbstractCellPopulation<2>& rCellPopulation)
{
	MeshBasedCellPopulation<2>* pTissue = static_cast<MeshBasedCellPopulation<2>*>(&rCellPopulation);


	for (std::vector<std::vector<CellPtr>>::iterator iter = mMembraneSections.begin(); iter != mMembraneSections.end(); ++iter)
	{
		std::vector<CellPtr> membraneCells = *iter;

		// We loop through the membrane sections to set the restoring forces
		for (unsigned i = 0; i < membraneCells.size() - 2; i++)
		{

			CellPtr leftCell = membraneCells[i];
			CellPtr centreCell = membraneCells[i+1];
			CellPtr rightCell = membraneCells[i+2];
			

			unsigned leftIndex = pTissue->GetLocationIndexUsingCell(leftCell);
			unsigned centreIndex = pTissue->GetLocationIndexUsingCell(centreCell);
			unsigned rightIndex = pTissue->GetLocationIndexUsingCell(rightCell);

			
			c_vector<double, 2> leftLocation = pTissue->GetLocationOfCellCentre(leftCell);
			c_vector<double, 2> rightLocation = pTissue->GetLocationOfCellCentre(rightCell);
			c_vector<double, 2> centreLocation = pTissue->GetLocationOfCellCentre(centreCell);
			

			// double currentAngle = GetAngleFromTriplet(rCellPopulation, leftLocation, centreLocation, rightLocation);
			// // double currentAngle = 0;

			double currentCurvature = FindParametricCurvature(rCellPopulation, leftLocation, centreLocation, rightLocation);

			
			if (std::abs(currentCurvature) < 1e-5)
			{
				// Close enough
				currentCurvature = 0.0;
				// We need to use the sign of the curvature to determine the angle correctly
				// Extrememly small curvatures due to precision errors might play havock with this
			}

			// The method of calculating the angle is not oriented by the lumen, so need to adjust
			// if (currentCurvature < 0)
			// {
			// 	currentAngle = 2 * M_PI - currentAngle;
			// }

			// double targetAngle = GetTargetAngle(rCellPopulation, centreCell, leftLocation, centreLocation, rightLocation);
			// // double targetAngle = 0;

			double targetCurvature = GetTargetCurvature(rCellPopulation, centreCell, leftLocation, centreLocation, rightLocation);

			// Applying the restoring force as a 'lifting' force on the centre cell
			double forceMagnitude = mMembraneRestoringRate * (currentCurvature - targetCurvature); // +ve force means away from lumen

			// c_vector<double, 2> vectorLR = pTissue->rGetMesh().GetVectorFromAtoB(leftLocation,rightLocation); // Used for determining where lumen is
			c_vector<double, 2> vectorLR = rightLocation - leftLocation;
			double lengthLR = norm_2(vectorLR);
			
			c_vector<double, 2> forceDirection; // Trying a force like SJD
			

			// Fix thsi so it is the same as in Axels half preprint
			forceDirection[0] = - vectorLR[1] / lengthLR; // This must be perpendicular to the LR vector
			forceDirection[1] = vectorLR[0] / lengthLR;

			c_vector<double, 2> forceVector = forceMagnitude * forceDirection;

			rCellPopulation.GetNode(centreIndex)->AddAppliedForceContribution(forceVector);

	
		}
	}
}





void MembraneInternalForce::SetMembraneSections(std::vector<std::vector<CellPtr>> membraneSections)
{
	mMembraneSections = membraneSections;
}

void MembraneInternalForce::OutputForceParameters(out_stream& rParamsFile)
{
	*rParamsFile <<  "\t\t\t<MembraneStiffness>"<<  mMembraneStiffness << "</MembraneStiffness> \n";

	// Call direct parent class
	AbstractForce<2>::OutputForceParameters(rParamsFile);
}


// Probaly won't use these functions, but keeping them here just in case

double MembraneInternalForce::GetAngleFromTriplet(AbstractCellPopulation<2>& rCellPopulation,
															c_vector<double, 2> leftLocation,
															c_vector<double, 2> centreLocation,
															c_vector<double, 2> rightLocation)
{

	MeshBasedCellPopulation<2>* pTissue = static_cast<MeshBasedCellPopulation<2>*>(&rCellPopulation);
	// Given three node which we know are neighbours, determine the angle their centres make


	MutableMesh<2,2>& test = pTissue->rGetMesh();

	c_vector<double, 2> vectorCL = pTissue->rGetMesh().GetVectorFromAtoB(centreLocation,leftLocation);

	c_vector<double, 2> vectorCR = pTissue->rGetMesh().GetVectorFromAtoB(centreLocation,rightLocation);

	double innerProductCRCL = vectorCL[0] * vectorCR[0] + vectorCL[1] * vectorCR[1];
	double lengthCL = norm_2(vectorCL);
	double lengthCR = norm_2(vectorCR);

	double acos_arg = innerProductCRCL / (lengthCL * lengthCR);

	double angle = acos(acos_arg);

	// Occasionally the argument steps out of the bounds for acos, for instance -1.0000000000000002
	// This is enough to make the acos function return nans
	// This line of code is not ideal, but catches the error for the time being
	if (isnan(angle) && acos_arg > -1.00000000000005) 
	{
		return acos(-1);
	}

	return angle;

}
double MembraneInternalForce::GetTargetAngle(AbstractCellPopulation<2>& rCellPopulation, CellPtr centreCell,
																		c_vector<double, 2> leftLocation,
																		c_vector<double, 2> centreLocation,
																		c_vector<double, 2> rightLocation)
{
	// Returns the angle that we're aiming for
	// At the moment, it doesn't handle membrane cells with both types separately, but treats them like  they're attached to transit cells

	MeshBasedCellPopulation<2>* pTissue = static_cast<MeshBasedCellPopulation<2>*>(&rCellPopulation);

	bool contactWithStem = false;

	unsigned centreIndex = pTissue->GetLocationIndexUsingCell(centreCell);

	std::set<unsigned> neighbourIndices = rCellPopulation.GetNeighbouringNodeIndices(centreIndex);


	for (std::set<unsigned>::iterator iter = neighbourIndices.begin();
	         			iter != neighbourIndices.end();
	         				++iter)
	{

		CellPtr neighbour = pTissue->GetCellUsingLocationIndex(*iter);
		if (!neighbour->IsDead())
		{

			if (neighbour->GetCellProliferativeType()->IsType<StemType>())
			{
				contactWithStem = true;
			}
		}
	}


	double targetAngle = M_PI; // Assume we're dealing with flat area by default

	c_vector<double, 2> vectorCL = pTissue->rGetMesh().GetVectorFromAtoB(centreLocation,leftLocation);

	c_vector<double, 2> vectorCR = pTissue->rGetMesh().GetVectorFromAtoB(centreLocation,rightLocation);


	double lengthCL = norm_2(vectorCL);
	double lengthCR = norm_2(vectorCR);


	if (contactWithStem)
	{
		targetAngle = acos(lengthCR * mTargetCurvatureStem / 2) + acos(lengthCL * mTargetCurvatureStem / 2);
		//targetAngle = 2.8;
	}

	return targetAngle;
}

// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(MembraneInternalForce)
