package edelta.resource.derivedstate;

import org.eclipse.emf.common.notify.impl.AdapterImpl;
import org.eclipse.xtext.resource.XtextResource;

import com.google.inject.Inject;

/**
 * Additional derived state installable in an {@link XtextResource}.
 * 
 * @author Lorenzo Bettini
 *
 */
public class EdeltaDerivedState extends AdapterImpl {
	private EdeltaCopiedEPackagesMap copiedEPackagesMap = new EdeltaCopiedEPackagesMap();
	private EdeltaEcoreReferenceStateMap ecoreReferenceStateMap = new EdeltaEcoreReferenceStateMap();
	@Inject
	private EdeltaENamedElementXExpressionMap enamedElementXExpressionMap;

	@Override
	public boolean isAdapterForType(final Object type) {
		return EdeltaDerivedState.class == type;
	}

	public EdeltaCopiedEPackagesMap getCopiedEPackagesMap() {
		return copiedEPackagesMap;
	}

	public EdeltaEcoreReferenceStateMap getEcoreReferenceStateMap() {
		return ecoreReferenceStateMap;
	}

	public EdeltaENamedElementXExpressionMap getEnamedElementXExpressionMap() {
		return enamedElementXExpressionMap;
	}
}