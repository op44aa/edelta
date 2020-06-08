package edelta.tests

import com.google.common.base.Joiner
import com.google.inject.Inject
import edelta.testutils.EdeltaTestUtils
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.resource.FileExtensionProvider
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.util.JavaVersion
import org.eclipse.xtext.xbase.lib.util.ReflectExtensions
import org.eclipse.xtext.xbase.testing.CompilationTestHelper
import org.eclipse.xtext.xbase.testing.CompilationTestHelper.Result
import org.eclipse.xtext.xbase.testing.TemporaryFolder
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

import static edelta.testutils.EdeltaTestUtils.*

import static extension org.junit.Assert.*
import java.util.List

@RunWith(XtextRunner)
@InjectWith(EdeltaInjectorProviderTestableDerivedStateComputer)
class EdeltaCompilerTest extends EdeltaAbstractTest {

	@Rule @Inject public TemporaryFolder temporaryFolder
	@Inject extension CompilationTestHelper compilationTestHelper
	@Inject FileExtensionProvider extensionProvider
	@Inject extension ReflectExtensions

	static final String MODIFIED = "modified";

	@Before
	def void setup() {
		compilationTestHelper.javaVersion = JavaVersion.JAVA8
	}

	@Test
	def void testEmptyProgram() {
		''''''.checkCompilation(
			'''
			package edelta;
			
			import edelta.lib.AbstractEdelta;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  public MyFile0() {
			    
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			}
			'''
		)
	}

	@Test
	def void testIncompleteProgram() {
		'''metamodel '''.checkCompilation(
			'''
			package edelta;
			
			import edelta.lib.AbstractEdelta;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  public MyFile0() {
			    
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			}
			''',
			false
		)
	}

	@Test
	def void testProgramWithPackage() {
		'''
		package foo
		'''.checkCompilation(
			'''
			package foo;
			
			import edelta.lib.AbstractEdelta;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  public MyFile0() {
			    
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			}
			'''
		)
	}

	@Test
	def void testOperationWithInferredReturnType() {
		operationWithInferredReturnType.checkCompilation(
			'''
			package foo;
			
			import edelta.lib.AbstractEdelta;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  public MyFile0() {
			    
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public boolean bar(final String s) {
			    return s.isEmpty();
			  }
			}
			'''
		)
	}

	@Test
	def void testOperationWithReturnType() {
		operationWithReturnType.checkCompilation(
			'''
			package foo;
			
			import edelta.lib.AbstractEdelta;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  public MyFile0() {
			    
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public boolean bar(final String s) {
			    return s.isEmpty();
			  }
			}
			'''
		)
	}

	@Test
	def void testOperationAccessingLib() {
		operationAccessingLib.checkCompilation(
			'''
			package foo;
			
			import edelta.lib.AbstractEdelta;
			import org.eclipse.emf.ecore.EClass;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  public MyFile0() {
			    
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public EClass bar(final String s) {
			    return this.lib.newEClass(s);
			  }
			}
			'''
		)
	}

	@Test
	def void testOperationNewEClassWithInitializer() {
		operationNewEClassWithInitializer.checkCompilation(
			'''
			package foo;
			
			import edelta.lib.AbstractEdelta;
			import java.util.function.Consumer;
			import org.eclipse.emf.common.util.EList;
			import org.eclipse.emf.ecore.EClass;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  public MyFile0() {
			    
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public EClass bar(final String s) {
			    final Consumer<EClass> _function = (EClass it) -> {
			      EList<EClass> _eSuperTypes = it.getESuperTypes();
			      EClass _newEClass = this.lib.newEClass("Base");
			      _eSuperTypes.add(_newEClass);
			    };
			    return this.lib.newEClass(s, _function);
			  }
			}
			'''
		)
	}

	@Test
	def void testCompilationOfEcoreReferenceExpression() {
		'''
		package foo;
		
		metamodel "foo"
		
		modifyEcore aTest epackage foo {
			ecoreref(foo)
			println(ecoreref(foo))
			ecoreref(FooClass)
			println(ecoreref(FooClass))
			ecoreref(myAttribute)
			println(ecoreref(myAttribute))
			ecoreref(FooEnum)
			println(ecoreref(FooEnum))
			ecoreref(FooEnumLiteral)
			println(ecoreref(FooEnumLiteral))
			val ref = ecoreref(myReference)
		}
		'''.checkCompilation(
			'''
			package foo;
			
			import edelta.lib.AbstractEdelta;
			import org.eclipse.emf.ecore.EAttribute;
			import org.eclipse.emf.ecore.EClass;
			import org.eclipse.emf.ecore.EEnum;
			import org.eclipse.emf.ecore.EEnumLiteral;
			import org.eclipse.emf.ecore.EPackage;
			import org.eclipse.emf.ecore.EReference;
			import org.eclipse.xtext.xbase.lib.InputOutput;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  public MyFile0() {
			    
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public void aTest(final EPackage it) {
			    getEPackage("foo");
			    InputOutput.<EPackage>println(getEPackage("foo"));
			    getEClass("foo", "FooClass");
			    InputOutput.<EClass>println(getEClass("foo", "FooClass"));
			    getEAttribute("foo", "FooClass", "myAttribute");
			    InputOutput.<EAttribute>println(getEAttribute("foo", "FooClass", "myAttribute"));
			    getEEnum("foo", "FooEnum");
			    InputOutput.<EEnum>println(getEEnum("foo", "FooEnum"));
			    getEEnumLiteral("foo", "FooEnum", "FooEnumLiteral");
			    InputOutput.<EEnumLiteral>println(getEEnumLiteral("foo", "FooEnum", "FooEnumLiteral"));
			    final EReference ref = getEReference("foo", "FooClass", "myReference");
			  }
			  
			  @Override
			  public void performSanityChecks() throws Exception {
			    ensureEPackageIsLoaded("foo");
			  }
			  
			  @Override
			  protected void doExecute() throws Exception {
			    aTest(getEPackage("foo"));
			  }
			}
			'''
		)
	}

