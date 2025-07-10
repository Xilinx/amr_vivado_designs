/*
 *
 * Copyright (C) 2024 - 2025 Advanced Micro Devices, Inc.
 * SPDX-License-Identifier: MIT
 *
 */

def logCommitIDs() {
    sh label: 'log commit IDs',
    script: '''
        idfile=${ws}/commitIDs
        pushd ${ws}/src
        echo "src-branch : ${BRANCH_NAME}" >> ${idfile}
        echo -n "src : " >> ${idfile}
        git rev-parse HEAD >> ${idfile}
        subm=($(cat .gitmodules | grep path | cut -d "=" -f2))
        for sm in "${subm[@]}"; do
            pushd ${sm}
            echo -n "${sm} : " >> ${idfile}
            git rev-parse HEAD >> ${idfile}
            popd
        done
        popd
        pushd ${ws}/paeg-helper
        echo -n "paeg-helper : " >> ${idfile}
        git rev-parse HEAD >> ${idfile}
        popd
        echo "vivado : ${tool_release}_${tool_build}" >> ${idfile}
        cat ${idfile}
        for host in ${HOSTS[@]} ; do
            ssh ${host} mkdir -p ${DEPLOY_DIR}
            rsync -avhzP ${idfile} ${host}:${DEPLOY_DIR}
        done
    '''
}

def createWorkDir() {
    sh label: 'create work dir',
    script: '''
        if [ ! -d ${work_dir} ]; then
            mkdir -p ${work_dir}
            cp -rf ${ws}/src/* ${work_dir}
        fi
    '''
}

def buildXSA() {
    sh label: 'XSA build',
    script: '''
        pushd ${work_dir}/${board}/platforms/${pfm_name}
        source ${setup} -r ${tool_release} -b ${tool_build} && set -e
        ${lsf} make all JOBS=32
        popd
    '''
}

def deployBaseXSA() {
    sh label: 'base XSA deploy',
    script: '''
        pushd ${work_dir}/${board}/platforms/${pfm_name}/project
        DSTDIR=${DEPLOY_DIR}/Vivado_files
        mkdir -p ${DSTDIR}/${pfm_name}
        cp *.xsa ${DSTDIR}/${pfm_name}
        pushd ${DSTDIR}/
        rsync -avh --delete ${work_dir}/${board}/platforms/${pfm_name}/project ${DSTDIR}/${pfm_name}
    '''
}

def updateDeploySuccess() {
    sh label: 'update deploy success symlink',
    script: '''
        if [ "${BRANCH_NAME}" == "${deploy_branch}" ]; then
            for host in ${HOSTS[@]} ; do
                ssh ${host} /bin/bash -x << EOF
                    if [ -d "${DEPLOY_DIR}" ]; then
                        pushd ${DEPLOY_BASE_DIR}
                        if [ -e daily_latest ]; then
                            rm daily_latest
                        fi
                        ln -s ${BUILD_ID} daily_latest
                        popd
                    fi
EOF
            done
        fi
    '''
}

def cleanDeployDir() {
    sh label: 'clean deploy dir',
    script: '''
        for host in ${HOSTS[@]} ; do
            ssh ${host} /bin/bash -x << EOF
                cnt=\\$(find $DEPLOY_BASE_DIR -maxdepth 1 -mindepth 1 -type d | wc -l)
                if [[ \\$cnt -gt $DEPLOY_MAX ]]; then
                    dcnt=\\$((\\$cnt-$DEPLOY_MAX))
                    # delete old build artifacts, retain DEPLOY_MAX most recent
                    dlist=( \\$(find $DEPLOY_BASE_DIR -maxdepth 1 -mindepth 1 -type d -exec ls -trd1 {} + | head -n \\$dcnt) )
                    llist=( \\$(find $DEPLOY_BASE_DIR -maxdepth 1 -mindepth 1 -type l -printf "%l\\n") )
                    for d in "\\${dlist[@]}"; do
                        islink=0
                        for l in "\\${llist[@]}"; do
                            dbase=\\$(basename "\\$d")
                            if [ "\\$dbase" = "\\$l" ]; then
                                islink=1
                                break
                            fi
                        done
                        if [ \\$islink -eq 1 ]; then
                            echo "Retain build output folder \\$d because it is symlinked"
                        else
                            echo "Delete build output folder \\$d"
                            rm -rf \\$d
                        fi
                    done
                else
                    echo "Number of build output folders not greater than $DEPLOY_MAX: \\$cnt"
                fi
EOF
        done
    '''
}

