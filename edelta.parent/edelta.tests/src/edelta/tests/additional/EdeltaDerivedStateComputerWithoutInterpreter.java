/**
 * 
 */
package edelta.tests.additional;

import java.util.List;
import java.util.Map;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.common.types.JvmGenericType;

import edelta.edelta.EdeltaEcoreBaseEClassManipulationWithBlockExpression;
import edelta.resource.EdeltaDerivedStateComputer;

/**
 * Avoids the derived state computer run the interpreter since the tests in this
 * class must concern interpreter only and we don't want side effects from the
 * derived state computer running the interpreter.
 * 
 * @author Lorenzo Bettini
 *
 */
public class EdeltaDerivedStateComputerWithoutInterpreter extends EdeltaDerivedStateComputer {

	@Override
	protected void runInterpreter(List<? extends EdeltaEcoreBaseEClassManipulationWithBlockExpression> expressions,
			Map<EdeltaEcoreBaseEClassManipulationWithBlockExpression, EClass> opToEClassMap,
			JvmGenericType jvmGenericType, List<EPackage> packages) {
		// No interpreter is run
	}

	@Override
	protected void recordEcoreReferenceOriginalENamedElement(Resource resource) {
		// No recording is done
	}
}