	@Test
	def void testCompilationOfEclassExpressionWithNonExistantEClass() {
		'''
		package foo;
		
		metamodel "foo"
		
		modifyEcore aTest epackage foo {
			ecoreref(NonExistent)
		}
		'''.checkCompilation(
			'''
			package foo;
			
			import edelta.lib.AbstractEdelta;
			import org.eclipse.emf.ecore.EPackage;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  public MyFile0() {
			    
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public void aTest(final EPackage it) {
			    getENamedElement("", "", "");
			  }
			  
			  @Override
			  public void performSanityChecks() throws Exception {
			    ensureEPackageIsLoaded("foo");
			  }
			  
			  @Override
			  protected void doExecute() throws Exception {
			    aTest(getEPackage("foo"));
			  }
			}
			''',
			false
		)
	}

	@Test
	def void testReferenceToCreatedEClass() {
		referenceToCreatedEClass.checkCompilation(
			'''
			package edelta;
			
			import edelta.lib.AbstractEdelta;
			import org.eclipse.emf.ecore.EPackage;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  public MyFile0() {
			    
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public void aTest(final EPackage it) {
			    this.lib.addNewEClass(it, "NewClass");
			  }
			  
			  public void anotherTest(final EPackage it) {
			    getEClass("foo", "NewClass");
			  }
			  
			  @Override
			  public void performSanityChecks() throws Exception {
			    ensureEPackageIsLoaded("foo");
			  }
			  
			  @Override
			  protected void doExecute() throws Exception {
			    aTest(getEPackage("foo"));
			    anotherTest(getEPackage("foo"));
			  }
			}
			'''
		)
	}

	@Test
	def void testReferenceToCreatedEClassRenamed() {
		// the name of the created EClass is changed
		// in the initialization block and the interpreter is executed
		// thus, we can access them both, but both with the new name.
		// However, a validation error is issued
		// see: https://github.com/LorenzoBettini/edelta/issues/113
		referenceToCreatedEClassRenamed.checkCompilation(
			'''
			package edelta;
			
			import edelta.lib.AbstractEdelta;
			import org.eclipse.emf.ecore.EPackage;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  public MyFile0() {
			    
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public void creation(final EPackage it) {
			    this.lib.addNewEClass(it, "NewClass");
			  }
			  
			  public void renaming(final EPackage it) {
			    getEClass("foo", "NewClass").setName("changed");
			  }
			  
			  public void accessing(final EPackage it) {
			    getEClass("foo", "changed");
			    getEClass("foo", "changed");
			  }
			  
			  @Override
			  public void performSanityChecks() throws Exception {
			    ensureEPackageIsLoaded("foo");
			  }
			  
			  @Override
			  protected void doExecute() throws Exception {
			    creation(getEPackage("foo"));
			    renaming(getEPackage("foo"));
			    accessing(getEPackage("foo"));
			  }
			}
			''',
			false
		)
	}

	@Test
	def void testUseAs() {
		useAsCustomEdeltaCreatingEClass.checkCompilation(
			'''
			package edelta;
			
			import edelta.lib.AbstractEdelta;
			import edelta.tests.additional.MyCustomEdelta;
			import org.eclipse.emf.ecore.EPackage;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  private MyCustomEdelta my;
			  
			  public MyFile0() {
			    my = new MyCustomEdelta(this);
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public void aTest(final EPackage it) {
			    this.my.createANewEAttribute(
			      this.my.createANewEClass());
			  }
			  
			  @Override
			  public void performSanityChecks() throws Exception {
			    ensureEPackageIsLoaded("foo");
			  }
			  
			  @Override
			  protected void doExecute() throws Exception {
			    aTest(getEPackage("foo"));
			  }
			}
			'''
		)
	}

	@Test
	def void testUseAsExtension() {
		useAsCustomEdeltaAsExtensionCreatingEClass.checkCompilation(
			'''
			package edelta;
			
			import edelta.lib.AbstractEdelta;
			import edelta.tests.additional.MyCustomEdelta;
			import org.eclipse.emf.ecore.EPackage;
			import org.eclipse.xtext.xbase.lib.Extension;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  @Extension
			  private MyCustomEdelta my;
			  
			  public MyFile0() {
			    my = new MyCustomEdelta(this);
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public void aTest(final EPackage it) {
			    this.my.createANewEAttribute(this.my.createANewEClass());
			  }
			  
			  @Override
			  public void performSanityChecks() throws Exception {
			    ensureEPackageIsLoaded("foo");
			  }
			  
			  @Override
			  protected void doExecute() throws Exception {
			    aTest(getEPackage("foo"));
			  }
			}
			'''
		)
	}

