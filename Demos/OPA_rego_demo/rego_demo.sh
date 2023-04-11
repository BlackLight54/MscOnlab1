#!/bin/bash
cd "$(dirname "$0")"

# function removeOldRegoFiles {
#     rm -f *.rego
# }
function removeOldBundleFilesAndDockerComposeContainer {
    printf "Removing old bundle files and docker-compose container..."
    docker compose down > /dev/null 2>&1
    until ! docker ps -q --filter "name=rego_demo" | grep -q .; do
        sleep 0.1;
    done;
    rm -rf *.tar.gz > /dev/null
    rm -rf bundles > /dev/null
    printf "\r\033[KRemoved old bundle files and docker-compose container.\n"
}

function createExamplePolicyBundle {
    printf "Creating example policy bundle..."
    mkdir bundles
    opa build example.rego -o ./bundles/bundle.tar.gz &&
    
    printf "\r\033[KCreated example policy bundle.\n" || printf "\r\e[1;31mFailed to create example policy bundle\e[0m\n"
}

function bootStrapDockerEnv {
    printf "Bootstrapping docker environment..."
    docker compose up -d > /dev/null 2>&1
    
    until [ "`docker inspect -f {{.State.Running}} rego_demo-api_server-1`"=="true" ]; do
        printf "\r\033[KWaiting for docker container to start..."
        sleep 0.5;
    done;
    sleep 0.5
    printf "\r\033[KBootstrapped docker environment.\n"
}
function checkThatAliceCanSeeHerOwnSalary {
    printf "Checking that Alice can see her own salary..."
    curl  -sSL --user alice:password localhost:5000/finance/salary/alice \
    | grep -qF "Success" \
    && printf "\r\033[K\033[0;32mAlice can see her own salary\033[0m\n" \
    || printf "\r\033[K\033[1;31mAlice can't see her own salary\033[0m\n"
}
function checkThatBobCanSeeAlicesSalary {
    #Bob is a manager of Alice
    printf "Checking that Bob can see Alice's salary..."
    curl --silent --user bob:password localhost:5000/finance/salary/alice \
    | grep -qF "Success" \
    && printf "\r\033[K\033[0;32mBob can see Alice's salary\033[0m\n" \
    || printf "\r\033[K\033[1;31mBob can't see Alice's salary\033[0m\n"
}
function checkThatBobCantSeeCharliesSalary {
    #Bob is not a manager of Charlie
    printf "Checking that Bob can't see Charlie's salary..."
    curl --silent --user bob:password localhost:5000/finance/salary/charlie \
    | grep -qF "Error" \
    && printf "\r\033[K\033[0;32mBob can't see Charlie's salary\033[0m\n" \
    || printf "\r\033[K\033[1;31mBob can see Charlie's salary\033[0m\n"
}
function createChangedExamplePolicyBundle {
    removeOldBundleFilesAndDockerComposeContainer
    && printf "Creating changed example policy bundle..."
    && mkdir bundles
    # sudo \
    && opa build example.rego example-hr.rego -o ./bundles/bundle.tar.gz
    
    && bootStrapDockerEnv
    #&& printf "\r\033[KCreated changed example policy bundle.\n" || printf "\r\e[K\e[1;31mFailed to create changed example policy bundle\e[0m\n"
    
}

function checkThatNewPolicyWorks {
    printf "Checking that new policy works..."
    
    curl -s --user david:password localhost:5000/finance/salary/alice | grep -qF "Success"  \
    && curl -s --user david:password localhost:5000/finance/salary/bob | grep -qF "Success"  \
    && curl -s --user david:password localhost:5000/finance/salary/charlie | grep -qF "Success"  \
    && curl -s --user david:password localhost:5000/finance/salary/david | grep -qF "Success"  \
    && printf "\r\033[K\033[0;32mNew policy works\033[0m\n" \
    || printf "\r\033[K\033[1;31mNew policy doesn't work\033[0m\n"
}
# run all funtions in order, only if the previous function was successful
removeOldBundleFilesAndDockerComposeContainer  \
&& createExamplePolicyBundle  \
&& bootStrapDockerEnv  \
&& checkThatAliceCanSeeHerOwnSalary  \
&& checkThatBobCanSeeAlicesSalary  \
&& checkThatBobCantSeeCharliesSalary \
&& createChangedExamplePolicyBundle \
&& checkThatNewPolicyWorks
