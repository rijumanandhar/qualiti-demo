#!/bin/bash

  set -ex

  API_KEY='36131f6d8d8af3fa'
  INTEGRATIONS_API_URL='https://3000-qualitiai-qualitiapi-vcfxwp4n2i3.ws-us65.gitpod.io'
  PROJECT_ID='3'
  CLIENT_ID='39bcdb9495b5951862d8b4c3703287bb'
  API_URL='https://3000-qualitiai-qualitiapi-vcfxwp4n2i3.ws-us65.gitpod.io/public/api-keys'
  INTEGRATION_JWT_TOKEN='8b538860d8b2746c783e19c4b3faeab68c15aed1cfa5f78fdee336ac33c19bd45ed4f208d346187f763b952f1b3a615fc8a92bbe4c76d7c264091ea6191355cb34b62170df57104e02f5300e63a5caf2a4779147a3ffef342a81f319a9bd848e89f0380cf182db2224ceb96d71cbdd548cdd7a2126d7738bc2a86f49216f939bc10a03ddcb55d91d3855923399321d646ba5f1c5c33f1552eb13d6739cc25dcd66563448f5cfea4839297a80491d92b2b705223ae3941a65f591178eef62ee5a70996e21c39891cc6f7aed01944821c39c2c6edb8c4b432479c43d1330019655a20ed91cd4bb993b41b3f7e39c8daf3ef7fcc117785a4d4a8fc82942b50cbc2d912b34c46ce86213446d616ab85e3e82|72b474e791002975b897526fd43a2366|7009df399b77318498b786bb6c1abe6f'

  sudo apt-get update -y
  sudo apt-get install -y jq

  #Trigger test run
  TEST_RESULT_ID="$( \
    curl -X POST -G ${INTEGRATIONS_API_URL}/integrations/appveyor/${PROJECT_ID}/events \
      -d 'token='$INTEGRATION_JWT_TOKEN''\
      -d 'triggeredBy=Deploy'\
      -d 'triggerType=automatic'\
    | jq -r '.test_result_id')"

  AUTHORIZATION_TOKEN="$( \
    curl -X POST -G ${API_URL}/token \
    -H 'x-api-key: '${API_KEY}'' \
    -H 'client-id: '${CLIENT_ID}'' \
    | jq -r '.token')"

  # Wait until the test run has finished
  TOTAL_ITERATION=50
  I=1
  STATUS="Pending"
  
  while [ "${STATUS}" = "Pending" ]
  do
     if [ "$I" -ge "$TOTAL_ITERATION" ]; then
      echo "Exit qualiti execution for taking too long time.";
      exit 1;
    fi
    echo "We are on iteration ${I}"

    STATUS="$( \
      curl -X GET ${INTEGRATIONS_API_URL}/tables/test-results/${TEST_RESULT_ID} \
        -H 'Authorization: Bearer '$AUTHORIZATION_TOKEN'' \
        | jq -r '.status' \
    )"

    ((I=I+1))

    sleep 15;
  done

  echo "Qualiti E2E Tests returned ${STATUS}"
  if [ "$STATUS" = "Passed" ]; then
    exit 0;
  fi
  exit 1;
  