	@Test
	def void testInvalidUseAs() {
		'''
			import edelta.tests.additional.MyCustomEdelta
			
			metamodel "foo"
			
			use MyCustomEdelta as
			use as my
			
			modifyEcore aTest epackage foo {
				my.myMethod()
			}
		'''.checkCompilation(
			'''
			package edelta;
			
			import edelta.lib.AbstractEdelta;
			import edelta.tests.additional.MyCustomEdelta;
			import org.eclipse.emf.ecore.EPackage;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  private Object my;
			  
			  public MyFile0() {
			     = new MyCustomEdelta(this);
			    my = new (this);
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public void aTest(final EPackage it) {
			    this.my./* name is null */;
			  }
			  
			  @Override
			  public void performSanityChecks() throws Exception {
			    ensureEPackageIsLoaded("foo");
			  }
			  
			  @Override
			  protected void doExecute() throws Exception {
			    aTest(getEPackage("foo"));
			  }
			}
			''',
			false
		)
	}

	@Test
	def void testUseAsExecution() {
		// the new created EClass and EAttribute are created by calling a method
		// of a custom Edelta implementation that is used in the program
		useAsCustomEdeltaCreatingEClass.checkCompiledCodeExecution(
			'''
			<?xml version="1.0" encoding="UTF-8"?>
			<ecore:EPackage xmi:version="2.0" xmlns:xmi="http://www.omg.org/XMI" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			    xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore" name="foo" nsURI="http://foo" nsPrefix="foo">
			  <eClassifiers xsi:type="ecore:EClass" name="FooClass"/>
			  <eClassifiers xsi:type="ecore:EClass" name="FooDerivedClass" eSuperTypes="#//FooClass"/>
			  <eClassifiers xsi:type="ecore:EDataType" name="FooDataType" instanceClassName="java.lang.String"/>
			  <eClassifiers xsi:type="ecore:EClass" name="ANewClass">
			    <eStructuralFeatures xsi:type="ecore:EAttribute" name="aNewAttr" eType="ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EString"/>
			  </eClassifiers>
			</ecore:EPackage>
			''',
			true
		)
	}

	@Test
	def void testUseAsExtensionExecution() {
		// the new created EClass and EAttribute are created by calling a method
		// of a custom Edelta implementation that is used in the program
		useAsCustomEdeltaAsExtensionCreatingEClass.checkCompiledCodeExecution(
			'''
			<?xml version="1.0" encoding="UTF-8"?>
			<ecore:EPackage xmi:version="2.0" xmlns:xmi="http://www.omg.org/XMI" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			    xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore" name="foo" nsURI="http://foo" nsPrefix="foo">
			  <eClassifiers xsi:type="ecore:EClass" name="FooClass"/>
			  <eClassifiers xsi:type="ecore:EClass" name="FooDerivedClass" eSuperTypes="#//FooClass"/>
			  <eClassifiers xsi:type="ecore:EDataType" name="FooDataType" instanceClassName="java.lang.String"/>
			  <eClassifiers xsi:type="ecore:EClass" name="ANewClass">
			    <eStructuralFeatures xsi:type="ecore:EAttribute" name="aNewAttr" eType="ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EString"/>
			  </eClassifiers>
			</ecore:EPackage>
			''',
			true
		)
	}

	@Test
	def void testStatefulUseAsExecution() {
		// the new created EClass and EAttribute are created by calling a method
		// of a custom Edelta implementation that is used in the program
		useAsCustomStatefulEdeltaCreatingEClass.checkCompiledCodeExecution(
			'''
			<?xml version="1.0" encoding="UTF-8"?>
			<ecore:EPackage xmi:version="2.0" xmlns:xmi="http://www.omg.org/XMI" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			    xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore" name="foo" nsURI="http://foo" nsPrefix="foo">
			  <eClassifiers xsi:type="ecore:EClass" name="FooClass"/>
			  <eClassifiers xsi:type="ecore:EClass" name="FooDerivedClass" eSuperTypes="#//FooClass"/>
			  <eClassifiers xsi:type="ecore:EDataType" name="FooDataType" instanceClassName="java.lang.String"/>
			  <eClassifiers xsi:type="ecore:EClass" name="ANewClass1">
			    <eStructuralFeatures xsi:type="ecore:EAttribute" name="aNewAttr2" eType="ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EString"/>
			  </eClassifiers>
			  <eClassifiers xsi:type="ecore:EClass" name="ANewClass3">
			    <eStructuralFeatures xsi:type="ecore:EAttribute" name="aNewAttr4" eType="ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EString"/>
			  </eClassifiers>
			</ecore:EPackage>
			''',
			true
		)
	}

	@Test
	def void testModifyEcore() {
		'''
			metamodel "foo"
			
			modifyEcore aModificationTest epackage foo {
				EClassifiers += newEClass("ANewClass") [
					ESuperTypes += newEClass("Base")
				]
			}
		'''.checkCompilation(
			'''
			package edelta;
			
			import edelta.lib.AbstractEdelta;
			import java.util.function.Consumer;
			import org.eclipse.emf.common.util.EList;
			import org.eclipse.emf.ecore.EClass;
			import org.eclipse.emf.ecore.EClassifier;
			import org.eclipse.emf.ecore.EPackage;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  public MyFile0() {
			    
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public void aModificationTest(final EPackage it) {
			    EList<EClassifier> _eClassifiers = it.getEClassifiers();
			    final Consumer<EClass> _function = (EClass it_1) -> {
			      EList<EClass> _eSuperTypes = it_1.getESuperTypes();
			      EClass _newEClass = this.lib.newEClass("Base");
			      _eSuperTypes.add(_newEClass);
			    };
			    EClass _newEClass = this.lib.newEClass("ANewClass", _function);
			    _eClassifiers.add(_newEClass);
			  }
			  
			  @Override
			  public void performSanityChecks() throws Exception {
			    ensureEPackageIsLoaded("foo");
			  }
			  
			  @Override
			  protected void doExecute() throws Exception {
			    aModificationTest(getEPackage("foo"));
			  }
			}
			'''
		)
	}

