pipeline {
    agent any

    stages {
        stage('Fetch Code') {
            steps {
               checkout scm
            }
        }
        stage('Build') {
            steps {
		sh 'echo "Estoy en: $(pwd)"'
		sh '/home/juan/buildroot/output/host/usr/bin/arm-linux-gcc -o main /home/juan/buildroot/14A1/src/main.c -static'
            }
        }
        stage('Deploy on Board') {
            steps {
                // Beispiel für das Übertragen der Build-Artefakte
                sh 'sshpass -p "root" scp main root@192.168.2.110:/root/14A1'
            }
        }
        stage('Test') {
            steps {
                // Beispiel für das Ausführen automatisierter Tests
		sh 'sshpass -p "root" scp /home/juan/buildroot/14A1/tests/tests.sh root@192.168.2.110:/root/14A1/tests'
                sh 'sshpass -p "root" ssh root@192.168.2.110 "cd /root/14A1/tests && ./tests.sh"'
            }
        }
        stage('Code Integration') {
            steps {
                echo 'No integration step defined yet'
            }
        }
	stage('Deployment') {
            steps {
                // Automatisierte Bereitstellung und Monitoring
                sh 'sshpass -p "root" ssh root@192.168.2.110 "cd /root/14A1/ && ./main &"'
            }
        }
        stage('Monitoring') {
            steps {
                // Monitoring-Schritt (Beispiel: Prüfen der Systemlogs)
                sh 'sshpass -p "root" ssh root@192.168.2.110 "tail -n 50 /var/log/messages"'
            }
        }
    }
	post {
	always {
	    // Crea carpeta si no existe
            sh 'sshpass -p "root" mkdir -p build && cp main build/'	            
            archiveArtifacts artifacts: 'build/**', fingerprint: true
        }
        failure {
	    // Rollback im Falle eines Fehlers
	    echo '❌ Error: Build o test falló.'
	    sh 'sshpass -p "root" scp rollback.sh root@192.168.2.110:/root/14A1'
            sh 'sshpass -p "root" ssh root@192.168.2.110 "bash /root/14A1/rollback.sh"'
        }
	success {
            echo '✅ Éxito: Build y test correctos.'
        }
    }
}
