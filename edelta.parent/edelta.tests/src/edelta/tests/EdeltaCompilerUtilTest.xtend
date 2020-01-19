package edelta.tests

import com.google.inject.Inject
import edelta.compiler.EdeltaCompilerUtil
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

import static extension org.junit.Assert.*

@RunWith(XtextRunner)
@InjectWith(EdeltaInjectorProviderCustom)
class EdeltaCompilerUtilTest extends EdeltaAbstractTest {

	@Inject extension EdeltaCompilerUtil

	@Test
	def void testMethodNameForCreatedEClass() {
		val program = '''
		package test
		
		metamodel "foo"
		
		createEClass First in foo
		createEClass Second in foo
		createEClass Third in 
		'''.
		parseWithTestEcore
		program.main.expressions => [
			assertEquals("_createEClass_First_in_foo", get(0).methodName)
			assertEquals("_createEClass_Second_in_foo", get(1).methodName)
			assertEquals("_createEClass_Third_in_", get(2).methodName)
		]
	}

	@Test
	def void testConsumerArgumentForCreateEClassSuperTypesEmpty() {
		'''
			metamodel "foo"
			
			createEClass MyDerivedNewClass in foo {
			}
		'''.parseWithTestEcore.
		main.expressions => [
			'''
createList(this::_createEClass_MyDerivedNewClass_in_foo)
			'''.toString.trim.
				assertEquals(
					head.
						createEClassExpression.
						consumerArguments.trim
				)
		]
	}

	@Test
	def void testConsumerArgumentForCreateEClassSuperTypes() {
		'''
			metamodel "foo"
			
			createEClass MyDerivedNewClass in foo extends FooClass {
			}
		'''.parseWithTestEcore.
		main.expressions => [
			'''
createList(
    c -> {
      c.getESuperTypes().add(getEClass("foo", "FooClass"));
    },
    this::_createEClass_MyDerivedNewClass_in_foo
  )
			'''.toString.trim.
				assertEquals(
					head.
						createEClassExpression.
						consumerArguments.trim
				)
		]
	}

	@Test
	def void testConsumerArgumentForChaneEClassWithNoChange() {
		'''
			metamodel "foo"
			
			changeEClass foo.FooClass {
			}
		'''.parseWithTestEcore.
		main.expressions => [
			'''
createList(this::_changeEClass_FooClass_in_foo)
			'''.toString.trim.
				assertEquals(
					head.
						changeEClassExpression.
						consumerArguments.trim
				)
		]
	}

	@Test
	def void testConsumerArgumentForChaneEClassWithNewName() {
		'''
			metamodel "foo"
			
			changeEClass foo.FooClass newName Renamed {
			}
		'''.parseWithTestEcore.
		main.expressions => [
			'''
createList(
    c -> c.setName("Renamed"),
    this::_changeEClass_FooClass_in_foo
  )
			'''.toString.trim.
				assertEquals(
					head.
						changeEClassExpression.
						consumerArguments.trim
				)
		]
	}

	@Test
	def void testMethodNameForCreatedEAttribute() {
		val program = '''
		package test
		
		metamodel "foo"
		
		createEClass First in foo {
			createEAttribute inFirst {}
		}
		createEClass Second in foo {
			createEAttribute inSecond {}
		}
		createEClass Third in {
			createEAttribute inSecond {}
		}
		'''.
		parseWithTestEcore
		program.main.expressions => [
			assertEquals("_createEAttribute_inFirst_in_createEClass_First_in_foo",
				get(0).createEClassExpression.body.expressions.head.methodName)
			assertEquals("_createEAttribute_inSecond_in_createEClass_Second_in_foo",
				get(1).createEClassExpression.body.expressions.head.methodName)
			assertEquals("_createEAttribute_inSecond_in_createEClass_Third_in_",
				get(2).createEClassExpression.body.expressions.head.methodName)
		]
	}

	@Test
	def void testConsumerArgumentForCreateEAttributeType() {
		'''
			metamodel "foo"
			
			createEClass MyDerivedNewClass in foo {
				createEAttribute attr type FooDataType
			}
		'''.parseWithTestEcore.
		main.expressions => [
			'''
createList(
    a -> a.setEType(getEDataType("foo", "FooDataType")),
    this::_createEAttribute_attr_in_createEClass_MyDerivedNewClass_in_foo
  )
			'''.toString.trim.
				assertEquals(
					head.
						createEClassExpression.
						body.expressions.last.createEAttributExpression.
						consumerArguments.trim
				)
		]
	}

	@Test
	def void testConsumerArgumentForCreateEAttributeNullType() {
		'''
			metamodel "foo"
			
			createEClass MyDerivedNewClass in foo {
				createEAttribute attr 
			}
		'''.parseWithTestEcore.
		main.expressions => [
			'''
createList(this::_createEAttribute_attr_in_createEClass_MyDerivedNewClass_in_foo)
			'''.toString.trim.
				assertEquals(
					head.
						createEClassExpression.
						body.expressions.last.createEAttributExpression.
						consumerArguments.trim
				)
		]
	}

	@Test
	def void testMethodNameForXExpression() {
		val program = '''
		package test
		
		eclass Foo
		'''.
		parseWithTestEcore
		program.main.expressions => [
			assertNull("_createEClass_First_in_foo", get(0).methodName)
		]
	}

