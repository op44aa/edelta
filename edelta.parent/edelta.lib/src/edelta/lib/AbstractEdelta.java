/**
 * 
 */
package edelta.lib;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map.Entry;
import java.util.function.Consumer;

import org.apache.log4j.Logger;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EClassifier;
import org.eclipse.emf.ecore.EDataType;
import org.eclipse.emf.ecore.EEnum;
import org.eclipse.emf.ecore.EEnumLiteral;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.EcorePackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.ecore.xmi.impl.EcoreResourceFactoryImpl;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl;
import org.eclipse.xtext.xbase.lib.Extension;

import com.google.common.collect.ImmutableList;

import edelta.lib.exception.EdeltaPackageNotLoadedException;

/**
 * Base class for code generated by the Edelta DSL
 * 
 * @author Lorenzo Bettini
 *
 */
public abstract class AbstractEdelta {

	private static final Logger LOG = Logger.getLogger(AbstractEdelta.class);

	/**
	 * Here we store the association between the Ecore file name and the
	 * corresponding loaded Resource.
	 */
	private HashMap<String, Resource> ecoreToResourceMap = new LinkedHashMap<String, Resource>();

	/**
	 * Here we store all the Ecores used by the Edelta
	 */
	private ResourceSet resourceSet = new ResourceSetImpl();

	/**
	 * Initializers for EClassifiers which will be executed later, after
	 * all EClassifiers have been created.
	 */
	private List<Runnable> eClassifierInitializers = new LinkedList<>();

	/**
	 * Initializers for EStructuralFeatures which will be executed later, after
	 * all EStructuralFeatures have been created.
	 */
	private List<Runnable> eStructuralFeaturesInitializers = new LinkedList<>();

	/**
	 * This will be used in the generated code with extension methods.
	 */
	@Extension
	protected EdeltaLibrary lib = new EdeltaLibrary();

	public AbstractEdelta() {
		// Register the appropriate resource factory to handle all file extensions.
		resourceSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put
			("ecore", 
			new EcoreResourceFactoryImpl());
		resourceSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put
			(Resource.Factory.Registry.DEFAULT_EXTENSION, 
			new XMIResourceFactoryImpl());

		// Register the Ecore package to ensure it is available during loading.
		resourceSet.getPackageRegistry().put
			(EcorePackage.eNS_URI, 
			 EcorePackage.eINSTANCE);
	}

	/**
	 * Performs the actual execution of the transformation, to be
	 * called by clients.
	 * 
	 * @throws Exception
	 */
	public void execute() throws Exception {
		performSanityChecks();
		doExecute();
		runInitializers();
	}

	/**
	 * This is meant to be implemented by the code generated by
	 * the Edelta DSL, in order to perform sanity checks, such as if
	 * all EPackages (their ecores) are loaded.
	 * 
	 * @throws Exception
	 */
	protected void performSanityChecks() throws Exception {
		// to be implemented by the generated code
	}

	/**
	 * Actual implementation of the transformation, to be generated
	 * by the Edelta DSL compiler.
	 * 
	 * @throws Exception
	 */
	protected void doExecute() throws Exception {
		// to be implemented by the generated code
	}

	/**
	 * Executes the initializers previously saved.
	 */
	protected void runInitializers() {
		eClassifierInitializers.forEach(r -> r.run());
		eStructuralFeaturesInitializers.forEach(r -> r.run());
	}

	/**
	 * Throws an {@link EdeltaPackageNotLoadedException} if the specified
	 * EPackage (its Ecore) has not been loaded.
	 * 
	 * @param packageName
	 * @throws EdeltaPackageNotLoadedException
	 */
	protected void ensureEPackageIsLoaded(String packageName) throws EdeltaPackageNotLoadedException {
		if (getEPackage(packageName) == null) {
			throw new EdeltaPackageNotLoadedException(packageName);
		}
	}

	public void loadEcoreFile(String path) {
		// make sure we have a complete file URI,
		// otherwise the saved modified ecore will contain
		// wrong references (i.e., with the prefixed relative path)
		URI uri = URI.createFileURI(Paths.get(path).toAbsolutePath().toString());
		// Demand load resource for this file.
		LOG.info("Loading " + path + " (URI: " + uri + ")");
		ecoreToResourceMap.put(path, resourceSet.getResource(uri, true));
	}

