package edelta.util

import edelta.edelta.EdeltaEcoreBaseEClassManipulationWithBlockExpression
import edelta.edelta.EdeltaEcoreChangeEClassExpression
import edelta.edelta.EdeltaProgram
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2

/**
 * Utilities for navigating an Edelta AST model
 * 
 * @author Lorenzo Bettini
 *
 */
class EdeltaModelUtil {

	def EdeltaProgram getProgram(EObject context) {
		EcoreUtil2.getContainerOfType(context, EdeltaProgram)
	}

	def EdeltaEcoreChangeEClassExpression getChangeEClass(EObject context) {
		EcoreUtil2.getContainerOfType(context, EdeltaEcoreChangeEClassExpression)
	}

	def EdeltaEcoreBaseEClassManipulationWithBlockExpression getEClassManipulation(EObject context) {
		EcoreUtil2.getContainerOfType(context, EdeltaEcoreBaseEClassManipulationWithBlockExpression)
	}
}