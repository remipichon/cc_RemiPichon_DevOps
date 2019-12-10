// create pipeline from file
// we don't directly create the pipeline in "create_pipeline_seeder" to allow easy debug via the UI

pipelineJob('build_push_deploy_api') {
    // Github trigger is managed via Terraform
    definition {
        cps {
            script(readFileFromWorkspace('/var/jenkins_home/build_push_deploy_api.pipeline.groovy'))
            sandbox()
        }
    }
}
