package edelta.tests

import com.google.inject.Inject
import edelta.edelta.EdeltaEcoreCreateEClassExpression
import edelta.resource.EdeltaDerivedStateComputer
import edelta.resource.EdeltaDerivedStateComputer.EdeltaDerivedStateAdapter
import java.util.Map
import org.eclipse.emf.common.notify.impl.AdapterImpl
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceImpl
import org.eclipse.xtext.common.types.JvmGenericType
import org.eclipse.xtext.resource.DerivedStateAwareResource
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(XtextRunner)
@InjectWith(EdeltaInjectorProviderCustom)
class EdeltaDerivedStateComputerTest extends EdeltaAbstractTest {

	@Inject extension TestableEdeltaDerivedStateComputer

	/**
	 * Make protected members public for testing
	 */
	static class TestableEdeltaDerivedStateComputer extends EdeltaDerivedStateComputer {

		override public getOrInstallAdapter(Resource resource) {
			super.getOrInstallAdapter(resource)
		}

		override public unloadDerivedPackages(Map<String, EPackage> nameToEPackageMap) {
			super.unloadDerivedPackages(nameToEPackageMap)
		}

		override public derivedToSourceMap(Resource resource) {
			super.derivedToSourceMap(resource)
		}

		override public nameToEPackageMap(Resource resource) {
			super.nameToEPackageMap(resource)
		}

	}

	@Test
	def void testGetOrInstallAdapterWithNotXtextResource() {
		assertNotNull(getOrInstallAdapter(new ResourceImpl))
	}

	@Test
	def void testGetOrInstallAdapterWithXtextResourceOfADifferentLanguage() {
		val res = new XtextResource
		res.languageName = "foo"
		assertNotNull(getOrInstallAdapter(res))
	}

	@Test
	def void testIsAdapterFor() {
		val adapter = getOrInstallAdapter(new ResourceImpl)
		assertTrue(adapter.isAdapterForType(EdeltaDerivedStateAdapter))
		assertFalse(adapter.isAdapterForType(String))
	}

	@Test
	def void testDerivedStateForCreatedEClass() {
		val program = '''
		package test
		
		metamodel "foo"
		
		createEClass First in foo
		'''.
		parseWithTestEcore
		val derivedEClass = program.getDerivedStateLastEClass
		assertEquals("First", derivedEClass.name)
		assertEquals("foo", derivedEClass.EPackage.name)
	}

	@Test
	def void testDerivedStateForCreatedEClassWithSuperTypes() {
		val program = createEClassWithSuperTypes.
			parseWithTestEcore
		val derivedEClass = program.getDerivedStateLastEClass
		// inherited from FooClass
		assertNamedElements(derivedEClass.EAllStructuralFeatures,
			'''
			myAttribute
			myReference
			'''
		)
	}

	@Test
	def void testDerivedStateForTwoCreatedEClass() {
		val program = '''
		package test
		
		metamodel "foo"
		
		createEClass First in foo
		createEClass Second in foo
		'''.
		parseWithTestEcore
		val derivedEClass = program.getDerivedStateLastEClass
		assertEquals("Second", derivedEClass.name)
		assertEquals("foo", derivedEClass.EPackage.name)
	}

	@Test
	def void testDerivedEPackages() {
		val program = '''
		package test
		
		metamodel "foo"
		
		createEClass First in foo
		createEClass Second in foo
		'''.
		parseWithTestEcore
		val derivedEPackages = program.eResource.derivedEPackages
		assertEquals(1, derivedEPackages.size)
		assertEquals("foo", derivedEPackages.head.name)
	}

	@Test
	def void testInstallDerivedStateDuringPreIndexingPhase() {
		val program = '''
		package test
		
		metamodel "foo"
		
		createEClass First in foo
		'''.
		parseWithTestEcore
		val resource = program.eResource as DerivedStateAwareResource
		installDerivedState(program.eResource as DerivedStateAwareResource, true)
		// only program must be there and the inferred Jvm Type
		// since we don't install anything during preIndexingPhase
		assertEquals("test.__synthetic0", (resource.contents.last as JvmGenericType).identifier)
	}

	@Test
	def void testDerivedStateForCreatedEClassWithMissingReferredPackage() {
		val program = '''
		package test
		
		createEClass First in foo
		'''.
		parseWithTestEcore
		val derivedEClass = program.getDerivedStateLastEClass
		assertEquals("First", derivedEClass.name)
		assertNull(derivedEClass.EPackage.name)
	}

	@Test
	def void testDerivedStateForCreatedEClassWithMissingPackage() {
		val program = '''
		package test
		
		createEClass First in 
		'''.
		parseWithTestEcore
		val resource = program.eResource as DerivedStateAwareResource
		// only program must be there and the inferred Jvm Type
		assertEquals("test.__synthetic0", (resource.contents.last as JvmGenericType).identifier)
	}

