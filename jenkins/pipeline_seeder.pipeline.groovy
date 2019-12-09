// create pipeline from file
// we don't directly create the pipeline in "create_pipeline_seeder" to allow easy debug via the UI


//create the seeder to allow updating the pipelines definition from Jenkins UI
// pipelineJob('pipeline_seeder') {
//     definition {
//         cps {
//             script(readFileFromWorkspace('/var/jenkins_home/pipeline_seeder.pipeline.groovy'))
//             sandbox()
//         }
//     }
// }

pipelineJob('build_push_deploy_api') {
    // Github trigger is managed via Terraform
    definition {
        cps {
            script(readFileFromWorkspace('/var/jenkins_home/build_push_deploy_api.pipeline.groovy'))
            sandbox()
        }
    }
}
