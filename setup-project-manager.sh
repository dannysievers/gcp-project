# Pre-requisites:
#   - must have set up and initialized GCP CLI and SDK
#   - initialized GCP CLI must use credentials of an organization owner
#   - GCP CLI beta commands must be enabled
#   - GCP CLI billing accounts subtree must be enabled

while getopts "ht:o:b:p:" opt; do
  case "${opt}" in
    h)  echo "-o: GCP organization ID"
        echo "-b: GCP billing account ID"
        echo "-p: GCP admin project name"
        exit
      ;;
    o)  GCP_ORG_ID=${OPTARG}
      ;;
    b)  GCP_BILLING_ID=${OPTARG}
      ;;
    p)  GCP_ADMIN_PROJECT_NAME=${OPTARG}
      ;;
    \?  ) echo "Usage: sh setup-admin-project.sh [-o gcp-org-id] [-b gcp-billing-account-id] [-p gcp-project-name]"
      exit
      ;;
  esac
done

GCP_CREDS_PATH="~/.config/gcloud"

gcloud projects create ${GCP_ADMIN_PROJECT_NAME} \
  --organization ${GCP_ORG_ID} \
  --set-as-default

gcloud beta billing projects link ${GCP_ADMIN_PROJECT_NAME} \
  --billing-account ${GCP_BILLING_ID}

gcloud iam service-accounts create terraform \
  --display-name "Terraform admin account"

gcloud iam service-accounts keys create ~/.config/gcloud/${GCP_ADMIN_PROJECT_NAME}-terraform-admin.json \
  --iam-account terraform@${GCP_ADMIN_PROJECT_NAME}.iam.gserviceaccount.com

gcloud projects add-iam-policy-binding ${GCP_ADMIN_PROJECT_NAME} \
  --member serviceAccount:terraform@${GCP_ADMIN_PROJECT_NAME}.iam.gserviceaccount.com \
  --role roles/viewer

gcloud projects add-iam-policy-binding ${GCP_ADMIN_PROJECT_NAME} \
  --member serviceAccount:terraform@${GCP_ADMIN_PROJECT_NAME}.iam.gserviceaccount.com \
  --role roles/storage.admin

gcloud organizations add-iam-policy-binding ${GCP_ORG_ID} \
  --member serviceAccount:terraform@${GCP_ADMIN_PROJECT_NAME}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator

gcloud organizations add-iam-policy-binding ${GCP_ORG_ID} \
  --member serviceAccount:terraform@${GCP_ADMIN_PROJECT_NAME}.iam.gserviceaccount.com \
  --role roles/billing.user

gsutil mb -p ${GCP_ADMIN_PROJECT_NAME} gs://${GCP_ADMIN_PROJECT_NAME}

gsutil versioning set on gs://${GCP_ADMIN_PROJECT_NAME}

# Add below environment variables to .bash_profile to persist terraform across terminal sessions
# export GOOGLE_CLOUD_KEYFILE_JSON="~/.config/gcloud/${GCP_ADMIN_PROJECT_NAME}-terraform-admin.json"
# export GOOGLE_PROJECT=${GCP_ADMIN_PROJECT_NAME}