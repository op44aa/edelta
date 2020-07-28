/*
 * generated by Xtext 2.21.0
 */
package edelta.ui.contentassist;

import static org.eclipse.xtext.EcoreUtil2.getContainerOfType;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.Assignment;
import org.eclipse.xtext.CrossReference;
import org.eclipse.xtext.resource.IEObjectDescription;
import org.eclipse.xtext.scoping.IScope;
import org.eclipse.xtext.scoping.Scopes;
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext;
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor;

import com.google.common.base.Predicates;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;

import edelta.edelta.EdeltaEcoreQualifiedReference;
import edelta.edelta.EdeltaEcoreReferenceExpression;
import edelta.edelta.EdeltaPackage;
import edelta.resource.derivedstate.EdeltaAccessibleElement;
import edelta.resource.derivedstate.EdeltaAccessibleElements;
import edelta.resource.derivedstate.EdeltaDerivedStateHelper;
import edelta.util.EdeltaEcoreHelper;
import edelta.util.EdeltaModelUtil;

/**
 * See
 * https://www.eclipse.org/Xtext/documentation/310_eclipse_support.html#content-assist
 * on how to customize the content assistant.
 * 
 * @author Lorenzo Bettini
 */
public class EdeltaProposalProvider extends AbstractEdeltaProposalProvider {

	@Inject
	private EdeltaDerivedStateHelper derivedStateHelper;

	@Inject
	private EdeltaEcoreHelper ecoreHelper;

	/**
	 * Avoids proposing subpackages since in Edelta they are not allowed
	 * to be directly imported.
	 */
	@Override
	public void completeEdeltaProgram_Metamodels(EObject model, Assignment assignment, ContentAssistContext context,
			ICompletionProposalAcceptor acceptor) {
		lookupCrossReference(
			((CrossReference) assignment.getTerminal()),
			context,
			acceptor,
			// EPackage are not loaded at this point, so we cannot rely
			// on super package relation.
			// Instead we rely on the fact that subpackages have segments
			(IEObjectDescription desc) ->
				desc.getQualifiedName().getSegmentCount() == 1
		);
	}

	/**
	 * Only proposes elements that are available in this context.
	 */
	@Override
	public void completeEdeltaEcoreDirectReference_Enamedelement(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		final var accessibleElements = getAccessibleElements(model);
		createENamedElementProposals(model, context, acceptor,
			Scopes.scopeFor(
				Iterables.transform(accessibleElements,
					EdeltaAccessibleElement::getElement)));
	}

	@Override
	public void completeEdeltaEcoreReference_Enamedelement(EObject model, Assignment assignment,
			ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		final var accessibleElements = getAccessibleElements(model);
		final var qualification = ((EdeltaEcoreQualifiedReference) model)
			.getQualification();
		String qualificationText = EdeltaModelUtil.getEcoreReferenceText(qualification);
		accessibleElements.stream()
			.filter(e -> e.getQualifiedName().toString().endsWith(qualificationText))
			.findFirst()
			.ifPresent(e -> 
				createENamedElementProposals(model, context, acceptor,
					Scopes.scopeFor(
						ecoreHelper.getENamedElements(e.getElement()))));
	}

	private EdeltaAccessibleElements getAccessibleElements(EObject model) {
		return derivedStateHelper.getAccessibleElements(
			getContainerOfType(model, EdeltaEcoreReferenceExpression.class));
	}

	private void createENamedElementProposals(EObject model, ContentAssistContext context, ICompletionProposalAcceptor acceptor,
			IScope scope) {
		getCrossReferenceProposalCreator()
			.lookupCrossReference(
				scope,
				model,
				EdeltaPackage.Literals.EDELTA_ECORE_REFERENCE__ENAMEDELEMENT,
				acceptor,
				Predicates.<IEObjectDescription> alwaysTrue(),
				getProposalFactory("ID", context));
	}

}
