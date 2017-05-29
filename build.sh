#!/bin/bash -e

export JOB_NAME_UP=$(echo $JOB_NAME | awk '{print toupper($0)}')
export CURR_JOB_PATH=$(eval echo "$"$JOB_NAME_UP"_PATH") #where the curr build is running

export REPO_RES="demo_doc_repo"
export DOC_CREDS_RES="docker_creds"
export DOC_IMG_RES="demo_doc_img"

export REPO_RES_UP=$(echo $REPO_RES | awk '{print toupper($0)}')
export REPO_RES_STATE=$(eval echo "$"$REPO_RES_UP"_STATE") #loc of git repo clone

export DOC_CREDS_RES_UP=$(echo $DOC_CREDS_RES | awk '{print toupper($0)}')
export DOC_CREDS_RES_INT_STR=$DOC_CREDS_RES_UP"_INTEGRATION"

export DOC_IMG_RES_UP=$(echo $DOC_IMG_RES | awk '{print toupper($0)}')
export DOC_IMG_SOURCENAME=$(eval echo "$"$DOC_IMG_RES_UP"_SOURCENAME") #lwhere image name is stored
export IMAGE_TAG=$BUILD_NUMBER.$BUILD_JOB_NUMBER

test_env_info() {
  export DH_USERNAME=$(eval echo "$"$DOC_CREDS_RES_INT_STR"_USERNAME")
  export DH_PASSWORD=$(eval echo "$"$DOC_CREDS_RES_INT_STR"_PASSWORD")
  export DH_EMAIL=$(eval echo "$"$DOC_CREDS_RES_INT_STR"_EMAIL")

  echo "Testing build ENV"

  echo "########### CURR_JOB_PATH: $CURR_JOB_PATH"

  echo "########### REPO_RES: $REPO_RES"
  echo "########### REPO_RES_UP: $REPO_RES_UP"
  echo "########### REPO_RES_STATE: $REPO_RES_STATE"

  echo "########### DOC_CREDS_RES: $DOC_CREDS_RES"
  echo "########### DOC_CREDS_RES_UP: $DOC_CREDS_RES_UP"
  echo "########### DH_USERNAME: ${#DH_USERNAME}"
  echo "########### DH_PASSWORD: ${#DH_PASSWORD}"
  echo "########### DH_EMAIL: $DH_EMAIL"

  echo "########### DOC_IMG_RES: $DOC_IMG_RES"
  echo "########### DOC_IMG_RES_UP: $DOC_IMG_RES_UP"
  echo "########### DOC_IMG_SOURCENAME: $DOC_IMG_SOURCENAME"
  echo "########### IMAGE_TAG: $IMAGE_TAG"

  echo "logging into Docker"
  docker login -u $DH_USERNAME -p $DH_PASSWORD -e $DH_EMAIL
  echo "Completed Docker login"

  echo "Build ENV is good"
}

build_push() {
  pushd $REPO_RES_STATE

  echo "Starting Docker build & push for" $DOC_IMG_SOURCENAME:$IMAGE_TAG
  sudo docker build -t=$DOC_IMG_SOURCENAME:$IMAGE_TAG .
  sudo docker push $DOC_IMG_SOURCENAME:$IMAGE_TAG
  echo "Completed Docker build & push for" $DOC_IMG_SOURCENAME:$IMAGE_TAG

  popd
}

create_state() {
  echo "Creating a state file for" $DOC_IMG_RES
  echo versionName=$IMAGE_TAG > "$JOB_STATE/$DOC_IMG_RES.env"
  cat "$JOB_STATE/$DOC_IMG_RES.env"
  echo "Completed creating a state file for" $DOC_IMG_RES
}

main() {
  test_env_info
  build_push
  create_state
}

main