	@Test
	def void testCompilationRenamedClassInModifyEcore() {
		'''
			metamodel "foo"
			
			modifyEcore modifyFoo epackage foo {
				ecoreref(foo.FooClass).name = "RenamedClass"
				ecoreref(RenamedClass).EStructuralFeatures +=
					newEAttribute("anotherAttr", ecoreref(FooDataType))
				ecoreref(RenamedClass).abstract = true
				ecoreref(foo.RenamedClass) => [abstract = true]
			}
		'''.checkCompilation(
			'''
			package edelta;
			
			import edelta.lib.AbstractEdelta;
			import org.eclipse.emf.common.util.EList;
			import org.eclipse.emf.ecore.EAttribute;
			import org.eclipse.emf.ecore.EClass;
			import org.eclipse.emf.ecore.EPackage;
			import org.eclipse.emf.ecore.EStructuralFeature;
			import org.eclipse.xtext.xbase.lib.ObjectExtensions;
			import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  public MyFile0() {
			    
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public void modifyFoo(final EPackage it) {
			    getEClass("foo", "FooClass").setName("RenamedClass");
			    EList<EStructuralFeature> _eStructuralFeatures = getEClass("foo", "RenamedClass").getEStructuralFeatures();
			    EAttribute _newEAttribute = this.lib.newEAttribute("anotherAttr", getEDataType("foo", "FooDataType"));
			    _eStructuralFeatures.add(_newEAttribute);
			    getEClass("foo", "RenamedClass").setAbstract(true);
			    final Procedure1<EClass> _function = (EClass it_1) -> {
			      it_1.setAbstract(true);
			    };
			    ObjectExtensions.<EClass>operator_doubleArrow(
			      getEClass("foo", "RenamedClass"), _function);
			  }
			  
			  @Override
			  public void performSanityChecks() throws Exception {
			    ensureEPackageIsLoaded("foo");
			  }
			  
			  @Override
			  protected void doExecute() throws Exception {
			    modifyFoo(getEPackage("foo"));
			  }
			}
			'''
		)
	}

	@Test
	def void testExecutionRenamedClassInModifyEcore() {
		'''
			metamodel "foo"
			
			modifyEcore modifyFoo epackage foo {
				ecoreref(foo.FooClass).name = "RenamedClass"
				ecoreref(RenamedClass).EStructuralFeatures +=
					newEAttribute("anotherAttr", ecoreref(FooDataType))
				ecoreref(RenamedClass).abstract = true
			}
		'''.checkCompiledCodeExecution(
			'''
			<?xml version="1.0" encoding="UTF-8"?>
			<ecore:EPackage xmi:version="2.0" xmlns:xmi="http://www.omg.org/XMI" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			    xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore" name="foo" nsURI="http://foo" nsPrefix="foo">
			  <eClassifiers xsi:type="ecore:EClass" name="RenamedClass" abstract="true">
			    <eStructuralFeatures xsi:type="ecore:EAttribute" name="anotherAttr" eType="#//FooDataType"/>
			  </eClassifiers>
			  <eClassifiers xsi:type="ecore:EClass" name="FooDerivedClass" eSuperTypes="#//RenamedClass"/>
			  <eClassifiers xsi:type="ecore:EDataType" name="FooDataType" instanceClassName="java.lang.String"/>
			</ecore:EPackage>
			''',
			true
		)
	}

	@Test
	def void testCompilationAfterInterpretationOfCreatedEClassStealingAttribute() {
		createEClassStealingAttribute.checkCompilation(
			'''
			package edelta;
			
			import edelta.lib.AbstractEdelta;
			import java.util.function.Consumer;
			import org.eclipse.emf.ecore.EClass;
			import org.eclipse.emf.ecore.EPackage;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  public MyFile0() {
			    
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public void aTest(final EPackage it) {
			    final Consumer<EClass> _function = (EClass it_1) -> {
			      this.lib.addEAttribute(it_1, getEAttribute("foo", "FooClass", "myAttribute"));
			    };
			    this.lib.addNewEClass(it, "NewClass", _function);
			  }
			  
			  @Override
			  public void performSanityChecks() throws Exception {
			    ensureEPackageIsLoaded("foo");
			  }
			  
			  @Override
			  protected void doExecute() throws Exception {
			    aTest(getEPackage("foo"));
			  }
			}
			'''
			// Note:
			// it must be getEAttribute("foo", "FooClass", "myAttribute")
			// since we use the originalENamedElement
			// (the interpreter changed the container of myAttribute to NewClass)
		)
	}

	@Test
	def void testCompilationAfterInterpretationChangeEClassRemovingAttribute() {
		changeEClassRemovingAttribute.checkCompilation(
			'''
			package edelta;
			
			import edelta.lib.AbstractEdelta;
			import org.eclipse.emf.common.util.EList;
			import org.eclipse.emf.ecore.EPackage;
			import org.eclipse.emf.ecore.EStructuralFeature;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  public MyFile0() {
			    
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public void aTest(final EPackage it) {
			    EList<EStructuralFeature> _eStructuralFeatures = getEClass("foo", "FooClass").getEStructuralFeatures();
			    _eStructuralFeatures.remove(getEAttribute("foo", "FooClass", "myAttribute"));
			  }
			  
			  @Override
			  public void performSanityChecks() throws Exception {
			    ensureEPackageIsLoaded("foo");
			  }
			  
			  @Override
			  protected void doExecute() throws Exception {
			    aTest(getEPackage("foo"));
			  }
			}
			'''
			// Note:
			// it must be getEAttribute("foo", "FooClass", "myAttribute")
			// since we use the originalENamedElement
			// (the interpeter removes the myAttribute from FooClass)
		)
	}

