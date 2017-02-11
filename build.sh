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
  echo "########### DH_USERNAME: $DH_USERNAME"
  echo "########### DH_PASSWORD: ${#DH_PASSWORD}"
  echo "########### DH_EMAIL: $DH_EMAIL"

  echo "########### DOC_IMG_RES: $DOC_IMG_RES"
  echo "########### DOC_IMG_RES_UP: $DOC_IMG_RES_UP"
  echo "########### DOC_IMG_SOURCENAME: $DOC_IMG_SOURCENAME"
  echo "########### IMAGE_TAG: $IMAGE_TAG"

  sudo add-apt-repository ppa:webupd8team/y-ppa-manager
  sudo apt-get update
  sudo apt-get install y-ppa-manager

  add-apt-repository -y ppa:openjdk-r/ppa
  apt-get update
  apt-get install -y openjdk-8-jdk
  update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
  update-alternatives --set javac /usr/lib/jvm/java-8-openjdk-amd64/bin/javac
  apt-get install --reinstall ca-certificates
  add-apt-repository ppa:maarten-fonville/ppa
  apt-get update
  apt-get install -y icedtea-8-plugin
  update-alternatives --set javaws /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/javaws
  
  echo "########### JAVA_HOME: $JAVA_HOME"
  which java

  sudo wget http://www-us.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
  sudo tar xzf apache-maven-3.3.9-bin.tar.gz -C /usr/local && rm -f apache-maven-3.3.9-bin.tar.gz
  ln -fs /usr/local/apache-maven-$3.3.9/bin/mvn /usr/bin
  echo "export PATH=$PATH:/usr/local/apache-maven-3.3.9/bin" >> $HOME/.bashrc

  echo "logging into Docker with username" $DH_USERNAME
  docker login -u $DH_USERNAME -p $DH_PASSWORD -e $DH_EMAIL
  echo "Completed Docker login"

  echo "Build ENV is good"
}

build_push() {
  pushd $REPO_RES_STATE

  echo "Building WAR file"
  mkdir -p shippable/testresults && mkdir -p shippable/codecoverage
  /usr/local/apache-maven-3.3.9/bin/mvn -q -B clean cobertura:cobertura install
  ls -al ./target
  echo "Completed WAR file build"

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
