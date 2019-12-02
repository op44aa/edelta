package edelta.ui.tests

import com.google.inject.Inject
import edelta.ui.internal.EdeltaActivator
import edelta.ui.tests.utils.EdeltaPluginProjectHelper
import edelta.ui.tests.utils.PDETargetPlatformUtils
import org.eclipse.core.runtime.CoreException
import org.eclipse.xtext.testing.Flaky
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.ui.testing.AbstractOutlineTest
import org.junit.BeforeClass
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

import static org.eclipse.xtext.ui.testing.util.IResourcesSetupUtil.*

@RunWith(XtextRunner)
@InjectWith(EdeltaUiInjectorProvider)
class EdeltaOutlineTest extends AbstractOutlineTest {

	@Inject EdeltaPluginProjectHelper edeltaProjectHelper

	@Rule
	public Flaky.Rule testRule = new Flaky.Rule();

	override protected getEditorId() {
		EdeltaActivator.EDELTA_EDELTA
	}

	override protected createjavaProject(String projectName) throws CoreException {
		// we use a Plug-in project so that types are resolved (e.g., EClass)
		edeltaProjectHelper.createEdeltaPluginProject(TEST_PROJECT)
	}

	@BeforeClass
	def static void beforeClass() {
		PDETargetPlatformUtils.setTargetPlatform();
	}

	@Test
	def void testOutlineWithNoContents() {
		''''''.assertAllLabels(
		'''
		test
		'''
		)
	}

	@Test
	def void testOutlineWithOperation() {
		'''
		def createClass(String name) {
			newEClass(name)
		}
		'''.assertAllLabels(
		'''
		test
		  createClass(String) : EClass
		'''
		)
	}

	@Test
	def void testOutlineWithOperationAndMain() {
		'''
		def createClass(String name) {
			newEClass(name)
		}
		
		println("")
		'''.assertAllLabels(
		'''
		test
		  createClass(String) : EClass
		  doExecute() : void
		'''
		)
	}

	@Test
	def void testOutlineWithCreateEClass() {
		// wait for build so that ecores are indexed
		// and then found by the test programs
		waitForBuild

		'''
		metamodel "mypackage"
		
		createEClass A in mypackage {
			createEAttribute attr type EString {
			}
		}
		'''.assertAllLabels(
		'''
		test
		  doExecute() : void
		  mypackage
		    A
		      attr
		    «allOtherContents»
		'''
		)
	}

	@Test
	def void testOutlineWithCreateEClassAndInterpretedNewAttribute() {
		// wait for build so that ecores are indexed
		// and then found by the test programs
		waitForBuild

		'''
		import org.eclipse.emf.ecore.EClass
		
		metamodel "mypackage"
		// don't rely on ecore, since the input files are not saved
		// during the test, thus external libraries are not seen
		// metamodel "ecore"
		
		def myNewAttribute(EClass c, String name) {
			c.EStructuralFeatures += newEAttribute(name) => [
				EType = ecoreref(MyDataType)
			]
		}
		
		createEClass A in mypackage {
			myNewAttribute(it, "foo")
		}
		'''.assertAllLabels(
		'''
		test
		  myNewAttribute(EClass, String) : boolean
		  doExecute() : void
		  mypackage
		    A
		      foo : MyDataType
		    «allOtherContents»
		'''
		)
	}

	@Test
	def void testOutlineWithCreateEClassAndInterpretedNewAttributeWithUseAs() {
		createFile(
			TEST_PROJECT + "/src/Refactorings.edelta",
			'''
			import org.eclipse.emf.ecore.EClass
			
			package com.example
			
			metamodel "mypackage"
			
			def myNewAttribute(EClass c, String name) {
				c.EStructuralFeatures += newEAttribute(name) => [
					EType = ecoreref(MyDataType)
				]
			}
			'''
		)
		// wait for build so that ecores are indexed
		// and then found by the test programs
		waitForBuild

		'''
		package com.example
		
		metamodel "mypackage"
		// don't rely on ecore, since the input files are not saved
		// during the test, thus external libraries are not seen
		// metamodel "ecore"
		
		use Refactorings as my
		
		createEClass A in mypackage {
			my.myNewAttribute(it, "foo")
		}
		'''.assertAllLabels(
		'''
		com.example
		  doExecute() : void
		  mypackage
		    A
		      foo
		    «allOtherContents»
		'''
		)
	}

	@Test @Flaky
	def void testOutlineWithCreateEClassInModifyEcore() {
		println("*** Executing testOutlineWithCreateEClassInModifyEcore...")
		// wait for build so that ecores are indexed
		// and then found by the test programs
		waitForBuild

		'''
		import org.eclipse.emf.ecore.EClass
		
		metamodel "mypackage"
		// don't rely on ecore, since the input files are not saved
		// during the test, thus external libraries are not seen
		// metamodel "ecore"
		
		def myNewAttribute(EClass c, String name) {
			c.EStructuralFeatures += newEAttribute(name) => [
				EType = ecoreref(MyDataType)
			]
		}
		
		modifyEcore aModification epackage mypackage {
			EClassifiers += newEClass("A")
			myNewAttribute(ecoreref(A), "foo")
		}
		'''.assertAllLabels(
		'''
		test
		  myNewAttribute(EClass, String) : boolean
		  aModification(EPackage) : void
		  mypackage
		    «allOtherContents»
		    A
		      foo : MyDataType
		'''
		)
	}

	@Test @Flaky
	def void testOutlineWithRemovedElementsInModifyEcore() {
		println("*** Executing testOutlineWithRemovedElementsInModifyEcore...")
		// wait for build so that ecores are indexed
		// and then found by the test programs
		waitForBuild

		'''
		import org.eclipse.emf.ecore.EClass
		
		metamodel "mypackage"
		
		modifyEcore aModification epackage mypackage {
			EClassifiers -= ecoreref(MyClass)
			ecoreref(MyDerivedClass).ESuperTypes -= ecoreref(MyBaseClass)
			EClassifiers -= ecoreref(MyBaseClass)
		}
		'''.assertAllLabels(
		'''
		test
		  aModification(EPackage) : void
		  mypackage
		    MyDataType [java.lang.String]
		    MyDerivedClass
		      myDerivedAttribute : EString
		      myDerivedReference : EObject
		'''
		)
	}


	def private allOtherContents()
	'''
	    MyClass
	      myAttribute : EString
	      myReference : EObject
	    MyDataType [java.lang.String]
	    MyBaseClass
	      myBaseAttribute : EString
	      myBaseReference : EObject
	    MyDerivedClass -> MyBaseClass
	      myDerivedAttribute : EString
	      myDerivedReference : EObject
	      MyBaseClass
	'''
}
