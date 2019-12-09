import javaposse.jobdsl.plugin.JenkinsJobManagement
import javaposse.jobdsl.dsl.DslScriptLoader

/*
	Programmatically create a Pipeline which can create feature pipelines
*/
def jobDslScript = new File('/var/jenkins_home/pipeline_seeder.pipeline.groovy')
def workspace = new File('.')
def jobManagement = new JenkinsJobManagement(System.out, [:], workspace)
new DslScriptLoader(jobManagement).runScript(jobDslScript.text)
