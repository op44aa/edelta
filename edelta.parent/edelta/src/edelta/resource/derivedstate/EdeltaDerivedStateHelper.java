package edelta.resource.derivedstate;

import java.util.Objects;

import org.eclipse.emf.ecore.ENamedElement;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.xtext.Constants;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.xbase.XExpression;

import com.google.inject.Inject;
import com.google.inject.Provider;
import com.google.inject.Singleton;
import com.google.inject.name.Named;

import edelta.edelta.EdeltaEcoreReference;

/**
 * Provides access (and possibly install) to the {@link EdeltaDerivedState}.
 * 
 * @author Lorenzo Bettini
 *
 */
@Singleton
public class EdeltaDerivedStateHelper {

	@Inject
	@Named(Constants.LANGUAGE_NAME)
	private String languageName;

	@Inject
	private Provider<EdeltaDerivedState> derivedStateProvider;

	public EdeltaDerivedState getOrInstallAdapter(final Resource resource) {
		if (resource instanceof XtextResource) {
			final String resourceLanguageName = ((XtextResource) resource).getLanguageName();
			if (Objects.equals(resourceLanguageName, this.languageName)) {
				EdeltaDerivedState adapter = 
					(EdeltaDerivedState) EcoreUtil.getAdapter
						(resource.eAdapters(), EdeltaDerivedState.class);
				if (adapter == null) {
					adapter = derivedStateProvider.get();
					resource.eAdapters().add(adapter);
				}
				return adapter;
			}
		}
		return new EdeltaDerivedState();
	}

	public EdeltaCopiedEPackagesMap getCopiedEPackagesMap(final Resource resource) {
		return getOrInstallAdapter(resource).getCopiedEPackagesMap();
	}

	public EdeltaEcoreReferenceState getEcoreReferenceState(EdeltaEcoreReference edeltaEcoreReference) {
		return getOrInstallAdapter(edeltaEcoreReference.eResource())
				.getEcoreReferenceStateMap()
				.computeIfAbsent(edeltaEcoreReference,
						e -> new EdeltaEcoreReferenceState());
	}

	public EdeltaENamedElementXExpressionMap getEnamedElementXExpressionMap(Resource resource) {
		return getOrInstallAdapter(resource).getEnamedElementXExpressionMap();
	}

	public ENamedElement getOriginalEnamedelement(EdeltaEcoreReference ecoreReference) {
		return getEcoreReferenceState(ecoreReference)
				.getOriginalEnamedelement();
	}

	public XExpression getResponsibleExpression(EdeltaEcoreReference ecoreReference) {
		return getEnamedElementXExpressionMap(ecoreReference.eResource())
				.get(ecoreReference.getEnamedelement());
	}
}
