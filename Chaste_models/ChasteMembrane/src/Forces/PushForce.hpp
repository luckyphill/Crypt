#ifndef PUSHFORCE_HPP_
#define PUSHFORCE_HPP_

#include "ChasteSerialization.hpp"
#include "ClassIsAbstract.hpp"

#include "AbstractCellPopulation.hpp"
#include "AbstractCellBasedSimulationModifier.hpp"
#include "AbstractForce.hpp"

class PushForce: public AbstractForce<2,2>
{
	private:

		CellPtr mpCell;
		c_vector<double, 2> mForce;
		double mOffTime = 100; // Ought to be DOUBLE_UNSET but this will only be used for a small test, so I'm cutting corners.

	public:

		PushForce();
		~PushForce();


		void SetCell(CellPtr cell);

		void SetForce(c_vector<double, 2> force);

		void AddForceContribution(AbstractCellPopulation<2>& rCellPopulation);

		void OutputForceParameters(out_stream& rParamsFile);
		void SetForceOffTime(double off_time);

};

#endif /*PUSHFORCE_HPP_*/