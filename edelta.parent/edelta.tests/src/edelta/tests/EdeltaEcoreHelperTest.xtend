/*
 * generated by Xtext 2.10.0
 */
package edelta.tests

import com.google.inject.Inject
import edelta.util.EdeltaEcoreHelper
import org.eclipse.emf.ecore.ENamedElement
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(XtextRunner)
@InjectWith(EdeltaInjectorProviderCustom)
class EdeltaEcoreHelperTest extends EdeltaAbstractTest {

	@Inject extension EdeltaEcoreHelper

	@Test
	def void testProgramENamedElements() {
		referencesToMetamodels.parseWithTestEcores.
			getProgramENamedElements.
			assertNamedElements(
				'''
				FooClass
				myAttribute
				myReference
				FooDataType
				FooEnum
				FooEnumLiteral
				BarClass
				myAttribute
				myReference
				BarDataType
				foo
				bar
				'''
			)
	}

	@Test
	def void testProgramWithCreatedEClassENamedElements() {
		referenceToCreatedEClass.parseWithTestEcore => [
			getProgramENamedElements.
			assertNamedElements(
				'''
				NewClass
				FooClass
				myAttribute
				myReference
				FooDataType
				FooEnum
				FooEnumLiteral
				foo
				'''
			)
		// NewClass is the one created in the program
		]
	}

	@Test
	def void testEPackageENamedElements() {
		referenceToMetamodel.parseWithTestEcore => [
			getENamedElements(getEPackageByName("foo"), it).
			assertNamedElements(
				'''
				FooClass
				FooDataType
				FooEnum
				'''
			)
		]
	}

	@Test
	def void testEPackageENamedElementsWithCreatedEClass() {
		referenceToCreatedEClass.parseWithTestEcore => [
			getENamedElements(getEPackageByName("foo"), it).
			assertNamedElements(
				'''
				NewClass
				FooClass
				FooDataType
				FooEnum
				'''
			)
		// NewClass is the one created in the program
		]
	}

	@Test
	def void testEDataTypeENamedElements() {
		referenceToMetamodel.parseWithTestEcore => [
			getENamedElements(getEClassifierByName("foo", "FooDataType"), it).
			assertNamedElements(
				'''

				'''
			)
		]
	}

	@Test
	def void testENumENamedElements() {
		referenceToMetamodel.parseWithTestEcore => [
			getENamedElements(getEClassifierByName("foo", "FooEnum"), it).
			assertNamedElements(
				'''
				FooEnumLiteral
				'''
			)
		]
	}

	@Test(expected=IllegalArgumentException)
	def void testNullENamedElements() {
		referenceToMetamodel.parseWithTestEcore => [
			getENamedElements(null, it)
		]
	}

	@Test
	def void testEClassENamedElements() {
		referenceToMetamodel.parseWithTestEcore => [
			getENamedElements(getEClassifierByName("foo", "FooClass"), it).
			assertNamedElements(
				'''
				myAttribute
				myReference
				'''
			)
		]
	}

	def private assertNamedElements(Iterable<? extends ENamedElement> elements, CharSequence expected) {
		expected.assertEqualsStrings(
			elements.map[name].join("\n") + "\n"
		)
	}

}
