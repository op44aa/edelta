package edelta.maven.plugin;

import static com.google.common.collect.Iterables.filter;
import static com.google.common.collect.Sets.newLinkedHashSet;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.plugins.annotations.LifecyclePhase;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.plugins.annotations.Parameter;
import org.apache.maven.plugins.annotations.ResolutionScope;
import org.apache.maven.project.MavenProject;
import org.eclipse.xtext.builder.standalone.ILanguageConfiguration;
import org.eclipse.xtext.builder.standalone.LanguageAccess;
import org.eclipse.xtext.builder.standalone.LanguageAccessFactory;
import org.eclipse.xtext.builder.standalone.StandaloneBuilder;
import org.eclipse.xtext.builder.standalone.compiler.CompilerConfiguration;
import org.eclipse.xtext.builder.standalone.compiler.IJavaCompiler;
import org.eclipse.xtext.ecore.EcoreSupport;
import org.eclipse.xtext.maven.Language;
import org.eclipse.xtext.maven.MavenStandaloneBuilderModule;
import org.eclipse.xtext.maven.OutputConfiguration;
import org.eclipse.xtext.util.Strings;
import org.eclipse.xtext.xbase.lib.IterableExtensions;

import com.google.common.base.Predicate;
import com.google.common.collect.Lists;
import com.google.inject.Guice;
import com.google.inject.Injector;

import edelta.EdeltaStandaloneSetup;

/**
 * Based on xtext-maven-plugin XtextGenerator
 * 
 * @author Lorenzo Bettini
 *
 */
@Mojo(name = "generate", defaultPhase = LifecyclePhase.GENERATE_SOURCES, requiresDependencyResolution = ResolutionScope.COMPILE, threadSafe = true)
public class EdeltaMojo extends AbstractMojo {

	/**
	 * Lock object to ensure thread-safety
	 */
	private static final Object lock = new Object();

	/**
	 * Location of the generated source files.
	 */
	@Parameter(defaultValue = "${project.build.directory}/xtext-temp")
	private String tmpClassDirectory;

	/**
	 * File encoding argument for the generator.
	 */
	@Parameter(property = "xtext.encoding", defaultValue = "${project.build.sourceEncoding}")
	protected String encoding;

	/**
	 * The project itself. This parameter is set by maven.
	 */
	@Parameter(defaultValue = "${project}", readonly = true, required = true)
	protected MavenProject project;

	/**
	 * Project classpath.
	 */
	@Parameter(defaultValue = "${project.compileClasspathElements}", readonly = true, required = true)
	private List<String> classpathElements;

	@Parameter(property = "edelta.generator.skip", defaultValue = "false")
	private Boolean skip;

	@Parameter(defaultValue = "true")
	private Boolean failOnValidationError;

	@Parameter(property = "maven.compiler.source", defaultValue = "1.6")
	private String compilerSourceLevel;

	@Parameter(property = "maven.compiler.target", defaultValue = "1.6")
	private String compilerTargetLevel;

	@Parameter(defaultValue = "false")
	private Boolean compilerSkipAnnotationProcessing;

	@Parameter(defaultValue = "false")
	private Boolean compilerPreserveInformationAboutFormalParameters;

	@Parameter(defaultValue = "edelta-gen")
	private String outputDirectory;

	/**
	 * RegEx expression to filter class path during model files look up
	 */
	@Parameter
	private String classPathLookupFilter;

	private ArrayList<String> sourceRoots;

	public void execute() throws MojoExecutionException, MojoFailureException {
		if (skip) {
			getLog().info("skipped.");
		} else {
			synchronized (lock) {
				new EdeltaMavenLog4JConfigurator().configureLog4j(getLog());
				internalExecute();
			}
		}
	}

	protected void internalExecute() throws MojoExecutionException {
		Map<String, LanguageAccess> languages = new LanguageAccessFactory().createLanguageAccess(getLanguages(), this.getClass().getClassLoader());
		Injector injector = Guice.createInjector(new MavenStandaloneBuilderModule());
		StandaloneBuilder builder = injector.getInstance(StandaloneBuilder.class);
		builder.setBaseDir(project.getBasedir().getAbsolutePath());
		builder.setLanguages(languages);
		builder.setEncoding(encoding);
		builder.setClassPathEntries(getClasspathElements());
		builder.setClassPathLookUpFilter(classPathLookupFilter);
		sourceRoots = Lists.newArrayList(project.getCompileSourceRoots());
		builder.setSourceDirs(sourceRoots);
		builder.setJavaSourceDirs(sourceRoots);
		builder.setFailOnValidationError(failOnValidationError);
		builder.setTempDir(createTempDir().getAbsolutePath());
		builder.setDebugLog(getLog().isDebugEnabled());
		configureCompiler(builder.getCompiler());
		logState();
		boolean errorDetected = !builder.launch();
		if (errorDetected && failOnValidationError) {
			throw new MojoExecutionException("Execution failed due to a severe validation error.");
		}
	}

	private List<? extends ILanguageConfiguration> getLanguages() {
		List<ILanguageConfiguration> languages = new ArrayList<>(2);
		Language ecoreSupport = new Language();
		ecoreSupport.setSetup(EcoreSupport.class.getName());
		languages.add(ecoreSupport);
		Language edeltaLangConfig = new Language();
		edeltaLangConfig.setSetup(EdeltaStandaloneSetup.class.getName());
		OutputConfiguration edeltaOutputConfig = new OutputConfiguration();
		edeltaOutputConfig.setOutputDirectory(outputDirectory);
		edeltaLangConfig.setOutputConfigurations(Lists.newArrayList(edeltaOutputConfig));
		languages.add(edeltaLangConfig);
		return languages;
	}

	private Set<String> getClasspathElements() {
		Set<String> elements = newLinkedHashSet();
		elements.addAll(this.classpathElements);
		elements.remove(project.getBuild().getOutputDirectory());
		elements.remove(project.getBuild().getTestOutputDirectory());
		return newLinkedHashSet(filter(elements, emptyStringFilter()));
	}

	private Predicate<String> emptyStringFilter() {
		return new Predicate<String>() {
			public boolean apply(String input) {
				return !Strings.isEmpty(input.trim());
			}
		};
	}

	private File createTempDir() {
		File tmpDir = new File(tmpClassDirectory);
		if (!tmpDir.mkdirs() && !tmpDir.exists()) {
			throw new IllegalArgumentException("Couldn't create directory '" + tmpClassDirectory + "'.");
		}
		return tmpDir;
	}

	private void configureCompiler(IJavaCompiler compiler) {
		CompilerConfiguration conf = compiler.getConfiguration();
		conf.setSourceLevel(compilerSourceLevel);
		conf.setTargetLevel(compilerTargetLevel);
		conf.setVerbose(getLog().isDebugEnabled());
		conf.setSkipAnnotationProcessing(compilerSkipAnnotationProcessing);
		conf.setPreserveInformationAboutFormalParameters(compilerPreserveInformationAboutFormalParameters);
	}

	private void logState() {
		getLog().info("Encoding: " + (encoding == null ? "not set. Encoding provider will be used." : encoding));
		getLog().info("Compiler source level: " + compilerSourceLevel);
		getLog().info("Compiler target level: " + compilerTargetLevel);
		if (getLog().isDebugEnabled()) {
			getLog().debug("Source dirs: " + IterableExtensions.join(sourceRoots, ", "));
			getLog().debug("Classpath entries: " + IterableExtensions.join(getClasspathElements(), ", "));
		}
	}

}
