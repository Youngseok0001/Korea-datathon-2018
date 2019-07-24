#!/bin/bash

set -u -e

OWNERS_GROUP="nus-datathon-owners@googlegroups.com"
EDITORS_GROUP="nus-datathon-auditors@googlegroups.com"
READERS_GROUP="nus-datathon-data-readers@googlegroups.com"
PROJECT_ID="singapore-datathon-data"
DATASET_NAME="synthetic"
INPUT_DIR="../dataset/synthetic"

# Lowercase is required for bucket name, and BigQuery dataset ID can't contain
# dash.
DATASET_NAME=`echo ${DATASET_NAME} | awk '{ print tolower($0) }' | sed -e 's/-/_/g'`
BUCKET_ID=${PROJECT_ID}-${DATASET_NAME}
DATASET_ID=${DATASET_NAME}
LOCATION=US
STATE_FILE="$0".state
# A list of state checkpoints for the script to resume to.
STATE_ENABLE_SERVICES="ENABLE_SERVICES"
STATE_CREATE_BQ="CREATE_BQ"
STATE_UPLOAD_GCS="UPLOAD_GCS"
STATE_UPLOAD_BQ="UPLOAD_BQ"

if [[ ! -e ${STATE_FILE} ]]; then
  echo "Creating the Google Cloud Storage bucket to host data."
  STORAGE_CLASS=multi_regional
  gsutil mb -p ${PROJECT_ID} -c ${STORAGE_CLASS} -l ${LOCATION} gs://${BUCKET_ID}
  gsutil requesterpays set on gs://${BUCKET_ID}
  echo "Setting Google Cloud Storage bucket access."
  TEMP=`tempfile`
  cat <<EOF >>${TEMP}
{
  "bindings": [
    {
      "members": [
        "group:${OWNERS_GROUP?}"
      ],
      "role": "roles/storage.admin"
    },
    {
      "members": [
        "group:${EDITORS_GROUP?}"
      ],
      "role": "roles/storage.objectCreator"
    },
    {
      "members": [
        "group:${READERS_GROUP?}"
      ],
      "role": "roles/storage.objectViewer"
    }
  ]
}
EOF
  gsutil -u ${PROJECT_ID} iam set ${TEMP} gs://${BUCKET_ID}
  echo ${STATE_ENABLE_SERVICES} > ${STATE_FILE}
else
  echo "Skip creating bucket since it has previously finished."
fi

if [[ `cat ${STATE_FILE}` == ${STATE_ENABLE_SERVICES} ]]; then
  echo "Enabling the following Google Cloud Platform services"
  echo "  - Deployment Manager"
  echo "  - BigQuery"
  gcloud services enable deploymentmanager bigquery --project ${PROJECT_ID}
  echo ${STATE_CREATE_BQ} > ${STATE_FILE}
else
  echo "Skip enabling services since it has previously finished."
fi

if [[ `cat ${STATE_FILE}` == ${STATE_CREATE_BQ} ]]; then
  echo "Creating the BigQuery to host tables."
  TEMP=`tempfile`
  cat <<EOF >>${TEMP}
resources:
- name: big-query-dataset
  type: bigquery.v2.dataset
  properties:
    datasetReference:
      datasetId: "${DATASET_ID?}"
    access:
      - role: 'OWNER'
        groupByEmail: "${OWNERS_GROUP?}"
      - role: 'WRITER'
        groupByEmail: "${EDITORS_GROUP?}"
      - role: 'READER'
        groupByEmail: "${READERS_GROUP?}"
    location: "${LOCATION?}"
EOF
  gcloud deployment-manager deployments create create-bq-dataset \
    --config=${TEMP} --project ${PROJECT_ID}
  # Delete the deployment job since it's finished. The created dataset is not
  # affected.
  gcloud --quiet deployment-manager deployments delete create-bq-dataset \
    --project ${PROJECT_ID} --delete-policy=ABANDON
  echo ${STATE_UPLOAD_GCS} > ${STATE_FILE}
else
  echo "Skip creating BigQuery dataset since it has previously finished."
fi

if [[ `cat ${STATE_FILE}` == ${STATE_UPLOAD_GCS} ]]; then
  echo "Uploading data to Google Cloud Storage."
  gsutil -u ${PROJECT_ID} -m cp ${INPUT_DIR}/*.csv gs://${BUCKET_ID}
  echo ${STATE_UPLOAD_BQ} > ${STATE_FILE}
else
  echo "Skip uploading data to GCS since it has previously finished."
fi


if [[ `cat ${STATE_FILE}` == ${STATE_UPLOAD_BQ} ]]; then
  job_ids=()
  echo "Loading data from Google Cloud Storage to BigQuery."
  for file in ${INPUT_DIR}/*.csv; do
    echo "Loading data file `basename ${file}` to BigQuery."
    # Assume the schema file ends with .csv.schema suffix.
    # Upload data to BigQuery.
    table_name=`echo $(basename ${file:0:(-4)}) | awk '{ print tolower($0) }'`

    # Asynchronously load data to BigQuery.
    job_id=${table_name}_$(date +%s)
    bq --nosync --location=${LOCATION} --project_id=${PROJECT_ID} \
      load --job_id=${job_id} --source_format=CSV \
      --autodetect --allow_quoted_newline "${DATASET_ID}.${table_name}" \
      gs://${BUCKET_ID}/$(basename ${file})
    job_ids+=(${job_id})

    # Remove the schema file if it's generated by this script.
  done

  echo "All BigQuery loading jobs have been submitted."
  echo "Waiting for jobs to finish."
  for job_id in ${job_ids[*]}; do
    # The wait command will print out real-time status of the job.
    bq wait --project_id=${PROJECT_ID} ${job_id}
  done
else
  echo "Skip uploading data to BigQuery since it has previously finished."
fi

rm -f ${STATE_FILE}

echo "Data upload for ${DATASET_NAME} has finished."
