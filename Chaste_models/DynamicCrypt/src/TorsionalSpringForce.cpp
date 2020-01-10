#include "TorsionalSpringForce.hpp"
#include "AbstractCellProperty.hpp"
#include "Debug.hpp"

/*
 * Created by: PHILLIP BROWN, 27/10/2017
 * Initial Structure borrows heavily from "EpithelialLayerForce.cpp"
 * as found in the Chaste Paper Tutorials for the CryptFissionPlos2016 project
 */

/**
 * To avoid warnings on some compilers, C++ style initialization of member
 * variables should be done in the order they are defined in the header file.
 */
TorsionalSpringForce::TorsionalSpringForce()
   :  AbstractForce<2>(),
   mTorsionalStiffness(5.0),
   mTargetCurvature(0.3)
{
}

TorsionalSpringForce::~TorsionalSpringForce()
{

}

void TorsionalSpringForce::SetTorsionalStiffness(double torsionalStiffness)
{
	mTorsionalStiffness = torsionalStiffness;
}


void TorsionalSpringForce::SetTargetCurvature(double targetCurvature)
{
	mTargetCurvature = targetCurvature;
}


/*
 * A method to find all the pairs of connections between healthy epithelial cells and labelled gel cells.
 * Returns a vector of node pairings, without repeats. The first of each pair is the epithelial node index,
 * and the second is the gel node index. Updating so that it also returns mutant-labelled cell pairs.
 */


double TorsionalSpringForce::GetAngleFromTriplet(AbstractCellPopulation<2>& rCellPopulation,
															c_vector<double, 2> leftNode,
															c_vector<double, 2> centreNode,
															c_vector<double, 2> rightNode)
{
	// Given three node which we know are neighbours, determine the angle their centres make
	// c_vector<double, 2> vector_AB = p_tissue->rGetMesh().GetVectorFromAtoB(centreNode,leftNode);
	// c_vector<double, 2> vector_AC = p_tissue->rGetMesh().GetVectorFromAtoB(centreNode,rightNode);
	c_vector<double, 2> vector_AB = leftNode - centreNode;
	c_vector<double, 2> vector_AC = rightNode - centreNode;

	double inner_product_AB_AC = vector_AB[0] * vector_AC[0] + vector_AB[1] * vector_AC[1];
	double length_AB = norm_2(vector_AB);
	double length_AC = norm_2(vector_AC);

	double acos_arg = inner_product_AB_AC / (length_AB * length_AC);

	double angle = acos(acos_arg);
	// Occasionally the argument steps out of the bounds for acos, for instance -1.0000000000000002
	// This is enough to make the acos function return nans
	// This line of code is not ideal, but catches the error for the time being
	if (isnan(angle) && acos_arg > -1.00000000000005) 
	{
		return acos(-1);
	}
	return angle;
	// Need to orient the vectors with respect to the lumen so we know which direction
	// THis is not done here, so must be done after
}

/*
* Function to return the curvature between three points parametrically - the midpoints of the springs connecting the
* transit cells to the differentiated cells. NB. The input arguments need to be in order from either left to right
* or right to left. If they are wrongly arranged (eg. middle, left, right) then you get a different curvature,
* but left->right = -(right-> left).
*/

double TorsionalSpringForce::FindParametricCurvature(AbstractCellPopulation<2>& rCellPopulation,
															c_vector<double, 2> leftCell,
															c_vector<double, 2> centreCell,
															c_vector<double, 2> rightCell)
{
	//Get the relevant vectors (all possible differences)
	c_vector<double, 2> left_to_centre = centreCell - leftCell;
	c_vector<double, 2> centre_to_right = rightCell - centreCell;
	c_vector<double, 2> left_to_right = rightCell - leftCell;

	// Firstly find the parametric intervals
	double left_s = sqrt(pow(left_to_centre[0],2) + pow(left_to_centre[1],2));
	double right_s = sqrt(pow(centre_to_right[0],2) + pow(centre_to_right[1],2));

	double sum_intervals = left_s + right_s;

	//Calculate finite difference of first derivatives
	double x_prime = (left_to_right[0])/sum_intervals;
	double y_prime = (left_to_right[1])/sum_intervals;

	//Calculate finite difference of second derivatives
	double x_double_prime = 2*(left_s*centre_to_right[0] - right_s*left_to_centre[0])/(left_s*right_s*sum_intervals);
	double y_double_prime = 2*(left_s*centre_to_right[1] - right_s*left_to_centre[1])/(left_s*right_s*sum_intervals);

	//Calculate curvature using formula
	double curvature = (x_prime*y_double_prime - y_prime*x_double_prime)/pow((pow(x_prime,2) + pow(y_prime,2)),3/2);

	return curvature;
}


double TorsionalSpringForce::GetTargetAngle(AbstractCellPopulation<2>& rCellPopulation, CellPtr centre_cell,
																		c_vector<double, 2> leftCell,
																		c_vector<double, 2> centreCell,
																		c_vector<double, 2> rightCell)
{
	MeshBasedCellPopulation<2>* cell_population = static_cast<MeshBasedCellPopulation<2>*>(&rCellPopulation);

	double target_angle = M_PI;

	c_vector<double, 2> vector_AB = leftCell - centreCell;
	c_vector<double, 2> vector_AC = rightCell - centreCell;

	double length_AB = norm_2(vector_AB);
	double length_AC = norm_2(vector_AC);


	target_angle = acos(length_AC * mTargetCurvature / 2) + acos(length_AB * mTargetCurvature / 2);


	return target_angle;
}