	@Test
	def void testDerivedStateIsCorrectlyDiscarted() {
		val program = '''
		package test
		
		metamodel "foo"
		
		createEClass First in foo
		'''.
		parseWithTestEcore
		val resource = program.eResource as DerivedStateAwareResource
		assertEquals("First", program.getDerivedStateLastEClass.name)
		// discard derived state
		program.main.expressions.clear
		resource.discardDerivedState
		// only program must be there and the inferred Jvm Type
		assertEquals("test.__synthetic0", (resource.contents.last as JvmGenericType).identifier)
	}

	@Test
	def void testDerivedStateIsCorrectlyDiscartedAndUnloaded() {
		val program = '''
		package test
		
		metamodel "foo"
		
		createEClass First in foo {}
		ecoreref(First)
		'''.
		parseWithTestEcore
		val resource = program.eResource as DerivedStateAwareResource
		val derivedStateEClass = program.getDerivedStateLastEClass
		val eclassRef = program.main.expressions.last.
			edeltaEcoreReferenceExpression.reference.enamedelement
		assertSame(derivedStateEClass, eclassRef)
		assertEquals("First", derivedStateEClass.name)
		assertFalse("should be resolved now", eclassRef.eIsProxy)
		// discard derived state
		program.main.expressions.remove(0)
		resource.discardDerivedState
		// the reference to the EClass is still there
		assertSame(derivedStateEClass, eclassRef)
		// but the EClass is now a proxy
		assertTrue("should be a proxy now", eclassRef.eIsProxy)
	}

	@Test
	def void testAdaptersAreRemovedFromDerivedEPackagesAfterUnloading() {
		val program = '''
		package test
		
		metamodel "foo"
		
		createEClass First in foo
		eclass First
		'''.
		parseWithTestEcore
		val resource = program.eResource as DerivedStateAwareResource
		val derivedToSourceMap = resource.derivedToSourceMap
		val nameToEPackageMap = resource.nameToEPackageMap
		assertFalse(resource.eAdapters.empty)
		assertFalse(derivedToSourceMap.empty)
		assertFalse(nameToEPackageMap.empty)
		// explicitly add an adapter to the EPackage
		nameToEPackageMap.values.head.eAdapters += new AdapterImpl
		assertTrue(nameToEPackageMap.values.forall[!eAdapters.empty])
		// unload packages
		unloadDerivedPackages(nameToEPackageMap)
		// maps are not empty yet
		assertFalse(derivedToSourceMap.empty)
		assertFalse(nameToEPackageMap.empty)
		assertFalse(resource.eAdapters.empty)
		// but adapters have been removed from EPackage
		assertTrue(nameToEPackageMap.values.forall[eAdapters.empty])
	}

	@Test
	def void testMapsAreClearedAfterDiscarding() {
		val program = '''
		package test
		
		metamodel "foo"
		
		createEClass First in foo
		eclass First
		'''.
		parseWithTestEcore
		val resource = program.eResource as DerivedStateAwareResource
		val derivedToSourceMap = resource.derivedToSourceMap
		val nameToEPackageMap = resource.nameToEPackageMap
		assertFalse(resource.eAdapters.empty)
		assertFalse(derivedToSourceMap.empty)
		assertFalse(nameToEPackageMap.empty)
		// discard derived state
		program.main.expressions.remove(0)
		resource.discardDerivedState
		// maps are empty now
		assertTrue(derivedToSourceMap.empty)
		assertTrue(nameToEPackageMap.empty)
		assertFalse(resource.eAdapters.empty)
	}

	@Test
	def void testDerivedStateForCreatedEAttribute() {
		val program = '''
		package test
		
		metamodel "foo"
		
		createEClass First in foo {
			createEAttribute newAttribute
		}
		'''.
		parseWithTestEcore
		val derivedEClass = program.getDerivedStateLastEClass
		val derivedEAttribute = derivedEClass.EStructuralFeatures.head as EAttribute
		assertEquals("newAttribute", derivedEAttribute.name)
		assertEquals("First", derivedEAttribute.EContainingClass.name)
	}

	@Test
	def void testSourceElementOfNull() {
		assertNull(getPrimarySourceElement(null))
	}

	@Test
	def void testSourceElementOfNotDerived() {
		assertNull('''
		package test
		'''.
		parse.getPrimarySourceElement
		)
	}

	@Test
	def void testSourceElementOfCreateEClass() {
		val program = '''
		package test
		
		metamodel "foo"
		
		createEClass First in foo
		'''.
		parseWithTestEcore
		val e = program.lastExpression
		val derived = program.getDerivedStateLastEClass
		assertSame(e, derived.getPrimarySourceElement)
	}

	@Test
	def void testSourceElementOfCreateEAttribute() {
		val program = '''
		package test
		
		metamodel "foo"
		
		createEClass First in foo {
			createEAttribute newAttribute
		}
		'''.
		parseWithTestEcore
		val e = (program.lastExpression as EdeltaEcoreCreateEClassExpression).
			body.expressions.last
		val derivedEClass = program.getDerivedStateLastEClass
		val derivedEAttribute = derivedEClass.EStructuralFeatures.head
		assertSame(e, derivedEAttribute.getPrimarySourceElement)
	}

