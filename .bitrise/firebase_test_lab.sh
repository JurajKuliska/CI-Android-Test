set -ex

#Download service account key
curl -o /tmp/sacc_key.json $BITRISEIO_SERVICE_ACCOUNT_KEY_URL
#Activate cloud client with the service account
gcloud auth activate-service-account -q --key-file /tmp/sacc_key.json
#Set the project's id used on Google Cloud Platform
gcloud config set project $GCP_PROJECT

RESULT_DIR="build-$BITRISE_BUILD_NUMBER"

APK="--app=$BITRISE_DEPLOY_DIR/app-debug.apk --test=$BITRISE_DEPLOY_DIR/app-debug-androidTest.apk"

TYPE="instrumentation"
DEVICES="--device model=Nexus6,version=21,locale=en,orientation=portrait"

echo "y" | gcloud firebase test android run $APK $DEVICES --type=$TYPE --results-bucket $GCP_PROJECT

SRCPTH=$BITRISE_DEPLOY_DIR/test_results
EXPPTH=$BITRISE_DEPLOY_DIR
mkdir $SRCPTH

#Download test results

gsutil -m cp -r -U `sudo gsutil ls gs://$GCP_PROJECT | tail -1` $SRCPTH | true

for file in $(find $SRCPTH -type f)
do
    if [[ -f $file ]]; then
       f=$(echo ${file//$SRCPTH\/$RESULT_DIR\/})
       mv $file $(echo $EXPPTH/${f//\//_})
    fi
done