//Method overriding the virtual method for AbstractForce. The crux of what really needs to be done.
void TorsionalSpringForce::AddForceContribution(AbstractCellPopulation<2>& rCellPopulation)
{

	// As a temporary measure, this relies on the cell indices matching the order they are given
	// this won't be the best way to do it, an in fact the approach used in MembraneCellForce may be the best
	MeshBasedCellPopulation<2>* p_tissue = static_cast<MeshBasedCellPopulation<2>*>(&rCellPopulation);

	std::list<CellPtr> cells =  p_tissue->rGetCells();
	
	// Sort the cells in order of height
	cells.sort(
		[p_tissue](CellPtr A, CellPtr B)
	{
		Node<2>* node_A = p_tissue->GetNodeCorrespondingToCell(A);
		Node<2>* node_B = p_tissue->GetNodeCorrespondingToCell(B);
		return (node_A->rGetLocation()[0] < node_B->rGetLocation()[0]);
	});

	for (std::list<CellPtr>::iterator it = cells.begin(); it != std::prev(cells.end(), 2); ++it)
	{
		CellPtr left_cell = (*it);
		CellPtr centre_cell = (*std::next(it,1));
		CellPtr right_cell = (*std::next(it,2));

		unsigned left_node = p_tissue->GetLocationIndexUsingCell(left_cell);
		unsigned centre_node = p_tissue->GetLocationIndexUsingCell(centre_cell);
		unsigned right_node = p_tissue->GetLocationIndexUsingCell(right_cell);
		
		c_vector<double, 2> left_location = p_tissue->GetLocationOfCellCentre(left_cell);
		c_vector<double, 2> right_location = p_tissue->GetLocationOfCellCentre(right_cell);
		c_vector<double, 2> centre_location = p_tissue->GetLocationOfCellCentre(centre_cell);

		double current_angle = GetAngleFromTriplet(rCellPopulation, left_location, centre_location, right_location);

		double current_curvature = FindParametricCurvature(rCellPopulation, left_location, centre_location, right_location);

		if (std::abs(current_curvature) < 1e-8)
		{
			// Close enough
			current_curvature = 0.0;
			// We need to use the sign of the curvature to determine the angle correctly
			// Extrememly small curvatures due to precision errors might play havock with this
		}

		// The method of calculating the angle is not oriented by the lumen, so need to adjust
		if (current_curvature < 0)
		{
			current_angle = 2 * M_PI - current_angle;
		}

		double target_angle = GetTargetAngle(rCellPopulation, centre_cell, left_location, centre_location, right_location);
		// Treating the membrane force like a torsion spring
		double torque = mTorsionalStiffness * (current_angle - target_angle); // Positive torque means force points into lumen

		// Use the CL and CR vectors to determine the line that the force will act on
		// If we have a vector (a, b), then the vector (b, -a) is perpendicular and creates a clockwise rotation when added to the end of (a,b)
		// while (-b, a) creates an anticlockwise rotation
		// forceDirectionLeft will always end up pointing into the lumen, and forceDirectionRight will always point out
		// Given we have decided that the actual direction of the force is encoded in the sign on the torque this is all we need to do
		// c_vector<double, 2> vector_CL = p_tissue->rGetMesh().GetVectorFromAtoB(centre_location,left_location);
		// c_vector<double, 2> vector_CR = p_tissue->rGetMesh().GetVectorFromAtoB(centre_location,right_location);

		c_vector<double, 2> vector_CL = left_location - centre_location;
		c_vector<double, 2> vector_CR = right_location - centre_location;
		
		double length_CL = norm_2(vector_CL);
		double length_CR = norm_2(vector_CR);
		
		double forceMagnitudeLeft = torque/length_CL;
		double forceMagnitudeRight = torque/length_CR;
		
		c_vector<double, 2> forceDirectionLeft;
		c_vector<double, 2> forceDirectionRight;
		
		forceDirectionLeft[0] = vector_CL[1] / length_CL;
		forceDirectionLeft[1] = - vector_CL[0] / length_CL;

		forceDirectionRight[0] = - vector_CR[1] / length_CR;
		forceDirectionRight[1] = vector_CR[0] / length_CR;

		c_vector<double, 2> forceVectorLeft = forceMagnitudeLeft * forceDirectionLeft;
		c_vector<double, 2> forceVectorRight = forceMagnitudeRight * forceDirectionRight;

		rCellPopulation.GetNode(left_node)->AddAppliedForceContribution(forceVectorLeft);
		rCellPopulation.GetNode(right_node)->AddAppliedForceContribution(forceVectorRight);
	}

}

void TorsionalSpringForce::OutputForceParameters(out_stream& rParamsFile)
{
	*rParamsFile <<  "\t\t\t<TorsionalStiffness>"<<  mTorsionalStiffness << "</TorsionalStiffness> \n";
	*rParamsFile <<  "\t\t\t<TargetCurvature>"<< mTargetCurvature << "</TargetCurvature> \n";

	// Call direct parent class
	AbstractForce<2>::OutputForceParameters(rParamsFile);
}


// Serialization for Boost >= 1.36
#include "SerializationExportWrapperForCpp.hpp"
CHASTE_CLASS_EXPORT(TorsionalSpringForce)
