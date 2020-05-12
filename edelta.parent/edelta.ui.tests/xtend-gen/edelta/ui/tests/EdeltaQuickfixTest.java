package edelta.ui.tests;

import com.google.inject.Inject;
import edelta.ui.tests.EdeltaUiInjectorProvider;
import edelta.ui.tests.utils.EdeltaPluginProjectHelper;
import edelta.validation.EdeltaValidator;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.testing.InjectWith;
import org.eclipse.xtext.testing.XtextRunner;
import org.eclipse.xtext.ui.testing.AbstractQuickfixTest;
import org.eclipse.xtext.ui.testing.util.IResourcesSetupUtil;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(XtextRunner.class)
@InjectWith(EdeltaUiInjectorProvider.class)
@SuppressWarnings("all")
public class EdeltaQuickfixTest extends AbstractQuickfixTest {
  @Inject
  private EdeltaPluginProjectHelper projectHelper;
  
  @Override
  protected String getFileName() {
    String _fileName = super.getFileName();
    return ("src/" + _fileName);
  }
  
  @Before
  public void setup() {
    try {
      this.projectHelper.createEdeltaPluginProject(this.getProjectName());
      String _projectName = this.getProjectName();
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
      _builder.newLine();
      _builder.append("<ecore:EPackage xmi:version=\"2.0\" xmlns:xmi=\"http://www.omg.org/XMI\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("xmlns:ecore=\"http://www.eclipse.org/emf/2002/Ecore\" name=\"mainpackage\" nsURI=\"http://my.mainpackage.org\" nsPrefix=\"mainpackage\">");
      _builder.newLine();
      _builder.append("  ");
      _builder.append("<eClassifiers xsi:type=\"ecore:EClass\" name=\"MyClass\">");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("<eStructuralFeatures xsi:type=\"ecore:EAttribute\" name=\"myAttribute\" eType=\"ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EString\"/>");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("<eStructuralFeatures xsi:type=\"ecore:EReference\" name=\"myReference\" eType=\"ecore:EClass http://www.eclipse.org/emf/2002/Ecore#//EObject\"/>");
      _builder.newLine();
      _builder.append("  ");
      _builder.append("</eClassifiers>");
      _builder.newLine();
      _builder.append("  ");
      _builder.append("<eSubpackages name=\"subpackage\" nsURI=\"http://mysubpackage\" nsPrefix=\"subpackage\">");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("<eClassifiers xsi:type=\"ecore:EClass\" name=\"MySubPackageClass\"/>");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("<eClassifiers xsi:type=\"ecore:EClass\" name=\"MyClass\">");
      _builder.newLine();
      _builder.append("      ");
      _builder.append("<eStructuralFeatures xsi:type=\"ecore:EAttribute\" name=\"myAttribute\" eType=\"ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EString\"/>");
      _builder.newLine();
      _builder.append("      ");
      _builder.append("<eStructuralFeatures xsi:type=\"ecore:EReference\" name=\"myReference\" eType=\"ecore:EClass http://www.eclipse.org/emf/2002/Ecore#//EObject\"/>");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("</eClassifiers>");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("<eSubpackages name=\"subsubpackage\" nsURI=\"http://mysubsubpackage\" nsPrefix=\"subsubpackage\">");
      _builder.newLine();
      _builder.append("      ");
      _builder.append("<eClassifiers xsi:type=\"ecore:EClass\" name=\"MyClass\">");
      _builder.newLine();
      _builder.append("        ");
      _builder.append("<eStructuralFeatures xsi:type=\"ecore:EAttribute\" name=\"myAttribute\" eType=\"ecore:EDataType http://www.eclipse.org/emf/2002/Ecore#//EString\"/>");
      _builder.newLine();
      _builder.append("        ");
      _builder.append("<eStructuralFeatures xsi:type=\"ecore:EReference\" name=\"myReference\" eType=\"ecore:EClass http://www.eclipse.org/emf/2002/Ecore#//EObject\"/>");
      _builder.newLine();
      _builder.append("      ");
      _builder.append("</eClassifiers>");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("</eSubpackages>");
      _builder.newLine();
      _builder.append("  ");
      _builder.append("</eSubpackages>");
      _builder.newLine();
      _builder.append("</ecore:EPackage>");
      _builder.newLine();
      IResourcesSetupUtil.createFile(_projectName, 
        "src/MySubPackages", "ecore", _builder.toString());
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  @Test
  public void fixSubPackageImport() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("metamodel \"mainpackage.subpackage\"");
    _builder.newLine();
    StringConcatenation _builder_1 = new StringConcatenation();
    _builder_1.append("metamodel \"mainpackage\"");
    _builder_1.newLine();
    AbstractQuickfixTest.Quickfix _quickfix = new AbstractQuickfixTest.Quickfix("Import root EPackage", 
      "Import root EPackage \'mainpackage\'", _builder_1.toString());
    this.testQuickfixesOn(_builder, EdeltaValidator.INVALID_SUBPACKAGE_IMPORT, _quickfix);
  }
  
  @Test
  public void fixSubPackageImportWithSeveralImports() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("metamodel \"foo\"");
    _builder.newLine();
    _builder.append("metamodel \"mainpackage.subpackage.subsubpackage\"");
    _builder.newLine();
    StringConcatenation _builder_1 = new StringConcatenation();
    _builder_1.append("metamodel \"foo\"");
    _builder_1.newLine();
    _builder_1.append("metamodel \"mainpackage\"");
    _builder_1.newLine();
    AbstractQuickfixTest.Quickfix _quickfix = new AbstractQuickfixTest.Quickfix("Import root EPackage", 
      "Import root EPackage \'mainpackage\'", _builder_1.toString());
    this.testQuickfixesOn(_builder, EdeltaValidator.INVALID_SUBPACKAGE_IMPORT, _quickfix);
  }
  
  @Test
  public void fixAccessToRenamedElement() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("metamodel \"mainpackage\"");
    _builder.newLine();
    _builder.newLine();
    _builder.append("modifyEcore renaming epackage mainpackage {");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("ecoreref(subsubpackage.MyClass.myAttribute).name = \"Renamed\"");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("modifyEcore access epackage mainpackage {");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("ecoreref(subsubpackage.MyClass.myAttribute)");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    StringConcatenation _builder_1 = new StringConcatenation();
    _builder_1.append("metamodel \"mainpackage\"");
    _builder_1.newLine();
    _builder_1.newLine();
    _builder_1.append("modifyEcore renaming epackage mainpackage {");
    _builder_1.newLine();
    _builder_1.append("\t");
    _builder_1.append("ecoreref(subsubpackage.MyClass.myAttribute).name = \"Renamed\"");
    _builder_1.newLine();
    _builder_1.append("}");
    _builder_1.newLine();
    _builder_1.newLine();
    _builder_1.append("modifyEcore access epackage mainpackage {");
    _builder_1.newLine();
    _builder_1.append("\t");
    _builder_1.append("ecoreref(mainpackage.subpackage.subsubpackage.MyClass.Renamed)");
    _builder_1.newLine();
    _builder_1.append("}");
    _builder_1.newLine();
    AbstractQuickfixTest.Quickfix _quickfix = new AbstractQuickfixTest.Quickfix("Use renamed element", 
      "Use renamed element \'mainpackage.subpackage.subsubpackage.MyClass.Renamed\'", _builder_1.toString());
    this.testQuickfixesOn(_builder, EdeltaValidator.INTERPRETER_ACCESS_RENAMED_ELEMENT, _quickfix);
  }
}
