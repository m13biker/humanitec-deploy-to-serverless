$env:HUMANITEC_ORG = "baptist-health"
$env:HUMANITEC_TOKEN = "gPElTiNuZ4fosB5s19JV1FwOIL93LVd0w2eKRfb6X2ps"
$env:HUMANITEC_APP = "d-cetnralized-kubernetes-apm0004223-app"
$env:HUMANITEC_ENV = "development"
$env:GCP_PROJECT_ID = "prj-d-apm0004223-10"
$env:GCP_REGION = "us-east1"

echo $HUMANITEC_ORG 
echo $HUMANITEC_APP 
echo $HUMANITEC_ENV 
echo $GCP_PROJECT_ID
echo $GCP_REGION

gcloud auth login --no-launch-browser

gcloud auth application-default login --no-launch-browser
