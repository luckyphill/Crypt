#ifndef PUSHFORCEMODIFIER_HPP_
#define PUSHFORCEMODIFIER_HPP_

#include "ChasteSerialization.hpp"
#include "ClassIsAbstract.hpp"

#include "AbstractCellPopulation.hpp"
#include "AbstractCellBasedSimulationModifier.hpp"

class PushForceModifier: public AbstractCellBasedSimulationModifier<2,2>
{
	private:

		// The cell and the force to be applied
		Node<2> * mpNode;
		CellPtr mpCell;
		c_vector<double, 2> mForce;

	public:

		PushForceModifier();
		~PushForceModifier();

		void UpdateAtEndOfTimeStep(AbstractCellPopulation<2>& rCellPopulation);

		void SetupSolve(AbstractCellPopulation<2>& rCellPopulation, std::string outputDirectory);

		void OutputSimulationModifierParameters(out_stream& rParamsFile);

		void SetNode(Node<2> * node);

		void SetCell(CellPtr cell);

		void SetForce(c_vector<double, 2> force);

		void ApplyForce(AbstractCellPopulation<2>& rCellPopulation);

};


// #include "SerializationExportWrapper.hpp"
// EXPORT_TEMPLATE_CLASS_SAME_DIMS(PushForceModifier)
#endif /*PUSHFORCEMODIFIER_HPP_*/