	@Test
	def void testCompilationOfModifyEcoreCallingLibMethods() {
		modifyEcoreUsingLibMethods.
		checkCompilation(
			'''
			package edelta;
			
			import edelta.lib.AbstractEdelta;
			import java.util.function.Consumer;
			import org.eclipse.emf.ecore.EAttribute;
			import org.eclipse.emf.ecore.EClass;
			import org.eclipse.emf.ecore.EEnum;
			import org.eclipse.emf.ecore.EEnumLiteral;
			import org.eclipse.emf.ecore.EPackage;
			import org.eclipse.emf.ecore.EReference;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  public MyFile0() {
			    
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public void aTest(final EPackage it) {
			    final Consumer<EClass> _function = (EClass it_1) -> {
			      final Consumer<EAttribute> _function_1 = (EAttribute it_2) -> {
			        it_2.setLowerBound(1);
			      };
			      this.lib.addNewEAttribute(it_1, "ANewAttribute", getEDataType("foo", "FooDataType"), _function_1);
			      final Consumer<EReference> _function_2 = (EReference it_2) -> {
			        it_2.setLowerBound(1);
			      };
			      this.lib.addNewEReference(it_1, "ANewReference", getEClass("foo", "FooClass"), _function_2);
			    };
			    this.lib.addNewEClass(it, "ANewClass", _function);
			    final Consumer<EEnum> _function_1 = (EEnum it_1) -> {
			      final Consumer<EEnumLiteral> _function_2 = (EEnumLiteral it_2) -> {
			        it_2.setValue(10);
			      };
			      this.lib.addNewEEnumLiteral(it_1, "ANewEnumLiteral", _function_2);
			    };
			    this.lib.addNewEEnum(it, "ANewEnum", _function_1);
			    this.lib.addNewEDataType(it, "ANewDataType", "java.lang.String");
			    getEClass("foo", "ANewClass");
			    getEAttribute("foo", "ANewClass", "ANewAttribute");
			    getEReference("foo", "ANewClass", "ANewReference");
			    getEEnum("foo", "ANewEnum");
			    getEEnumLiteral("foo", "ANewEnum", "ANewEnumLiteral");
			    getEDataType("foo", "ANewDataType");
			  }
			  
			  @Override
			  public void performSanityChecks() throws Exception {
			    ensureEPackageIsLoaded("foo");
			  }
			  
			  @Override
			  protected void doExecute() throws Exception {
			    aTest(getEPackage("foo"));
			  }
			}
			'''
		)
	}

	@Test
	def void testCompilationEcorerefWhenAttributeRemovedFromOriginalContainer() {
		'''
			metamodel "foo"
			
			modifyEcore modifyFoo epackage foo {
				ecoreref(foo.FooClass).name = "Renamed"
				ecoreref(foo.Renamed).EStructuralFeatures.remove(ecoreref(foo.Renamed.myAttribute))
			}
		'''.checkCompilation(
			'''
			package edelta;
			
			import edelta.lib.AbstractEdelta;
			import org.eclipse.emf.common.util.EList;
			import org.eclipse.emf.ecore.EPackage;
			import org.eclipse.emf.ecore.EStructuralFeature;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  public MyFile0() {
			    
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public void modifyFoo(final EPackage it) {
			    getEClass("foo", "FooClass").setName("Renamed");
			    EList<EStructuralFeature> _eStructuralFeatures = getEClass("foo", "Renamed").getEStructuralFeatures();
			    _eStructuralFeatures.remove(getEAttribute("foo", "Renamed", "myAttribute"));
			  }
			  
			  @Override
			  public void performSanityChecks() throws Exception {
			    ensureEPackageIsLoaded("foo");
			  }
			  
			  @Override
			  protected void doExecute() throws Exception {
			    modifyFoo(getEPackage("foo"));
			  }
			}
			'''
		)
	}

