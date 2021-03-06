/**
 * generated by Xtext 2.10.0
 */
package edelta.ui.outline;

import org.eclipse.emf.ecore.ENamedElement;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.swt.graphics.Image;
import org.eclipse.xtext.ui.editor.outline.IOutlineNode;
import org.eclipse.xtext.ui.editor.outline.impl.DefaultOutlineTreeProvider;
import org.eclipse.xtext.ui.editor.outline.impl.EObjectNode;
import org.eclipse.xtext.xbase.XExpression;

import com.google.inject.Inject;

import edelta.edelta.EdeltaModifyEcoreOperation;
import edelta.edelta.EdeltaOperation;
import edelta.edelta.EdeltaProgram;
import edelta.resource.derivedstate.EdeltaDerivedStateHelper;

/**
 * Customization of the default outline structure.
 * 
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#outline
 */
public class EdeltaOutlineTreeProvider extends DefaultOutlineTreeProvider {
	@Inject
	private EdeltaDerivedStateHelper derivedStateHelper;

	protected void _createChildren(final IOutlineNode parentNode, final EdeltaProgram p) {
		for (final var o : p.getOperations()) {
			this.createNode(parentNode, o);
		}
		for (final var o : p.getModifyEcoreOperations()) {
			this.createNode(parentNode, o);
		}
		final var eResource = p.eResource();
		final var modifiedElements = derivedStateHelper.getModifiedElements(eResource);
		for (final var ePackage : this.derivedStateHelper.getCopiedEPackagesMap(eResource).values()) {
			// the cool thing is that we don't need to provide
			// customization in the label provider for EPackage and EClass
			// since Xtext defaults to the .edit plugin :)
			if (modifiedElements.contains(ePackage))
				this.createNode(parentNode, ePackage);
			// only show EPackage with some modifications
		}
	}

	public boolean _isLeaf(final EdeltaOperation m) {
		return true;
	}

	public boolean _isLeaf(final EdeltaModifyEcoreOperation m) {
		return true;
	}

	@Override
	protected EObjectNode createEObjectNode(IOutlineNode parentNode, EObject modelElement, Image image, Object text,
			boolean isLeaf) {
		final var eObjectNode = super.createEObjectNode(parentNode, modelElement, image, text, isLeaf);
		if (modelElement instanceof ENamedElement) {
			// try to associate the node to the responsible XExpression
			XExpression expression = derivedStateHelper.
				getLastResponsibleExpression((ENamedElement) modelElement);
			if (expression != null)
				eObjectNode.setShortTextRegion(
					locationInFileProvider.getSignificantTextRegion(expression));
		}
		return eObjectNode;
	}
}
