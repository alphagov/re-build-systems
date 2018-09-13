import jenkins.model.*
import java.util.logging.Logger
import hudson.plugins.git.*
import io.jenkins.docker.connector.DockerComputerAttachConnector

import com.nirima.jenkins.plugins.docker.DockerCloud
import com.nirima.jenkins.plugins.docker.DockerTemplate
import com.nirima.jenkins.plugins.docker.DockerTemplateBase
import com.nirima.jenkins.plugins.docker.launcher.AttachedDockerComputerLauncher

// Step 1/4 - Define jobs

def jobDefinitions =
[
   [
      "name" : "build-sample-java-app",
      "scm" : "https://github.com/alphagov/re-build-systems-sample-java-app",
      "description" : "Build and test sample app at https://github.com/alphagov/re-build-systems-sample-java-app",
      "jenkinsFilePath" : "Jenkinsfile",
   ],
]

// Step 2/4 - Define agents

def agentDefinitions =
[
   [
      "imageDockerPath" : "gdsre/jenkins-agent-java8-with-maven:latest",
      "dockerTemplateLabel" : "sample-docker-jnlp-java-agent",
      "dockerCloudName" : "sample-docker-worker--java"
   ],
]

// Step 3/4 - Define extra plugins (as space-separated string)

def pluginList = "greenballs"

// Step 4/4 - Define any extra custom configuration

def jenkinsLocationConfiguration = JenkinsLocationConfiguration.get()
jenkinsLocationConfiguration.setAdminAddress("Test Email Address <myemail@domain>")
jenkinsLocationConfiguration.save()

// You should not need to edit anything after this line

def registerJobs(jobList) {
  jobList.each{jobEntry->
    def scm = new GitSCM(jobEntry["scm"])
    def flowDefinition = new org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition(scm, jobEntry["jenkinsFilePath"])
    def job = new org.jenkinsci.plugins.workflow.job.WorkflowJob(Jenkins.instance, jobEntry["name"])
    job.description = jobEntry["description"]
    job.definition = flowDefinition
  }
}

def registerPlugins(pluginString) {
  def logger = Logger.getLogger("")
  def installed = false
  def initialized = false
  def plugins = pluginString.split()
  logger.info("" + plugins)
  def instance = Jenkins.getInstance()
  def pm = instance.getPluginManager()
  def uc = instance.getUpdateCenter()
  plugins.each {
    logger.info("Checking " + it)
    if (!pm.getPlugin(it)) {
      logger.info("Looking UpdateCenter for " + it)
      if (!initialized) {
        uc.updateAllSites()
        initialized = true
      }
      def plugin = uc.getPlugin(it)
      if (plugin) {
        logger.info("Installing " + it)
          def installFuture = plugin.deploy()
        while(!installFuture.isDone()) {
          logger.info("Waiting for plugin install: " + it)
          sleep(3000)
        }
        installed = true
      }
    }
  }
}

def registerAgent(imageDockerPath, dockerTemplateLabel, dockerCloudName) {
  def dockerTemplateBaseParameters = [
    bindAllPorts:       false,
    bindPorts:          '',
    cpuShares:          null,
    dnsString:          '',
    dockerCommand:      '',
    environmentsString: '',
    extraHostsString:   '',
    hostname:           '',
    image:              imageDockerPath,
    macAddress:         '',
    memoryLimit:        null,
    memorySwap:         null,
    network:            '',
    privileged:         false,
    pullCredentialsId:  '',
    tty:                true,
    volumesFromString:  '',
    volumesString:      ''
  ]

  def DockerTemplateParameters = [
    instanceCapStr: '4',
    labelString:    dockerTemplateLabel,
    remoteFs:       '/home/jenkins'
  ]

  def dockerCloudParameters = [
    connectTimeout:   3,
    containerCapStr:  '4',
    credentialsId:    '',
    dockerHostname:   '',
    name:             dockerCloudName,
    readTimeout:      60,
    serverUrl:        'tcp://worker:2375',
    version:          ''
  ]

  // https://github.com/jenkinsci/docker-plugin/blob/docker-plugin-1.1.2/src/main/java/com/nirima/jenkins/plugins/docker/DockerTemplateBase.java
  DockerTemplateBase dockerTemplateBase = new DockerTemplateBase(
    dockerTemplateBaseParameters.image,
    dockerTemplateBaseParameters.pullCredentialsId,
    dockerTemplateBaseParameters.dnsString,
    dockerTemplateBaseParameters.network,
    dockerTemplateBaseParameters.dockerCommand,
    dockerTemplateBaseParameters.volumesString,
    dockerTemplateBaseParameters.volumesFromString,
    dockerTemplateBaseParameters.environmentsString,
    dockerTemplateBaseParameters.hostname,
    dockerTemplateBaseParameters.memoryLimit,
    dockerTemplateBaseParameters.memorySwap,
    dockerTemplateBaseParameters.cpuShares,
    dockerTemplateBaseParameters.bindPorts,
    dockerTemplateBaseParameters.bindAllPorts,
    dockerTemplateBaseParameters.privileged,
    dockerTemplateBaseParameters.tty,
    dockerTemplateBaseParameters.macAddress,
    dockerTemplateBaseParameters.extraHostsString
  )

  // https://github.com/jenkinsci/docker-plugin/blob/docker-plugin-1.1.2/src/main/java/com/nirima/jenkins/plugins/docker/DockerTemplate.java
  DockerTemplate dockerTemplate = new DockerTemplate(
    dockerTemplateBase,
    new DockerComputerAttachConnector(),
    DockerTemplateParameters.labelString,
    DockerTemplateParameters.remoteFs,
    DockerTemplateParameters.instanceCapStr
  )

  // https://github.com/jenkinsci/docker-plugin/blob/docker-plugin-1.1.2/src/main/java/com/nirima/jenkins/plugins/docker/DockerCloud.java
  DockerCloud dockerCloud = new DockerCloud(
    dockerCloudParameters.name,
    [dockerTemplate],
    dockerCloudParameters.serverUrl,
    dockerCloudParameters.containerCapStr,
    dockerCloudParameters.connectTimeout,
    dockerCloudParameters.readTimeout,
    dockerCloudParameters.credentialsId,
    dockerCloudParameters.version,
    dockerCloudParameters.dockerHostname
  )

  // get Jenkins instance
  Jenkins jenkins = Jenkins.getInstance()

  // add cloud configuration to Jenkins
  jenkins.clouds.add(dockerCloud)
}

def registerAgents(agentList) {
  agentList.each { agentEntry->
    registerAgent(agentEntry["imageDockerPath"], agentEntry["dockerTemplateLabel"], agentEntry["dockerCloudName"])
  }
}

registerJobs(jobDefinitions);
registerAgents(agentDefinitions);
registerPlugins(pluginList);

Jenkins jenkins = Jenkins.getInstance()
jenkins.save()