	@Test
	def void testCompilationOfComplexOperationsWithSubPackages() {
		'''
			metamodel "foo"
			
			modifyEcore modifyFoo epackage foo {
				addNewESubpackage("anewsubpackage", "aprefix", "aURI") [
					addNewESubpackage("anestedsubpackage", "aprefix2", "aURI2") [
						addNewEClass("ANestedSubPackageClass")
					]
				]
				ecoreref(anewsubpackage).addNewEClass("NewClass") [
					EStructuralFeatures +=
						newEReference("newTestRef", ecoreref(ANestedSubPackageClass))
				]
				ecoreref(NewClass).name = "RenamedClass"
				ecoreref(RenamedClass).getEStructuralFeatures +=
					newEAttribute("added", ecoreref(FooDataType))
			}
		'''.checkCompilation(
			'''
			package edelta;
			
			import edelta.lib.AbstractEdelta;
			import java.util.function.Consumer;
			import org.eclipse.emf.common.util.EList;
			import org.eclipse.emf.ecore.EAttribute;
			import org.eclipse.emf.ecore.EClass;
			import org.eclipse.emf.ecore.EPackage;
			import org.eclipse.emf.ecore.EReference;
			import org.eclipse.emf.ecore.EStructuralFeature;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  public MyFile0() {
			    
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public void modifyFoo(final EPackage it) {
			    final Consumer<EPackage> _function = (EPackage it_1) -> {
			      final Consumer<EPackage> _function_1 = (EPackage it_2) -> {
			        this.lib.addNewEClass(it_2, "ANestedSubPackageClass");
			      };
			      this.lib.addNewESubpackage(it_1, "anestedsubpackage", "aprefix2", "aURI2", _function_1);
			    };
			    this.lib.addNewESubpackage(it, "anewsubpackage", "aprefix", "aURI", _function);
			    final Consumer<EClass> _function_1 = (EClass it_1) -> {
			      EList<EStructuralFeature> _eStructuralFeatures = it_1.getEStructuralFeatures();
			      EReference _newEReference = this.lib.newEReference("newTestRef", getEClass("foo.anewsubpackage.anestedsubpackage", "ANestedSubPackageClass"));
			      _eStructuralFeatures.add(_newEReference);
			    };
			    this.lib.addNewEClass(getEPackage("foo.anewsubpackage"), "NewClass", _function_1);
			    getEClass("foo.anewsubpackage", "NewClass").setName("RenamedClass");
			    EList<EStructuralFeature> _eStructuralFeatures = getEClass("foo.anewsubpackage", "RenamedClass").getEStructuralFeatures();
			    EAttribute _newEAttribute = this.lib.newEAttribute("added", getEDataType("foo", "FooDataType"));
			    _eStructuralFeatures.add(_newEAttribute);
			  }
			  
			  @Override
			  public void performSanityChecks() throws Exception {
			    ensureEPackageIsLoaded("foo");
			  }
			  
			  @Override
			  protected void doExecute() throws Exception {
			    modifyFoo(getEPackage("foo"));
			  }
			}
			'''
		)
	}

	@Test
	def void testCompilationOfRenameReferencesAcrossEPackages() {
		val rs = createResourceSet(
		'''
			package test
			
			metamodel "testecoreforreferences1"
			metamodel "testecoreforreferences2"

			modifyEcore aTest1 epackage testecoreforreferences1 {
				// renames WorkPlace.persons to renamedPersons
				ecoreref(Person.works).EOpposite.name = "renamedPersons"
			}
			modifyEcore aTest2 epackage testecoreforreferences2 {
				// renames Person.works to renamedWorks
				// using the already renamed feature (was persons)
				ecoreref(renamedPersons).EOpposite.name = "renamedWorks"
			}
		''')
		rs.addEPackagesWithReferencesForTests
		checkCompilation(rs,
			'''
			package test;
			
			import edelta.lib.AbstractEdelta;
			import org.eclipse.emf.ecore.EPackage;
			import org.eclipse.emf.ecore.EReference;
			
			@SuppressWarnings("all")
			public class MyFile0 extends AbstractEdelta {
			  public MyFile0() {
			    
			  }
			  
			  public MyFile0(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public void aTest1(final EPackage it) {
			    EReference _eOpposite = getEReference("testecoreforreferences1", "Person", "works").getEOpposite();
			    _eOpposite.setName("renamedPersons");
			  }
			  
			  public void aTest2(final EPackage it) {
			    EReference _eOpposite = getEReference("testecoreforreferences2", "WorkPlace", "renamedPersons").getEOpposite();
			    _eOpposite.setName("renamedWorks");
			  }
			  
			  @Override
			  public void performSanityChecks() throws Exception {
			    ensureEPackageIsLoaded("testecoreforreferences1");
			    ensureEPackageIsLoaded("testecoreforreferences2");
			  }
			  
			  @Override
			  protected void doExecute() throws Exception {
			    aTest1(getEPackage("testecoreforreferences1"));
			    aTest2(getEPackage("testecoreforreferences2"));
			  }
			}
			''',
			true
		)
	}

	@Test
	def void testExecutionOfComplexOperationsWithSubPackages() {
		'''
			metamodel "foo"
			
			modifyEcore modifyFoo epackage foo {
				addNewESubpackage("anewsubpackage", "anewsubpackage", "http://anewsubpackage") [
					addNewESubpackage("anestedsubpackage", "anestedsubpackage", "http://anestedsubpackage") [
						addNewEClass("ANestedSubPackageClass")
					]
				]
				ecoreref(anewsubpackage).addNewEClass("NewClass") [
					EStructuralFeatures +=
						newEReference("newTestRef", ecoreref(ANestedSubPackageClass))
				]
				ecoreref(NewClass).name = "RenamedClass"
				ecoreref(RenamedClass).getEStructuralFeatures +=
					newEAttribute("added", ecoreref(FooDataType))
			}
		'''.checkCompiledCodeExecution(
			'''
			<?xml version="1.0" encoding="UTF-8"?>
			<ecore:EPackage xmi:version="2.0" xmlns:xmi="http://www.omg.org/XMI" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			    xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore" name="foo" nsURI="http://foo" nsPrefix="foo">
			  <eClassifiers xsi:type="ecore:EClass" name="FooClass"/>
			  <eClassifiers xsi:type="ecore:EClass" name="FooDerivedClass" eSuperTypes="#//FooClass"/>
			  <eClassifiers xsi:type="ecore:EDataType" name="FooDataType" instanceClassName="java.lang.String"/>
			  <eSubpackages name="anewsubpackage" nsURI="http://anewsubpackage" nsPrefix="anewsubpackage">
			    <eClassifiers xsi:type="ecore:EClass" name="RenamedClass">
			      <eStructuralFeatures xsi:type="ecore:EReference" name="newTestRef" eType="#//anewsubpackage/anestedsubpackage/ANestedSubPackageClass"/>
			      <eStructuralFeatures xsi:type="ecore:EAttribute" name="added" eType="#//FooDataType"/>
			    </eClassifiers>
			    <eSubpackages name="anestedsubpackage" nsURI="http://anestedsubpackage" nsPrefix="anestedsubpackage">
			      <eClassifiers xsi:type="ecore:EClass" name="ANestedSubPackageClass"/>
			    </eSubpackages>
			  </eSubpackages>
			</ecore:EPackage>
			''',
			true
		)
	}