	@Test
	def void testDerivedEPackagesWithChangeEClass() {
		val program = '''
		package test
		
		metamodel "foo"
		
		changeEClass foo.First {}
		changeEClass foo.Second {}
		'''.
		parseWithTestEcore
		val derivedEPackages = program.eResource.derivedEPackages
		assertEquals(1, derivedEPackages.size)
		assertEquals("foo", derivedEPackages.head.name)
	}

	@Test
	def void testDerivedEClassesWithChangeEClass() {
		val program = '''
		package test
		
		metamodel "foo"
		
		changeEClass foo.FooClass {}
		'''.
		parseWithTestEcore
		val derivedEClass = program.getDerivedStateLastEClass
		assertEquals("FooClass", derivedEClass.name)
	}

	@Test
	def void testDerivedEClassesWithChangeEClassNoOriginalReference() {
		val program = '''
		package test
		
		metamodel "foo"
		
		changeEClass foo. {}
		'''.
		parseWithTestEcore
		val derivedEPackages = program.eResource.derivedEPackages
		assertEquals(0, derivedEPackages.size)
		// no EPackage is added to the derived state, since
		// we don't refer to any existing class
	}

	@Test
	def void testDerivedEClassesWithChangeEClassWithNewName() {
		val program = '''
		package test
		
		metamodel "foo"
		
		changeEClass foo.FooClass newName Renamed {}
		'''.
		parseWithTestEcore
		val derivedEClass = program.getDerivedStateLastEClass
		assertEquals("Renamed", derivedEClass.name)
		val derivedEPackages = program.eResource.derivedEPackages
		assertEquals(1, derivedEPackages.head.EClassifiers.size)
	}

	@Test
	def void testDerivedStateForCreatedEAttributeInChangeEClass() {
		val program = '''
		package test
		
		metamodel "foo"
		
		changeEClass foo.FooClass {
			createEAttribute newAttribute
		}
		'''.
		parseWithTestEcore
		val derivedEClass = program.getDerivedStateLastEClass
		val derivedEAttribute = derivedEClass.EStructuralFeatures.last as EAttribute
		assertEquals("newAttribute", derivedEAttribute.name)
		assertEquals("FooClass", derivedEAttribute.EContainingClass.name)
	}

	@Test
	def void testDerivedStateForCreatedEAttributeInChangeEClassWithNewName() {
		val program = '''
		package test
		
		metamodel "foo"
		
		changeEClass foo.FooClass newName Renamed {
			createEAttribute newAttribute
		}
		'''.
		parseWithTestEcore
		val derivedEClass = program.getDerivedStateLastEClass
		val derivedEAttribute = derivedEClass.EStructuralFeatures.last as EAttribute
		assertEquals("newAttribute", derivedEAttribute.name)
		assertEquals("Renamed", derivedEAttribute.EContainingClass.name)
	}

	@Test
	def void testGetEAttributeElement() {
		val program = '''
		package test
		
		metamodel "foo"
		
		createEClass First in foo {
			createEAttribute newAttribute
		}
		'''.
		parseWithTestEcore
		val e = (program.lastExpression as EdeltaEcoreCreateEClassExpression).
			body.expressions.last
		val derivedEClass = program.getDerivedStateLastEClass
		val derivedEAttribute = derivedEClass.EStructuralFeatures.head
		assertNotNull(derivedEAttribute)
		assertSame(derivedEAttribute, e.getEAttributeElement)
	}

	@Test
	def void testInterpretedCreateEClassAndCallOperationFromUseAs() {
		val program = '''
			import edelta.tests.additional.MyCustomEdelta
			
			metamodel "foo"
			
			use MyCustomEdelta as my
			
			createEClass NewClass in foo {
				my.createANewEAttribute(it)
			}
		'''.
		parseWithTestEcore
		val derivedEClass = program.getDerivedStateLastEClass
		assertEquals("NewClass", derivedEClass.name)
		assertEquals(1, derivedEClass.EStructuralFeatures.size)
		val attr = derivedEClass.EStructuralFeatures.head
		assertEquals("aNewAttr", attr.name)
		assertEquals("EString", attr.EType.name)
	}

	@Test
	def void testInterpretedChangeEClassAndRenameEAttribute() {
		val program = '''
			metamodel "foo"
			
			changeEClass foo.FooClass {
				val attr = ecoreref(FooClass.myAttribute)
				attr.name = "renamed"
			}
		'''.
		parseWithTestEcore
		val derivedEClass = program.getDerivedStateLastEClass
		assertEquals("FooClass", derivedEClass.name)
		val attr = derivedEClass.EStructuralFeatures.head
		assertEquals("renamed", attr.name)
		program.assertNoErrors
	}
}
