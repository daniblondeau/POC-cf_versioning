# Git Commands



## last tag

```
git describe --tags
git describe --tags --abbrev=0
```

## commit - head
```
git rev-parse --short HEAD
```





# Pipeline



## Tag and Commit pipeline - OK

```
pipeline {

    agent any

    stages {

        stage('Check') {
            steps {
                echo 'Testing...'
                git credentialsId: 'GitHub', url: 'https://github.com/GITHUB_USER/Test.git'
                sh 'git status'
                sh 'git checkout'
            }
        }

        stage('Tag') {
            steps {
                echo 'Consulting Tag'
                sh 'git describe --tags'
            }
        }

        stage('Commit') {
            steps {
                echo 'Consulting Commit'
                sh 'git rev-parse --short HEAD'
            }
        }
    }
}
```



## Variables Test

```
pipeline {
    agent any
    
    environment {
        USER_NAME = "Joe"
        USER_ID = 35
    }

    stages {
        stage('Variables') {
            steps {
                git credentialsId: 'GitHub', url: 'https://github.com/GITHUB-USER/Test.git'
                echo "BUILD_NUMBER = ${env.BUILD_NUMBER}"
                sh 'echo BUILD_NUMBER = $BUILD_NUMBER'
                
                echo "Current user is ${env.USER_NAME}"
                echo "User ID is ${env.USER_ID}"
                
                script {
                    env.USER_GROUP = "users"
                }
                
                sh 'echo Current user group is $USER_GROUP'
                
                
                withEnv(["USER_PWD=secret", "USER_IS_ADMIN=false"]) {
                    echo "Current user password is ${env.USER_PWD}"
                    sh 'echo Current user is admin? $USER_IS_ADMIN'
                }
            }
        }
        
        stage("Capture") {
            environment {
                TAG = sh(script: "git describe --tags", returnStdout: true)
            }
            
            steps {
                echo "the last tag from Test repository is ${TAG}"
            }
        }
    }
}
```



## Gcloud Authentication

```
pipeline {

    agent any
    
    environment {
        PROJECT = 'YOUR-PROJECT'
    }

    stages {        
        stage('Set GCP') {
            steps {
                withCredentials([file(credentialsId: 'sa-jenkins', variable: 'SA')]) {
                    sh 'gcloud auth activate-service-account --key-file=$SA'
                    sh 'gcloud config set project $PROJECT'
                    sh 'gcloud functions list'
                }
            }
        }
    }
}
```



## Final Version

```
pipeline {

    agent any
    
    environment {
        PROJECT = 'YOUR-PROJECT'
    }

    stages {

        stage('Set Git') {
            steps {
                echo 'Setting GitHub...'
                git credentialsId: 'GitHub', url: 'https://github.com/GITHUB-USER/Test.git'
            }
        }

        stage('Get Commit and Tag') {

        	environment {
        		TAG = sh(script: "git describe --tags", returnStdout: true)
        		COMMIT = sh(script: "git rev-parse --short HEAD", returnStdout: true)
        		FILE = "/var/jenkins_home/build/deploy.sh"
        	}
            
            steps {
            	withCredentials([file(credentialsId: 'sa-jenkins', variable: 'SA')]) {
                sh 'gcloud auth activate-service-account --key-file=$SA'
                sh 'gcloud config set project $PROJECT'
                sh 'gcloud functions list'
                sh '$FILE $TAG $COMMIT'
                sh 'gcloud functions list'
                }
            }
        }
    }
}
```



## Final Version with Parameters

https://github.com/jenkinsci/git-parameter-plugin

```
pipeline {

    agent any
    
    environment {
        PROJECT = 'YOUR-PROJECT'
    }
    
    parameters {
    gitParameter name: 'TAG', 
                 type: 'PT_TAG',
                 defaultValue: 'v*'
    }

    stages {

        stage('Set Git') {
            steps {
                echo 'Setting GitHub...'
                checkout([$class: 'GitSCM', branches: [[name: "${params.TAG}"]], extensions: [], userRemoteConfigs: [[credentialsId: 'GitHub', url: 'https://github.com/GITHUB-USER/Test.git']]])
            }
        }

        stage('Get Commit and Tag') {

            environment {
                TAG = sh(script: "git describe --tags", returnStdout: true)
                COMMIT = sh(script: "git rev-parse --short HEAD", returnStdout: true)
                FILE = "/var/jenkins_home/build/deploy.sh"
            }
            
            steps {
                echo "the last tag from Test repository is ${TAG}"
                echo "its commit is ${COMMIT}"
                echo "the file is ${FILE}"
            }
        }
    }
}
```