	@Test
	def void testCompilationOfSeveralFilesWithUseAs() {
		#[
		'''
			import org.eclipse.emf.ecore.EClass
			import org.eclipse.emf.ecore.EcorePackage

			package test1
			
			def enrichWithReference(EClass c, String prefix) : void {
				c.addNewEReference(prefix + "Ref",
					EcorePackage.eINSTANCE.EObject)
			}
		''',
		'''
			import org.eclipse.emf.ecore.EClass
			import org.eclipse.emf.ecore.EcorePackage
			import test1.MyFile0

			package test2
			
			use test1.MyFile0 as extension my

			def enrichWithAttribute(EClass c, String prefix) : void {
				c.addNewEAttribute(prefix + "Attr",
					EcorePackage.eINSTANCE.EString)
				c.enrichWithReference(prefix)
			}
		''',
		'''
			import org.eclipse.emf.ecore.EClass
			import test2.MyFile1
			
			package test3
			
			metamodel "foo"
			
			use test2.MyFile1 as extension my
			
			modifyEcore aModificationTest epackage foo {
				ecoreref(FooClass)
					.enrichWithAttribute("prefix")
				// attribute and reference are added by the calls
				// to external operations!
				ecoreref(prefixAttr).changeable = true
				ecoreref(prefixRef).containment = true
			}
		'''].checkCompilationOfSeveralFiles(
			#[
				"test3.MyFile2" ->
				'''
				package test3;
				
				import edelta.lib.AbstractEdelta;
				import org.eclipse.emf.ecore.EPackage;
				import org.eclipse.xtext.xbase.lib.Extension;
				import test2.MyFile1;
				
				@SuppressWarnings("all")
				public class MyFile2 extends AbstractEdelta {
				  @Extension
				  private MyFile1 my;
				  
				  public MyFile2() {
				    my = new MyFile1(this);
				  }
				  
				  public MyFile2(final AbstractEdelta other) {
				    super(other);
				  }
				  
				  public void aModificationTest(final EPackage it) {
				    this.my.enrichWithAttribute(getEClass("foo", "FooClass"), "prefix");
				    getEAttribute("foo", "FooClass", "prefixAttr").setChangeable(true);
				    getEReference("foo", "FooClass", "prefixRef").setContainment(true);
				  }
				  
				  @Override
				  public void performSanityChecks() throws Exception {
				    ensureEPackageIsLoaded("foo");
				  }
				  
				  @Override
				  protected void doExecute() throws Exception {
				    aModificationTest(getEPackage("foo"));
				  }
				}
				'''
			]
		)
	}

	@Test
	def void testCompilationOfPersonListExampleModifyEcore() {
		val rs = createResourceSetWithEcore(
			PERSON_LIST_ECORE, PERSON_LIST_ECORE_PATH,
			personListExampleModifyEcore
		)
		rs.
		checkCompilation(
			'''
			package edelta.personlist.example;
			
			import edelta.lib.AbstractEdelta;
			import edelta.refactorings.lib.EdeltaRefactorings;
			import java.util.Collections;
			import java.util.function.Consumer;
			import org.eclipse.emf.ecore.EAttribute;
			import org.eclipse.emf.ecore.EClass;
			import org.eclipse.emf.ecore.EPackage;
			import org.eclipse.emf.ecore.EReference;
			import org.eclipse.xtext.xbase.lib.CollectionLiterals;
			import org.eclipse.xtext.xbase.lib.Extension;
			import org.eclipse.xtext.xbase.lib.ObjectExtensions;
			import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
			
			@SuppressWarnings("all")
			public class Example extends AbstractEdelta {
			  @Extension
			  private EdeltaRefactorings refactorings;
			  
			  public Example() {
			    refactorings = new EdeltaRefactorings(this);
			  }
			  
			  public Example(final AbstractEdelta other) {
			    super(other);
			  }
			  
			  public void improvePerson(final EPackage it) {
			    final Procedure1<EClass> _function = (EClass it_1) -> {
			      this.refactorings.introduceSubclasses(it_1, 
			        getEAttribute("PersonList", "Person", "gender"), 
			        getEEnum("PersonList", "Gender"));
			      this.lib.addEAttribute(it_1, 
			        this.refactorings.mergeAttributes("name", 
			          getEAttribute("PersonList", "Person", "firstname").getEAttributeType(), 
			          Collections.<EAttribute>unmodifiableList(CollectionLiterals.<EAttribute>newArrayList(getEAttribute("PersonList", "Person", "firstname"), getEAttribute("PersonList", "Person", "lastname")))));
			    };
			    ObjectExtensions.<EClass>operator_doubleArrow(
			      getEClass("PersonList", "Person"), _function);
			  }
			  
			  public void introducePlace(final EPackage it) {
			    final Consumer<EClass> _function = (EClass it_1) -> {
			      it_1.setAbstract(true);
			      this.refactorings.extractIntoSuperclass(it_1, Collections.<EAttribute>unmodifiableList(CollectionLiterals.<EAttribute>newArrayList(getEAttribute("PersonList", "LivingPlace", "address"), getEAttribute("PersonList", "WorkPlace", "address"))));
			    };
			    this.lib.addNewEClass(it, "Place", _function);
			  }
			  
			  public void introduceWorkingPosition(final EPackage it) {
			    final Consumer<EClass> _function = (EClass it_1) -> {
			      this.lib.addNewEAttribute(it_1, "description", getEDataType("ecore", "EString"));
			      this.refactorings.extractMetaClass(it_1, getEReference("PersonList", "Person", "works"), "position", "works");
			    };
			    this.lib.addNewEClass(it, "WorkingPosition", _function);
			  }
			  
			  public void improveList(final EPackage it) {
			    this.lib.addEReference(getEClass("PersonList", "List"), 
			      this.refactorings.mergeReferences("places", 
			        getEClass("PersonList", "Place"), 
			        Collections.<EReference>unmodifiableList(CollectionLiterals.<EReference>newArrayList(getEReference("PersonList", "List", "wplaces"), getEReference("PersonList", "List", "lplaces")))));
			  }
			  
			  @Override
			  public void performSanityChecks() throws Exception {
			    ensureEPackageIsLoaded("PersonList");
			    ensureEPackageIsLoaded("ecore");
			  }
			  
			  @Override
			  protected void doExecute() throws Exception {
			    improvePerson(getEPackage("PersonList"));
			    introducePlace(getEPackage("PersonList"));
			    introduceWorkingPosition(getEPackage("PersonList"));
			    improveList(getEPackage("PersonList"));
			  }
			}
			''',
			true
		)
	}

	def private checkCompilation(CharSequence input, CharSequence expectedGeneratedJava) {
		checkCompilation(input, expectedGeneratedJava, true)
	}

	def private checkCompilation(CharSequence input, CharSequence expectedGeneratedJava,
		boolean checkValidationErrors) {
		val rs = createResourceSet(input)
		checkCompilation(rs, expectedGeneratedJava, checkValidationErrors)
	}

	private def void checkCompilation(ResourceSet rs, CharSequence expectedGeneratedJava, boolean checkValidationErrors) {
		rs.compile [
			if (checkValidationErrors) {
				assertNoValidationErrors
			}
			if (expectedGeneratedJava !== null) {
				assertGeneratedJavaCode(expectedGeneratedJava)
			}
			if (checkValidationErrors) {
				assertGeneratedJavaCodeCompiles
			}
		]
	}

	private def void checkCompilationOfSeveralFiles(List<? extends CharSequence> inputs,
		List<Pair<String, CharSequence>> expectations) {
		createResourceSet(inputs).compile [
			assertNoValidationErrors
			for (expectation : expectations) {
				expectation.value.toString.assertEquals
					(getGeneratedCode(expectation.key))
			}
			assertGeneratedJavaCodeCompiles
		]
	}

	private def assertNoValidationErrors(Result it) {
		val allErrors = getErrorsAndWarnings.filter[severity == Severity.ERROR]
		if (!allErrors.empty) {
			throw new IllegalStateException(
				"One or more resources contained errors : " + Joiner.on(',').join(allErrors)
			);
		}
	}

	def private assertGeneratedJavaCode(CompilationTestHelper.Result r, CharSequence expected) {
		expected.toString.assertEquals(r.singleGeneratedCode)
	}

	def private assertGeneratedJavaCodeCompiles(CompilationTestHelper.Result r) {
		r.compiledClass // check Java compilation succeeds
	}

	def private createResourceSet(CharSequence... inputs) {
		val pairs = newArrayList() => [
			list |
			inputs.forEach[e, i|
				list += "MyFile" + i + "." + 
					extensionProvider.getPrimaryFileExtension() -> e
			]
		]
		val rs = resourceSet(pairs)
		addEPackageForTests(rs)
		return rs
	}

	def private createResourceSetWithEcore(String ecoreName, String ecorePath, CharSequence input) {
		val pairs = newArrayList(
			"EcoreForTests.ecore" -> EdeltaTestUtils.loadFile(ECORE_PATH),
			ecoreName -> EdeltaTestUtils.loadFile(ecorePath),
			"Example." + 
					extensionProvider.getPrimaryFileExtension() -> input
		)
		val rs = resourceSet(pairs)
		return rs
	}

	def private checkCompiledCodeExecution(CharSequence input, CharSequence expectedGeneratedEcore,
			boolean checkValidationErrors) {
		wipeModifiedDirectoryContents
		val rs = createResourceSet(input)
		rs.compile [
			if (checkValidationErrors) {
				assertNoValidationErrors
			}
			if (checkValidationErrors) {
				assertGeneratedJavaCodeCompiles
			}
			val genClass = compiledClass
			val edeltaObj = genClass.getDeclaredConstructor().newInstance()
			// load ecore files
			edeltaObj.invoke("loadEcoreFile", #["testecores/foo.ecore"])
			edeltaObj.invoke("execute")
			edeltaObj.invoke("saveModifiedEcores", #[MODIFIED])
			compareSingleFileContents(MODIFIED+"/foo.ecore", expectedGeneratedEcore.toString)
		]
	}

	def private void wipeModifiedDirectoryContents() {
		cleanDirectory(MODIFIED);
	}

}