pipeline {
    agent {
        label 'Build_Master'
    }
    environment {
        deploy_branch="main"
        tool_release="2025.2"
        tool_build=sh(script: "readlink /proj/xbuilds/${env.tool_release}_daily_latest | sed -r 's/${env.tool_release}_(.*)/\\1/'", returnStdout: true)
        auto_branch="2025.1"
        pfm_ver="202520_1"
        ws="${WORKSPACE}"
        setup="${ws}/paeg-helper/env-setup.sh"
        lsf="${ws}/paeg-helper/scripts/lsf"
        PAEG_LSF_MEM=65536
        PAEG_LSF_QUEUE="long"
        BUILD_DATE=sh(script: 'date +"%m%d%H%M" | tr -d "\n"', returnStdout: true)
        BUILD_ID="${env.BRANCH_NAME == env.deploy_branch ? env.BUILD_DATE : env.BRANCH_NAME}"
        HOSTS="localhost"
        PAEG_BASE_DIR="/wrk/paeg_builds/build-artifacts/emb-plus-vivado-designs/${tool_release}"
        DEPLOY_BASE_DIR="${env.PAEG_BASE_DIR}"
        DEPLOY_DIR="${DEPLOY_BASE_DIR}/${BUILD_ID}"
        DEPLOY_MAX=15
    }
    options {
        // don't let the implicit checkout happen
        skipDefaultCheckout true
        // keep logs for last 20 builds
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }
    triggers {
        cron(env.BRANCH_NAME == 'main' ? 'H 21 * * *' : '')
    }
    stages {
        stage('Clone Repos') {
            when {
                not {
                    triggeredBy 'BranchIndexingCause'
                }
            }
            steps {
                // checkout main source repo
                checkout([
                    $class: 'GitSCM',
                    branches: scm.branches,
                    doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                    extensions: scm.extensions +
                    [
                        [$class: 'RelativeTargetDirectory', relativeTargetDir: 'src'],
                        [$class: 'ChangelogToBranch', options: [compareRemote: 'origin', compareTarget: env.deploy_branch]]
                    ],
                    userRemoteConfigs: scm.userRemoteConfigs
                ])
                // checkout paeg-automation helper repo
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: auto_branch]],
                    doGenerateSubmoduleConfigurations: false,
                    extensions:
                    [
                        [$class: 'CleanCheckout'],
                        [$class: 'RelativeTargetDirectory', relativeTargetDir: 'paeg-helper']
                    ],
                    submoduleCfg: [],
                    userRemoteConfigs: [[
                        credentialsId: '01d4faf7-fb5a-4bd9-b300-57ac0bfc7991',
                        url: 'https://gitenterprise.xilinx.com/PAEG/paeg-automation.git'
                    ]]
                ])
            }
        }
        stage('Create Build Directories') {
            when {
                not {
                    triggeredBy 'BranchIndexingCause'
                }
            }
            parallel {
                stage('ve2302_xdma_base')  {
                    environment {
                        pfm_name="ve2302_xdma_base"
                        work_dir="${ws}/build/${pfm_name}"
                    }
                    steps {
                        createWorkDir()
                    }
                }
                stage('ve2302_10g_mrmac')  {
                    environment {
                        pfm_name="ve2302_10g_mrmac"
                        work_dir="${ws}/build/${pfm_name}"
                    }
                    steps {
                        createWorkDir()
                    }
                }
                stage('ve2302_1gEth')  {
                    environment {
                        pfm_name="ve2302_1gEth"
                        work_dir="${ws}/build/${pfm_name}"
                    }
                    steps {
                        createWorkDir()
                    }
                }
                stage('ve2302_gmsl')  {
                    environment {
                        pfm_name="ve2302_gmsl"
                        work_dir="${ws}/build/${pfm_name}"
                    }
                    steps {
                        createWorkDir()
                    }
                }
                stage('ve2302_xdma_gmsl')  {
                    environment {
                        pfm_name="ve2302_xdma_gmsl"
                        work_dir="${ws}/build/${pfm_name}"
                    }
                    steps {
                        createWorkDir()
                    }
                }
            }
        }
        stage('Build Platforms') {
            parallel {
                stage('ve2302_xdma_base')  {
                    environment {

                        pfm_name="ve2302_xdma_base"
                        board="emb_plus_ve2302"
                        work_dir="${ws}/build/${pfm_name}"
                    }
                    when {
                        anyOf {
                            changeset "**/platforms/ve2302_xdma_base/**"
                            changeset "**/dfx/**"
                            triggeredBy 'TimerTrigger'
                            triggeredBy 'UserIdCause'
                            expression { true }
                        }
                    }
                    steps {
                        buildXSA()
                    }
                    post {
                        success {
                            script {
                                env.VE2302_PFM_SUCCESS = '1'
                            }
                            deployBaseXSA()
                        }
                    }
                }
                stage('ve2302_1gEth build')  {
                    environment {
                        pfm_name="ve2302_1gEth"
                        board="emb_plus_ve2302"
                        work_dir="${ws}/build/${pfm_name}"
                    }
                    when {
                        anyOf {
                            changeset "**/platforms/ve2302_1gEth/**"
                            triggeredBy 'TimerTrigger'
                            triggeredBy 'UserIdCause'
                            expression { true }
                        }
                    }
                    steps {
                        buildXSA()
                    }
                    post {
                        success {
                            script {
                                env.VE2302_PFM_SUCCESS = '1'
                            }
                            deployBaseXSA()
                        }
                    }
                }
                stage('ve2302_10g_mrmac platform build')  {
                    environment {
                        pfm_name="ve2302_10g_mrmac"
                        board="emb_plus_ve2302"
                        work_dir="${ws}/build/${pfm_name}"
                    }
                    when {
                        anyOf {
                            changeset "**/platforms/ve2302_10g_mrmac/**"
                            triggeredBy 'TimerTrigger'
                            triggeredBy 'UserIdCause'
                            expression { true }
                        }
                    }
                    steps {
                        buildXSA()
                    }
                    post {
                        success {
                            script {
                                env.VE2302_PFM_SUCCESS = '1'
                            }
                            deployBaseXSA()
                        }
                    }
                }
                stage('ve2302_gmsl platform build')  {
                    environment {
                        pfm_name="ve2302_gmsl"
                        board="emb_plus_ve2302"
                        work_dir="${ws}/build/${pfm_name}"
                    }
                    when {
                        anyOf {
                            changeset "**/platforms/ve2302_gmsl/**"
                            triggeredBy 'TimerTrigger'
                            triggeredBy 'UserIdCause'
                            expression { true }
                        }
                    }
                    steps {
                        buildXSA()
                    }
                    post {
                        success {
                            script {
                                env.VE2302_PFM_SUCCESS = '1'
                            }
                            deployBaseXSA()
                        }
                    }
                }
                stage('ve2302_xdma_gmsl platform build')  {
                    environment {
                        pfm_name="ve2302_xdma_gmsl"
                        board="emb_plus_ve2302"
                        work_dir="${ws}/build/${pfm_name}"
                    }
                    when {
                        anyOf {
                            changeset "**/platforms/ve2302_xdma_gmsl/**"
                            triggeredBy 'TimerTrigger'
                            triggeredBy 'UserIdCause'
                            expression { true }
                        }
                    }
                    steps {
                        buildXSA()
                    }
                    post {
                        success {
                            script {
                                env.VE2302_PFM_SUCCESS = '1'
                            }
                            deployBaseXSA()
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                def isBranchIndexingCause = currentBuild.getBuildCauses('jenkins.branch.BranchIndexingCause').size()
                if (isBranchIndexingCause != 1) {
                    logCommitIDs()
                }
            }
        }
        success {
            updateDeploySuccess()
        }
        cleanup {
            cleanWs()
            cleanDeployDir()
        }
    }
}