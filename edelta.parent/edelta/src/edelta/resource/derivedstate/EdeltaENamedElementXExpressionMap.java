package edelta.resource.derivedstate;

import java.util.HashMap;

import org.eclipse.emf.ecore.ENamedElement;
import org.eclipse.xtext.naming.IQualifiedNameProvider;
import org.eclipse.xtext.naming.QualifiedName;
import org.eclipse.xtext.xbase.XExpression;

import com.google.inject.Inject;

/**
 * Associates an {@link ENamedElement}, by its {@link QualifiedName}, to the
 * {@link XExpression} that created it with a name, or changed its name, during
 * the interpretation.
 * 
 * @author Lorenzo Bettini
 *
 */
public class EdeltaENamedElementXExpressionMap extends HashMap<QualifiedName, XExpression> {

	private static final long serialVersionUID = 1L;

	private transient IQualifiedNameProvider qualifiedNameProvider;

	@Inject
	public EdeltaENamedElementXExpressionMap(IQualifiedNameProvider qualifiedNameProvider) {
		this.qualifiedNameProvider = qualifiedNameProvider;
	}

	public XExpression get(ENamedElement element) {
		return super.get(qualifiedNameProvider.getFullyQualifiedName(element));
	}

	public void put(ENamedElement element, XExpression expression) {
		super.put(qualifiedNameProvider.getFullyQualifiedName(element), expression);
	}

}
