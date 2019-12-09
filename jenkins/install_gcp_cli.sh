#Ref: https://github.com/circleci/android-cloud-test-lab/blob/master/circle.yml
export DIRECTORY="/var/jenkins_home/GoogleCloudSDK/google-cloud-sdk/bin"
if [ ! -d "$DIRECTORY" ]; then
  # Control will enter here if $DIRECTORY doesn't exist.
	cd /var/jenkins_home
	wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip -O google-cloud-sdk.zip
	unzip -o google-cloud-sdk.zip -d ./GoogleCloudSDK/
	./GoogleCloudSDK/google-cloud-sdk/install.sh

fi
export PATH=/var/jenkins_home/GoogleCloudSDK/google-cloud-sdk/bin:$PATH

gcloud --quiet components update
gcloud --quiet components install kubectl