	@Test(expected=IllegalArgumentException)
	def void testMethodNameForNull() {
		assertNull("_createEClass_First_in_foo", methodName(null))
	}

	@Test
	def void testConsumerArgumentForBodyNotSpecified() {
		'''
			metamodel "foo"
			
			createEClass MyNewClass in foo
		'''.parseWithTestEcore.
		main.expressions => [
			"createList(this::_createEClass_MyNewClass_in_foo)".
				assertEquals(head.createEClassExpression.consumerArguments)
		]
	}

	@Test
	def void testConsumerArgumentForBody() {
		'''
			metamodel "foo"
			
			createEClass MyDerivedNewClass in foo {
				ESuperTypes += ecoreref(MyNewClass)
			}
		'''.parseWithTestEcore.
		main.expressions => [
			"createList(this::_createEClass_MyDerivedNewClass_in_foo)".
				assertEquals(head.createEClassExpression.consumerArguments)
		]
	}

	@Test
	def void testEPackageNameOrNull() {
		'''
			metamodel "foo"
			
			createEClass MyNewClass in foo

			createEClass MyNewClass in NonExistant
			
			createEClass MyDerivedNewClass 
		'''.parseWithTestEcore.
		main.expressions => [
			"foo".
				assertEquals(head.createEClassExpression.epackage.EPackageNameOrNull)
			assertNull(get(1).createEClassExpression.epackage.EPackageNameOrNull)
			assertNull(last.createEClassExpression.epackage.EPackageNameOrNull)
		]
	}

	@Test
	def void testNameOrNull() {
		assertNull(getNameOrNull(null))
		assertEquals("Test", getNameOrNull(
			EcoreFactory.eINSTANCE.createEClass => [ name = "Test" ]
		))
	}

	@Test
	def void testGetStringForEcoreReferenceExpressionEClass() {
		'''
			metamodel "foo"
			
			ecoreref(FooClass)
		'''.parseWithTestEcore.
		lastExpression.edeltaEcoreReferenceExpression => [
			'getEClass("foo", "FooClass")'.
				assertEquals(stringForEcoreReferenceExpression)
		]
	}

	@Test
	def void testGetStringForEcoreReferenceExpressionEAttribute() {
		'''
			metamodel "foo"
			
			ecoreref(myAttribute)
		'''.parseWithTestEcore.
		lastExpression.edeltaEcoreReferenceExpression => [
			'getEAttribute("foo", "FooClass", "myAttribute")'.
				assertEquals(stringForEcoreReferenceExpression)
		]
	}

	@Test
	def void testGetStringForEcoreReferenceExpressionEEnumLiteral() {
		'''
			metamodel "foo"
			
			ecoreref(FooEnumLiteral)
		'''.parseWithTestEcore.
		lastExpression.edeltaEcoreReferenceExpression => [
			'getEEnumLiteral("foo", "FooEnum", "FooEnumLiteral")'.
				assertEquals(stringForEcoreReferenceExpression)
		]
	}

	@Test
	def void testGetStringForEcoreReferenceExpressionEPackage() {
		'''
			metamodel "foo"
			
			ecoreref(foo)
		'''.parseWithTestEcore.
		lastExpression.edeltaEcoreReferenceExpression => [
			'getEPackage("foo")'.
				assertEquals(stringForEcoreReferenceExpression)
		]
	}

	@Test
	def void testGetStringForEcoreReferenceExpressionIncomplete() {
		'''
			metamodel "foo"
			
			ecoreref
		'''.parseWithTestEcore.
		lastExpression.edeltaEcoreReferenceExpression => [
			'null'.
				assertEquals(stringForEcoreReferenceExpression)
		]
	}

	@Test
	def void testGetStringForEcoreReferenceExpressionUnresolved() {
		'''
			metamodel "foo"
			
			ecoreref(NonExistant)
		'''.parseWithTestEcore.
		lastExpression.edeltaEcoreReferenceExpression => [
			'getENamedElement("", "", "")'.
				assertEquals(stringForEcoreReferenceExpression)
		]
	}

	@Test
	def void testGetStringForEcoreReferenceExpressionEClassInThePresenceOfCreateEClass() {
		'''
			metamodel "foo"
			
			createEClass NewClass in foo {}
			ecoreref(FooClass)
		'''.parseWithTestEcore.
		lastExpression.edeltaEcoreReferenceExpression => [
			'getEClass("foo", "FooClass")'.
				assertEquals(stringForEcoreReferenceExpression)
		]
	}

	@Test
	def void testGetStringForEcoreReferenceExpressionEClassWhenCreateEClassStealingAttribute() {
		createEClassStealingAttribute.parseWithTestEcore.
		lastExpression.
			createEClassExpression.body.expressions.head.variableDeclaration.right.
			edeltaEcoreReferenceExpression => [
			'getEAttribute("foo", "FooClass", "myAttribute")'.
				assertEquals(stringForEcoreReferenceExpression)
		]
	}

	@Test
	def void testGetStringForEcoreReferenceExpressionEClassWhenChangeEClassRemovingAttribute() {
		changeEClassRemovingAttribute.parseWithTestEcore.
		lastExpression.
			changeEClassExpression.body.expressions.head.variableDeclaration.right.
			edeltaEcoreReferenceExpression => [
			'getEAttribute("foo", "FooClass", "myAttribute")'.
				assertEquals(stringForEcoreReferenceExpression)
		]
	}
}