	/**
	 * Saves the modified EPackages as Ecore files in the specified
	 * output path.
	 * 
	 * The final path of the generated Ecore files is made of the
	 * specified outputPath and the original loaded Ecore
	 * file names.
	 * 
	 * @param outputPath
	 * @throws IOException 
	 */
	public void saveModifiedEcores(String outputPath) throws IOException {
		for (Entry<String, Resource> entry : ecoreToResourceMap.entrySet()) {
			Path p = Paths.get(entry.getKey());
			String outputFileName = outputPath + "/" + p.getFileName().toString();
			LOG.info("Saving " + outputFileName);
			File newFile = new File(outputFileName);
			FileOutputStream fos = new FileOutputStream(newFile);
			entry.getValue().save(fos, null);
			fos.flush();
			fos.close();
		}
	}

	public EPackage getEPackage(String packageName) {
		// Ecore package is implicitly available
		if (EcorePackage.eNAME.equals(packageName)) {
			return EcorePackage.eINSTANCE;
		}
		return resourceSet.getResources().
			stream().
			map(resource -> resource.getContents().get(0)).
			filter(o -> o instanceof EPackage).
			map(o -> (EPackage) o).
			filter(p -> p.getName().equals(packageName)).
			findAny().
			orElse(null);
	}

	public EClassifier getEClassifier(String packageName, String classifierName) {
		EPackage p = getEPackage(packageName);
		if (p == null) {
			return null;
		}
		return p.getEClassifier(classifierName);
	}

	public EClass getEClass(String packageName, String className) {
		EClassifier c = getEClassifier(packageName, className);
		if (c instanceof EClass) {
			return (EClass) c;
		}
		return null;
	}

	public EDataType getEDataType(String packageName, String datatypeName) {
		EClassifier c = getEClassifier(packageName, datatypeName);
		if (c instanceof EDataType) {
			return (EDataType) c;
		}
		return null;
	}

	public EEnum getEEnum(String packageName, String enumName) {
		EClassifier c = getEClassifier(packageName, enumName);
		if (c instanceof EEnum) {
			return (EEnum) c;
		}
		return null;
	}

	public EStructuralFeature getEStructuralFeature(String packageName, String className, String featureName) {
		EClass c = getEClass(packageName, className);
		if (c == null) {
			return null;
		}
		return c.getEStructuralFeature(featureName);
	}

	public EAttribute getEAttribute(String packageName, String className, String attributeName) {
		EStructuralFeature f = getEStructuralFeature(packageName, className, attributeName);
		if (f instanceof EAttribute) {
			return (EAttribute) f;
		}
		return null;
	}

	public EReference getEReference(String packageName, String className, String referenceName) {
		EStructuralFeature f = getEStructuralFeature(packageName, className, referenceName);
		if (f instanceof EReference) {
			return (EReference) f;
		}
		return null;
	}

	public EEnumLiteral getEEnumLiteral(String packageName, String enumName, String enumLiteralName) {
		EEnum eenum = getEEnum(packageName, enumName);
		if (eenum == null) {
			return null;
		}
		return eenum.getEEnumLiteral(enumLiteralName);
	}

	public EClass createEClass(String packageName, String name, final List<Consumer<EClass>> initializers) {
		final EClass newEClass = lib.newEClass(name);
		getEPackage(packageName).getEClassifiers().add(newEClass);
		if (initializers != null)
			initializers.forEach(i -> safeAddInitializer(eClassifierInitializers, newEClass, i));
		return newEClass;
	}

	protected <E> List<E> createList(E e) {
		return ImmutableList.of(e);
	}

	protected <E> List<E> createList(E e1, E e2) {
		return ImmutableList.of(e1, e2);
	}

	private <T> void safeAddInitializer(List<Runnable> list, final T element, final Consumer<T> initializer) {
		list.add(
			() -> initializer.accept(element)
		);
	}

	public EAttribute createEAttribute(EClass eClass, String attributeName, final List<Consumer<EAttribute>> initializers) {
		EAttribute newAttribute = lib.newEAttribute(attributeName);
		eClass.getEStructuralFeatures().add(newAttribute);
		if (initializers != null)
			initializers.forEach(i -> safeAddInitializer(eStructuralFeaturesInitializers, newAttribute, i));
		return newAttribute;
	}

	public void removeEClassifier(String packageName, String name) {
		EcoreUtil.delete(getEClassifier(packageName, name), true);
	}
}
