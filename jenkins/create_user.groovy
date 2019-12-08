import jenkins.model.*
import hudson.security.*

/*
	reading required env JENKINS_ADMIN and JENKINS_ADMIN_PASS to create Jenkins Admin user
	reading optional env JENKINS_USER and JENKINS_USER_PASS to create basic Jenkins user
*/

def env = System.getenv()

def jenkins = Jenkins.getInstance()
if(!(jenkins.getSecurityRealm() instanceof HudsonPrivateSecurityRealm))
    jenkins.setSecurityRealm(new HudsonPrivateSecurityRealm(false))

if(!(jenkins.getAuthorizationStrategy() instanceof GlobalMatrixAuthorizationStrategy))
    jenkins.setAuthorizationStrategy(new GlobalMatrixAuthorizationStrategy())

// create admin user from ENV
if( env.JENKINS_ADMIN == "" || env.JENKINS_ADMIN_PASS == ""){
	system.out.println("configuration error, env JENKINS_ADMIN must be defined as well as JENKINS_ADMIN_PASS")
	System.exit(1)
}
def user = jenkins.getSecurityRealm().createAccount(env.JENKINS_ADMIN, env.JENKINS_ADMIN_PASS)
user.save()
jenkins.getAuthorizationStrategy().add(Jenkins.ADMINISTER, env.JENKINS_ADMIN)

if( env.JENKINS_USER != "" && env.JENKINS_USER_PASS != ""){
	def user = jenkins.getSecurityRealm().createAccount(env.JENKINS_USER, env.JENKINS_USER_PASS)
	user.save()
	# TODO give this user access to the pipeline
	jenkins.getAuthorizationStrategy().add(Jenkins.READ, env.JENKINS_USER)
} else {
	system.out.println("skip basic Jenkins user creation as JENKINS_USER and JENKINS_USER_PASS appear empty")
}

