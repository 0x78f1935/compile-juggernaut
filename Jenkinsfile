// #!groovy

pipeline {
    agent any
    stages { 
        stage('Cloning Project') {
            steps {
                dir('./compile-juggernaut') {
                    git([url: 'git@github.com:0x78f1935/compile-juggernaut.git', branch: 'development', credentialsId: 'ddc4e41d-52d9-4540-93dc-409f8e9db209' ])
                }
            }
        }
        stage('Build Compilers') {
            steps {
                dir('./compile-juggernaut') {
                    script {
                        sh 'docker-compose up --build'
                    }
                }
            }
        }
    }
}